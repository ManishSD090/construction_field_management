import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/models/user.dart';

class DailyProgressReport {
  final String id;
  final String reportNo;
  final String projectId;
  final String preparedById;
  final User? preparedBy;
  final DateTime date;
  final String? weather;
  final String? temperature;
  final String? humidity;
  final String workDescription;
  final String? completedWork;
  final String? pendingWork;
  final String? challenges;
  final int? totalWorkers;
  final bool? supervisorPresent;
  final String? equipmentUsed;
  final String? materialsUsed;
  final String? materialsReceived;
  final String? materialsRequired;
  final String? safetyObservations;
  final String? incidents;
  final String? qualityChecks;
  final String? issuesFound;
  final String? nextDayPlan;
  final String? approvedById;
  final User? approvedBy;
  final DateTime? approvedAt;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  final List<DPRPhoto>? photos;

  DailyProgressReport({
    required this.id,
    required this.reportNo,
    required this.projectId,
    required this.preparedById,
    this.preparedBy,
    required this.date,
    this.weather,
    this.temperature,
    this.humidity,
    required this.workDescription,
    this.completedWork,
    this.pendingWork,
    this.challenges,
    this.totalWorkers,
    this.supervisorPresent,
    this.equipmentUsed,
    this.materialsUsed,
    this.materialsReceived,
    this.materialsRequired,
    this.safetyObservations,
    this.incidents,
    this.qualityChecks,
    this.issuesFound,
    this.nextDayPlan,
    this.approvedById,
    this.approvedBy,
    this.approvedAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.photos,
  });

  factory DailyProgressReport.fromJson(Map<String, dynamic> json) {
    return DailyProgressReport(
      id: json['id'] as String,
      reportNo: json['reportNo'] as String,
      projectId: json['projectId'] as String,
      preparedById: json['preparedById'] as String,
      preparedBy:
          json['preparedBy'] != null ? User.fromJson(json['preparedBy']) : null,
      date: DateTime.parse(json['date']),
      weather: json['weather'] as String?,
      temperature: json['temperature'] as String?,
      humidity: json['humidity'] as String?,
      workDescription: json['workDescription'] as String,
      completedWork: json['completedWork'] as String?,
      pendingWork: json['pendingWork'] as String?,
      challenges: json['challenges'] as String?,
      totalWorkers: json['totalWorkers'] as int? ?? 0,
      supervisorPresent: json['supervisorPresent'] as bool? ?? false,
      equipmentUsed: json['equipmentUsed'] as String?,
      materialsUsed: json['materialsUsed'] as String?,
      materialsReceived: json['materialsReceived'] as String?,
      materialsRequired: json['materialsRequired'] as String?,
      safetyObservations: json['safetyObservations'] as String?,
      incidents: json['incidents'] as String?,
      qualityChecks: json['qualityChecks'] as String?,
      issuesFound: json['issuesFound'] as String?,
      nextDayPlan: json['nextDayPlan'] as String?,
      approvedById: json['approvedById'] as String?,
      approvedBy:
          json['approvedBy'] != null ? User.fromJson(json['approvedBy']) : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      status: TaskStatus.values.byName(json['status'] as String? ?? 'TODO'),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      photos: json['photos'] != null
          ? (json['photos'] as List).map((p) => DPRPhoto.fromJson(p)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportNo': reportNo,
      'projectId': projectId,
      'preparedById': preparedById,
      'preparedBy': preparedBy?.toJson(),
      'date': date.toIso8601String(),
      'weather': weather,
      'temperature': temperature,
      'humidity': humidity,
      'workDescription': workDescription,
      'completedWork': completedWork,
      'pendingWork': pendingWork,
      'challenges': challenges,
      'totalWorkers': totalWorkers,
      'supervisorPresent': supervisorPresent,
      'equipmentUsed': equipmentUsed,
      'materialsUsed': materialsUsed,
      'materialsReceived': materialsReceived,
      'materialsRequired': materialsRequired,
      'safetyObservations': safetyObservations,
      'incidents': incidents,
      'qualityChecks': qualityChecks,
      'issuesFound': issuesFound,
      'nextDayPlan': nextDayPlan,
      'approvedById': approvedById,
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt?.toIso8601String(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'photos': photos?.map((p) => p.toJson()).toList(),
    };
  }

  @override
  String toString() =>
      'DailyProgressReport(id: $id, reportNo: $reportNo, projectId: $projectId)';
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
      uploadedBy:
          json['uploadedBy'] != null ? User.fromJson(json['uploadedBy']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
  }

  @override
  String toString() => 'DPRPhoto(id: $id, dprId: $dprId)';
}
