class ProjectSettings {
  final String id;
  final String projectId;

  final String checkInStart;
  final String checkInEnd;
  final String checkOutStart;
  final String checkOutEnd;

  final bool requireLocation;
  final double maxDistance;
  final bool notifyManagerOnDPR;
  final bool notifyOnDelay;

  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectSettings({
    required this.id,
    required this.projectId,
    required this.checkInStart,
    required this.checkInEnd,
    required this.checkOutStart,
    required this.checkOutEnd,
    required this.requireLocation,
    required this.maxDistance,
    required this.notifyManagerOnDPR,
    required this.notifyOnDelay,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectSettings.fromJson(Map<String, dynamic> json) {
    return ProjectSettings(
      id: json['id'],
      projectId: json['projectId'],
      checkInStart: json['checkInStart'] ?? '08:00',
      checkInEnd: json['checkInEnd'] ?? '09:00',
      checkOutStart: json['checkOutStart'] ?? '17:00',
      checkOutEnd: json['checkOutEnd'] ?? '18:00',
      requireLocation: json['requireLocation'] ?? true,
      maxDistance: (json['maxDistance'] ?? 100).toDouble(),
      notifyManagerOnDPR: json['notifyManagerOnDPR'] ?? true,
      notifyOnDelay: json['notifyOnDelay'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Project {
  final String id;
  final String projectId;
  final String companyId;
  final String? clientId;

  final String name;
  final String? description;

  final String location;
  final double latitude;
  final double longitude;
  final double geofenceRadius;

  final double estimatedBudget;
  final double? actualBudget;
  final double? contractValue;
  final double advanceReceived;

  final String status;
  final String priority;
  final int progress;

  final DateTime startDate;
  final DateTime estimatedEndDate;
  final DateTime? actualEndDate;

  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdById;

  final ProjectSettings? settings;

  Project({
    required this.id,
    required this.projectId,
    required this.companyId,
    this.clientId,
    required this.name,
    this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.geofenceRadius,
    required this.estimatedBudget,
    this.actualBudget,
    this.contractValue,
    required this.advanceReceived,
    required this.status,
    required this.priority,
    required this.progress,
    required this.startDate,
    required this.estimatedEndDate,
    this.actualEndDate,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.settings,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      projectId: json['projectId'],
      companyId: json['companyId'],
      clientId: json['clientId'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      geofenceRadius: (json['geofenceRadius'] ?? 200).toDouble(),
      estimatedBudget: json['estimatedBudget'].toDouble(),
      actualBudget: json['actualBudget']?.toDouble(),
      contractValue: json['contractValue']?.toDouble(),
      advanceReceived: (json['advanceReceived'] ?? 0).toDouble(),
      status: json['status'],
      priority: json['priority'],
      progress: json['progress'] ?? 0,
      startDate: DateTime.parse(json['startDate']),
      estimatedEndDate: DateTime.parse(json['estimatedEndDate']),
      actualEndDate: json['actualEndDate'] != null
          ? DateTime.parse(json['actualEndDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'],
      settings: json['projectSettings'] != null
          ? ProjectSettings.fromJson(json['projectSettings'])
          : null,
    );
  }
}

