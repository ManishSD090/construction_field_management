import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/models/user.dart';

class DailyProgressReport {
  final String id;
  final String reportNo;
  final String projectId;

  // UI now has these, keep them optional unless backend already sends them
  final String? projectName;
  final String? projectManagerId;
  final User? projectManager;
  final String? siteEngineerId;
  final User? siteEngineer;

  final String preparedById;
  final User? preparedBy;

  final DateTime date;

  // Weather
  final String? weather; // Sunny/Cloudy/Rainy
  final String? temperature;
  final String? humidity;

  // Description (UI)
  final String workDescription; // keep required (maps to Description)
  final String? siteVisitor; // UI has Site Visitor dropdown/text

  // Old fields (keep if backend uses)
  final String? completedWork;
  final String? pendingWork;
  final String? challenges;
  final bool? supervisorPresent;

  // Attendance (NEW)
  final int? workersPresent;
  final int? workersTotal;
  final int? staffPresent;
  final int? staffTotal;

  // Old totalWorkers (keep)
  final int? totalWorkers;

  // Tasks completed (NEW structured)
  final List<DPRTask>? tasksCompleted;

  // Materials + Equipments (NEW structured)
  final List<DPRMaterial>? materials;
  final List<DPREquipment>? equipments;

  // Sub-contractor details (NEW)
  final String? subContractorName;
  final String? subContractorNotes;

  // Next day planning (NEW)
  final String? nextDayTaskName;
  final String? nextDayNotes;

  // Old “string” usage (keep for backward compatibility)
  final String? equipmentUsed;
  final String? materialsUsed;
  final String? materialsReceived;
  final String? materialsRequired;

  // Safety / quality / issues (keep)
  final String? safetyObservations;
  final String? incidents;
  final String? qualityChecks;
  final String? issuesFound;

  // Notes (NEW – bottom notes section)
  final String? notes;

  // Approvals
  final String? approvedById;
  final User? approvedBy;
  final DateTime? approvedAt;

  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Uploads
  final List<DPRPhoto>? photos;
  final List<DPRDocument>? documents;

  DailyProgressReport({
    required this.id,
    required this.reportNo,
    required this.projectId,
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
    required this.workDescription,
    this.siteVisitor,
    this.completedWork,
    this.pendingWork,
    this.challenges,
    this.totalWorkers,
    this.supervisorPresent,
    this.workersPresent,
    this.workersTotal,
    this.staffPresent,
    this.staffTotal,
    this.tasksCompleted,
    this.materials,
    this.equipments,
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
    this.photos,
    this.documents,
  });

  factory DailyProgressReport.fromJson(Map<String, dynamic> json) {
    return DailyProgressReport(
      id: (json['id'] ?? '') as String,
      reportNo: (json['reportNo'] ?? '') as String,
      projectId: (json['projectId'] ?? '') as String,

      projectName: json['projectName'] as String?,
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
      siteVisitor: json['siteVisitor'] as String?,

      completedWork: json['completedWork'] as String?,
      pendingWork: json['pendingWork'] as String?,
      challenges: json['challenges'] as String?,
      totalWorkers: (json['totalWorkers'] as int?) ?? 0,
      supervisorPresent: (json['supervisorPresent'] as bool?) ?? false,

      // NEW attendance
      workersPresent: json['workersPresent'] as int?,
      workersTotal: json['workersTotal'] as int?,
      staffPresent: json['staffPresent'] as int?,
      staffTotal: json['staffTotal'] as int?,

      // NEW tasks list
      tasksCompleted: json['tasksCompleted'] != null
          ? (json['tasksCompleted'] as List)
              .map((t) => DPRTask.fromJson(t))
              .toList()
          : null,

      // NEW materials/equipments list
      materials: json['materials'] != null
          ? (json['materials'] as List)
              .map((m) => DPRMaterial.fromJson(m))
              .toList()
          : null,
      equipments: json['equipments'] != null
          ? (json['equipments'] as List)
              .map((e) => DPREquipment.fromJson(e))
              .toList()
          : null,

      // NEW sub-contractor
      subContractorName: json['subContractorName'] as String?,
      subContractorNotes: json['subContractorNotes'] as String?,

      // NEW next day planning
      nextDayTaskName: json['nextDayTaskName'] as String?,
      nextDayNotes: json['nextDayNotes'] as String?,

      // Old strings
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
      approvedBy:
          json['approvedBy'] != null ? User.fromJson(json['approvedBy']) : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,

      status: TaskStatus.values.byName((json['status'] as String?) ?? 'TODO'),

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),

      photos: json['photos'] != null
          ? (json['photos'] as List).map((p) => DPRPhoto.fromJson(p)).toList()
          : null,

      documents: json['documents'] != null
          ? (json['documents'] as List)
              .map((d) => DPRDocument.fromJson(d))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportNo': reportNo,
      'projectId': projectId,

      'projectName': projectName,
      'projectManagerId': projectManagerId,
      'projectManager': projectManager?.toJson(),
      'siteEngineerId': siteEngineerId,
      'siteEngineer': siteEngineer?.toJson(),

      'preparedById': preparedById,
      'preparedBy': preparedBy?.toJson(),

      'date': date.toIso8601String(),

      'weather': weather,
      'temperature': temperature,
      'humidity': humidity,

      'workDescription': workDescription,
      'siteVisitor': siteVisitor,

      'completedWork': completedWork,
      'pendingWork': pendingWork,
      'challenges': challenges,

      'totalWorkers': totalWorkers,
      'supervisorPresent': supervisorPresent,

      // NEW attendance
      'workersPresent': workersPresent,
      'workersTotal': workersTotal,
      'staffPresent': staffPresent,
      'staffTotal': staffTotal,

      // NEW tasks/materials/equipments
      'tasksCompleted': tasksCompleted?.map((t) => t.toJson()).toList(),
      'materials': materials?.map((m) => m.toJson()).toList(),
      'equipments': equipments?.map((e) => e.toJson()).toList(),

      // NEW sub contractor + next day
      'subContractorName': subContractorName,
      'subContractorNotes': subContractorNotes,
      'nextDayTaskName': nextDayTaskName,
      'nextDayNotes': nextDayNotes,

      // old strings
      'equipmentUsed': equipmentUsed,
      'materialsUsed': materialsUsed,
      'materialsReceived': materialsReceived,
      'materialsRequired': materialsRequired,

      'safetyObservations': safetyObservations,
      'incidents': incidents,
      'qualityChecks': qualityChecks,
      'issuesFound': issuesFound,

      'notes': notes,

      'approvedById': approvedById,
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt?.toIso8601String(),

      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),

      'photos': photos?.map((p) => p.toJson()).toList(),
      'documents': documents?.map((d) => d.toJson()).toList(),
    };
  }

  @override
  String toString() =>
      'DailyProgressReport(id: $id, reportNo: $reportNo, projectId: $projectId)';
}

// -------------------- NEW STRUCTURED MODELS --------------------

class DPRTask {
  final String? id;
  final String name;
  final int? percent; // 0-100
  final TaskStatus? status;
  final List<DPRSubtask>? subtasks;

  const DPRTask({
    this.id,
    required this.name,
    this.percent,
    this.status,
    this.subtasks,
  });

  factory DPRTask.fromJson(Map<String, dynamic> json) {
    return DPRTask(
      id: json['id'] as String?,
      name: (json['name'] ?? '') as String,
      percent: json['percent'] as int?,
      status: json['status'] != null
          ? TaskStatus.values.byName(json['status'] as String)
          : null,
      subtasks: json['subtasks'] != null
          ? (json['subtasks'] as List)
              .map((s) => DPRSubtask.fromJson(s))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'percent': percent,
        'status': status?.name,
        'subtasks': subtasks?.map((s) => s.toJson()).toList(),
      };
}

class DPRSubtask {
  final String? id;
  final String name;

  const DPRSubtask({this.id, required this.name});

  factory DPRSubtask.fromJson(Map<String, dynamic> json) {
    return DPRSubtask(
      id: json['id'] as String?,
      name: (json['name'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class DPRMaterial {
  final String? id;
  final String name;
  final int qtyUsed;

  const DPRMaterial({this.id, required this.name, required this.qtyUsed});

  factory DPRMaterial.fromJson(Map<String, dynamic> json) {
    return DPRMaterial(
      id: json['id'] as String?,
      name: (json['name'] ?? '') as String,
      qtyUsed: (json['qtyUsed'] as int?) ?? 0,
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
      qty: (json['qty'] as int?) ?? 0,
      hoursUsed: (json['hoursUsed'] as int?) ?? 0,
      fuel: (json['fuel'] ?? '') as String,
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

// -------------------- DOCUMENT MODEL (NEW) --------------------

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
      uploadedBy:
          json['uploadedBy'] != null ? User.fromJson(json['uploadedBy']) : null,
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

// -------------------- YOUR EXISTING PHOTO MODEL (UNCHANGED) --------------------

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
      uploadedBy:
          json['uploadedBy'] != null ? User.fromJson(json['uploadedBy']) : null,
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