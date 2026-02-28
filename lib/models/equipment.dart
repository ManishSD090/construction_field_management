import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/enums.dart';

class Equipment {
  final String id;
  final String companyId;
  final String name;
  final String? code;
  final String type;
  final String? model;
  final String? serialNumber;
  final String? registrationNumber;
  final InventoryLocation location;
  final String? currentProjectId;
  final OwnershipType ownershipType;
  final String? rentalProvider;
  final double? rentalRate;
  final String? rentalUnit;
  final DateTime? purchaseDate;
  final double? purchaseCost;
  final FuelType? fuelType;
  final double? fuelConsumption;
  final EquipmentStatus status;
  final String? condition;
  final String? manufacturer;
  final int? year;
  final DateTime? lastServiceDate;
  final DateTime? nextServiceDate;
  final String? assignedToId;
  final User? assignedTo;
  final DateTime? assignedDate;
  final String? createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  Equipment({
    required this.id,
    required this.companyId,
    required this.name,
    this.code,
    required this.type,
    this.model,
    this.serialNumber,
    this.registrationNumber,
    required this.location,
    this.currentProjectId,
    required this.ownershipType,
    this.rentalProvider,
    this.rentalRate,
    this.rentalUnit,
    this.purchaseDate,
    this.purchaseCost,
    this.fuelType,
    this.fuelConsumption,
    required this.status,
    this.condition,
    this.manufacturer,
    this.year,
    this.lastServiceDate,
    this.nextServiceDate,
    this.assignedToId,
    this.assignedTo,
    this.assignedDate,
    this.createdById,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      type: json['type']?.toString() ?? '',
      model: json['model']?.toString(),
      serialNumber: json['serialNumber']?.toString(),
      registrationNumber: json['registrationNumber']?.toString(),
      location: InventoryLocation.fromJson(json['location']?.toString()),
      currentProjectId: json['currentProjectId']?.toString(),
      ownershipType: OwnershipType.fromJson(json['ownershipType']?.toString()),
      rentalProvider: json['rentalProvider']?.toString(),
      rentalRate:
          num.tryParse(json['rentalRate']?.toString() ?? '')?.toDouble(),
      rentalUnit: json['rentalUnit']?.toString(),
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.tryParse(json['purchaseDate'].toString())
          : null,
      purchaseCost:
          num.tryParse(json['purchaseCost']?.toString() ?? '')?.toDouble(),
      fuelType: json['fuelType'] != null
          ? FuelType.fromJson(json['fuelType']?.toString())
          : null,
      fuelConsumption:
          num.tryParse(json['fuelConsumption']?.toString() ?? '')?.toDouble(),
      status: EquipmentStatus.fromJson(json['status']?.toString()),
      condition: json['condition']?.toString(),
      manufacturer: json['manufacturer']?.toString(),
      year: int.tryParse(json['year']?.toString() ?? ''),
      lastServiceDate: json['lastServiceDate'] != null
          ? DateTime.tryParse(json['lastServiceDate'].toString())
          : null,
      nextServiceDate: json['nextServiceDate'] != null
          ? DateTime.tryParse(json['nextServiceDate'].toString())
          : null,
      assignedToId: json['assignedToId']?.toString(),
      assignedTo: json['assignedTo'] is Map<String, dynamic>
          ? User.fromJson(json['assignedTo'])
          : null,
      assignedDate: json['assignedDate'] != null
          ? DateTime.tryParse(json['assignedDate'].toString())
          : null,
      createdById: json['createdById']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'name': name,
      'code': code,
      'type': type,
      'model': model,
      'serialNumber': serialNumber,
      'registrationNumber': registrationNumber,
      'location': location.toJson(),
      'currentProjectId': currentProjectId,
      'ownershipType': ownershipType.toJson(),
      'rentalProvider': rentalProvider,
      'rentalRate': rentalRate,
      'rentalUnit': rentalUnit,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'purchaseCost': purchaseCost,
      'fuelType': fuelType?.toJson(),
      'fuelConsumption': fuelConsumption,
      'status': status.toJson(),
      'condition': condition,
      'manufacturer': manufacturer,
      'year': year,
      'lastServiceDate': lastServiceDate?.toIso8601String(),
      'nextServiceDate': nextServiceDate?.toIso8601String(),
      'assignedToId': assignedToId,
      'assignedTo': assignedTo?.toJson(),
      'assignedDate': assignedDate?.toIso8601String(),
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class EquipmentLog {
  final String id;
  final String equipmentId;
  final String projectId;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final double totalHours;
  final double? billableHours;
  final double? rentalRateSnapshot;
  final double? rentalCost;
  final double? fuelConsumed;
  final double? fuelRate;
  final double? fuelCost;
  final double totalCost;
  final String? workDescription;
  final String? operatorId;
  final User? operator;
  final String? operatorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  EquipmentLog({
    required this.id,
    required this.equipmentId,
    required this.projectId,
    required this.date,
    this.startTime,
    this.endTime,
    required this.totalHours,
    this.billableHours,
    this.rentalRateSnapshot,
    this.rentalCost,
    this.fuelConsumed,
    this.fuelRate,
    this.fuelCost,
    required this.totalCost,
    this.workDescription,
    this.operatorId,
    this.operator,
    this.operatorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EquipmentLog.fromJson(Map<String, dynamic> json) {
    return EquipmentLog(
      id: json['id']?.toString() ?? '',
      equipmentId: json['equipmentId']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'].toString())
          : null,
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'].toString())
          : null,
      totalHours:
          num.tryParse(json['totalHours']?.toString() ?? '')?.toDouble() ?? 0.0,
      billableHours:
          num.tryParse(json['billableHours']?.toString() ?? '')?.toDouble(),
      rentalRateSnapshot:
          num.tryParse(json['rentalRateSnapshot']?.toString() ?? '')
              ?.toDouble(),
      rentalCost:
          num.tryParse(json['rentalCost']?.toString() ?? '')?.toDouble(),
      fuelConsumed:
          num.tryParse(json['fuelConsumed']?.toString() ?? '')?.toDouble(),
      fuelRate: num.tryParse(json['fuelRate']?.toString() ?? '')?.toDouble(),
      fuelCost: num.tryParse(json['fuelCost']?.toString() ?? '')?.toDouble(),
      totalCost:
          num.tryParse(json['totalCost']?.toString() ?? '')?.toDouble() ?? 0.0,
      workDescription: json['workDescription']?.toString(),
      operatorId: json['operatorId']?.toString(),
      operator: json['operator'] is Map<String, dynamic>
          ? User.fromJson(json['operator'])
          : null,
      operatorName: json['operatorName']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipmentId': equipmentId,
      'projectId': projectId,
      'date': date.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalHours': totalHours,
      'billableHours': billableHours,
      'rentalRateSnapshot': rentalRateSnapshot,
      'rentalCost': rentalCost,
      'fuelConsumed': fuelConsumed,
      'fuelRate': fuelRate,
      'fuelCost': fuelCost,
      'totalCost': totalCost,
      'workDescription': workDescription,
      'operatorId': operatorId,
      'operator': operator?.toJson(),
      'operatorName': operatorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
