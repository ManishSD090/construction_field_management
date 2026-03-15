import 'package:construction_erp/models/client.dart';
import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/enums.dart';

class Project {
  final String id;
  final String projectId;
  final String companyId;
  final String? clientId;
  final String name;
  final String? description;

  final String location;
  final double? latitude;
  final double? longitude;
  final double geofenceRadius;

  final double estimatedBudget;
  final double? actualBudget;
  final double? contractValue;
  final double? advanceReceived;

  final ProjectStatus status;
  final Priority priority;
  final int? progress;

  final DateTime startDate;
  final DateTime estimatedEndDate;
  final DateTime? actualEndDate;

  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdById;
  final User? createdBy;
  final ProjectStats? stats;

  final Client? client;

  final ProjectSettings? settings;

  Project({
    required this.id,
    required this.projectId,
    required this.companyId,
    this.clientId,
    required this.name,
    this.description,
    required this.location,
    this.latitude,
    this.longitude,
    this.geofenceRadius = 200,
    required this.estimatedBudget,
    this.actualBudget,
    this.contractValue,
    this.advanceReceived,
    required this.status,
    required this.priority,
    this.progress,
    required this.startDate,
    required this.estimatedEndDate,
    this.actualEndDate,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.createdBy,
    this.stats,
    this.client,
    this.settings,
  });

  Project copyWith({
    String? id,
    String? projectId,
    String? companyId,
    String? clientId,
    String? name,
    String? location,
    DateTime? startDate,
    DateTime? estimatedEndDate,
    DateTime? actualEndDate,
    double? estimatedBudget,
    double? actualBudget,
    double? contractValue,
    double? advanceReceived,
    ProjectStatus? status,
    Priority? priority,
    int? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? createdBy,
    ProjectStats? stats,
    Client? client,
    ProjectSettings? settings,
  }) {
    return Project(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      companyId: companyId ?? this.companyId,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      estimatedEndDate: estimatedEndDate ?? this.estimatedEndDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      actualBudget: actualBudget ?? this.actualBudget,
      contractValue: contractValue ?? this.contractValue,
      advanceReceived: advanceReceived ?? this.advanceReceived,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      stats: stats ?? this.stats,
      client: client ?? this.client,
      settings: settings ?? this.settings,
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      // 1. Avoid "as String". Use ?.toString() ?? ''
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',

      // 2. Safe nested access for clientId
      clientId: (json['client'] != null && json['client'] is Map)
          ? json['client']['id']?.toString()
          : json['clientId']?.toString(),

      name: json['name']?.toString() ?? 'Unnamed Project',
      description: json['description']?.toString(), // Nullable is okay here
      location: json['location']?.toString() ?? '',

      // 3. Safe Number parsing (handles int or double from JSON)
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      geofenceRadius: (json['geofenceRadius'] as num?)?.toDouble() ?? 200.0,
      estimatedBudget: (json['estimatedBudget'] as num?)?.toDouble() ?? 0.0,
      actualBudget: (json['actualBudget'] as num?)?.toDouble(),
      contractValue: (json['contractValue'] as num?)?.toDouble(),
      advanceReceived: (json['advanceReceived'] as num?)?.toDouble() ?? 0.0,

      // 4. Safe Enum/Type parsing
      status: ProjectStatus.fromJson(json['status']?.toString() ?? 'PLANNING'),
      priority: Priority.fromJson(json['priority']?.toString() ?? 'MEDIUM'),
      progress: (json['progress'] as num?)?.toInt() ?? 0,

      // 5. Safe Date parsing
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      estimatedEndDate: json['estimatedEndDate'] != null
          ? DateTime.tryParse(json['estimatedEndDate'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      actualEndDate: json['actualEndDate'] != null
          ? DateTime.tryParse(json['actualEndDate'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),

      createdById: json['createdById']?.toString(),

      // 6. Safe Object parsing (check if value is actually a Map)
      createdBy: (json['createdBy'] is Map<String, dynamic>)
          ? User.fromJson(json['createdBy'] as Map<String, dynamic>)
          : null,
      stats: (json['stats'] is Map<String, dynamic>)
          ? ProjectStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      client: (json['client'] is Map<String, dynamic>)
          ? Client.fromJson(json['client'] as Map<String, dynamic>)
          : null,
      settings: (json['settings'] is Map<String, dynamic>)
          ? ProjectSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'companyId': companyId,
      'clientId': clientId,
      'name': name,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'geofenceRadius': geofenceRadius,
      'estimatedBudget': estimatedBudget,
      'actualBudget': actualBudget,
      'contractValue': contractValue,
      'advanceReceived': advanceReceived,
      'status': status.toJson(),
      'priority': priority.toJson(),
      'progress': progress,
      'startDate': startDate.toIso8601String(),
      'estimatedEndDate': estimatedEndDate.toIso8601String(),
      'actualEndDate': actualEndDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
      'client': client?.toJson(),
      'settings': settings?.toJson(),
    };
  }
}

class ProjectSettings {
  final String id;
  final String projectId;
  final String? checkInStart;
  final String? checkInEnd;
  final String? checkOutStart;
  final String? checkOutEnd;
  final bool requireLocation;
  final double? maxDistance;
  final bool notifyManagerOnDPR;
  final bool notifyOnDelay;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectSettings({
    required this.id,
    required this.projectId,
    this.checkInStart,
    this.checkInEnd,
    this.checkOutStart,
    this.checkOutEnd,
    required this.requireLocation,
    this.maxDistance,
    required this.notifyManagerOnDPR,
    required this.notifyOnDelay,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectSettings.fromJson(Map<String, dynamic> json) {
    return ProjectSettings(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      checkInStart: json['checkInStart'] as String? ?? '08:00',
      checkInEnd: json['checkInEnd'] as String? ?? '09:00',
      checkOutStart: json['checkOutStart'] as String? ?? '17:00',
      checkOutEnd: json['checkOutEnd'] as String? ?? '18:00',
      requireLocation: json['requireLocation'] as bool? ?? true,
      maxDistance: (json['maxDistance'] as num?)?.toDouble() ?? 100,
      notifyManagerOnDPR: json['notifyManagerOnDPR'] as bool? ?? true,
      notifyOnDelay: json['notifyOnDelay'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'checkInStart': checkInStart,
      'checkInEnd': checkInEnd,
      'checkOutStart': checkOutStart,
      'checkOutEnd': checkOutEnd,
      'requireLocation': requireLocation,
      'maxDistance': maxDistance,
      'notifyManagerOnDPR': notifyManagerOnDPR,
      'notifyOnDelay': notifyOnDelay,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Milestone {
  final String id;
  final String name;
  final String? description;
  final double? amount;
  final String projectId;
  final TaskStatus status;
  final DateTime dueDate;
  final DateTime? completedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdById;
  final User? createdBy;

  Milestone({
    required this.id,
    required this.name,
    this.description,
    this.amount,
    required this.projectId,
    required this.status,
    required this.dueDate,
    this.completedDate,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.createdBy,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      projectId: json['projectId'] as String,
      status: TaskStatus.values.byName(
        (json['status'] as String? ?? 'TODO').toLowerCase(),
      ),
      dueDate: DateTime.parse(json['dueDate']),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
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
      'name': name,
      'description': description,
      'amount': amount,
      'projectId': projectId,
      'status': status.name.toUpperCase(),
      'dueDate': dueDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
    };
  }
}

// Create a small helper class
class ProjectStats {
  final int tasks;
  final int teamMembers;
  final int expenses;
  final int materialRequests;

  ProjectStats({
    required this.tasks,
    required this.teamMembers,
    required this.expenses,
    required this.materialRequests,
  });

  factory ProjectStats.fromJson(Map<String, dynamic> json) {
    return ProjectStats(
      tasks: json['tasks'] ?? 0,
      teamMembers: json['teamMembers'] ?? 0,
      expenses: json['expenses'] ?? 0,
      materialRequests: json['materialRequests'] ?? 0,
    );
  }
}

class ProjectState {
  final List<Project> projects;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  ProjectState({
    required this.projects,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  ProjectState copyWith({
    List<Project>? projects,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
