extension EnumFormatter on Enum {
  String toDisplayString() {
    // This will now work for ANY enum in your app
    final result = name
        .replaceAllMapped(
            RegExp(r'(?<=[a-z])[A-Z]'), (Match m) => ' ${m.group(0)}')
        .replaceAll('_', ' ');

    return result[0].toUpperCase() + result.substring(1).toLowerCase();
  }
}

String _toCamel(String value) {
  return value
      .toLowerCase()
      .split('_')
      .indexed
      .map((e) => e.$1 == 0 ? e.$2 : e.$2[0].toUpperCase() + e.$2.substring(1))
      .join('');
}

String _toSnake(String value) {
  return value
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toUpperCase();
}

/* ======================= USER ======================= */

enum UserType {
  superAdmin,
  companyAdmin,
  employee;

  static UserType fromJson(String? value) {
    if (value == null || value.isEmpty) return UserType.employee;

    final camel = _toCamel(value);
    return UserType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => UserType.employee,
    );
  }

  String toJson() => _toSnake(name);
}

enum EmployeeStatus {
  active,
  inactive,
  suspended,
  retired,
  injured,
  terminated,
  onProbation;

  static EmployeeStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return EmployeeStatus.active;

    final camel = _toCamel(value);
    return EmployeeStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => EmployeeStatus.active,
    );
  }

  String toJson() => _toSnake(name);
}

/* ======================= SALARY ======================= */

enum SalaryType {
  hourly,
  monthly,
  daily,
  weekly,
  projectBased;

  static SalaryType fromJson(String? value) {
    if (value == null || value.isEmpty) return SalaryType.monthly;

    final camel = _toCamel(value);
    return SalaryType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => SalaryType.monthly,
    );
  }

  String toJson() => _toSnake(name);
}

/* ======================= ATTENDANCE ======================= */

enum AttendanceLocation {
  office,
  site,
  remote;

  static AttendanceLocation fromJson(String? value) {
    if (value == null || value.isEmpty) return AttendanceLocation.office;

    return AttendanceLocation.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => AttendanceLocation.office,
    );
  }

  String toJson() => name.toUpperCase();
}

enum AttendanceStatus {
  present,
  absent,
  late,
  halfDay,
  onLeave;

  static AttendanceStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return AttendanceStatus.present;

    final camel = _toCamel(value);
    return AttendanceStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => AttendanceStatus.present,
    );
  }

  String toJson() => _toSnake(name);
}

/* ======================= LEAVE ======================= */

enum LeaveType {
  sickLeave,
  casualLeave,
  earnedLeave,
  maternityLeave,
  paternityLeave;

  static LeaveType fromJson(String? value) {
    if (value == null || value.isEmpty) return LeaveType.casualLeave;

    final camel = _toCamel(value);
    return LeaveType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => LeaveType.casualLeave,
    );
  }

  String toJson() => _toSnake(name);
}

/* ======================= EXPENSE ======================= */

enum ExpenseCategory {
  material,
  labor,
  equipmentRental,
  transportation,
  officeSupplies,
  utilities,
  maintenance,
  travel,
  food,
  accommodation,
  permits,
  insurance,
  professionalFees,
  advertising,
  other;

  static ExpenseCategory fromJson(String? value) {
    if (value == null || value.isEmpty) return ExpenseCategory.other;

    final camel = _toCamel(value);
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => ExpenseCategory.other,
    );
  }

  String toJson() => _toSnake(name);
}

/* ======================= PAYMENT ======================= */

enum PaymentMethod {
  cash,
  bankTransfer,
  cheque,
  online,
  upi;

  static PaymentMethod fromJson(String? value) {
    if (value == null || value.isEmpty) return PaymentMethod.cash;

    final camel = _toCamel(value);
    return PaymentMethod.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => PaymentMethod.cash,
    );
  }

  String toJson() => _toSnake(name);
}

/* ======================= INVOICE ======================= */

enum InvoiceStatus {
  draft,
  issued,
  partiallyPaid,
  paid,
  overdue,
  cancelled,
  disputed;

  static InvoiceStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return InvoiceStatus.draft;

    final camel = _toCamel(value);
    return InvoiceStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => InvoiceStatus.draft,
    );
  }

  String toJson() => _toSnake(name);
}

/* ======================= PRIORITY ======================= */

enum Priority {
  low,
  medium,
  high,
  critical;

  static Priority fromJson(String? value) {
    if (value == null || value.isEmpty) return Priority.medium;

    return Priority.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Priority.medium,
    );
  }

  String toJson() => name.toUpperCase();
}

/* ======================= MATERIAL ======================= */

enum MaterialStatus {
  requested,
  approved,
  ordered,
  inTransit,
  delivered,
  rejected,
  returned;

  static MaterialStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return MaterialStatus.requested;

    final camel = _toCamel(value);
    return MaterialStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => MaterialStatus.requested,
    );
  }

  String toJson() => _toSnake(name);
}

/* ======================= PROJECT ======================= */

enum ProjectStatus {
  planning,
  ongoing,
  onHold,
  completed,
  cancelled,
  delayed;

  static ProjectStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return ProjectStatus.planning;

    final camel = _toCamel(value);
    return ProjectStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => ProjectStatus.planning,
    );
  }

  String toJson() => _toSnake(name);
}

/* ======================= TASK ======================= */

enum TaskStatus {
  todo,
  inProgress,
  review,
  completed,
  blocked;

  static TaskStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return TaskStatus.todo;

    final camel = _toCamel(value);
    return TaskStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => TaskStatus.todo,
    );
  }

  String toJson() => _toSnake(name);
}

enum DocumentType {
  contract,
  permit,
  drawing,
  report,
  invoice,
  certificate,
  photo,
  other;

  /// Converts JSON String (SCREAMING_SNAKE_CASE) to Enum
  static DocumentType fromJson(String name) {
    return DocumentType.values.firstWhere(
      (e) => e.name.toUpperCase() == name.toUpperCase(),
      orElse: () => DocumentType.other,
    );
  }

  /// Converts Enum to JSON String (SCREAMING_SNAKE_CASE)
  String toJson() => name.toUpperCase();
}

enum ContractorType {
  labor,
  equipment,
  materialSupply,
  transportation,
  other;

  static ContractorType fromJson(String? value) {
    if (value == null || value.isEmpty) return ContractorType.other;
    final camel = _toCamel(value);
    return ContractorType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => ContractorType.other,
    );
  }

  String toJson() => _toSnake(name);
}

enum WorkType {
  concrete,
  steel,
  carpentry,
  electrical,
  plumbing,
  painting,
  tiling,
  excavation,
  demolition,
  renovation,
  maintenance,
  cleaning,
  landscaping,
  other;

  static WorkType fromJson(String? value) {
    if (value == null || value.isEmpty) return WorkType.other;
    final camel = _toCamel(value);
    return WorkType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => WorkType.other,
    );
  }

  String toJson() => name.toUpperCase();
}

enum ContractorStatus {
  active,
  inactive,
  blacklisted,
  underReview;

  static ContractorStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return ContractorStatus.underReview;
    final camel = _toCamel(value);
    return ContractorStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => ContractorStatus.underReview,
    );
  }

  String toJson() => _toSnake(name);
}

enum PaymentStatus {
  pending,
  partial,
  paid,
  overdue,
  disputed;

  static PaymentStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return PaymentStatus.pending;
    final camel = _toCamel(value);
    return PaymentStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => PaymentStatus.pending,
    );
  }

  String toJson() => _toSnake(name);
}

enum TimelineStatus {
  draft,
  pendingApproval,
  approved,
  rejected,
  active,
  archived,
  locked;

  static TimelineStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return TimelineStatus.draft;

    final camel = _toCamel(value);
    return TimelineStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => TimelineStatus.draft,
    );
  }

  String toJson() => _toSnake(name).toUpperCase();
}

enum TimelineVersionStatus {
  draft,
  pendingReview,
  approved,
  rejected,
  active,
  archived;

  static TimelineVersionStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return TimelineVersionStatus.draft;

    final camel = _toCamel(value);
    return TimelineVersionStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => TimelineVersionStatus.draft,
    );
  }

  String toJson() => _toSnake(name).toUpperCase();
}

enum TimelineTaskStatus {
  scheduled,
  inProgress,
  completed,
  delayed,
  cancelled;

  static TimelineTaskStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return TimelineTaskStatus.scheduled;

    final camel = _toCamel(value);
    return TimelineTaskStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => TimelineTaskStatus.scheduled,
    );
  }

  String toJson() => _toSnake(name).toUpperCase();
}
