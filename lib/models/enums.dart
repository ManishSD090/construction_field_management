// Enums for Construction Field Management

enum UserType {
  superAdmin,
  companyAdmin,
  employee;

  static UserType fromJson(String name) {
    String camel = name.toLowerCase().split('_').indexed.map((e) {
      return e.$1 == 0 ? e.$2 : e.$2[0].toUpperCase() + e.$2.substring(1);
    }).join('');

    return UserType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => UserType.employee,
    );
  }

  String toJson() => name
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toUpperCase();
}

enum EmployeeStatus {
  active,
  inactive,
  suspended,
  retired,
  injured,
  terminated,
  onProbation;

  static EmployeeStatus fromJson(String name) {
    String camel = name.toLowerCase().split('_').indexed.map((e) {
      return e.$1 == 0 ? e.$2 : e.$2[0].toUpperCase() + e.$2.substring(1);
    }).join('');

    return EmployeeStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => EmployeeStatus.active,
    );
  }

  String toJson() => name
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toUpperCase();
}

enum SalaryType {
  hourly,
  monthly,
  daily,
  weekly,
  projectBased;

  static SalaryType fromJson(String name) {
    String camel = name.toLowerCase().split('_').indexed.map((e) {
      return e.$1 == 0 ? e.$2 : e.$2[0].toUpperCase() + e.$2.substring(1);
    }).join('');

    return SalaryType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => SalaryType.monthly,
    );
  }

  String toJson() => name
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toUpperCase();
}

enum AttendanceLocation {
  office,
  site,
  remote;

  /// Helper to convert JSON String (SCREAMING_SNAKE_CASE) to Enum
  static AttendanceLocation fromJson(String name) {
    return AttendanceLocation.values.firstWhere(
      (e) => e.name.toUpperCase() == name.toUpperCase(),
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

  static AttendanceStatus fromJson(String name) {
    // Handles conversion from HALF_DAY to halfDay
    String camelName = name.toLowerCase().split('_').indexed.map((e) {
      return e.$1 == 0 ? e.$2 : e.$2[0].toUpperCase() + e.$2.substring(1);
    }).join('');

    return AttendanceStatus.values.firstWhere(
      (e) => e.name == camelName,
      orElse: () => AttendanceStatus.present,
    );
  }

  // Converts halfDay to HALF_DAY for backend compatibility
  String toJson() => name
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)}_${match.group(2)}')
      .toUpperCase();
}

enum LeaveType {
  sickLeave,
  casualLeave,
  earnedLeave,
  maternityLeave,
  paternityLeave;

  static LeaveType fromJson(String name) {
    String camelName = name.toLowerCase().split('_').indexed.map((e) {
      return e.$1 == 0 ? e.$2 : e.$2[0].toUpperCase() + e.$2.substring(1);
    }).join('');

    return LeaveType.values.firstWhere(
      (e) => e.name == camelName,
      orElse: () => LeaveType.casualLeave,
    );
  }

  String toJson() => name
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)}_${match.group(2)}')
      .toUpperCase();
}

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

  static ExpenseCategory fromJson(String name) {
    // Converts SCREAMING_SNAKE_CASE to lowerCamelCase
    String camel = name.toLowerCase().split('_').indexed.map((e) {
      return e.$1 == 0 ? e.$2 : e.$2[0].toUpperCase() + e.$2.substring(1);
    }).join('');

    return ExpenseCategory.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => ExpenseCategory.other,
    );
  }

  String toJson() => name
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toUpperCase();
}

enum PaymentMethod {
  cash,
  bankTransfer,
  cheque,
  online,
  upi;

  static PaymentMethod fromJson(String name) {
    String camel = name.toLowerCase().split('_').indexed.map((e) {
      return e.$1 == 0 ? e.$2 : e.$2[0].toUpperCase() + e.$2.substring(1);
    }).join('');
    return PaymentMethod.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => PaymentMethod.cash,
    );
  }

  String toJson() => name
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toUpperCase();
}

enum InvoiceStatus {
  draft,
  issued,
  partiallyPaid,
  paid,
  overdue,
  cancelled,
  disputed;

  static InvoiceStatus fromJson(String name) {
    String camel = name.toLowerCase().split('_').indexed.map((e) {
      return e.$1 == 0 ? e.$2 : e.$2[0].toUpperCase() + e.$2.substring(1);
    }).join('');
    return InvoiceStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => InvoiceStatus.draft,
    );
  }

  String toJson() => name
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toUpperCase();
}

enum Priority {
  low,
  medium,
  high,
  critical;

  static Priority fromJson(String name) {
    return Priority.values.firstWhere(
      (e) => e.name.toUpperCase() == name.toUpperCase(),
      orElse: () => Priority.medium,
    );
  }

  String toJson() => name.toUpperCase();
}

enum MaterialStatus {
  requested,
  approved,
  ordered,
  inTransit,
  delivered,
  rejected,
  returned;

  static MaterialStatus fromJson(String name) {
    // Converts SCREAMING_SNAKE_CASE (IN_TRANSIT) to lowerCamelCase (inTransit)
    String camel = name.toLowerCase().split('_').indexed.map((e) {
      return e.$1 == 0 ? e.$2 : e.$2[0].toUpperCase() + e.$2.substring(1);
    }).join('');

    return MaterialStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => MaterialStatus.requested,
    );
  }

  String toJson() => name
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toUpperCase();
}

enum ProjectStatus {
  planning,
  ongoing,
  onHold,
  completed,
  cancelled,
  delayed;

  static ProjectStatus fromJson(String name) {
    // Converts ON_HOLD to onHold
    String camel = name.toLowerCase().split('_').indexed.map((e) {
      return e.$1 == 0 ? e.$2 : e.$2[0].toUpperCase() + e.$2.substring(1);
    }).join('');

    return ProjectStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => ProjectStatus.planning,
    );
  }

  String toJson() => name
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toUpperCase();
}

enum TaskStatus {
  todo,
  inProgress,
  review,
  completed,
  blocked;

  static TaskStatus fromJson(String name) {
    // Converts IN_PROGRESS to inProgress
    String camel = name.toLowerCase().split('_').indexed.map((e) {
      return e.$1 == 0 ? e.$2 : e.$2[0].toUpperCase() + e.$2.substring(1);
    }).join('');

    return TaskStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => TaskStatus.todo,
    );
  }

  String toJson() => name
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toUpperCase();
}
