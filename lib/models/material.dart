import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/models/budget.dart';

class Material {
  final String id;
  final String? materialCode;
  final String companyId;
  final String name;
  final String unit;
  final double? stockQuantity;
  final double? minimumStock;
  final double? unitPrice;
  final String? supplier;
  final String? supplierContact;
  final double? pendingPOQuantity;
  final double? onOrderQuantity;
  final double? availableQuantity;
  final double? committedQuantity;
  final List<String>? preferredSuppliers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdById;
  final User? createdBy;

  Material({
    required this.id,
    this.materialCode,
    required this.companyId,
    required this.name,
    required this.unit,
    this.stockQuantity,
    this.minimumStock,
    this.unitPrice,
    this.supplier,
    this.supplierContact,
    this.pendingPOQuantity,
    this.onOrderQuantity,
    this.availableQuantity,
    this.committedQuantity,
    this.preferredSuppliers,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.createdBy,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id']?.toString() ?? '',
      materialCode: json['materialCode']?.toString(),
      companyId: json['companyId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      stockQuantity:
          num.tryParse(json['stockQuantity']?.toString() ?? '')?.toDouble() ??
              0.0,
      minimumStock:
          num.tryParse(json['minimumStock']?.toString() ?? '')?.toDouble() ??
              10.0,
      unitPrice: num.tryParse(json['unitPrice']?.toString() ?? '')?.toDouble(),
      supplier: json['supplier']?.toString(),
      supplierContact: json['supplierContact']?.toString(),
      pendingPOQuantity:
          num.tryParse(json['pendingPOQuantity']?.toString() ?? '')
                  ?.toDouble() ??
              0.0,
      onOrderQuantity:
          num.tryParse(json['onOrderQuantity']?.toString() ?? '')?.toDouble() ??
              0.0,
      availableQuantity:
          num.tryParse(json['availableQuantity']?.toString() ?? '')
                  ?.toDouble() ??
              0.0,
      committedQuantity:
          num.tryParse(json['committedQuantity']?.toString() ?? '')
                  ?.toDouble() ??
              0.0,
      preferredSuppliers: (json['preferredSuppliers'] as List?)
          ?.map((e) => e?.toString() ?? '')
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      createdById: json['createdById']?.toString(),
      createdBy: json['createdBy'] is Map<String, dynamic>
          ? User.fromJson(json['createdBy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialCode': materialCode,
      'companyId': companyId,
      'name': name,
      'unit': unit,
      'stockQuantity': stockQuantity,
      'minimumStock': minimumStock,
      'unitPrice': unitPrice,
      'supplier': supplier,
      'supplierContact': supplierContact,
      'pendingPOQuantity': pendingPOQuantity,
      'onOrderQuantity': onOrderQuantity,
      'availableQuantity': availableQuantity,
      'committedQuantity': committedQuantity,
      'preferredSuppliers': preferredSuppliers,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
    };
  }

  @override
  String toString() => 'Material(id: $id, name: $name, unit: $unit)';
}

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

class StockTransaction {
  final String id;
  final String materialId;
  final String transactionType;
  final double quantity;
  final double previousStock;
  final double newStock;
  final String? projectId;
  final String? referenceId;
  final String? referenceType;
  final String? notes;
  final String? goodsReceiptItemId;
  final String? createdById;
  final User? createdBy;
  final DateTime createdAt;

  StockTransaction({
    required this.id,
    required this.materialId,
    required this.transactionType,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.projectId,
    this.referenceId,
    this.referenceType,
    this.notes,
    this.goodsReceiptItemId,
    this.createdById,
    this.createdBy,
    required this.createdAt,
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id']?.toString() ?? '',
      materialId: json['materialId']?.toString() ?? '',
      transactionType: json['transactionType']?.toString() ?? '',
      quantity:
          num.tryParse(json['quantity']?.toString() ?? '')?.toDouble() ?? 0.0,
      previousStock:
          num.tryParse(json['previousStock']?.toString() ?? '')?.toDouble() ??
              0.0,
      newStock:
          num.tryParse(json['newStock']?.toString() ?? '')?.toDouble() ?? 0.0,
      projectId: json['projectId']?.toString(),
      referenceId: json['referenceId']?.toString(),
      referenceType: json['referenceType']?.toString(),
      notes: json['notes']?.toString(),
      goodsReceiptItemId: json['goodsReceiptItemId']?.toString(),
      createdById: json['createdById']?.toString(),
      createdBy: json['createdBy'] is Map<String, dynamic>
          ? User.fromJson(json['createdBy'])
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialId': materialId,
      'transactionType': transactionType,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'projectId': projectId,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'notes': notes,
      'goodsReceiptItemId': goodsReceiptItemId,
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class StockAlert {
  final String id;
  final String materialId;
  final String alertType;
  final double currentStock;
  final double threshold;
  final String message;
  final bool isResolved;
  final bool isNotified;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedById;

  StockAlert({
    required this.id,
    required this.materialId,
    required this.alertType,
    required this.currentStock,
    required this.threshold,
    required this.message,
    required this.isResolved,
    required this.isNotified,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedById,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      id: json['id']?.toString() ?? '',
      materialId: json['materialId']?.toString() ?? '',
      alertType: json['alertType']?.toString() ?? '',
      currentStock:
          num.tryParse(json['currentStock']?.toString() ?? '')?.toDouble() ??
              0.0,
      threshold:
          num.tryParse(json['threshold']?.toString() ?? '')?.toDouble() ?? 0.0,
      message: json['message']?.toString() ?? '',
      isResolved: json['isResolved'] == true ||
          json['isResolved']?.toString().toLowerCase() == 'true',
      isNotified: json['isNotified'] == true ||
          json['isNotified']?.toString().toLowerCase() == 'true',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'].toString())
          : null,
      resolvedById: json['resolvedById']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialId': materialId,
      'alertType': alertType,
      'currentStock': currentStock,
      'threshold': threshold,
      'message': message,
      'isResolved': isResolved,
      'isNotified': isNotified,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedById': resolvedById,
    };
  }
}
