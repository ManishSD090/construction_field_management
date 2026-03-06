import 'package:construction_erp/models/equipment.dart';
import 'package:construction_erp/models/material.dart';
import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/enums.dart';

// Helper class to handle nested project names from the API response
class ProjectRef {
  final String? name;

  ProjectRef({this.name});

  factory ProjectRef.fromJson(Map<String, dynamic> json) {
    return ProjectRef(name: json['name']?.toString());
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class Inventory {
  final String id;
  final String companyId;
  final InventoryLocation location;
  final String? projectId;
  final String materialId;
  final double quantityTotal;
  final double quantityUsed;
  final double quantityAvailable;
  final double averageRate;
  final double totalValue;
  final DateTime lastUpdated;
  final Material? material;
  final Equipment? equipment;

  Inventory({
    required this.id,
    required this.companyId,
    required this.location,
    this.projectId,
    required this.materialId,
    required this.quantityTotal,
    required this.quantityUsed,
    required this.quantityAvailable,
    required this.averageRate,
    required this.totalValue,
    required this.lastUpdated,
    this.material,
    this.equipment,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      location: InventoryLocation.fromJson(json['location']?.toString()),
      projectId: json['projectId']?.toString(),
      materialId: json['materialId']?.toString() ?? '',
      quantityTotal:
          num.tryParse(json['quantityTotal']?.toString() ?? '')?.toDouble() ??
              0.0,
      quantityUsed:
          num.tryParse(json['quantityUsed']?.toString() ?? '')?.toDouble() ??
              0.0,
      quantityAvailable:
          num.tryParse(json['quantityAvailable']?.toString() ?? '')
                  ?.toDouble() ??
              0.0,
      averageRate:
          num.tryParse(json['averageRate']?.toString() ?? '')?.toDouble() ??
              0.0,
      totalValue:
          num.tryParse(json['totalValue']?.toString() ?? '')?.toDouble() ?? 0.0,
      lastUpdated: DateTime.tryParse(json['lastUpdated']?.toString() ?? '') ??
          DateTime.now(),
      material:
          json['material'] != null ? Material.fromJson(json['material']) : null,
      equipment: json['equipment'] != null
          ? Equipment.fromJson(json['equipment'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'location': location.toJson(),
      'projectId': projectId,
      'materialId': materialId,
      'quantityTotal': quantityTotal,
      'quantityUsed': quantityUsed,
      'quantityAvailable': quantityAvailable,
      'averageRate': averageRate,
      'totalValue': totalValue,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class InventoryTransfer {
  final String id;
  final String transferNo;
  final String companyId;
  final InventoryLocation fromLocation;
  final String? fromProjectId;
  final ProjectRef? fromProject; // Added to map the relation from API
  final InventoryLocation toLocation;
  final String? toProjectId;
  final ProjectRef? toProject; // Added to map the relation from API
  final DateTime transferDate;
  final TransferStatus status;
  final String? description;
  final String requestedById;
  final User? requestedBy;
  final String? approvedById;
  final User? approvedBy;
  final DateTime? approvedAt;
  final String? userId;
  final User? user;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<InventoryTransferItem>? items;

  InventoryTransfer({
    required this.id,
    required this.transferNo,
    required this.companyId,
    required this.fromLocation,
    this.fromProjectId,
    this.fromProject,
    required this.toLocation,
    this.toProjectId,
    this.toProject,
    required this.transferDate,
    required this.status,
    this.description,
    required this.requestedById,
    this.requestedBy,
    this.approvedById,
    this.approvedBy,
    this.approvedAt,
    this.userId,
    this.user,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  factory InventoryTransfer.fromJson(Map<String, dynamic> json) {
    return InventoryTransfer(
      id: json['id']?.toString() ?? '',
      transferNo: json['transferNo']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      fromLocation:
          InventoryLocation.fromJson(json['fromLocation']?.toString()),
      fromProjectId: json['fromProjectId']?.toString(),
      fromProject: json['fromProject'] != null
          ? ProjectRef.fromJson(json['fromProject'])
          : null,
      toLocation: InventoryLocation.fromJson(json['toLocation']?.toString()),
      toProjectId: json['toProjectId']?.toString(),
      toProject: json['toProject'] != null
          ? ProjectRef.fromJson(json['toProject'])
          : null,
      transferDate: DateTime.tryParse(json['transferDate']?.toString() ?? '') ??
          DateTime.now(),
      status: TransferStatus.fromJson(json['status']?.toString()),
      description: json['description']?.toString(),
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
      userId: json['userId']?.toString(),
      user: json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'])
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      items: (json['items'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map((i) => InventoryTransferItem.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transferNo': transferNo,
      'companyId': companyId,
      'fromLocation': fromLocation.toJson(),
      'fromProjectId': fromProjectId,
      'fromProject': fromProject?.toJson(),
      'toLocation': toLocation.toJson(),
      'toProjectId': toProjectId,
      'toProject': toProject?.toJson(),
      'transferDate': transferDate.toIso8601String(),
      'status': status.toJson(),
      'description': description,
      'requestedById': requestedById,
      'requestedBy': requestedBy?.toJson(),
      'approvedById': approvedById,
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt?.toIso8601String(),
      'userId': userId,
      'user': user?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items?.map((i) => i.toJson()).toList(),
    };
  }
}

class InventoryTransferItem {
  final String id;
  final String transferId;
  final String itemType;
  final String? materialId;
  final double? quantity;
  final String? equipmentId;
  final double? assignedRate;
  final double? assignedFuelCost;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Added nested models from the API include relation
  final Material? material;
  final Equipment? equipment;

  InventoryTransferItem({
    required this.id,
    required this.transferId,
    required this.itemType,
    this.materialId,
    this.quantity,
    this.equipmentId,
    this.assignedRate,
    this.assignedFuelCost,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.material,
    this.equipment,
  });

  factory InventoryTransferItem.fromJson(Map<String, dynamic> json) {
    return InventoryTransferItem(
      id: json['id']?.toString() ?? '',
      transferId: json['transferId']?.toString() ?? '',
      itemType: json['itemType']?.toString() ?? '',
      materialId: json['materialId']?.toString(),
      quantity: num.tryParse(json['quantity']?.toString() ?? '')?.toDouble(),
      equipmentId: json['equipmentId']?.toString(),
      assignedRate:
          num.tryParse(json['assignedRate']?.toString() ?? '')?.toDouble(),
      assignedFuelCost:
          num.tryParse(json['assignedFuelCost']?.toString() ?? '')?.toDouble(),
      notes: json['notes']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      material:
          json['material'] != null ? Material.fromJson(json['material']) : null,
      equipment: json['equipment'] != null
          ? Equipment.fromJson(json['equipment'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transferId': transferId,
      'itemType': itemType,
      'materialId': materialId,
      'quantity': quantity,
      'equipmentId': equipmentId,
      'assignedRate': assignedRate,
      'assignedFuelCost': assignedFuelCost,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'material': material?.toJson(),
      'equipment': equipment?.toJson(),
    };
  }
}
