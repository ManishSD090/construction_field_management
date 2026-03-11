import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/enums.dart';

class Budget {
  final String id;
  final String budgetNo;
  final String projectId;
  final Project? project;
  final String companyId;
  final String name;
  final String? description;
  final int version;
  final BudgetStatus status;
  final BudgetPeriodType budgetPeriod;
  final double totalApproved;
  final double totalCommitted;
  final double totalSpent;
  final double totalRemaining;
  final double utilizationRate;
  final DateTime startDate;
  final DateTime? endDate;
  final int? fiscalYear;
  final double contingencyPercent;
  final double contingencyAmount;
  final double contingencyRemaining;
  final String requestedById;
  final User? requestedBy;
  final DateTime requestedAt;
  final String? approvedById;
  final User? approvedBy;
  final DateTime? approvedAt;
  final String? approvalNotes;
  final String? rejectionReason;
  final String? previousVersionId;
  final bool isActive;
  final DateTime? lockedAt;
  final String? lockedById;
  final String createdById;
  final User? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final List<BudgetCategoryAllocation>? categories;
  final List<BudgetRevision>? revisions;
  final List<BudgetTransaction>? transactions;
  final List<BudgetAlert>? alerts;
  final List<BudgetForecast>? forecasts;

  Budget({
    required this.id,
    required this.budgetNo,
    required this.projectId,
    this.project,
    required this.companyId,
    required this.name,
    this.description,
    this.version = 1,
    required this.status,
    required this.budgetPeriod,
    this.totalApproved = 0,
    this.totalCommitted = 0,
    this.totalSpent = 0,
    this.totalRemaining = 0,
    this.utilizationRate = 0,
    required this.startDate,
    this.endDate,
    this.fiscalYear,
    this.contingencyPercent = 5,
    this.contingencyAmount = 0,
    this.contingencyRemaining = 0,
    required this.requestedById,
    this.requestedBy,
    required this.requestedAt,
    this.approvedById,
    this.approvedBy,
    this.approvedAt,
    this.approvalNotes,
    this.rejectionReason,
    this.previousVersionId,
    this.isActive = true,
    this.lockedAt,
    this.lockedById,
    required this.createdById,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.categories,
    this.revisions,
    this.transactions,
    this.alerts,
    this.forecasts,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String? ?? '',
      budgetNo: json['budgetNo'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      project:
          json['project'] != null ? Project.fromJson(json['project']) : null,
      companyId: json['companyId'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Budget',
      description: json['description'] as String?,
      version: json['version'] as int? ?? 1,
      status: BudgetStatus.fromJson(json['status'] as String?),
      budgetPeriod: BudgetPeriodType.fromJson(json['budgetPeriod'] as String?),
      totalApproved: (json['totalApproved'] as num?)?.toDouble() ?? 0,
      totalCommitted: (json['totalCommitted'] as num?)?.toDouble() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0,
      totalRemaining: (json['totalRemaining'] as num?)?.toDouble() ?? 0,
      utilizationRate: (json['utilizationRate'] as num?)?.toDouble() ?? 0,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'].toString())
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'].toString())
          : null,
      fiscalYear: json['fiscalYear'] as int?,
      contingencyPercent: (json['contingencyPercent'] as num?)?.toDouble() ?? 5,
      contingencyAmount: (json['contingencyAmount'] as num?)?.toDouble() ?? 0,
      contingencyRemaining:
          (json['contingencyRemaining'] as num?)?.toDouble() ?? 0,
      requestedById: json['requestedById'] as String? ?? '',
      requestedBy: json['requestedBy'] != null
          ? User.fromJson(json['requestedBy'])
          : null,
      requestedAt: json['requestedAt'] != null
          ? DateTime.parse(json['requestedAt'].toString())
          : DateTime.now(),
      approvedById: json['approvedById'] as String?,
      approvedBy:
          json['approvedBy'] != null ? User.fromJson(json['approvedBy']) : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'].toString())
          : null,
      approvalNotes: json['approvalNotes'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      previousVersionId: json['previousVersionId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      lockedAt: json['lockedAt'] != null
          ? DateTime.parse(json['lockedAt'].toString())
          : null,
      lockedById: json['lockedById'] as String?,
      createdById: json['createdById'] as String? ?? '',
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      categories: (json['categories'] as List?)
          ?.map((e) => BudgetCategoryAllocation.fromJson(e))
          .toList(),
      revisions: (json['revisions'] as List?)
          ?.map((e) => BudgetRevision.fromJson(e))
          .toList(),
      transactions: (json['transactions'] as List?)
          ?.map((e) => BudgetTransaction.fromJson(e))
          .toList(),
      alerts: (json['alerts'] as List?)
          ?.map((e) => BudgetAlert.fromJson(e))
          .toList(),
      forecasts: (json['forecasts'] as List?)
          ?.map((e) => BudgetForecast.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'budgetNo': budgetNo,
      'projectId': projectId,
      'companyId': companyId,
      'name': name,
      'description': description,
      'version': version,
      'status': status.toJson(),
      'budgetPeriod': budgetPeriod.toJson(),
      'totalApproved': totalApproved,
      'totalCommitted': totalCommitted,
      'totalSpent': totalSpent,
      'totalRemaining': totalRemaining,
      'utilizationRate': utilizationRate,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'fiscalYear': fiscalYear,
      'contingencyPercent': contingencyPercent,
      'contingencyAmount': contingencyAmount,
      'contingencyRemaining': contingencyRemaining,
      'requestedById': requestedById,
      'requestedAt': requestedAt.toIso8601String(),
      'approvedById': approvedById,
      'approvedAt': approvedAt?.toIso8601String(),
      'approvalNotes': approvalNotes,
      'rejectionReason': rejectionReason,
      'previousVersionId': previousVersionId,
      'isActive': isActive,
      'lockedAt': lockedAt?.toIso8601String(),
      'lockedById': lockedById,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class BudgetCategoryAllocation {
  final String id;
  final String budgetId;
  final BudgetCategory category;
  final String? subCategory;
  final String? description;
  final double allocatedAmount;
  final double committedAmount;
  final double spentAmount;
  final double remainingAmount;
  final double utilizationRate;
  final bool isContingency;
  final String? parentCategoryId;
  final double warningThreshold;
  final double criticalThreshold;
  final Map<String, dynamic>? monthlyAllocation;
  final Map<String, dynamic>? quarterlyAllocation;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final List<BudgetCategoryAllocation>? subCategories;

  BudgetCategoryAllocation({
    required this.id,
    required this.budgetId,
    required this.category,
    this.subCategory,
    this.description,
    this.allocatedAmount = 0,
    this.committedAmount = 0,
    this.spentAmount = 0,
    this.remainingAmount = 0,
    this.utilizationRate = 0,
    this.isContingency = false,
    this.parentCategoryId,
    this.warningThreshold = 80,
    this.criticalThreshold = 95,
    this.monthlyAllocation,
    this.quarterlyAllocation,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    this.subCategories,
  });

  factory BudgetCategoryAllocation.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryAllocation(
      id: json['id'] as String? ?? '',
      budgetId: json['budgetId'] as String? ?? '',
      category: BudgetCategory.fromJson(json['category'] as String?),
      subCategory: json['subCategory'] as String?,
      description: json['description'] as String?,
      allocatedAmount: (json['allocatedAmount'] as num?)?.toDouble() ?? 0,
      committedAmount: (json['committedAmount'] as num?)?.toDouble() ?? 0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0,
      utilizationRate: (json['utilizationRate'] as num?)?.toDouble() ?? 0,
      isContingency: json['isContingency'] as bool? ?? false,
      parentCategoryId: json['parentCategoryId'] as String?,
      warningThreshold: (json['warningThreshold'] as num?)?.toDouble() ?? 80,
      criticalThreshold: (json['criticalThreshold'] as num?)?.toDouble() ?? 95,
      monthlyAllocation: json['monthlyAllocation'] as Map<String, dynamic>?,
      quarterlyAllocation: json['quarterlyAllocation'] as Map<String, dynamic>?,
      createdById: json['createdById'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      subCategories: (json['subCategories'] as List?)
          ?.map((e) => BudgetCategoryAllocation.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'budgetId': budgetId,
      'category': category.toJson(),
      'subCategory': subCategory,
      'description': description,
      'allocatedAmount': allocatedAmount,
      'committedAmount': committedAmount,
      'spentAmount': spentAmount,
      'remainingAmount': remainingAmount,
      'utilizationRate': utilizationRate,
      'isContingency': isContingency,
      'parentCategoryId': parentCategoryId,
      'warningThreshold': warningThreshold,
      'criticalThreshold': criticalThreshold,
      'monthlyAllocation': monthlyAllocation,
      'quarterlyAllocation': quarterlyAllocation,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'subCategories': subCategories?.map((s) => s.toJson()).toList(),
    };
  }
}

class BudgetTransaction {
  final String id;
  final String transactionNo;
  final String budgetId;
  final String categoryId;
  final BudgetCategoryAllocation? category;
  final BudgetTransactionType transactionType;
  final BudgetTransactionStatus status;
  final String description;
  final double amount;
  final double committedAmount;
  final double taxAmount;
  final double totalAmount;
  final double exchangeRate;
  final String currency;
  final String? referenceType;
  final String? referenceId;
  final String? referenceNo;
  final DateTime transactionDate;
  final DateTime? committedDate;
  final DateTime? disbursedDate;
  final String? transferToCategoryId;
  final String? notes;
  final String? attachmentUrl;
  final String createdById;
  final User? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BudgetCategoryAllocation? transferToCategory;

  BudgetTransaction({
    required this.id,
    required this.transactionNo,
    required this.budgetId,
    required this.categoryId,
    this.category,
    required this.transactionType,
    required this.status,
    required this.description,
    required this.amount,
    this.committedAmount = 0,
    this.taxAmount = 0,
    required this.totalAmount,
    this.exchangeRate = 1,
    this.currency = 'INR',
    this.referenceType,
    this.referenceId,
    this.referenceNo,
    required this.transactionDate,
    this.committedDate,
    this.disbursedDate,
    this.transferToCategoryId,
    this.notes,
    this.attachmentUrl,
    required this.createdById,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.transferToCategory,
  });

  factory BudgetTransaction.fromJson(Map<String, dynamic> json) {
    return BudgetTransaction(
      id: json['id'] as String? ?? '',
      transactionNo: json['transactionNo'] as String? ?? '',
      budgetId: json['budgetId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      category: json['category'] != null
          ? BudgetCategoryAllocation.fromJson(json['category'])
          : null,
      transactionType:
          BudgetTransactionType.fromJson(json['transactionType'] as String?),
      status: BudgetTransactionStatus.fromJson(json['status'] as String?),
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      committedAmount: (json['committedAmount'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble() ?? 1,
      currency: json['currency'] as String? ?? 'INR',
      referenceType: json['referenceType'] as String?,
      referenceId: json['referenceId'] as String?,
      referenceNo: json['referenceNo'] as String?,
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'].toString())
          : DateTime.now(),
      committedDate: json['committedDate'] != null
          ? DateTime.parse(json['committedDate'].toString())
          : null,
      disbursedDate: json['disbursedDate'] != null
          ? DateTime.parse(json['disbursedDate'].toString())
          : null,
      transferToCategoryId: json['transferToCategoryId'] as String?,
      notes: json['notes'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      createdById: json['createdById'] as String? ?? '',
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),

      // CRITICAL FIX: Properly parsing the partial nested map for transferToCategory!
      transferToCategory: json['transferToCategory'] != null
          ? BudgetCategoryAllocation.fromJson(json['transferToCategory'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionNo': transactionNo,
      'budgetId': budgetId,
      'categoryId': categoryId,
      'transactionType': transactionType.toJson(),
      'status': status.toJson(),
      'description': description,
      'amount': amount,
      'committedAmount': committedAmount,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'exchangeRate': exchangeRate,
      'currency': currency,
      'referenceType': referenceType,
      'referenceId': referenceId,
      'referenceNo': referenceNo,
      'transactionDate': transactionDate.toIso8601String(),
      'committedDate': committedDate?.toIso8601String(),
      'disbursedDate': disbursedDate?.toIso8601String(),
      'transferToCategoryId': transferToCategoryId,
      'notes': notes,
      'attachmentUrl': attachmentUrl,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class BudgetRevision {
  final String id;
  final String revisionNo;
  final String budgetId;
  final BudgetRevisionType revisionType;
  final String reason;
  final String? description;
  final double previousTotal;
  final double newTotal;
  final double changeAmount;
  final double changePercent;
  final Map<String, dynamic> categoryChanges;
  final Map<String, dynamic>? supportingData;
  final String requestedById;
  final User? requestedBy;
  final DateTime requestedAt;
  final String? approvedById;
  final User? approvedBy;
  final DateTime? approvedAt;
  final String? approvalNotes;
  final String? rejectionReason;
  final DateTime effectiveDate;
  final bool isApplied;
  final DateTime? appliedAt;
  final String createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final BudgetRevisionStatus? status;

  BudgetRevision({
    required this.id,
    required this.revisionNo,
    required this.budgetId,
    required this.revisionType,
    required this.reason,
    this.description,
    required this.previousTotal,
    required this.newTotal,
    required this.changeAmount,
    required this.changePercent,
    required this.categoryChanges,
    this.supportingData,
    required this.requestedById,
    this.requestedBy,
    required this.requestedAt,
    this.approvedById,
    this.approvedBy,
    this.approvedAt,
    this.approvalNotes,
    this.rejectionReason,
    required this.effectiveDate,
    this.isApplied = false,
    this.appliedAt,
    required this.createdById,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  factory BudgetRevision.fromJson(Map<String, dynamic> json) {
    return BudgetRevision(
      id: json['id'] as String? ?? '',
      revisionNo: json['revisionNo'] as String? ?? '',
      budgetId: json['budgetId'] as String? ?? '',
      revisionType:
          BudgetRevisionType.fromJson(json['revisionType'] as String?),
      reason: json['reason'] as String? ?? '',
      description: json['description'] as String?,
      previousTotal: (json['previousTotal'] as num?)?.toDouble() ?? 0,
      newTotal: (json['newTotal'] as num?)?.toDouble() ?? 0,
      changeAmount: (json['changeAmount'] as num?)?.toDouble() ?? 0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0,
      categoryChanges: json['categoryChanges'] as Map<String, dynamic>? ?? {},
      supportingData: json['supportingData'] as Map<String, dynamic>?,
      requestedById: json['requestedById'] as String? ?? '',
      requestedBy: json['requestedBy'] != null
          ? User.fromJson(json['requestedBy'])
          : null,
      requestedAt: json['requestedAt'] != null
          ? DateTime.parse(json['requestedAt'].toString())
          : DateTime.now(),
      approvedById: json['approvedById'] as String?,
      approvedBy:
          json['approvedBy'] != null ? User.fromJson(json['approvedBy']) : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'].toString())
          : null,
      approvalNotes: json['approvalNotes'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      effectiveDate: json['effectiveDate'] != null
          ? DateTime.parse(json['effectiveDate'].toString())
          : DateTime.now(),
      isApplied: json['isApplied'] as bool? ?? false,
      appliedAt: json['appliedAt'] != null
          ? DateTime.parse(json['appliedAt'].toString())
          : null,
      createdById: json['createdById'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      status: BudgetRevisionStatus.fromJson(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'revisionNo': revisionNo,
      'budgetId': budgetId,
      'revisionType': revisionType.toJson(),
      'reason': reason,
      'description': description,
      'previousTotal': previousTotal,
      'newTotal': newTotal,
      'changeAmount': changeAmount,
      'changePercent': changePercent,
      'categoryChanges': categoryChanges,
      'supportingData': supportingData,
      'requestedById': requestedById,
      'requestedAt': requestedAt.toIso8601String(),
      'approvedById': approvedById,
      'approvedAt': approvedAt?.toIso8601String(),
      'approvalNotes': approvalNotes,
      'rejectionReason': rejectionReason,
      'effectiveDate': effectiveDate.toIso8601String(),
      'isApplied': isApplied,
      'appliedAt': appliedAt?.toIso8601String(),
      'createdById': createdById,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class BudgetAlert {
  final String id;
  final String alertNo;
  final String budgetId;
  final String? categoryId;
  final BudgetAlertType alertType;
  final String severity;
  final String title;
  final String message;
  final double currentAmount;
  final double thresholdAmount;
  final double thresholdPercent;
  final double? projectedAmount;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? resolvedById;
  final User? resolvedBy;
  final String? resolutionNotes;
  final String? resolutionAction;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetAlert({
    required this.id,
    required this.alertNo,
    required this.budgetId,
    this.categoryId,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.message,
    required this.currentAmount,
    required this.thresholdAmount,
    required this.thresholdPercent,
    this.projectedAmount,
    this.isResolved = false,
    this.resolvedAt,
    this.resolvedById,
    this.resolvedBy,
    this.resolutionNotes,
    this.resolutionAction,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetAlert.fromJson(Map<String, dynamic> json) {
    return BudgetAlert(
      id: json['id'] as String? ?? '',
      alertNo: json['alertNo'] as String? ?? '',
      budgetId: json['budgetId'] as String? ?? '',
      categoryId: json['categoryId'] as String?,
      alertType: BudgetAlertType.fromJson(json['alertType'] as String?),
      severity: json['severity'] as String? ?? 'WARNING',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
      thresholdAmount: (json['thresholdAmount'] as num?)?.toDouble() ?? 0,
      thresholdPercent: (json['thresholdPercent'] as num?)?.toDouble() ?? 0,
      projectedAmount: (json['projectedAmount'] as num?)?.toDouble(),
      isResolved: json['isResolved'] as bool? ?? false,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'].toString())
          : null,
      resolvedById: json['resolvedById'] as String?,
      resolvedBy:
          json['resolvedBy'] != null ? User.fromJson(json['resolvedBy']) : null,
      resolutionNotes: json['resolutionNotes'] as String?,
      resolutionAction: json['resolutionAction'] as String?,
      createdById: json['createdById'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alertNo': alertNo,
      'budgetId': budgetId,
      'categoryId': categoryId,
      'alertType': alertType.toJson(),
      'severity': severity,
      'title': title,
      'message': message,
      'currentAmount': currentAmount,
      'thresholdAmount': thresholdAmount,
      'thresholdPercent': thresholdPercent,
      'projectedAmount': projectedAmount,
      'isResolved': isResolved,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedById': resolvedById,
      'resolutionNotes': resolutionNotes,
      'resolutionAction': resolutionAction,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class BudgetForecast {
  final String id;
  final String budgetId;
  final DateTime forecastMonth;
  final double forecastAmount;
  final double? actualAmount;
  final double? variance;
  final double? variancePercent;
  final double? confidenceLevel;
  final Map<String, dynamic> categoryForecasts;
  final String? forecastMethod;
  final Map<String, dynamic>? forecastFactors;
  final String createdById;
  final User? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetForecast({
    required this.id,
    required this.budgetId,
    required this.forecastMonth,
    required this.forecastAmount,
    this.actualAmount,
    this.variance,
    this.variancePercent,
    this.confidenceLevel = 80,
    required this.categoryForecasts,
    this.forecastMethod,
    this.forecastFactors,
    required this.createdById,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetForecast.fromJson(Map<String, dynamic> json) {
    return BudgetForecast(
      id: json['id'] as String? ?? '',
      budgetId: json['budgetId'] as String? ?? '',
      forecastMonth: json['forecastMonth'] != null
          ? DateTime.parse(json['forecastMonth'].toString())
          : DateTime.now(),
      forecastAmount: (json['forecastAmount'] as num?)?.toDouble() ?? 0,
      actualAmount: (json['actualAmount'] as num?)?.toDouble(),
      variance: (json['variance'] as num?)?.toDouble(),
      variancePercent: (json['variancePercent'] as num?)?.toDouble(),
      confidenceLevel: (json['confidenceLevel'] as num?)?.toDouble() ?? 80,
      categoryForecasts:
          json['categoryForecasts'] as Map<String, dynamic>? ?? {},
      forecastMethod: json['forecastMethod'] as String?,
      forecastFactors: json['forecastFactors'] as Map<String, dynamic>?,
      createdById: json['createdById'] as String? ?? '',
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'budgetId': budgetId,
      'forecastMonth': forecastMonth.toIso8601String(),
      'forecastAmount': forecastAmount,
      'actualAmount': actualAmount,
      'variance': variance,
      'variancePercent': variancePercent,
      'confidenceLevel': confidenceLevel,
      'categoryForecasts': categoryForecasts,
      'forecastMethod': forecastMethod,
      'forecastFactors': forecastFactors,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class BudgetState {
  final List<Budget> budgets;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  BudgetState({
    this.budgets = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  BudgetState copyWith({
    List<Budget>? budgets,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
