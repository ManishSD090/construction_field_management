// enums.dart — NULL SAFE & CRASH-PROOF

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
