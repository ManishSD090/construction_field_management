import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/enums.dart';

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
  final Priority urgency;
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
  final MaterialStatus status;
  final String? rejectionReason;

  // PO & Budget related new fields
  final String? purchaseOrderId;
  final String? poItemId;
  final bool committedToBudget;
  final double? estimatedCost;
  final bool poCreated;
  final String? poNumber;

  final DateTime createdAt;
  final DateTime updatedAt;

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
    this.purchaseOrderId,
    this.poItemId,
    this.committedToBudget = false,
    this.estimatedCost,
    this.poCreated = false,
    this.poNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaterialRequest.fromJson(Map<String, dynamic> json) {
    return MaterialRequest(
      id: json['id']?.toString() ?? '',
      requestNo: json['requestNo']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      materialId: json['materialId']?.toString(),
      materialName: json['materialName']?.toString() ?? '',
      quantity:
          num.tryParse(json['quantity']?.toString() ?? '')?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      urgency: Priority.fromJson(json['urgency']?.toString()),
      requestedById: json['requestedById']?.toString() ?? '',
      requestedBy: json['requestedBy'] is Map<String, dynamic>
          ? User.fromJson(json['requestedBy'])
          : null,
      approvedById: json['approvedById']?.toString(),
      approvedBy: json['approvedBy'] is Map<String, dynamic>
          ? User.fromJson(json['approvedBy'])
          : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'].toString())
          : null,
      orderedById: json['orderedById']?.toString(),
      orderedBy: json['orderedBy'] is Map<String, dynamic>
          ? User.fromJson(json['orderedBy'])
          : null,
      orderedAt: json['orderedAt'] != null
          ? DateTime.tryParse(json['orderedAt'].toString())
          : null,
      supplier: json['supplier']?.toString(),
      expectedDelivery: json['expectedDelivery'] != null
          ? DateTime.tryParse(json['expectedDelivery'].toString())
          : null,
      actualDelivery: json['actualDelivery'] != null
          ? DateTime.tryParse(json['actualDelivery'].toString())
          : null,
      status: MaterialStatus.fromJson(json['status']?.toString()),
      rejectionReason: json['rejectionReason']?.toString(),
      purchaseOrderId: json['purchaseOrderId']?.toString(),
      poItemId: json['poItemId']?.toString(),
      committedToBudget: json['committedToBudget'] == true ||
          json['committedToBudget']?.toString().toLowerCase() == 'true',
      estimatedCost:
          num.tryParse(json['estimatedCost']?.toString() ?? '')?.toDouble(),
      poCreated: json['poCreated'] == true ||
          json['poCreated']?.toString().toLowerCase() == 'true',
      poNumber: json['poNumber']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
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
      'urgency': urgency.toJson(),
      'requestedById': requestedById,
      'requestedBy': requestedBy?.toJson(),
      'approvedById': approvedById,
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt?.toIso8601String(),
      'orderedById': orderedById,
      'orderedBy': orderedBy?.toJson(),
      'orderedAt': orderedAt?.toIso8601String(),
      'supplier': supplier,
      'expectedDelivery': expectedDelivery?.toIso8601String(),
      'actualDelivery': actualDelivery?.toIso8601String(),
      'status': status.toJson(),
      'rejectionReason': rejectionReason,
      'purchaseOrderId': purchaseOrderId,
      'poItemId': poItemId,
      'committedToBudget': committedToBudget,
      'estimatedCost': estimatedCost,
      'poCreated': poCreated,
      'poNumber': poNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
