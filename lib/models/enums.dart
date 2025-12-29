// Enums for Construction Field Management

enum UserType {
  SUPER_ADMIN,    // The platform owner
  COMPANY_ADMIN,  // Created by Super Admin
  EMPLOYEE,       // Created by Company Admin
}

enum AttendanceLocation {
  OFFICE,
  SITE,
  REMOTE,
}

enum ProjectStatus {
  PLANNING,
  ONGOING,
  ON_HOLD,
  COMPLETED,
  CANCELLED,
  DELAYED,
}

enum Priority {
  LOW,
  MEDIUM,
  HIGH,
  CRITICAL,
}

enum TaskStatus {
  TODO,
  IN_PROGRESS,
  REVIEW,
  COMPLETED,
  BLOCKED,
}

enum AttendanceStatus {
  PRESENT,
  ABSENT,
  LATE,
  HALF_DAY,
  ON_LEAVE,
}

enum LeaveType {
  SICK_LEAVE,
  CASUAL_LEAVE,
  EARNED_LEAVE,
  MATERNITY_LEAVE,
  PATERNITY_LEAVE,
}

enum MaterialStatus {
  REQUESTED,
  APPROVED,
  ORDERED,
  IN_TRANSIT,
  DELIVERED,
  REJECTED,
  RETURNED,
}

enum PaymentMethod {
  CASH,
  BANK_TRANSFER,
  CHEQUE,
  ONLINE,
  UPI,
}

enum InvoiceStatus {
  DRAFT,
  ISSUED,
  PARTIALLY_PAID,
  PAID,
  OVERDUE,
  CANCELLED,
  DISPUTED,
}

enum DocumentType {
  CONTRACT,
  PERMIT,
  DRAWING,
  REPORT,
  INVOICE,
  CERTIFICATE,
  PHOTO,
  OTHER,
}

enum ExpenseCategory {
  MATERIAL,
  LABOR,
  EQUIPMENT_RENTAL,
  TRANSPORTATION,
  OFFICE_SUPPLIES,
  UTILITIES,
  MAINTENANCE,
  TRAVEL,
  FOOD,
  ACCOMMODATION,
  PERMITS,
  INSURANCE,
  PROFESSIONAL_FEES,
  ADVERTISING,
  OTHER,
}

enum EmployeeStatus {
  ACTIVE,
  INACTIVE,
  SUSPENDED,
  RETIRED,
  INJURED,
  TERMINATED,
  ON_PROBATION,
}

enum SalaryType {
  HOURLY,
  MONTHLY,
  DAILY,
  WEEKLY,
  PROJECT_BASED,
}
