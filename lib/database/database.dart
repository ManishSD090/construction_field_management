import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import the tables we just defined
import 'package:construction_erp/database/schema.dart';

// 1. Generate the part file
// Run: dart run build_runner build --delete-conflicting-outputs
part 'database.g.dart';

typedef ProjectEntityCompanion = ProjectsCompanion;
typedef AttendanceEntityCompanion = AttendancesCompanion;
typedef TaskEntityCompanion = TasksCompanion;
typedef DPREntityCompanion = DailyProgressReportsCompanion;
typedef UserEntityCompanion = UsersCompanion;

@DriftDatabase(tables: [
  Projects,
  Attendances,
  Tasks,
  DailyProgressReports,
  SyncRegistry,
  Users
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ==========================================================
  // REGION: AUTH & USER (Hybrid Strategy)
  // ==========================================================

  /// Login: Wipes old user data and saves the new one.
  /// Call this immediately after a successful API login.
  Future<void> saveUserOnLogin(UserEntity user) {
    return transaction(() async {
      await delete(users).go(); // Clear any previous session
      await into(users).insert(user);
    });
  }

  /// Get the currently logged-in user. Returns null if logged out.
  /// Use this to populate your App Drawer / Profile Page instantly.
  Future<UserEntity?> getCurrentUser() {
    return select(users).getSingleOrNull();
  }

  /// Logout: Clears the local user cache.
  Future<void> logout() {
    return delete(users).go();
  }

  // ==========================================================
  // REGION: PROJECTS (Read-Only Reference Data)
  // ==========================================================

  /// Get all projects for the Project List screen.
  Future<List<ProjectEntity>> getAllProjects() {
    return select(projects).get();
  }

  /// Get specific project details (e.g., for Geofencing checks).
  Future<ProjectEntity?> getProjectById(String projectId) {
    return (select(projects)..where((tbl) => tbl.id.equals(projectId)))
        .getSingleOrNull();
  }

  /// Sync: Batch insert/update projects coming from the Server.
  /// This deletes projects that are marked 'isDeleted' on the server.
  Future<void> syncProjectsFromServer(
      List<ProjectEntity> serverProjects) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(projects, serverProjects);
    });
  }

  // ==========================================================
  // REGION: ATTENDANCE (Offline Write -> Sync Push)
  // ==========================================================

  /// 1. CHECK-IN: Creates a new attendance record locally.
  Future<int> checkIn(AttendanceEntityCompanion entry) {
    return into(attendances).insert(entry);
  }

  /// 2. CHECK-OUT: Updates the existing record with checkout time.
  Future<void> checkOut(
      String attendanceId, DateTime time, double? lat, double? long) {
    return (update(attendances)..where((tbl) => tbl.id.equals(attendanceId)))
        .write(
      AttendancesCompanion(
        checkOutTime: Value(time),
        // If you capture location on checkout, add those columns to update here
        // isSynced: Value(false), // Mark as unsynced again if you sync per-action
      ),
    );
  }

  /// 3. GET ACTIVE: Check if user is currently checked in (has checkIn but no checkOut).
  Future<AttendanceEntity?> getActiveAttendance(String userId) {
    return (select(attendances)
          ..where(
              (tbl) => tbl.userId.equals(userId) & tbl.checkOutTime.isNull()))
        .getSingleOrNull();
  }

  /// 4. SYNC FETCH: Get all unsynced attendance records to push to server.
  Future<List<AttendanceEntity>> getUnsyncedAttendance() {
    return (select(attendances)..where((tbl) => tbl.isSynced.equals(false)))
        .get();
  }

  /// 5. SYNC MARK: Mark records as synced after server confirms receipt.
  Future<void> markAttendanceSynced(List<String> ids) {
    return (update(attendances)..where((tbl) => tbl.id.isIn(ids))).write(
      const AttendancesCompanion(isSynced: Value(true)),
    );
  }

  /// 6. HISTORY: Get past attendance for the specific user (UI Display).
  Future<List<AttendanceEntity>> getUserAttendanceHistory(String userId) {
    return (select(attendances)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // ==========================================================
  // REGION: TASKS (Two-Way Sync)
  // ==========================================================

  /// Get tasks for a specific project.
  Future<List<TaskEntity>> getTasksForProject(String projectId) {
    return (select(tasks)..where((tbl) => tbl.projectId.equals(projectId)))
        .get();
  }

  /// Create a new task locally (Offline).
  Future<int> createTask(TaskEntityCompanion task) {
    return into(tasks).insert(task);
  }

  /// Update task status (e.g., TODO -> DONE).
  /// Sets 'isDirty' to true so the sync service knows to push this.
  Future<void> updateTaskStatus(String taskId, String newStatus) {
    return (update(tasks)..where((tbl) => tbl.id.equals(taskId))).write(
      TasksCompanion(
        status: Value(newStatus),
        isDirty: const Value(true), // Important for sync!
        localUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// SYNC PUSH: Get tasks modified locally ('isDirty' = true).
  Future<List<TaskEntity>> getDirtyTasks() {
    return (select(tasks)..where((tbl) => tbl.isDirty.equals(true))).get();
  }

  /// SYNC PULL: Save tasks fetched from server.
  Future<void> syncTasksFromServer(List<TaskEntity> serverTasks) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(tasks, serverTasks);
    });
  }

  /// SYNC CLEANUP: After pushing changes, mark them as clean.
  Future<void> markTasksClean(List<String> ids) {
    return (update(tasks)..where((tbl) => tbl.id.isIn(ids))).write(
      const TasksCompanion(isDirty: Value(false)),
    );
  }

  // ==========================================================
  // REGION: DAILY PROGRESS REPORTS (Heavy Write)
  // ==========================================================

  Future<int> createDPR(DPREntityCompanion report) {
    return into(dailyProgressReports).insert(report);
  }

  Future<List<DPREntity>> getUnsyncedDPRs() {
    return (select(dailyProgressReports)
          ..where((tbl) => tbl.isSynced.equals(false)))
        .get();
  }

  Future<void> markDPRSynced(List<String> ids) {
    return (update(dailyProgressReports)..where((tbl) => tbl.id.isIn(ids)))
        .write(
      const DailyProgressReportsCompanion(isSynced: Value(true)),
    );
  }

  // ==========================================================
  // REGION: SYNC METADATA
  // ==========================================================

  /// Get the last time we synced a specific model (e.g., 'Projects').
  Future<DateTime?> getLastSyncTime(String modelName) async {
    final record = await (select(syncRegistry)
          ..where((tbl) => tbl.model.equals(modelName)))
        .getSingleOrNull();
    return record?.lastSyncedAt;
  }

  /// Update the sync time after a successful pull.
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
    // Put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_erp.sqlite'));

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      // await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file);
  });
}
