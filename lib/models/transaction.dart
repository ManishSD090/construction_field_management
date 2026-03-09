// lib/models/transaction.dart
import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/enums.dart';

class ProjectCashbox {
  final String id;
  final String projectId;
  final Project? project;
  final String companyId;
  final double currentBalance;
  final String currency;
  final bool isActive;
  final double? minimumBalance;
  final double? maximumBalance;
  final String? createdById;
  final User? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectCashbox({
    required this.id,
    required this.projectId,
    this.project,
    required this.companyId,
    this.currentBalance = 0,
    this.currency = 'INR',
    this.isActive = true,
    this.minimumBalance,
    this.maximumBalance,
    this.createdById,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectCashbox.fromJson(Map<String, dynamic> json) {
    return ProjectCashbox(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      project:
          json['project'] != null ? Project.fromJson(json['project']) : null,
      companyId: json['companyId'] as String? ?? '',
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      isActive: json['isActive'] as bool? ?? true,
      minimumBalance: (json['minimumBalance'] as num?)?.toDouble(),
      maximumBalance: (json['maximumBalance'] as num?)?.toDouble(),
      createdById: json['createdById'] as String?,
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
      'projectId': projectId,
      'companyId': companyId,
      'currentBalance': currentBalance,
      'currency': currency,
      'isActive': isActive,
      'minimumBalance': minimumBalance,
      'maximumBalance': maximumBalance,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Transaction {
  final String id;
  final String transactionNo;
  final String projectId;
  final Project? project;
  final String companyId;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final String currency;
  final DateTime transactionDate;
  final String description;
  final String? category;
  final String? counterpartyName;
  final String? invoiceId;
  final String? paymentId;
  final String? budgetId;
  final String? budgetCategoryId;
  final String? purchaseOrderId;
  final String? contractorPaymentId;
  final String? payrollId;
  final String? cashboxId;
  final ProjectCashbox? cashbox;
  final TransactionSourceType sourceType;
  final String? sourceId;
  final String? referenceNo;
  final String requestedById;
  final User? requestedBy;
  final String? approvedById;
  final User? approvedBy;
  final DateTime? approvedAt;
  final String? rejectedById;
  final User? rejectedBy;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final String? voidedById;
  final User? voidedBy;
  final DateTime? voidedAt;
  final String? voidReason;
  final String? notes;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.transactionNo,
    required this.projectId,
    this.project,
    required this.companyId,
    required this.type,
    this.status = TransactionStatus.pendingApproval,
    required this.amount,
    this.taxAmount = 0,
    required this.totalAmount,
    this.currency = 'INR',
    required this.transactionDate,
    required this.description,
    this.category,
    this.counterpartyName,
    this.invoiceId,
    this.paymentId,
    this.budgetId,
    this.budgetCategoryId,
    this.purchaseOrderId,
    this.contractorPaymentId,
    this.payrollId,
    this.cashboxId,
    this.cashbox,
    this.sourceType = TransactionSourceType.direct,
    this.sourceId,
    this.referenceNo,
    required this.requestedById,
    this.requestedBy,
    this.approvedById,
    this.approvedBy,
    this.approvedAt,
    this.rejectedById,
    this.rejectedBy,
    this.rejectedAt,
    this.rejectionReason,
    this.voidedById,
    this.voidedBy,
    this.voidedAt,
    this.voidReason,
    this.notes,
    this.attachmentUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String? ?? '',
      transactionNo: json['transactionNo'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      project:
          json['project'] != null ? Project.fromJson(json['project']) : null,
      companyId: json['companyId'] as String? ?? '',
      type: TransactionType.fromJson(json['type'] as String?),
      status: TransactionStatus.fromJson(json['status'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'].toString())
          : DateTime.now(),
      description: json['description'] as String? ?? '',
      category: json['category'] as String?,
      counterpartyName: json['counterpartyName'] as String?,
      invoiceId: json['invoiceId'] as String?,
      paymentId: json['paymentId'] as String?,
      budgetId: json['budgetId'] as String?,
      budgetCategoryId: json['budgetCategoryId'] as String?,
      purchaseOrderId: json['purchaseOrderId'] as String?,
      contractorPaymentId: json['contractorPaymentId'] as String?,
      payrollId: json['payrollId'] as String?,
      cashboxId: json['cashboxId'] as String?,
      cashbox: json['cashbox'] != null
          ? ProjectCashbox.fromJson(json['cashbox'])
          : null,
      sourceType: TransactionSourceType.fromJson(json['sourceType'] as String?),
      sourceId: json['sourceId'] as String?,
      referenceNo: json['referenceNo'] as String?,
      requestedById: json['requestedById'] as String? ?? '',
      requestedBy: json['requestedBy'] != null
          ? User.fromJson(json['requestedBy'])
          : null,
      approvedById: json['approvedById'] as String?,
      approvedBy:
          json['approvedBy'] != null ? User.fromJson(json['approvedBy']) : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'].toString())
          : null,
      rejectedById: json['rejectedById'] as String?,
      rejectedBy:
          json['rejectedBy'] != null ? User.fromJson(json['rejectedBy']) : null,
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'].toString())
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      voidedById: json['voidedById'] as String?,
      voidedBy:
          json['voidedBy'] != null ? User.fromJson(json['voidedBy']) : null,
      voidedAt: json['voidedAt'] != null
          ? DateTime.parse(json['voidedAt'].toString())
          : null,
      voidReason: json['voidReason'] as String?,
      notes: json['notes'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
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
      'transactionNo': transactionNo,
      'projectId': projectId,
      'companyId': companyId,
      'type': type.toJson(),
      'status': status.toJson(),
      'amount': amount,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'transactionDate': transactionDate.toIso8601String(),
      'description': description,
      'category': category,
      'counterpartyName': counterpartyName,
      'invoiceId': invoiceId,
      'paymentId': paymentId,
      'budgetId': budgetId,
      'budgetCategoryId': budgetCategoryId,
      'purchaseOrderId': purchaseOrderId,
      'contractorPaymentId': contractorPaymentId,
      'payrollId': payrollId,
      'cashboxId': cashboxId,
      'sourceType': sourceType.toJson(),
      'sourceId': sourceId,
      'referenceNo': referenceNo,
      'requestedById': requestedById,
      'approvedById': approvedById,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedById': rejectedById,
      'rejectedAt': rejectedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'voidedById': voidedById,
      'voidedAt': voidedAt?.toIso8601String(),
      'voidReason': voidReason,
      'notes': notes,
      'attachmentUrl': attachmentUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// ==========================================================================
// STATE CLASS
// ==========================================================================

class TransactionState {
  final List<Transaction> transactions;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  TransactionState({
    this.transactions = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  TransactionState copyWith({
    List<Transaction>? transactions,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
