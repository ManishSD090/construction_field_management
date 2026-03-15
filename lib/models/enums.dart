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
  agreement,
  registration,
  gstProof,
  panProof,
  aadharProof,
  bankProof,
  insurance,
  license,
  other;

  static DocumentType fromJson(String name) {
    return DocumentType.values.firstWhere(
      (e) => e.name.toUpperCase() == name.toUpperCase(),
      orElse: () => DocumentType.other,
    );
  }

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

/* ======================= INVENTORY & EQUIPMENT ======================= */

enum EquipmentStatus {
  available,
  inUse,
  maintenance,
  repair,
  decommissioned;

  static EquipmentStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return EquipmentStatus.available;
    final camel = _toCamel(value);
    return EquipmentStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => EquipmentStatus.available,
    );
  }

  String toJson() => _toSnake(name);
}

enum InventoryLocation {
  global,
  project;

  static InventoryLocation fromJson(String? value) {
    if (value == null || value.isEmpty) return InventoryLocation.global;
    final camel = _toCamel(value);
    return InventoryLocation.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => InventoryLocation.global,
    );
  }

  String toJson() => _toSnake(name);
}

enum OwnershipType {
  owned,
  rented;

  static OwnershipType fromJson(String? value) {
    if (value == null || value.isEmpty) return OwnershipType.owned;
    final camel = _toCamel(value);
    return OwnershipType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => OwnershipType.owned,
    );
  }

  String toJson() => _toSnake(name);
}

enum FuelType {
  diesel,
  petrol,
  electric,
  hybrid,
  cng,
  lpg,
  other;

  static FuelType fromJson(String? value) {
    if (value == null || value.isEmpty) return FuelType.diesel;
    final camel = _toCamel(value);
    return FuelType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => FuelType.diesel,
    );
  }

  String toJson() => _toSnake(name);
}

enum TransferStatus {
  draft,
  pendingApproval,
  approved,
  inTransit,
  completed,
  rejected;

  static TransferStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return TransferStatus.draft;
    final camel = _toCamel(value);
    return TransferStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => TransferStatus.draft,
    );
  }

  String toJson() => _toSnake(name);
}

enum MaintenanceType {
  scheduled,
  breakdown,
  emergency,
  upgrade;

  static MaintenanceType fromJson(String? value) {
    if (value == null || value.isEmpty) return MaintenanceType.scheduled;
    final camel = _toCamel(value);
    return MaintenanceType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => MaintenanceType.scheduled,
    );
  }

  String toJson() => _toSnake(name);
}

/* ======================= PAYROLL & WORKERS ======================= */

enum PayrollStatus {
  pending,
  processed,
  paid,
  cancelled;

  static PayrollStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return PayrollStatus.pending;
    final camel = _toCamel(value);
    return PayrollStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => PayrollStatus.pending,
    );
  }

  String toJson() => _toSnake(name);
}

enum WorkerType {
  siteStaff,
  subcontractor;

  static WorkerType fromJson(String? value) {
    if (value == null || value.isEmpty) return WorkerType.siteStaff;
    final camel = _toCamel(value);
    return WorkerType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => WorkerType.siteStaff,
    );
  }

  String toJson() => _toSnake(name);
}

enum WorkerStatus {
  active,
  inactive,
  suspended,
  terminated;

  static WorkerStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return WorkerStatus.active;
    final camel = _toCamel(value);
    return WorkerStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => WorkerStatus.active,
    );
  }

  String toJson() => _toSnake(name);
}

enum WorkerAttendanceStatus {
  present,
  absent,
  late,
  halfDay;

  static WorkerAttendanceStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return WorkerAttendanceStatus.present;
    final camel = _toCamel(value);
    return WorkerAttendanceStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => WorkerAttendanceStatus.present,
    );
  }

  String toJson() => _toSnake(name);
}

enum SubtaskAssignmentStatus {
  pending,
  accepted,
  inProgress,
  completed,
  verified,
  rejected;

  static SubtaskAssignmentStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return SubtaskAssignmentStatus.pending;
    final camel = _toCamel(value);
    return SubtaskAssignmentStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => SubtaskAssignmentStatus.pending,
    );
  }

  String toJson() => _toSnake(name);
}

/* ======================= SAFETY ======================= */

enum SafetyStatus {
  passed,
  failed,
  conditional;

  static SafetyStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return SafetyStatus.passed;
    final camel = _toCamel(value);
    return SafetyStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => SafetyStatus.passed,
    );
  }

  String toJson() => _toSnake(name);
}

/* ======================= BUDGET ======================= */

enum BudgetStatus {
  draft,
  pendingApproval,
  approved,
  rejected,
  active,
  locked,
  archived;

  static BudgetStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return BudgetStatus.draft;
    final camel = _toCamel(value);
    return BudgetStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => BudgetStatus.draft,
    );
  }

  String toJson() => _toSnake(name);
}

enum BudgetCategory {
  material,
  labor,
  subcontractor,
  equipment,
  equipmentRental,
  transportation,
  permits,
  insurance,
  contingency,
  overhead,
  tools,
  safety,
  quality,
  design,
  consultancy,
  utilities,
  fuel,
  food,
  accommodation,
  travel,
  officeSupplies,
  communication,
  legal,
  marketing,
  taxes,
  other;

  static BudgetCategory fromJson(String? value) {
    if (value == null || value.isEmpty) return BudgetCategory.other;
    final camel = _toCamel(value);
    return BudgetCategory.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => BudgetCategory.other,
    );
  }

  String toJson() => _toSnake(name);
}

enum BudgetRevisionType {
  increase,
  decrease,
  reallocate,
  emergency,
  timeAdjustment,
  scopeChange,
  priceAdjustment,
  quantityAdjustment,
  contingencyRelease;

  static BudgetRevisionType fromJson(String? value) {
    if (value == null || value.isEmpty) return BudgetRevisionType.increase;
    final camel = _toCamel(value);
    return BudgetRevisionType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => BudgetRevisionType.increase,
    );
  }

  String toJson() => _toSnake(name);
}

enum BudgetRevisionStatus {
  draft,
  pendingApproval,
  approved,
  rejected,
  applied;

  static BudgetRevisionStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return BudgetRevisionStatus.draft;
    final camel = _toCamel(value);
    return BudgetRevisionStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => BudgetRevisionStatus.draft,
    );
  }

  String toJson() => _toSnake(name);
}

enum BudgetAlertType {
  thresholdWarning,
  criticalWarning,
  exceeded,
  forecastWarning,
  revisionNeeded,
  categoryExceeded,
  timeExceeded,
  commitmentHigh,
  lowRemaining;

  static BudgetAlertType fromJson(String? value) {
    if (value == null || value.isEmpty) return BudgetAlertType.thresholdWarning;
    final camel = _toCamel(value);
    return BudgetAlertType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => BudgetAlertType.thresholdWarning,
    );
  }

  String toJson() => _toSnake(name);
}

enum BudgetTransactionType {
  initialAllocation,
  commitment,
  expense,
  revision,
  transfer,
  adjustment,
  contingencyRelease,
  cancellation;

  static BudgetTransactionType fromJson(String? value) {
    if (value == null || value.isEmpty) return BudgetTransactionType.adjustment;
    final camel = _toCamel(value);
    return BudgetTransactionType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => BudgetTransactionType.adjustment,
    );
  }

  String toJson() => _toSnake(name);
}

enum BudgetTransactionStatus {
  pending,
  committed,
  disbursed,
  cancelled,
  reversed;

  static BudgetTransactionStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return BudgetTransactionStatus.pending;
    final camel = _toCamel(value);
    return BudgetTransactionStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => BudgetTransactionStatus.pending,
    );
  }

  String toJson() => _toSnake(name);
}

enum BudgetPeriodType {
  monthly,
  quarterly,
  yearly,
  projectPhase,
  custom;

  static BudgetPeriodType fromJson(String? value) {
    if (value == null || value.isEmpty) return BudgetPeriodType.projectPhase;
    final camel = _toCamel(value);
    return BudgetPeriodType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => BudgetPeriodType.projectPhase,
    );
  }

  String toJson() => _toSnake(name);
}

/* ======================= TRANSACTIONS ======================= */

enum TransactionType {
  income,
  expense,
  pettyCashIssue,
  pettyCashSettlement,
  pettyCashReplenishment;

  static TransactionType fromJson(String? value) {
    if (value == null || value.isEmpty) return TransactionType.expense;
    final camel = _toCamel(value);
    return TransactionType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => TransactionType.expense,
    );
  }

  String toJson() => _toSnake(name);
}

enum TransactionStatus {
  pendingApproval,
  approved,
  rejected,
  voided;

  static TransactionStatus fromJson(String? value) {
    if (value == null || value.isEmpty) {
      return TransactionStatus.pendingApproval;
    }
    final camel = _toCamel(value);
    return TransactionStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => TransactionStatus.pendingApproval,
    );
  }

  String toJson() => _toSnake(name);
}

enum TransactionSourceType {
  direct,
  invoice,
  payment,
  budget,
  purchaseOrder,
  contractorPayment,
  payroll,
  pettyCash;

  static TransactionSourceType fromJson(String? value) {
    if (value == null || value.isEmpty) return TransactionSourceType.direct;
    final camel = _toCamel(value);
    return TransactionSourceType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => TransactionSourceType.direct,
    );
  }

  String toJson() => _toSnake(name);
}

/* ======================= PURCHASE ORDER & SUPPLIER ======================= */

enum PurchaseOrderStatus {
  draft,
  pendingApproval,
  approved,
  rejected,
  ordered,
  partiallyReceived,
  received,
  invoiced,
  partiallyPaid,
  paid,
  cancelled,
  closed,
  onHold;

  static PurchaseOrderStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return PurchaseOrderStatus.draft;
    final camel = _toCamel(value);
    return PurchaseOrderStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => PurchaseOrderStatus.draft,
    );
  }

  String toJson() => _toSnake(name);
}

enum PurchaseOrderType {
  material,
  equipment,
  service,
  subcontract,
  tool,
  consumable,
  stationery,
  fuel,
  other;

  static PurchaseOrderType fromJson(String? value) {
    if (value == null || value.isEmpty) return PurchaseOrderType.other;
    final camel = _toCamel(value);
    return PurchaseOrderType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => PurchaseOrderType.other,
    );
  }

  String toJson() => _toSnake(name);
}

enum PaymentTerm {
  advanceFull,
  advancePartial,
  onDelivery,
  net7,
  net15,
  net30,
  net45,
  net60,
  net90,
  letterOfCredit,
  cashOnDelivery,
  chequeOnDelivery,
  other;

  static PaymentTerm fromJson(String? value) {
    if (value == null || value.isEmpty) return PaymentTerm.onDelivery;
    final camel = _toCamel(value);
    return PaymentTerm.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => PaymentTerm.onDelivery,
    );
  }

  String toJson() => _toSnake(name);
}

enum GoodsReceiptStatus {
  expected,
  partiallyReceived,
  received,
  inspected,
  qualityChecked,
  accepted,
  rejected,
  partiallyAccepted,
  returned,
  quarantine;

  static GoodsReceiptStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return GoodsReceiptStatus.expected;
    final camel = _toCamel(value);
    return GoodsReceiptStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => GoodsReceiptStatus.expected,
    );
  }

  String toJson() => _toSnake(name);
}

enum InspectionStatus {
  pending,
  inProgress,
  passed,
  failed,
  conditionalPass,
  reinspectionRequired;

  static InspectionStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return InspectionStatus.pending;
    final camel = _toCamel(value);
    return InspectionStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => InspectionStatus.pending,
    );
  }

  String toJson() => _toSnake(name);
}

enum QualityRating {
  excellent,
  good,
  average,
  poor,
  reject;

  static QualityRating fromJson(String? value) {
    if (value == null || value.isEmpty) return QualityRating.average;
    final camel = _toCamel(value);
    return QualityRating.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => QualityRating.average,
    );
  }

  String toJson() => _toSnake(name);
}

enum SupplierStatus {
  active,
  inactive,
  blacklisted,
  underReview,
  pendingVerification,
  approved,
  rejected;

  static SupplierStatus fromJson(String? value) {
    if (value == null || value.isEmpty) return SupplierStatus.underReview;
    final camel = _toCamel(value);
    return SupplierStatus.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => SupplierStatus.underReview,
    );
  }

  String toJson() => _toSnake(name);
}

enum SupplierType {
  manufacturer,
  distributor,
  wholesaler,
  retailer,
  serviceProvider,
  consultant,
  contractor,
  importer,
  other;

  static SupplierType fromJson(String? value) {
    if (value == null || value.isEmpty) return SupplierType.other;
    final camel = _toCamel(value);
    return SupplierType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => SupplierType.other,
    );
  }

  String toJson() => _toSnake(name);
}

enum PODocumentType {
  purchaseOrder,
  quotation,
  invoice,
  deliveryChallan,
  goodsReceiptNote,
  paymentReceipt,
  contract,
  agreement,
  technicalSpecification,
  qualityCertificate,
  warrantyCard,
  insurance,
  other;

  static PODocumentType fromJson(String? value) {
    if (value == null || value.isEmpty) return PODocumentType.other;
    final camel = _toCamel(value);
    return PODocumentType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => PODocumentType.other,
    );
  }

  String toJson() => _toSnake(name);
}

enum POActionType {
  created,
  updated,
  submitted,
  approved,
  rejected,
  ordered,
  received,
  invoiced,
  paid,
  cancelled,
  closed,
  onHold,
  reopened;

  static POActionType fromJson(String? value) {
    if (value == null || value.isEmpty) return POActionType.created;
    final camel = _toCamel(value);
    return POActionType.values.firstWhere(
      (e) => e.name == camel,
      orElse: () => POActionType.created,
    );
  }

  String toJson() => _toSnake(name);
}
