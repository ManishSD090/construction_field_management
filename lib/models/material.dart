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
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.createdBy,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] as String,
      materialCode: json['materialCode'] as String?,
      companyId: json['companyId'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      stockQuantity: (json['stockQuantity'] as num?)?.toDouble() ?? 0,
      minimumStock: (json['minimumStock'] as num?)?.toDouble() ?? 10,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'] as String?,
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaterialRequest.fromJson(Map<String, dynamic> json) {
    return MaterialRequest(
      id: json['id'] as String,
      requestNo: json['requestNo'] as String,
      projectId: json['projectId'] as String,
      materialId: json['materialId'] as String?,
      materialName: json['materialName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      purpose: json['purpose'] as String,
      urgency: Priority.fromJson(json['urgency'] as String? ?? 'MEDIUM'),
      requestedById: json['requestedById'] as String,
      requestedBy: json['requestedBy'] != null
          ? User.fromJson(json['requestedBy'])
          : null,
      approvedById: json['approvedById'] as String?,
      approvedBy:
          json['approvedBy'] != null ? User.fromJson(json['approvedBy']) : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      orderedById: json['orderedById'] as String?,
      orderedBy:
          json['orderedBy'] != null ? User.fromJson(json['orderedBy']) : null,
      orderedAt:
          json['orderedAt'] != null ? DateTime.parse(json['orderedAt']) : null,
      supplier: json['supplier'] as String?,
      expectedDelivery: json['expectedDelivery'] != null
          ? DateTime.parse(json['expectedDelivery'])
          : null,
      actualDelivery: json['actualDelivery'] != null
          ? DateTime.parse(json['actualDelivery'])
          : null,
      status: MaterialStatus.fromJson(json['status'] as String? ?? 'REQUESTED'),
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
    this.createdById,
    this.createdBy,
    required this.createdAt,
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'] as String,
      materialId: json['materialId'] as String,
      transactionType: json['transactionType'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      previousStock: (json['previousStock'] as num).toDouble(),
      newStock: (json['newStock'] as num).toDouble(),
      projectId: json['projectId'] as String?,
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
      notes: json['notes'] as String?,
      createdById: json['createdById'] as String?,
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      createdAt: DateTime.parse(json['createdAt']),
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
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      id: json['id'] as String,
      materialId: json['materialId'] as String,
      alertType: json['alertType'] as String,
      currentStock: (json['currentStock'] as num).toDouble(),
      threshold: (json['threshold'] as num).toDouble(),
      message: json['message'] as String,
      isResolved: json['isResolved'] as bool? ?? false,
      isNotified: json['isNotified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
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
    };
  }
}
