import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import your schema
import 'package:construction_erp/database/schema.dart';
import 'package:construction_erp/core/converters/string_list_converter.dart';

part 'database.g.dart';

// ==========================================================
// TYPEDEFS (Shortcuts for cleaner code)
// ==========================================================
// Typedefs for cleaner usage
typedef ProjectEntityCompanion = ProjectsCompanion;
typedef AttendanceEntityCompanion = AttendancesCompanion;
typedef TaskEntityCompanion = TasksCompanion;
typedef SubtaskEntityCompanion = SubtasksCompanion;
typedef DPREntityCompanion = DailyProgressReportsCompanion;
typedef DprPhotosEntityCompanion = DprPhotosCompanion;
typedef UserEntityCompanion = UsersCompanion;

@DriftDatabase(tables: [
  Projects,
  Attendances,
  Tasks,
  Subtasks,
  DailyProgressReports,
  DprPhotos,
  SyncRegistry,
  Users
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ==========================================================
  // REGION: AUTH & USER
  // ==========================================================

  Future<void> saveUserOnLogin(UserEntity user) {
    return transaction(() async {
      await delete(users).go();
      await into(users).insert(user);
    });
  }

  Future<UserEntity?> getCurrentUser() => select(users).getSingleOrNull();

  Future<void> logout() => delete(users).go();

  // ==========================================================
  // REGION: PROJECTS (Read-Only from App perspective)
  // ==========================================================

  // [REFACTOR] Added stream for Reactive UI
  Stream<List<ProjectEntity>> watchAllProjects() {
    return select(projects).watch();
  }

  Future<List<ProjectEntity>> getAllProjects() => select(projects).get();

  Future<ProjectEntity?> getProjectById(String projectId) {
    return (select(projects)..where((tbl) => tbl.id.equals(projectId)))
        .getSingleOrNull();
  }

  // [REFACTOR] Wrapped in transaction for safety
  Future<void> syncProjectsFromServer(
      List<ProjectEntity> serverProjects) async {
    await batch((batch) {
      // insertAllOnConflictUpdate is perfect for "Server Wins" strategy
      batch.insertAllOnConflictUpdate(projects, serverProjects);
    });
  }

  // ==========================================================
  // REGION: ATTENDANCE (Offline Write -> Sync Push)
  // ==========================================================

  // [REFACTOR] Changed return to void, relying on ID in the Companion
  Future<void> checkIn(AttendanceEntityCompanion entry) {
    return into(attendances).insert(entry);
  }

  Future<void> checkOut(
      String attendanceId, DateTime time, double? lat, double? long) {
    return (update(attendances)..where((tbl) => tbl.id.equals(attendanceId)))
        .write(AttendancesCompanion(
      checkOutTime: Value(time),
      // Add location updates here if your schema has them
      checkOutLatitude: Value(lat),
      checkOutLongitude: Value(long),
    ));
  }

  Future<AttendanceEntity?> getActiveAttendance(String userId) {
    return (select(attendances)
          ..where(
              (tbl) => tbl.userId.equals(userId) & tbl.checkOutTime.isNull()))
        .getSingleOrNull();
  }

  Future<List<AttendanceEntity>> getUnsyncedAttendance() {
    return (select(attendances)..where((tbl) => tbl.isSynced.equals(false)))
        .get();
  }

  Future<void> markAttendanceSynced(List<String> ids) {
    return (update(attendances)..where((tbl) => tbl.id.isIn(ids))).write(
      const AttendancesCompanion(isSynced: Value(true)),
    );
  }

  Stream<List<AttendanceEntity>> watchUserAttendanceHistory(String userId) {
    return (select(attendances)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  // ==========================================================
  // REGION: TASKS (Two-Way Sync)
  // ==========================================================

  // 1. READ: Stream tasks (Filters out locally deleted items)
  Stream<List<TaskEntity>> watchTasksForProject(String projectId) {
    return (select(tasks)
          ..where((t) => t.projectId.equals(projectId))
          ..where((t) => t.isDeleted.equals(false)) // Hides deleted tasks
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.localUpdatedAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  // 2. CREATE: Insert Task
  Future<void> createTask(TaskEntityCompanion task) {
    return into(tasks).insert(task);
  }

  // 3. UPDATE: Status (Mark as Dirty)
  Future<void> updateTaskStatus(String taskId, String newStatus) {
    return (update(tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        status: Value(newStatus),
        isDirty: const Value(true),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  // 4. UPDATE: Edit Details
  Future<void> updateTaskDetails(String taskId, String title, String? desc) {
    return (update(tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        title: Value(title),
        description: Value(desc),
        isDirty: const Value(true),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  // 5. DELETE: Soft Delete (Mark isDeleted = true, isDirty = true)
  // We DO NOT remove the row yet. We wait for Sync to tell server, then server confirms.
  Future<void> deleteTaskLocally(String taskId) {
    return (update(tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  // 6. SYNC GET: Get all changed items (Modified OR Deleted)
  Future<List<TaskEntity>> getDirtyTasks() {
    return (select(tasks)..where((t) => t.isDirty.equals(true))).get();
  }

  // 7. SYNC PULL: Save from Server
  Future<void> syncTasksFromServer(List<TaskEntity> serverTasks) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(tasks, serverTasks);
    });
  }

  // 8. SYNC CLEANUP: Mark as clean
  Future<void> markTasksClean(List<String> ids) {
    return (update(tasks)..where((t) => t.id.isIn(ids))).write(
      const TasksCompanion(isDirty: Value(false)),
    );
  }

  // 9. HARD DELETE: Clean up items that are fully deleted on server
  // Call this if the server sends a "Deleted IDs" list or after a full sync
  Future<void> purgeDeletedTasks() {
    return (delete(tasks)..where((t) => t.isDeleted.equals(true))).go();
  }

  // ==========================================================
  // REGION: SUBTASKS (Two-Way Sync)
  // ==========================================================

  // 1. READ: Stream subtasks for a specific task
  Stream<List<SubtaskEntity>> watchSubtasksForTask(String taskId) {
    return (select(subtasks)
          ..where((s) => s.taskId.equals(taskId))
          ..where((s) => s.isDeleted.equals(false))
          ..orderBy([(s) => OrderingTerm(expression: s.createdAt)]))
        .watch();
  }

  // 2. CREATE
  Future<void> createSubtask(SubtaskEntityCompanion subtask) {
    return into(subtasks).insert(subtask);
  }

  // 3. TOGGLE COMPLETE
  Future<void> toggleSubtask(String subtaskId, bool isCompleted) {
    return (update(subtasks)..where((s) => s.id.equals(subtaskId))).write(
      SubtasksCompanion(
        isCompleted: Value(isCompleted),
        isDirty: const Value(true),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  // 4. SOFT DELETE
  Future<void> deleteSubtaskLocally(String subtaskId) {
    return (update(subtasks)..where((s) => s.id.equals(subtaskId))).write(
      SubtasksCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  // 5. SYNC GET
  Future<List<SubtaskEntity>> getDirtySubtasks() {
    return (select(subtasks)..where((s) => s.isDirty.equals(true))).get();
  }

  // 6. SYNC PULL
  Future<void> syncSubtasksFromServer(
      List<SubtaskEntity> serverSubtasks) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(subtasks, serverSubtasks);
    });
  }

  // 7. SYNC CLEANUP
  Future<void> markSubtasksClean(List<String> ids) {
    return (update(subtasks)..where((s) => s.id.isIn(ids))).write(
      const SubtasksCompanion(isDirty: Value(false)),
    );
  }

// ==========================================================
  // REGION: DAILY PROGRESS REPORTS (DPR)
  // ==========================================================

  // 1. Create a Full Report (Text + Photos) Transactionally
  Future<void> createFullDPR(
      DPREntityCompanion report, List<DprPhotosCompanion> photos) {
    return transaction(() async {
      // A. Insert the main report
      await into(dailyProgressReports).insert(report);

      // B. Insert all associated photos
      for (var photo in photos) {
        await into(dprPhotos).insert(photo);
      }
    });
  }

  // 2. Get specific DPR by ID
  Future<DPREntity?> getDPRById(String id) {
    return (select(dailyProgressReports)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  // 3. Get all DPRs for a specific Project (Reactive Stream)
  Stream<List<DPREntity>> watchDPRsForProject(String projectId) {
    return (select(dailyProgressReports)
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  // 4. Get Unsynced Reports (For Sync Job)
  Future<List<DPREntity>> getUnsyncedDPRs() {
    return (select(dailyProgressReports)
          ..where((t) => t.isSynced.equals(false)))
        .get();
  }

  // 5. Mark Reports as Synced (Batch Update)
  Future<void> markDPRSynced(List<String> ids) {
    return (update(dailyProgressReports)..where((t) => t.id.isIn(ids)))
        .write(const DailyProgressReportsCompanion(isSynced: Value(true)));
  }

  // ==========================================================
  // REGION: DPR PHOTOS
  // ==========================================================

  // 1. Get all photos for a specific report (Reactive Stream for UI)
  Stream<List<DPRPhotoEntity>> watchPhotosForDPR(String reportId) {
    return (select(dprPhotos)..where((t) => t.dprId.equals(reportId))).watch();
  }

  // 2. Get Unsynced Photos (For Sync Job - ONLY photos that aren't synced yet)
  Future<List<DPRPhotoEntity>> getUnsyncedPhotos() {
    return (select(dprPhotos)..where((t) => t.isSynced.equals(false))).get();
  }

  // 3. Update Photo after Upload (Swap Local Path -> Server URL)
  Future<void> markPhotoAsSynced(
      String photoId, String serverUrl, String? thumbUrl) {
    return (update(dprPhotos)..where((t) => t.id.equals(photoId))).write(
      DprPhotosCompanion(
        imageUrl: Value(serverUrl),
        thumbnailUrl: Value(thumbUrl),
        localPath: const Value(null), // Clean up local path
        isSynced: const Value(true),
      ),
    );
  }

  // 4. Delete a photo locally
  Future<void> deletePhoto(String photoId) {
    return (delete(dprPhotos)..where((t) => t.id.equals(photoId))).go();
  }

  // ==========================================================
  // REGION: SYNC METADATA
  // ==========================================================

  Future<DateTime?> getLastSyncTime(String modelName) async {
    final record = await (select(syncRegistry)
          ..where((tbl) => tbl.model.equals(modelName)))
        .getSingleOrNull();
    return record?.lastSyncedAt;
  }

  Future<void> updateLastSyncTime(String modelName, DateTime time) {
    return into(syncRegistry).insertOnConflictUpdate(
      SyncRegistryCompanion(
        model: Value(modelName),
        lastSyncedAt: Value(time),
      ),
    );
  }
}

// ==========================================================
//  CONNECTION LOGIC
// ==========================================================
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_erp.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
