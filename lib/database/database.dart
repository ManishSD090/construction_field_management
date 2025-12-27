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

@DriftDatabase(
    tables: [Projects, Attendances, Tasks, DailyProgressReports, SyncRegistry])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ==========================================================
  //  HELPER QUERIES (Examples for your App)
  // ==========================================================

  // // 1. Get Projects for the Home Screen
  // Future<List<Project>> getAllProjects() => select(projects).get();

  // // 2. Get Unsynced Attendance (For Background Worker)
  // Future<List<Attendance>> getUnsyncedAttendance() {
  //   return (select(attendances)..where((tbl) => tbl.isSynced.equals(false)))
  //       .get();
  // }

  // // 3. Mark Attendance as Synced (After successful API call)
  // Future<void> markAttendanceSynced(String uuid) {
  //   return (update(attendances)..where((t) => t.id.equals(uuid)))
  //       .write(const AttendancesCompanion(isSynced: Value(true)));
  // }

  // // 4. Get Tasks for a specific user
  // Future<List<Task>> getTasksForUser(String userId) {
  //   return (select(tasks)..where((t) => t.assignedToId.equals(userId))).get();
  // }
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
