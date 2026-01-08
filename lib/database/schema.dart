import 'package:drift/drift.dart';
import 'package:construction_erp/core/converters/string_list_converter.dart';

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

  RealColumn get checkOutLatitude => real().nullable()();
  RealColumn get checkOutLongitude => real().nullable()();

  // Sync Metadata
  // If false, background service needs to push this to Prisma
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 3. TASKS (Two-Way Sync)
// ==========================================
@DataClassName('TaskEntity')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get assignedToId => text().nullable()();
  TextColumn get createdById => text()();

  // Core Info
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();

  // Status & Priority (Store Enum as Text)
  // Use TaskStatus.values.byName(row.status) in UI
  TextColumn get status => text().withDefault(const Constant('TODO'))();
  TextColumn get priority => text().withDefault(const Constant('MEDIUM'))();

  // Progress & Dates
  IntColumn get progress => integer().withDefault(const Constant(0))(); // 0-100
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get completedDate => dateTime().nullable()();

  // Time Tracking
  RealColumn get estimatedHours => real().nullable()();
  RealColumn get actualHours => real().withDefault(const Constant(0.0))();

  // Sync Metadata
  // isDirty = true: User changed something locally (needs upload)
  // isDeleted = true: User deleted it locally (needs server DELETE)
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable()(); // Server's update time
  DateTimeColumn get localUpdatedAt =>
      dateTime().withDefault(currentDateAndTime)(); // Local change time

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 3b. SUBTASKS (Child of Task)
// ==========================================
@DataClassName('SubtaskEntity')
class Subtasks extends Table {
  TextColumn get id => text()();

  // Parent Relation (Cascade Delete: If Task is deleted, delete Subtasks)
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();

  TextColumn get description => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  TextColumn get createdById => text().nullable()();

  // Sync Metadata
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 4. DAILY PROGRESS REPORTS (Offline Write)
// ==========================================
@DataClassName('DPREntity')
class DailyProgressReports extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get reportNo => text()();
  TextColumn get preparedById => text()(); // Needed for relation mapping

  DateTimeColumn get date => dateTime()();

  // Core Data
  TextColumn get workDescription => text()();
  TextColumn get weather => text().nullable()();
  TextColumn get temperature => text().nullable()();
  TextColumn get humidity => text().nullable()();

  // Progress Details
  TextColumn get completedWork => text().nullable()();
  TextColumn get pendingWork => text().nullable()();
  TextColumn get challenges => text().nullable()();

  // Site Stats
  IntColumn get totalWorkers => integer().withDefault(const Constant(0))();
  BoolColumn get supervisorPresent =>
      boolean().withDefault(const Constant(false))();

  // Resources & Safety
  TextColumn get equipmentUsed => text().nullable()();
  TextColumn get materialsUsed => text().nullable()();
  TextColumn get materialsReceived => text().nullable()();
  TextColumn get materialsRequired => text().nullable()();
  TextColumn get safetyObservations => text().nullable()();
  TextColumn get incidents => text().nullable()();
  TextColumn get qualityChecks => text().nullable()();
  TextColumn get issuesFound => text().nullable()();
  TextColumn get nextDayPlan => text().nullable()();

  // Status (Store Enum as Text locally)
  TextColumn get status => text().withDefault(const Constant('TODO'))();

  // Sync Metadata
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 5. DPR PHOTOS (Hybrid: File -> URL)
// ==========================================
@DataClassName('DPRPhotoEntity')
class DprPhotos extends Table {
  TextColumn get id => text()();

  // Relation to DPR Table (Cascade delete: if DPR is deleted, delete photos)
  TextColumn get dprId => text()
      .references(DailyProgressReports, #id, onDelete: KeyAction.cascade)();

  // Metadata
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();

  // The Hybrid Strategy Columns
  // 1. When Offline: This has value, 'imageUrl' is null
  TextColumn get localPath => text().nullable()();

  // 2. When Synced: This has value, 'localPath' becomes null
  TextColumn get imageUrl => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();

  TextColumn get uploadedById => text()();

  // Sync Metadata
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 6. SYNC REGISTRY (Internal Tool)
// ==========================================
// Keeps track of the last time we pulled data from the server.
class SyncRegistry extends Table {
  // Renamed 'tableName' to 'model' to avoid conflict with Drift's internal property
  TextColumn get model => text()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {model};
}

// ==========================================
// 7. CURRENT USER (Offline Read-Only cache)
// ==========================================
// Strategy: Upsert on Login. Delete on Logout.
// Only contains the currently logged-in user.
@DataClassName('UserEntity')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text()();

  // IDs for logic
  TextColumn get companyId => text().nullable()();
  TextColumn get companyName => text().nullable()();
  TextColumn get roleId => text()();
  TextColumn get roleName => text().nullable()();
  TextColumn get employeeId => text().nullable()();

  // Display fields for UI
  TextColumn get designation => text().nullable()();
  TextColumn get department => text().nullable()();
  TextColumn get profilePicture =>
      text().nullable()(); // Store URL or local path

  // Logic fields (Stored as Strings/Enums)
  TextColumn get userType => text()(); // 'EMPLOYEE', 'ADMIN', etc.
  TextColumn get employeeStatus => text()(); // 'ACTIVE', etc.
  TextColumn get defaultLocation =>
      text()(); // 'OFFICE', 'SITE' - Crucial for attendance logic
  TextColumn get salaryType => text().nullable()(); // 'HOURLY', 'DAILY', etc.

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  BoolColumn get isSystemAdmin =>
      boolean().withDefault(const Constant(false))();

  TextColumn get permissions => text()
      .map(const StringListConverter())
      .nullable()
      .withDefault(const Constant('[]'))();

  // Settings (Optional: You can store this as a JSON string using a TypeConverter if needed)
  TextColumn get theme =>
      text().nullable().withDefault(const Constant('light'))();
  TextColumn get language =>
      text().nullable().withDefault(const Constant('en'))();

  // Meta
  DateTimeColumn get lastLogin => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
