import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/task.dart';

// ==========================================
// TIMELINE MODELS (Null-Safe Resilient Version)
// ==========================================

class Timeline {
  final String id;
  final String projectId;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final TimelineStatus status;
  final int currentVersion;
  final bool isCurrent;
  final bool isBaseline;

  final String? approvedById;
  final User? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;

  final DateTime? lockedAt;
  final String? lockedById;
  final User? lockedBy;

  final DateTime? archivedAt;
  final String? archivedById;
  final User? archivedBy;

  final String createdById;
  final User? createdBy;
  final String? versionComment;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final List<TimelineVersion>? timelineVersions;
  final List<TimelineTask>? timelineTasks;
  final List<TimelineHistory>? timelineHistory;
  final List<TimelineApproval>? approvals;

  Timeline({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.currentVersion = 1,
    this.isCurrent = true,
    this.isBaseline = false,
    this.approvedById,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.lockedAt,
    this.lockedById,
    this.lockedBy,
    this.archivedAt,
    this.archivedById,
    this.archivedBy,
    required this.createdById,
    this.createdBy,
    this.versionComment,
    required this.createdAt,
    required this.updatedAt,
    this.timelineVersions,
    this.timelineTasks,
    this.timelineHistory,
    this.approvals,
  });

  Timeline copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    TimelineStatus? status,
    int? currentVersion,
    bool? isCurrent,
    bool? isBaseline,
    String? approvedById,
    User? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    DateTime? lockedAt,
    String? lockedById,
    User? lockedBy,
    DateTime? archivedAt,
    String? archivedById,
    User? archivedBy,
    String? createdById,
    User? createdBy,
    String? versionComment,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TimelineVersion>? timelineVersions,
    List<TimelineTask>? timelineTasks,
    List<TimelineHistory>? timelineHistory,
    List<TimelineApproval>? approvals,
  }) {
    return Timeline(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      currentVersion: currentVersion ?? this.currentVersion,
      isCurrent: isCurrent ?? this.isCurrent,
      isBaseline: isBaseline ?? this.isBaseline,
      approvedById: approvedById ?? this.approvedById,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      lockedAt: lockedAt ?? this.lockedAt,
      lockedById: lockedById ?? this.lockedById,
      lockedBy: lockedBy ?? this.lockedBy,
      archivedAt: archivedAt ?? this.archivedAt,
      archivedById: archivedById ?? this.archivedById,
      archivedBy: archivedBy ?? this.archivedBy,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      versionComment: versionComment ?? this.versionComment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timelineVersions: timelineVersions ?? this.timelineVersions,
      timelineTasks: timelineTasks ?? this.timelineTasks,
      timelineHistory: timelineHistory ?? this.timelineHistory,
      approvals: approvals ?? this.approvals,
    );
  }

  factory Timeline.fromJson(Map<String, dynamic> json) {
    return Timeline(
      id: json['id'] as String? ?? '',
      // Extract projectId from root or nested project object safely
      projectId: json['projectId'] as String? ??
          json['project']?['id'] as String? ??
          '',
      name: json['name'] as String? ?? 'Untitled Timeline',
      description: json['description'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'].toString())
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'].toString())
          : DateTime.now(),
      status: TimelineStatus.fromJson(json['status']),
      currentVersion: json['currentVersion'] as int? ?? 1,
      isCurrent: json['isCurrent'] as bool? ?? true,
      isBaseline: json['isBaseline'] as bool? ?? false,
      approvedById: json['approvedById'] as String?,
      approvedBy:
          json['approvedBy'] != null ? User.fromJson(json['approvedBy']) : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'].toString())
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      lockedAt: json['lockedAt'] != null
          ? DateTime.parse(json['lockedAt'].toString())
          : null,
      lockedById: json['lockedById'] as String?,
      lockedBy:
          json['lockedBy'] != null ? User.fromJson(json['lockedBy']) : null,
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'].toString())
          : null,
      archivedById: json['archivedById'] as String?,
      archivedBy:
          json['archivedBy'] != null ? User.fromJson(json['archivedBy']) : null,
      createdById: json['createdById'] as String? ?? '',
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      versionComment: json['versionComment'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      timelineVersions: (json['timelineVersions'] as List?)
          ?.map((v) => TimelineVersion.fromJson(v))
          .toList(),
      timelineTasks: (json['timelineTasks'] as List?)
          ?.map((tt) => TimelineTask.fromJson(tt))
          .toList(),
      timelineHistory: (json['timelineHistory'] as List?)
          ?.map((h) => TimelineHistory.fromJson(h))
          .toList(),
      approvals: (json['approvals'] as List?)
          ?.map((a) => TimelineApproval.fromJson(a))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.toJson(),
      'currentVersion': currentVersion,
      'isCurrent': isCurrent,
      'isBaseline': isBaseline,
      'approvedById': approvedById,
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'lockedAt': lockedAt?.toIso8601String(),
      'lockedById': lockedById,
      'lockedBy': lockedBy?.toJson(),
      'archivedAt': archivedAt?.toIso8601String(),
      'archivedById': archivedById,
      'archivedBy': archivedBy?.toJson(),
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
      'versionComment': versionComment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'timelineVersions': timelineVersions?.map((v) => v.toJson()).toList(),
      'timelineTasks': timelineTasks?.map((tt) => tt.toJson()).toList(),
      'timelineHistory': timelineHistory?.map((h) => h.toJson()).toList(),
      'approvals': approvals?.map((a) => a.toJson()).toList(),
    };
  }
}

class TimelineVersion {
  final String id;
  final String timelineId;
  final int versionNumber;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final TimelineVersionStatus status;
  final bool isBaseline;
  final String? changesSummary;
  final String createdById;
  final User? createdBy;
  final String? approvedById;
  final User? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final String? submittedById;
  final User? submittedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final List<TimelineTask>? timelineTasks;

  TimelineVersion({
    required this.id,
    required this.timelineId,
    required this.versionNumber,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.isBaseline = false,
    this.changesSummary,
    required this.createdById,
    this.createdBy,
    this.approvedById,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.submittedAt,
    this.submittedById,
    this.submittedBy,
    required this.createdAt,
    required this.updatedAt,
    this.timelineTasks,
  });

  TimelineVersion copyWith({
    String? id,
    String? timelineId,
    int? versionNumber,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    TimelineVersionStatus? status,
    bool? isBaseline,
    String? changesSummary,
    String? createdById,
    User? createdBy,
    String? approvedById,
    User? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    DateTime? submittedAt,
    String? submittedById,
    User? submittedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TimelineTask>? timelineTasks,
  }) {
    return TimelineVersion(
      id: id ?? this.id,
      timelineId: timelineId ?? this.timelineId,
      versionNumber: versionNumber ?? this.versionNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      isBaseline: isBaseline ?? this.isBaseline,
      changesSummary: changesSummary ?? this.changesSummary,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      approvedById: approvedById ?? this.approvedById,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
      submittedById: submittedById ?? this.submittedById,
      submittedBy: submittedBy ?? this.submittedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timelineTasks: timelineTasks ?? this.timelineTasks,
    );
  }

  factory TimelineVersion.fromJson(Map<String, dynamic> json) {
    return TimelineVersion(
      id: json['id'] as String? ?? '',
      timelineId: json['timelineId'] as String? ?? '',
      versionNumber: json['versionNumber'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'].toString())
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'].toString())
          : DateTime.now(),
      status: TimelineVersionStatus.fromJson(json['status']),
      isBaseline: json['isBaseline'] as bool? ?? false,
      changesSummary: json['changesSummary'] as String?,
      createdById: json['createdById'] as String? ?? '',
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      approvedById: json['approvedById'] as String?,
      approvedBy:
          json['approvedBy'] != null ? User.fromJson(json['approvedBy']) : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'].toString())
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'].toString())
          : null,
      submittedById: json['submittedById'] as String?,
      submittedBy: json['submittedBy'] != null
          ? User.fromJson(json['submittedBy'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      timelineTasks: (json['timelineTasks'] as List?)
          ?.map((tt) => TimelineTask.fromJson(tt))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timelineId': timelineId,
      'versionNumber': versionNumber,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.toJson(),
      'isBaseline': isBaseline,
      'changesSummary': changesSummary,
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
      'approvedById': approvedById,
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'submittedAt': submittedAt?.toIso8601String(),
      'submittedById': submittedById,
      'submittedBy': submittedBy?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'timelineTasks': timelineTasks?.map((tt) => tt.toJson()).toList(),
    };
  }
}

class TimelineTask {
  final String id;
  final String timelineId;
  final String timelineVersionId;
  final String taskId;
  final Task? task; // Loaded relation

  final int month;
  final int year;
  final int week;
  final int weekOfMonth;
  final int order;

  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final TimelineTaskStatus timelineStatus;
  final bool isCritical;
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  TimelineTask({
    required this.id,
    required this.timelineId,
    required this.timelineVersionId,
    required this.taskId,
    this.task,
    required this.month,
    required this.year,
    required this.week,
    required this.weekOfMonth,
    this.order = 0,
    this.plannedStartDate,
    this.plannedEndDate,
    required this.timelineStatus,
    this.isCritical = false,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  TimelineTask copyWith({
    String? id,
    String? timelineId,
    String? timelineVersionId,
    String? taskId,
    Task? task,
    int? month,
    int? year,
    int? week,
    int? weekOfMonth,
    int? order,
    DateTime? plannedStartDate,
    DateTime? plannedEndDate,
    TimelineTaskStatus? timelineStatus,
    bool? isCritical,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimelineTask(
      id: id ?? this.id,
      timelineId: timelineId ?? this.timelineId,
      timelineVersionId: timelineVersionId ?? this.timelineVersionId,
      taskId: taskId ?? this.taskId,
      task: task ?? this.task,
      month: month ?? this.month,
      year: year ?? this.year,
      week: week ?? this.week,
      weekOfMonth: weekOfMonth ?? this.weekOfMonth,
      order: order ?? this.order,
      plannedStartDate: plannedStartDate ?? this.plannedStartDate,
      plannedEndDate: plannedEndDate ?? this.plannedEndDate,
      timelineStatus: timelineStatus ?? this.timelineStatus,
      isCritical: isCritical ?? this.isCritical,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TimelineTask.fromJson(Map<String, dynamic> json) {
    return TimelineTask(
      id: json['id'] as String? ?? '',
      timelineId: json['timelineId'] as String? ?? '',
      timelineVersionId: json['timelineVersionId'] as String? ?? '',
      taskId: json['taskId'] as String? ?? json['task']?['id'] as String? ?? '',
      task: json['task'] != null ? Task.fromJson(json['task']) : null,
      month: json['month'] as int? ?? 1,
      year: json['year'] as int? ?? DateTime.now().year,
      week: json['week'] as int? ?? 1,
      weekOfMonth: json['weekOfMonth'] as int? ?? 1,
      order: json['order'] as int? ?? 0,
      plannedStartDate: json['plannedStartDate'] != null
          ? DateTime.parse(json['plannedStartDate'].toString())
          : null,
      plannedEndDate: json['plannedEndDate'] != null
          ? DateTime.parse(json['plannedEndDate'].toString())
          : null,
      timelineStatus: TimelineTaskStatus.fromJson(json['timelineStatus']),
      isCritical: json['isCritical'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timelineId': timelineId,
      'timelineVersionId': timelineVersionId,
      'taskId': taskId,
      'task': task?.toJson(),
      'month': month,
      'year': year,
      'week': week,
      'weekOfMonth': weekOfMonth,
      'order': order,
      'plannedStartDate': plannedStartDate?.toIso8601String(),
      'plannedEndDate': plannedEndDate?.toIso8601String(),
      'timelineStatus': timelineStatus.toJson(),
      'isCritical': isCritical,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TimelineHistory {
  final String id;
  final String timelineId;
  final String? timelineVersionId;
  final String action;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic>? changes;
  final String performedById;
  final User? performedBy;
  final DateTime performedAt;
  final String? notes;

  TimelineHistory({
    required this.id,
    required this.timelineId,
    this.timelineVersionId,
    required this.action,
    required this.entityType,
    this.entityId,
    this.changes,
    required this.performedById,
    this.performedBy,
    required this.performedAt,
    this.notes,
  });

  TimelineHistory copyWith({
    String? id,
    String? timelineId,
    String? timelineVersionId,
    String? action,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? changes,
    String? performedById,
    User? performedBy,
    DateTime? performedAt,
    String? notes,
  }) {
    return TimelineHistory(
      id: id ?? this.id,
      timelineId: timelineId ?? this.timelineId,
      timelineVersionId: timelineVersionId ?? this.timelineVersionId,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      changes: changes ?? this.changes,
      performedById: performedById ?? this.performedById,
      performedBy: performedBy ?? this.performedBy,
      performedAt: performedAt ?? this.performedAt,
      notes: notes ?? this.notes,
    );
  }

  factory TimelineHistory.fromJson(Map<String, dynamic> json) {
    return TimelineHistory(
      id: json['id'] as String? ?? '',
      timelineId: json['timelineId'] as String? ?? '',
      timelineVersionId: json['timelineVersionId'] as String?,
      action: json['action'] as String? ?? 'UNKNOWN',
      entityType: json['entityType'] as String? ?? 'TIMELINE',
      entityId: json['entityId'] as String?,
      changes: json['changes'] as Map<String, dynamic>?,
      performedById: json['performedById'] as String? ?? '',
      performedBy: json['performedBy'] != null
          ? User.fromJson(json['performedBy'])
          : null,
      performedAt: json['performedAt'] != null
          ? DateTime.parse(json['performedAt'].toString())
          : DateTime.now(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timelineId': timelineId,
      'timelineVersionId': timelineVersionId,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'changes': changes,
      'performedById': performedById,
      'performedBy': performedBy?.toJson(),
      'performedAt': performedAt.toIso8601String(),
      'notes': notes,
    };
  }
}

class TimelineApproval {
  final String id;
  final String timelineId;
  final String? timelineVersionId;
  final String approvalType;
  final String entityType;
  final String? entityId;
  final String requestedById;
  final User? requestedBy;
  final DateTime requestedAt;
  final String approverId;
  final User? approver;
  final String status;
  final String? decision;
  final String? decisionNotes;
  final DateTime? decidedAt;
  final DateTime? dueDate;

  TimelineApproval({
    required this.id,
    required this.timelineId,
    this.timelineVersionId,
    required this.approvalType,
    required this.entityType,
    this.entityId,
    required this.requestedById,
    this.requestedBy,
    required this.requestedAt,
    required this.approverId,
    this.approver,
    this.status = 'PENDING',
    this.decision,
    this.decisionNotes,
    this.decidedAt,
    this.dueDate,
  });

  TimelineApproval copyWith({
    String? id,
    String? timelineId,
    String? timelineVersionId,
    String? approvalType,
    String? entityType,
    String? entityId,
    String? requestedById,
    User? requestedBy,
    DateTime? requestedAt,
    String? approverId,
    User? approver,
    String? status,
    String? decision,
    String? decisionNotes,
    DateTime? decidedAt,
    DateTime? dueDate,
  }) {
    return TimelineApproval(
      id: id ?? this.id,
      timelineId: timelineId ?? this.timelineId,
      timelineVersionId: timelineVersionId ?? this.timelineVersionId,
      approvalType: approvalType ?? this.approvalType,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      requestedById: requestedById ?? this.requestedById,
      requestedBy: requestedBy ?? this.requestedBy,
      requestedAt: requestedAt ?? this.requestedAt,
      approverId: approverId ?? this.approverId,
      approver: approver ?? this.approver,
      status: status ?? this.status,
      decision: decision ?? this.decision,
      decisionNotes: decisionNotes ?? this.decisionNotes,
      decidedAt: decidedAt ?? this.decidedAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  factory TimelineApproval.fromJson(Map<String, dynamic> json) {
    return TimelineApproval(
      id: json['id'] as String? ?? '',
      timelineId: json['timelineId'] as String? ?? '',
      timelineVersionId: json['timelineVersionId'] as String?,
      approvalType: json['approvalType'] as String? ?? '',
      entityType: json['entityType'] as String? ?? 'TIMELINE',
      entityId: json['entityId'] as String?,
      requestedById: json['requestedById'] as String? ?? '',
      requestedBy: json['requestedBy'] != null
          ? User.fromJson(json['requestedBy'])
          : null,
      requestedAt: json['requestedAt'] != null
          ? DateTime.parse(json['requestedAt'].toString())
          : DateTime.now(),
      approverId: json['approverId'] as String? ?? '',
      approver:
          json['approver'] != null ? User.fromJson(json['approver']) : null,
      status: json['status'] as String? ?? 'PENDING',
      decision: json['decision'] as String?,
      decisionNotes: json['decisionNotes'] as String?,
      decidedAt: json['decidedAt'] != null
          ? DateTime.parse(json['decidedAt'].toString())
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timelineId': timelineId,
      'timelineVersionId': timelineVersionId,
      'approvalType': approvalType,
      'entityType': entityType,
      'entityId': entityId,
      'requestedById': requestedById,
      'requestedBy': requestedBy?.toJson(),
      'requestedAt': requestedAt.toIso8601String(),
      'approverId': approverId,
      'approver': approver?.toJson(),
      'status': status,
      'decision': decision,
      'decisionNotes': decisionNotes,
      'decidedAt': decidedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }
}
