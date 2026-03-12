import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/models/budget.dart';
import 'package:construction_erp/models/user.dart';

// ==========================================================================
// MATERIAL REQUEST MODEL
// ==========================================================================
class MaterialRequest {
  final String id;
  final String requestNo;
  final String projectId;
  final String? materialId;
  final String materialName;
  final double quantity;
  final String unit;
  final String purpose;
  final String urgency; // e.g., MEDIUM, HIGH
  final String requestedById;
  final User? requestedBy;
  final String? approvedById;
  final User? approvedBy;
  final DateTime? approvedAt;
  final String? orderedById;
  final User? orderedBy;
  final DateTime? orderedAt;
  final String? supplier;
  final DateTime? expectedDelivery;
  final DateTime? actualDelivery;
  final String status; // e.g., REQUESTED, APPROVED, DELIVERED
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool committedToBudget;
  final double? estimatedCost;
  final bool poCreated;
  final String? poNumber;
  final String? purchaseOrderId;
  final String? purchaseOrderItemId;
  final Project? project;
  final List<BudgetTransaction>? budgetTransactions; // NEW FIELD

  MaterialRequest({
    required this.id,
    required this.requestNo,
    required this.projectId,
    this.materialId,
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.purpose,
    required this.urgency,
    required this.requestedById,
    this.requestedBy,
    this.approvedById,
    this.approvedBy,
    this.approvedAt,
    this.orderedById,
    this.orderedBy,
    this.orderedAt,
    this.supplier,
    this.expectedDelivery,
    this.actualDelivery,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.committedToBudget = false,
    this.estimatedCost,
    this.poCreated = false,
    this.poNumber,
    this.purchaseOrderId,
    this.purchaseOrderItemId,
    this.project,
    this.budgetTransactions, // NEW FIELD
  });

  MaterialRequest copyWith({
    String? id,
    String? requestNo,
    String? projectId,
    String? materialId,
    String? materialName,
    double? quantity,
    String? unit,
    String? purpose,
    String? urgency,
    String? requestedById,
    User? requestedBy,
    String? approvedById,
    User? approvedBy,
    DateTime? approvedAt,
    String? orderedById,
    User? orderedBy,
    DateTime? orderedAt,
    String? supplier,
    DateTime? expectedDelivery,
    DateTime? actualDelivery,
    String? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? committedToBudget,
    double? estimatedCost,
    bool? poCreated,
    String? poNumber,
    String? purchaseOrderId,
    String? purchaseOrderItemId,
    Project? project,
    List<BudgetTransaction>? budgetTransactions, // NEW FIELD
  }) {
    return MaterialRequest(
      id: id ?? this.id,
      requestNo: requestNo ?? this.requestNo,
      projectId: projectId ?? this.projectId,
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purpose: purpose ?? this.purpose,
      urgency: urgency ?? this.urgency,
      requestedById: requestedById ?? this.requestedById,
      requestedBy: requestedBy ?? this.requestedBy,
      approvedById: approvedById ?? this.approvedById,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      orderedById: orderedById ?? this.orderedById,
      orderedBy: orderedBy ?? this.orderedBy,
      orderedAt: orderedAt ?? this.orderedAt,
      supplier: supplier ?? this.supplier,
      expectedDelivery: expectedDelivery ?? this.expectedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      committedToBudget: committedToBudget ?? this.committedToBudget,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      poCreated: poCreated ?? this.poCreated,
      poNumber: poNumber ?? this.poNumber,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      purchaseOrderItemId: purchaseOrderItemId ?? this.purchaseOrderItemId,
      project: project ?? this.project,
      budgetTransactions:
          budgetTransactions ?? this.budgetTransactions, // NEW FIELD
    );
  }

  factory MaterialRequest.fromJson(Map<String, dynamic> json) {
    return MaterialRequest(
      id: json['id'] as String? ?? '',
      requestNo: json['requestNo'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      materialId: json['materialId'] as String?,
      materialName: json['materialName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      urgency: json['urgency'] as String? ?? 'MEDIUM',
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
      orderedById: json['orderedById'] as String?,
      orderedBy:
          json['orderedBy'] != null ? User.fromJson(json['orderedBy']) : null,
      orderedAt: json['orderedAt'] != null
          ? DateTime.parse(json['orderedAt'].toString())
          : null,
      supplier: json['supplier'] as String?,
      expectedDelivery: json['expectedDelivery'] != null
          ? DateTime.parse(json['expectedDelivery'].toString())
          : null,
      actualDelivery: json['actualDelivery'] != null
          ? DateTime.parse(json['actualDelivery'].toString())
          : null,
      status: json['status'] as String? ?? 'REQUESTED',
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      committedToBudget: json['committedToBudget'] as bool? ?? false,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      poCreated: json['poCreated'] as bool? ?? false,
      poNumber: json['poNumber'] as String?,
      purchaseOrderId: json['purchaseOrderId'] as String?,
      purchaseOrderItemId: json['purchaseOrderItemId'] as String?,
      project:
          json['project'] != null ? Project.fromJson(json['project']) : null,
      // NEW FIELD PARSING
      budgetTransactions: json['budgetTransactions'] != null
          ? (json['budgetTransactions'] as List)
              .map((e) => BudgetTransaction.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestNo': requestNo,
      'projectId': projectId,
      'materialId': materialId,
      'materialName': materialName,
      'quantity': quantity,
      'unit': unit,
      'purpose': purpose,
      'urgency': urgency,
      'requestedById': requestedById,
      'approvedById': approvedById,
      'approvedAt': approvedAt?.toIso8601String(),
      'orderedById': orderedById,
      'orderedAt': orderedAt?.toIso8601String(),
      'supplier': supplier,
      'expectedDelivery': expectedDelivery?.toIso8601String(),
      'actualDelivery': actualDelivery?.toIso8601String(),
      'status': status,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'committedToBudget': committedToBudget,
      'estimatedCost': estimatedCost,
      'poCreated': poCreated,
      'poNumber': poNumber,
      'purchaseOrderId': purchaseOrderId,
      'purchaseOrderItemId': purchaseOrderItemId,
      'budgetTransactions':
          budgetTransactions?.map((e) => e.toJson()).toList(), // NEW FIELD
    };
  }
}

// ==========================================================================
// PURCHASE ORDER MODEL
// ==========================================================================

class PurchaseOrder {
  final String id;
  final String poNumber;
  final String projectId;
  final String companyId;
  final String title;
  final String? description;
  final String type; // e.g., MATERIAL, EQUIPMENT
  final String status; // e.g., DRAFT, APPROVED, ORDERED, RECEIVED
  final String? supplierId;
  final String supplierName;
  final double subtotal;
  final double taxAmount;
  final double? taxRate;
  final double? discount;
  final double? shippingCost;
  final double? otherCharges;
  final double totalAmount;
  final String currency;
  final String paymentTerm;
  final double? advancePercentage;
  final double? advanceAmount;
  final bool advancePaid;
  final DateTime? advancePaidDate; // NEW
  final String? advancePaymentId; // NEW
  final DateTime orderDate;
  final DateTime? expectedDelivery;
  final DateTime? actualDelivery;
  final String? deliveryAddress;
  final String? deliveryInstructions;
  final String? notes;
  final String? terms;
  final double? totalReceived;
  final double? totalPending;
  final double? receiptPercent;
  final double? totalPaid;
  final double? totalDue;
  final double? paymentPercent;
  final String? requestedById;
  final User? requestedBy;
  final String? approvedById;
  final User? approvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Lifecycle & Budget (NEW)
  final DateTime? closedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? budgetId;
  final String? budgetTransactionId;

  // Relations
  final Project? project;
  final List<PurchaseOrderItem>? items;
  final List<GoodsReceipt>? receipts;
  final List<PurchaseOrderPayment>? payments;

  PurchaseOrder({
    required this.id,
    required this.poNumber,
    required this.projectId,
    required this.companyId,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    this.supplierId,
    required this.supplierName,
    required this.subtotal,
    required this.taxAmount,
    this.taxRate,
    this.discount,
    this.shippingCost,
    this.otherCharges,
    required this.totalAmount,
    required this.currency,
    required this.paymentTerm,
    this.advancePercentage,
    this.advanceAmount,
    this.advancePaid = false,
    this.advancePaidDate,
    this.advancePaymentId,
    required this.orderDate,
    this.expectedDelivery,
    this.actualDelivery,
    this.deliveryAddress,
    this.deliveryInstructions,
    this.notes,
    this.terms,
    this.totalReceived,
    this.totalPending,
    this.receiptPercent,
    this.totalPaid,
    this.totalDue,
    this.paymentPercent,
    this.requestedById,
    this.requestedBy,
    this.approvedById,
    this.approvedBy,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.budgetId,
    this.budgetTransactionId,
    this.project,
    this.items,
    this.receipts,
    this.payments,
  });

  PurchaseOrder copyWith({
    String? id,
    String? poNumber,
    String? projectId,
    String? companyId,
    String? title,
    String? description,
    String? type,
    String? status,
    String? supplierId,
    String? supplierName,
    double? subtotal,
    double? taxAmount,
    double? taxRate,
    double? discount,
    double? shippingCost,
    double? otherCharges,
    double? totalAmount,
    String? currency,
    String? paymentTerm,
    double? advancePercentage,
    double? advanceAmount,
    bool? advancePaid,
    DateTime? advancePaidDate,
    String? advancePaymentId,
    DateTime? orderDate,
    DateTime? expectedDelivery,
    DateTime? actualDelivery,
    String? deliveryAddress,
    String? deliveryInstructions,
    String? notes,
    String? terms,
    double? totalReceived,
    double? totalPending,
    double? receiptPercent,
    double? totalPaid,
    double? totalDue,
    double? paymentPercent,
    String? requestedById,
    User? requestedBy,
    String? approvedById,
    User? approvedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? budgetId,
    String? budgetTransactionId,
    Project? project,
    List<PurchaseOrderItem>? items,
    List<GoodsReceipt>? receipts,
    List<PurchaseOrderPayment>? payments,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      projectId: projectId ?? this.projectId,
      companyId: companyId ?? this.companyId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      taxRate: taxRate ?? this.taxRate,
      discount: discount ?? this.discount,
      shippingCost: shippingCost ?? this.shippingCost,
      otherCharges: otherCharges ?? this.otherCharges,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      paymentTerm: paymentTerm ?? this.paymentTerm,
      advancePercentage: advancePercentage ?? this.advancePercentage,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      advancePaid: advancePaid ?? this.advancePaid,
      advancePaidDate: advancePaidDate ?? this.advancePaidDate,
      advancePaymentId: advancePaymentId ?? this.advancePaymentId,
      orderDate: orderDate ?? this.orderDate,
      expectedDelivery: expectedDelivery ?? this.expectedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      totalReceived: totalReceived ?? this.totalReceived,
      totalPending: totalPending ?? this.totalPending,
      receiptPercent: receiptPercent ?? this.receiptPercent,
      totalPaid: totalPaid ?? this.totalPaid,
      totalDue: totalDue ?? this.totalDue,
      paymentPercent: paymentPercent ?? this.paymentPercent,
      requestedById: requestedById ?? this.requestedById,
      requestedBy: requestedBy ?? this.requestedBy,
      approvedById: approvedById ?? this.approvedById,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedAt: closedAt ?? this.closedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      budgetId: budgetId ?? this.budgetId,
      budgetTransactionId: budgetTransactionId ?? this.budgetTransactionId,
      project: project ?? this.project,
      items: items ?? this.items,
      receipts: receipts ?? this.receipts,
      payments: payments ?? this.payments,
    );
  }

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] as String? ?? '',
      poNumber: json['poNumber'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      companyId: json['companyId'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled PO',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'MATERIAL',
      status: json['status'] as String? ?? 'DRAFT',
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String? ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['taxRate'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      otherCharges: (json['otherCharges'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      paymentTerm: json['paymentTerm'] as String? ?? 'NET_30',
      advancePercentage: (json['advancePercentage'] as num?)?.toDouble(),
      advanceAmount: (json['advanceAmount'] as num?)?.toDouble(),
      advancePaid: json['advancePaid'] as bool? ?? false,
      advancePaidDate: json['advancePaidDate'] != null
          ? DateTime.parse(json['advancePaidDate'].toString())
          : null,
      advancePaymentId: json['advancePaymentId'] as String?,
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'].toString())
          : DateTime.now(),
      expectedDelivery: json['expectedDelivery'] != null
          ? DateTime.parse(json['expectedDelivery'].toString())
          : null,
      actualDelivery: json['actualDelivery'] != null
          ? DateTime.parse(json['actualDelivery'].toString())
          : null,
      deliveryAddress: json['deliveryAddress'] as String?,
      deliveryInstructions: json['deliveryInstructions'] as String?,
      notes: json['notes'] as String?,
      terms: json['terms'] as String?,
      totalReceived: (json['totalReceived'] as num?)?.toDouble(),
      totalPending: (json['totalPending'] as num?)?.toDouble(),
      receiptPercent: (json['receiptPercent'] as num?)?.toDouble(),
      totalPaid: (json['totalPaid'] as num?)?.toDouble(),
      totalDue: (json['totalDue'] as num?)?.toDouble(),
      paymentPercent: (json['paymentPercent'] as num?)?.toDouble(),
      requestedById: json['requestedById'] as String?,
      requestedBy: json['requestedBy'] != null
          ? User.fromJson(json['requestedBy'])
          : null,
      approvedById: json['approvedById'] as String?,
      approvedBy:
          json['approvedBy'] != null ? User.fromJson(json['approvedBy']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      closedAt: json['closedAt'] != null
          ? DateTime.parse(json['closedAt'].toString())
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'].toString())
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      budgetId: json['budgetId'] as String?,
      budgetTransactionId: json['budgetTransactionId'] as String?,
      project:
          json['project'] != null ? Project.fromJson(json['project']) : null,
      items: (json['items'] as List?)
          ?.map((i) => PurchaseOrderItem.fromJson(i))
          .toList(),
      receipts: (json['receipts'] as List?)
          ?.map((r) => GoodsReceipt.fromJson(r))
          .toList(),
      payments: (json['payments'] as List?)
          ?.map((p) => PurchaseOrderPayment.fromJson(p))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poNumber': poNumber,
      'projectId': projectId,
      'companyId': companyId,
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'taxRate': taxRate,
      'discount': discount,
      'shippingCost': shippingCost,
      'otherCharges': otherCharges,
      'totalAmount': totalAmount,
      'currency': currency,
      'paymentTerm': paymentTerm,
      'advancePercentage': advancePercentage,
      'advanceAmount': advanceAmount,
      'advancePaid': advancePaid,
      'advancePaidDate': advancePaidDate?.toIso8601String(),
      'advancePaymentId': advancePaymentId,
      'orderDate': orderDate.toIso8601String(),
      'expectedDelivery': expectedDelivery?.toIso8601String(),
      'actualDelivery': actualDelivery?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'deliveryInstructions': deliveryInstructions,
      'notes': notes,
      'terms': terms,
      'totalReceived': totalReceived,
      'totalPending': totalPending,
      'receiptPercent': receiptPercent,
      'totalPaid': totalPaid,
      'totalDue': totalDue,
      'paymentPercent': paymentPercent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'budgetId': budgetId,
      'budgetTransactionId': budgetTransactionId,
    };
  }
}

// ==========================================================================
// PURCHASE ORDER ITEM MODEL
// ==========================================================================

class PurchaseOrderItem {
  final String id;
  final String purchaseOrderId;
  final int lineNo;
  final String description;
  final String? materialId;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double? discountPercent;
  final double? discountAmount;
  final double? taxPercent;
  final double? taxAmount;
  final double totalPrice;
  final double receivedQuantity;
  final double pendingQuantity;
  final double acceptedQuantity;
  final double rejectedQuantity;
  final double returnedQuantity;
  final String? qualityStandard; // NEW
  final bool inspectionRequired; // NEW
  final String? budgetCategoryId; // NEW
  final bool isClosed;
  final String? notes;

  PurchaseOrderItem({
    required this.id,
    required this.purchaseOrderId,
    required this.lineNo,
    required this.description,
    this.materialId,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    this.discountPercent,
    this.discountAmount,
    this.taxPercent,
    this.taxAmount,
    required this.totalPrice,
    this.receivedQuantity = 0.0,
    required this.pendingQuantity,
    this.acceptedQuantity = 0.0,
    this.rejectedQuantity = 0.0,
    this.returnedQuantity = 0.0,
    this.qualityStandard,
    this.inspectionRequired = false,
    this.budgetCategoryId,
    this.isClosed = false,
    this.notes,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      id: json['id'] as String? ?? '',
      purchaseOrderId: json['purchaseOrderId'] as String? ?? '',
      lineNo: json['lineNo'] as int? ?? 1,
      description: json['description'] as String? ?? '',
      materialId: json['materialId'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      taxPercent: (json['taxPercent'] as num?)?.toDouble(),
      taxAmount: (json['taxAmount'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      receivedQuantity: (json['receivedQuantity'] as num?)?.toDouble() ?? 0.0,
      pendingQuantity: (json['pendingQuantity'] as num?)?.toDouble() ?? 0.0,
      acceptedQuantity: (json['acceptedQuantity'] as num?)?.toDouble() ?? 0.0,
      rejectedQuantity: (json['rejectedQuantity'] as num?)?.toDouble() ?? 0.0,
      returnedQuantity: (json['returnedQuantity'] as num?)?.toDouble() ?? 0.0,
      qualityStandard: json['qualityStandard'] as String?,
      inspectionRequired: json['inspectionRequired'] as bool? ?? false,
      budgetCategoryId: json['budgetCategoryId'] as String?,
      isClosed: json['isClosed'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchaseOrderId': purchaseOrderId,
      'lineNo': lineNo,
      'description': description,
      'materialId': materialId,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'discountPercent': discountPercent,
      'discountAmount': discountAmount,
      'taxPercent': taxPercent,
      'taxAmount': taxAmount,
      'totalPrice': totalPrice,
      'receivedQuantity': receivedQuantity,
      'pendingQuantity': pendingQuantity,
      'acceptedQuantity': acceptedQuantity,
      'rejectedQuantity': rejectedQuantity,
      'returnedQuantity': returnedQuantity,
      'qualityStandard': qualityStandard,
      'inspectionRequired': inspectionRequired,
      'budgetCategoryId': budgetCategoryId,
      'isClosed': isClosed,
      'notes': notes,
    };
  }
}

// ==========================================================================
// GOODS RECEIPT MODEL
// ==========================================================================

class GoodsReceipt {
  final String id;
  final String grNumber;
  final String purchaseOrderId;
  final String projectId;
  final DateTime receiptDate;
  final String receivedById;
  final User? receivedBy;
  final String? deliveryChallanNo;
  final String
      inspectionStatus; // e.g., PENDING, PASSED, FAILED, ACCEPTED, REJECTED
  final bool? qualityCheckPassed;
  final String? qualityRating; // NEW
  final String? qualityNotes; // NEW
  final bool stockUpdated;
  final DateTime? stockUpdatedAt;
  final bool isRejected; // NEW
  final String? rejectionReason; // NEW
  final String? returnVoucherNo; // NEW
  final DateTime? returnedDate; // NEW
  final String? notes;
  final List<GoodsReceiptItem>? items; // NEW (CRITICAL FOR UI)

  GoodsReceipt({
    required this.id,
    required this.grNumber,
    required this.purchaseOrderId,
    required this.projectId,
    required this.receiptDate,
    required this.receivedById,
    this.receivedBy,
    this.deliveryChallanNo,
    required this.inspectionStatus,
    this.qualityCheckPassed,
    this.qualityRating,
    this.qualityNotes,
    this.stockUpdated = false,
    this.stockUpdatedAt,
    this.isRejected = false,
    this.rejectionReason,
    this.returnVoucherNo,
    this.returnedDate,
    this.notes,
    this.items,
  });

  factory GoodsReceipt.fromJson(Map<String, dynamic> json) {
    return GoodsReceipt(
      id: json['id'] as String? ?? '',
      grNumber: json['grNumber'] as String? ?? '',
      purchaseOrderId: json['purchaseOrderId'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      receiptDate: json['receiptDate'] != null
          ? DateTime.parse(json['receiptDate'].toString())
          : DateTime.now(),
      receivedById: json['receivedById'] as String? ?? '',
      receivedBy:
          json['receivedBy'] != null ? User.fromJson(json['receivedBy']) : null,
      deliveryChallanNo: json['deliveryChallanNo'] as String?,
      inspectionStatus: json['inspectionStatus'] as String? ?? 'PENDING',
      qualityCheckPassed: json['qualityCheckPassed'] as bool?,
      qualityRating: json['qualityRating'] as String?,
      qualityNotes: json['qualityNotes'] as String?,
      stockUpdated: json['stockUpdated'] as bool? ?? false,
      stockUpdatedAt: json['stockUpdatedAt'] != null
          ? DateTime.parse(json['stockUpdatedAt'].toString())
          : null,
      isRejected: json['isRejected'] as bool? ?? false,
      rejectionReason: json['rejectionReason'] as String?,
      returnVoucherNo: json['returnVoucherNo'] as String?,
      returnedDate: json['returnedDate'] != null
          ? DateTime.parse(json['returnedDate'].toString())
          : null,
      notes: json['notes'] as String?,
      items: (json['items'] as List?)
          ?.map((i) => GoodsReceiptItem.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grNumber': grNumber,
      'purchaseOrderId': purchaseOrderId,
      'projectId': projectId,
      'receiptDate': receiptDate.toIso8601String(),
      'receivedById': receivedById,
      'deliveryChallanNo': deliveryChallanNo,
      'inspectionStatus': inspectionStatus,
      'qualityCheckPassed': qualityCheckPassed,
      'qualityRating': qualityRating,
      'qualityNotes': qualityNotes,
      'stockUpdated': stockUpdated,
      'stockUpdatedAt': stockUpdatedAt?.toIso8601String(),
      'isRejected': isRejected,
      'rejectionReason': rejectionReason,
      'returnVoucherNo': returnVoucherNo,
      'returnedDate': returnedDate?.toIso8601String(),
      'notes': notes,
    };
  }
}

// ==========================================================================
// GOODS RECEIPT ITEM MODEL (NEW)
// ==========================================================================

class GoodsReceiptItem {
  final String id;
  final String goodsReceiptId;
  final String poItemId;
  final double receivedQuantity;
  final double acceptedQuantity;
  final double rejectedQuantity;
  final double returnedQuantity;
  final String unit;
  final String? condition;
  final String? qualityRating;
  final String inspectionStatus;
  final String? inspectionNotes;
  final String? batchNo;
  final String? serialNo;
  final DateTime? manufacturingDate;
  final DateTime? expiryDate;
  final String? storedLocation;
  final String? binLocation;
  final String? notes;

  final PurchaseOrderItem? poItem;

  GoodsReceiptItem({
    required this.id,
    required this.goodsReceiptId,
    required this.poItemId,
    required this.receivedQuantity,
    this.acceptedQuantity = 0.0,
    this.rejectedQuantity = 0.0,
    this.returnedQuantity = 0.0,
    required this.unit,
    this.condition,
    this.qualityRating,
    this.inspectionStatus = 'PENDING',
    this.inspectionNotes,
    this.batchNo,
    this.serialNo,
    this.manufacturingDate,
    this.expiryDate,
    this.storedLocation,
    this.binLocation,
    this.notes,
    this.poItem,
  });

  factory GoodsReceiptItem.fromJson(Map<String, dynamic> json) {
    return GoodsReceiptItem(
      id: json['id'] as String? ?? '',
      goodsReceiptId: json['goodsReceiptId'] as String? ?? '',
      poItemId: json['poItemId'] as String? ?? '',
      receivedQuantity: (json['receivedQuantity'] as num?)?.toDouble() ?? 0.0,
      acceptedQuantity: (json['acceptedQuantity'] as num?)?.toDouble() ?? 0.0,
      rejectedQuantity: (json['rejectedQuantity'] as num?)?.toDouble() ?? 0.0,
      returnedQuantity: (json['returnedQuantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      condition: json['condition'] as String?,
      qualityRating: json['qualityRating'] as String?,
      inspectionStatus: json['inspectionStatus'] as String? ?? 'PENDING',
      inspectionNotes: json['inspectionNotes'] as String?,
      batchNo: json['batchNo'] as String?,
      serialNo: json['serialNo'] as String?,
      manufacturingDate: json['manufacturingDate'] != null
          ? DateTime.parse(json['manufacturingDate'].toString())
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'].toString())
          : null,
      storedLocation: json['storedLocation'] as String?,
      binLocation: json['binLocation'] as String?,
      notes: json['notes'] as String?,
      poItem: json['poItem'] != null
          ? PurchaseOrderItem.fromJson(json['poItem'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goodsReceiptId': goodsReceiptId,
      'poItemId': poItemId,
      'receivedQuantity': receivedQuantity,
      'acceptedQuantity': acceptedQuantity,
      'rejectedQuantity': rejectedQuantity,
      'returnedQuantity': returnedQuantity,
      'unit': unit,
      'condition': condition,
      'qualityRating': qualityRating,
      'inspectionStatus': inspectionStatus,
      'inspectionNotes': inspectionNotes,
      'batchNo': batchNo,
      'serialNo': serialNo,
      'manufacturingDate': manufacturingDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'storedLocation': storedLocation,
      'binLocation': binLocation,
      'notes': notes,
    };
  }
}

// ==========================================================================
// PURCHASE ORDER PAYMENT MODEL
// ==========================================================================

class PurchaseOrderPayment {
  final String id;
  final String paymentNo;
  final String purchaseOrderId;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String? transactionId;
  final String? referenceNo;
  final String paymentType; // e.g., ADVANCE, PARTIAL, FINAL
  final int? paymentOrder; // NEW
  final String status; // e.g., PENDING, PAID
  final String? bankName; // NEW
  final String? bankAccount; // NEW
  final String? bankIfsc; // NEW
  final String? approvedById;
  final User? approvedBy;
  final DateTime? approvedAt;
  final String? notes;

  PurchaseOrderPayment({
    required this.id,
    required this.paymentNo,
    required this.purchaseOrderId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.transactionId,
    this.referenceNo,
    required this.paymentType,
    this.paymentOrder,
    required this.status,
    this.bankName,
    this.bankAccount,
    this.bankIfsc,
    this.approvedById,
    this.approvedBy,
    this.approvedAt,
    this.notes,
  });

  factory PurchaseOrderPayment.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderPayment(
      id: json['id'] as String? ?? '',
      paymentNo: json['paymentNo'] as String? ?? '',
      purchaseOrderId: json['purchaseOrderId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'].toString())
          : DateTime.now(),
      paymentMethod: json['paymentMethod'] as String? ?? 'BANK_TRANSFER',
      transactionId: json['transactionId'] as String?,
      referenceNo: json['referenceNo'] as String?,
      paymentType: json['paymentType'] as String? ?? 'PARTIAL',
      paymentOrder: json['paymentOrder'] as int?,
      status: json['status'] as String? ?? 'PENDING',
      bankName: json['bankName'] as String?,
      bankAccount: json['bankAccount'] as String?,
      bankIfsc: json['bankIfsc'] as String?,
      approvedById: json['approvedById'] as String?,
      approvedBy:
          json['approvedBy'] != null ? User.fromJson(json['approvedBy']) : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'].toString())
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentNo': paymentNo,
      'purchaseOrderId': purchaseOrderId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'referenceNo': referenceNo,
      'paymentType': paymentType,
      'paymentOrder': paymentOrder,
      'status': status,
      'bankName': bankName,
      'bankAccount': bankAccount,
      'bankIfsc': bankIfsc,
      'approvedById': approvedById,
      'approvedAt': approvedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}
