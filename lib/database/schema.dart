import 'package:drift/drift.dart';

// ==========================================
// 1. PROJECTS (Reference Data)
// ==========================================
// Workers need this to know where to check in.
// Strategy: Mirror from Server (Read-Only for field users)
@DataClassName('ProjectEntity')
class Projects extends Table {
  TextColumn get id => text()(); // Prisma UUID
  TextColumn get projectId => text()(); // e.g. PROJ-001
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();

  // Location for Geofencing checks
  TextColumn get location => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get geofenceRadius => real().withDefault(const Constant(200.0))();

  TextColumn get status => text()(); // Store Enum as String

  // Sync Metadata
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get serverUpdatedAt =>
      dateTime().nullable()(); // Version control

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 2. ATTENDANCE (Offline Write)
// ==========================================
// Strategy: Create Locally -> Push to Server
@DataClassName('AttendanceEntity')
class Attendances extends Table {
  TextColumn get id => text()(); // Generated UUID v4 locally
  TextColumn get userId => text()();
  TextColumn get projectId => text().nullable()();

  // Storing Enums as Strings for simplicity in SQLite
  TextColumn get locationType => text()(); // OFFICE, SITE, REMOTE
  TextColumn get status =>
      text().withDefault(const Constant('PRESENT'))(); // PRESENT, LATE, etc.

  DateTimeColumn get date => dateTime()();
  DateTimeColumn get checkInTime => dateTime().nullable()();
  DateTimeColumn get checkOutTime => dateTime().nullable()();

  RealColumn get checkInLatitude => real().nullable()();
  RealColumn get checkInLongitude => real().nullable()();

  // Sync Metadata
  // If false, background service needs to push this to Prisma
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 3. TASKS (Offline Read/Write)
// ==========================================
// Strategy: Two-way Sync. Users update status offline.
@DataClassName('TaskEntity')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get assignedToId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();

  // Status:TODO, IN_PROGRESS, DONE
  TextColumn get status => text().withDefault(const Constant('TODO'))();

  // Sync Metadata
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // Changed locally?
  DateTimeColumn get serverUpdatedAt =>
      dateTime().nullable()(); // Last version from server
  DateTimeColumn get localUpdatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 4. DAILY PROGRESS REPORTS (Offline Write)
// ==========================================
// Strategy: Heavy Write. Create locally -> Push.
@DataClassName('DPREntity')
class DailyProgressReports extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get reportNo => text()();

  DateTimeColumn get date => dateTime()();
  TextColumn get workDescription => text()();
  TextColumn get weather => text().nullable()();

  // Sync Metadata
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 5. SYNC REGISTRY (Internal Tool)
// ==========================================
// Keeps track of the last time we pulled data from the server.
class SyncRegistry extends Table {
  // Renamed 'tableName' to 'model' to avoid conflict with Drift's internal property
  TextColumn get model => text()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {model};
}
