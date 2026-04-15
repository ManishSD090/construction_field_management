import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/models/user.dart';

class MaterialDetail {
  final String name;
  MaterialDetail({required this.name});
  factory MaterialDetail.fromJson(Map<String, dynamic> json) =>
      MaterialDetail(name: (json['name'] ?? '') as String);
  Map<String, dynamic> toJson() => {'name': name};
}

class MaterialConsumption {
  final String id;
  final double quantity;
  final String unit;
  final MaterialDetail? material;

  MaterialConsumption({
    required this.id,
    required this.quantity,
    required this.unit,
    this.material,
  });

  factory MaterialConsumption.fromJson(Map<String, dynamic> json) {
    return MaterialConsumption(
      id: (json['id'] ?? '') as String,
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: (json['unit'] ?? '') as String,
      material: json['material'] != null
          ? MaterialDetail.fromJson(Map<String, dynamic>.from(json['material']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quantity': quantity,
        'unit': unit,
        'material': material?.toJson(),
      };
}

class DPRTask {
  final String? id;
  final String name;
  final int? percent;
  final TaskStatus? status;
  final List<DPRSubtask> subtasks;

  const DPRTask({
    this.id,
    required this.name,
    this.percent,
    this.status,
    this.subtasks = const [],
  });

  factory DPRTask.fromJson(Map<String, dynamic> json) {
    return DPRTask(
      id: json['id'] as String?,
      name: (json['name'] ?? '') as String,
      percent: DailyProgressReport._toInt(json['percent']),
      status: json['status'] != null
          ? DailyProgressReport._parseTaskStatus(json['status'] as String?)
          : null,
      subtasks: json['subtasks'] is List
          ? (json['subtasks'] as List)
              .map((e) => DPRSubtask.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'percent': percent,
        'status': status?.name,
        'subtasks': subtasks.map((e) => e.toJson()).toList(),
      };
}

class DPRSubtask {
  final String? id;
  final String name;

  const DPRSubtask({
    this.id,
    required this.name,
  });

  factory DPRSubtask.fromJson(Map<String, dynamic> json) {
    return DPRSubtask(
      id: json['id'] as String?,
      name: (json['name'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class DPRMaterial {
  final String? id;
  final String name;
  final int qtyUsed;

  const DPRMaterial({
    this.id,
    required this.name,
    required this.qtyUsed,
  });

  factory DPRMaterial.fromJson(Map<String, dynamic> json) {
    return DPRMaterial(
      id: json['id'] as String?,
      name: (json['name'] ?? '') as String,
      qtyUsed: DailyProgressReport._toInt(json['qtyUsed']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'qtyUsed': qtyUsed,
      };
}

class DPREquipment {
  final String? id;
  final String name;
  final int qty;
  final int hoursUsed;
  final String fuel;

  const DPREquipment({
    this.id,
    required this.name,
    required this.qty,
    required this.hoursUsed,
    required this.fuel,
  });

  factory DPREquipment.fromJson(Map<String, dynamic> json) {
    return DPREquipment(
      id: json['id'] as String?,
      name: (json['name'] ?? '') as String,
      qty: DailyProgressReport._toInt(json['qty']) ?? 0,
      hoursUsed: DailyProgressReport._toInt(json['hoursUsed']) ?? 0,
      fuel: (json['fuel'] ?? '') as String,
    );
  }

  factory DPREquipment.fromUsageJson(Map<String, dynamic> json) {
    return DPREquipment(
      id: json['equipmentId'] as String?,
      name: (json['name'] ?? '') as String,
      qty: DailyProgressReport._toInt(json['quantity']) ?? 0,
      hoursUsed: DailyProgressReport._toInt(json['hours']) ?? 0,
      fuel: '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'qty': qty,
        'hoursUsed': hoursUsed,
        'fuel': fuel,
      };
}

class DPRDocument {
  final String id;
  final String fileUrl;
  final String? fileName;
  final String dprId;
  final String uploadedById;
  final User? uploadedBy;
  final DateTime createdAt;

  DPRDocument({
    required this.id,
    required this.fileUrl,
    this.fileName,
    required this.dprId,
    required this.uploadedById,
    this.uploadedBy,
    required this.createdAt,
  });

  factory DPRDocument.fromJson(Map<String, dynamic> json) {
    return DPRDocument(
      id: json['id'] as String,
      fileUrl: json['fileUrl'] as String,
      fileName: json['fileName'] as String?,
      dprId: json['dprId'] as String,
      uploadedById: json['uploadedById'] as String,
      uploadedBy: json['uploadedBy'] != null
          ? User.fromJson(json['uploadedBy'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'dprId': dprId,
        'uploadedById': uploadedById,
        'uploadedBy': uploadedBy?.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };
}

class DPRPhoto {
  final String id;
  final String? title;
  final String? description;
  final String imageUrl;
  final String? thumbnailUrl;
  final String dprId;
  final String uploadedById;
  final User? uploadedBy;
  final DateTime createdAt;

  DPRPhoto({
    required this.id,
    this.title,
    this.description,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.dprId,
    required this.uploadedById,
    this.uploadedBy,
    required this.createdAt,
  });

  factory DPRPhoto.fromJson(Map<String, dynamic> json) {
    return DPRPhoto(
      id: json['id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      dprId: json['dprId'] as String,
      uploadedById: json['uploadedById'] as String,
      uploadedBy: json['uploadedBy'] != null
          ? User.fromJson(json['uploadedBy'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
        'dprId': dprId,
        'uploadedById': uploadedById,
        'uploadedBy': uploadedBy?.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  String toString() => 'DPRPhoto(id: $id, dprId: $dprId)';
}

class DailyProgressReport {
  final String id;
  final String reportNo;
  final String projectId;

  final String? projectName;
  final String? projectManagerId;
  final User? projectManager;
  final String? siteEngineerId;
  final User? siteEngineer;

  final String preparedById;
  final User? preparedBy;

  final DateTime date;

  final String? weather;
  final String? temperature;
  final String? humidity;

  final String workDescription;

  final List<Map<String, dynamic>> siteVisitors;

  final String? completedWork;
  final String? pendingWork;
  final String? challenges;
  final bool? supervisorPresent;

  final int? workersPresent;
  final int? workersTotal;
  final int? staffPresent;
  final int? staffTotal;
  final int? totalWorkers;

  final List<DPRTask> tasksCompleted;
  final List<DPRMaterial> materials;
  final List<DPREquipment> equipments;

  final Map<String, dynamic>? attendanceSummary;
  final List<MaterialConsumption>? materialConsumptions;

  final String? subContractorName;
  final String? subContractorNotes;

  final String? nextDayTaskName;
  final String? nextDayNotes;
  final String? nextDayPlan; 

  final String? equipmentUsed;
  final String? materialsUsed;
  final String? materialsReceived;
  final String? materialsRequired;

  final String? safetyObservations;
  final String? incidents;
  final String? qualityChecks;
  final String? issuesFound;
  final String? notes;

  final String? approvedById;
  final User? approvedBy;
  final DateTime? approvedAt;

  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  final double? materialsCost;
  final double? laborCost;
  final double? equipmentCost;
  final double? budgetUsed;

  final List<DPRPhoto> photos;
  final List<DPRDocument> documents;

  DailyProgressReport({
    required this.id,
    required this.reportNo,
    required this.projectId,
    this.materialsCost,
    this.laborCost,
    this.equipmentCost,
    this.budgetUsed,
    this.projectName,
    this.projectManagerId,
    this.projectManager,
    this.siteEngineerId,
    this.siteEngineer,
    required this.preparedById,
    this.preparedBy,
    required this.date,
    this.weather,
    this.temperature,
    this.humidity,
    this.nextDayPlan,
    required this.workDescription,
    this.siteVisitors = const [],
    this.completedWork,
    this.pendingWork,
    this.challenges,
    this.totalWorkers,
    this.supervisorPresent,
    this.workersPresent,
    this.workersTotal,
    this.staffPresent,
    this.staffTotal,
    this.tasksCompleted = const [],
    this.materials = const [],
    this.equipments = const [],
    this.attendanceSummary, 
    this.materialConsumptions,
    this.subContractorName,
    this.subContractorNotes,
    this.nextDayTaskName,
    this.nextDayNotes,
    this.equipmentUsed,
    this.materialsUsed,
    this.materialsReceived,
    this.materialsRequired,
    this.safetyObservations,
    this.incidents,
    this.qualityChecks,
    this.issuesFound,
    this.notes,
    this.approvedById,
    this.approvedBy,
    this.approvedAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.photos = const [],
    this.documents = const [],
  });

  factory DailyProgressReport.fromJson(Map<String, dynamic> json) {
    return DailyProgressReport(
      id: (json['id'] ?? '') as String,
      reportNo: (json['reportNo'] ?? '') as String,
      projectId: (json['projectId'] ?? '') as String,
      projectName: json['projectName'] as String? ??
          (json['project'] is Map ? json['project']['name'] as String? : null),
      projectManagerId: json['projectManagerId'] as String?,
      projectManager: json['projectManager'] != null
          ? User.fromJson(json['projectManager'])
          : null,
      siteEngineerId: json['siteEngineerId'] as String?,
      siteEngineer: json['siteEngineer'] != null
          ? User.fromJson(json['siteEngineer'])
          : null,
      preparedById: (json['preparedById'] ?? '') as String,
      preparedBy:
          json['preparedBy'] != null ? User.fromJson(json['preparedBy']) : null,
      date: DateTime.parse(json['date']),
      weather: json['weather'] as String?,
      temperature: json['temperature'] as String?,
      humidity: json['humidity'] as String?,
      workDescription: (json['workDescription'] ?? '') as String,
      siteVisitors: json['siteVisitors'] is List
          ? List<Map<String, dynamic>>.from(
              (json['siteVisitors'] as List).map(
                (e) => Map<String, dynamic>.from(e as Map),
              ),
            )
          : [],
      completedWork: json['completedWork'] as String?,
      pendingWork: json['pendingWork'] as String?,
      challenges: json['challenges'] as String?,
      totalWorkers: _toInt(json['totalWorkers']),
      supervisorPresent: json['supervisorPresent'] as bool?,
      workersPresent: _toInt(json['workersPresent']),
      workersTotal: _toInt(json['workersTotal']),
      staffPresent: _toInt(json['staffPresent']),
      staffTotal: _toInt(json['staffTotal']),

      attendanceSummary: json['attendanceSummary'],
      materialConsumptions: json['materialConsumptions'] != null
          ? (json['materialConsumptions'] as List)
              .map((e) => MaterialConsumption.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,

      tasksCompleted: json['tasksCompleted'] is List
          ? (json['tasksCompleted'] as List)
              .map((e) => DPRTask.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      materials: json['materials'] is List
          ? (json['materials'] as List)
              .map((e) => DPRMaterial.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      equipments: json['equipments'] is List
          ? (json['equipments'] as List)
              .map((e) => DPREquipment.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : json['equipmentUsage'] is List
              ? (json['equipmentUsage'] as List)
                  .map((e) =>
                      DPREquipment.fromUsageJson(Map<String, dynamic>.from(e)))
                  .toList()
              : [],
      subContractorName: json['subContractorName'] as String? ??
          (json['subcontractorDetails'] is Map
              ? json['subcontractorDetails']['name'] as String?
              : null),
      subContractorNotes: json['subContractorNotes'] as String? ??
          (json['subcontractorDetails'] is Map
              ? json['subcontractorDetails']['notes'] as String?
              : null),
      nextDayTaskName: json['nextDayTaskName'] as String? ??
          (json['nextDayPlanning'] is Map
              ? json['nextDayPlanning']['taskName'] as String?
              : null),
      nextDayNotes: json['nextDayNotes'] as String? ??
          (json['nextDayPlanning'] is Map
              ? json['nextDayPlanning']['description'] as String?
              : null), 
      nextDayPlan: json['nextDayPlan'] as String?,
      equipmentUsed: json['equipmentUsed'] as String?,
      materialsUsed: json['materialsUsed'] as String?,
      materialsReceived: json['materialsReceived'] as String?,
      materialsRequired: json['materialsRequired'] as String?,
      safetyObservations: json['safetyObservations'] as String?,
      incidents: json['incidents'] as String?,
      qualityChecks: json['qualityChecks'] as String?,
      issuesFound: json['issuesFound'] as String?,
      notes: json['notes'] as String?,
      approvedById: json['approvedById'] as String?,
      approvedBy: json['approvedBy'] != null ? User.fromJson(json['approvedBy']) : null,
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      
      status: _parseTaskStatus(json['status'] as String?),
      
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      
      materialsCost: (json['materialsCost'] as num?)?.toDouble(),
      laborCost: (json['laborCost'] as num?)?.toDouble(),
      equipmentCost: (json['equipmentCost'] as num?)?.toDouble(),
      budgetUsed: (json['budgetUsed'] as num?)?.toDouble(),

      photos: json['photos'] is List
          ? (json['photos'] as List)
              .map((e) => DPRPhoto.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      documents: json['documents'] is List
          ? (json['documents'] as List)
              .map((e) => DPRDocument.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportNo': reportNo,
      'projectId': projectId,
      'attendanceSummary': attendanceSummary,
      'materialConsumptions': materialConsumptions?.map((e) => e.toJson()).toList(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static TaskStatus _parseTaskStatus(String? status) {
    if (status == null) return TaskStatus.values.first;
    return TaskStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == status.toUpperCase(),
      orElse: () => TaskStatus.values.first,
    );
  }
}