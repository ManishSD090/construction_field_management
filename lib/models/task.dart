import 'package:construction_erp/models/timeline.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/models/user.dart';
// ==========================================
// TASK MODELS
// ==========================================

class Task {
  final String id;
  final String title;
  final String? description;
  final String projectId;
  final String? assignedToId;
  final User? assignedTo;
  final String createdById;
  final User? creator;
  final TaskStatus status;
  final Priority priority;
  final int? progress;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final double? estimatedHours;
  final double? actualHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final List<Subtask>? subtasks;
  final List<TaskComment>? comments;
  final List<TaskAttachment>? attachments;
  final List<TimelineTask>? timelineTasks;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.projectId,
    this.assignedToId,
    this.assignedTo,
    required this.createdById,
    this.creator,
    required this.status,
    required this.priority,
    this.progress = 0,
    this.startDate,
    this.dueDate,
    this.completedDate,
    this.estimatedHours,
    this.actualHours = 0,
    required this.createdAt,
    required this.updatedAt,
    this.subtasks,
    this.comments,
    this.attachments,
    this.timelineTasks,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? projectId,
    String? assignedToId,
    User? assignedTo,
    String? createdById,
    User? creator,
    TaskStatus? status,
    Priority? priority,
    int? progress,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedDate,
    double? estimatedHours,
    double? actualHours,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Subtask>? subtasks,
    List<TaskComment>? comments,
    List<TaskAttachment>? attachments,
    List<TimelineTask>? timelineTasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdById: createdById ?? this.createdById,
      creator: creator ?? this.creator,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subtasks: subtasks ?? this.subtasks,
      comments: comments ?? this.comments,
      attachments: attachments ?? this.attachments,
      timelineTasks: timelineTasks ?? this.timelineTasks,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      projectId: json['projectId'] as String,
      assignedToId: json['assignedToId'] as String?,
      assignedTo:
          json['assignedTo'] != null ? User.fromJson(json['assignedTo']) : null,
      createdById: json['createdById'] as String,
      creator: json['creator'] != null ? User.fromJson(json['creator']) : null,
      status: TaskStatus.fromJson(json['status'] as String? ?? 'TODO'),
      priority: Priority.fromJson(json['priority'] as String? ?? 'MEDIUM'),
      progress: json['progress'] as int? ?? 0,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble(),
      actualHours: (json['actualHours'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      subtasks:
          (json['subtasks'] as List?)?.map((s) => Subtask.fromJson(s)).toList(),
      comments: (json['comments'] as List?)
          ?.map((c) => TaskComment.fromJson(c))
          .toList(),
      attachments: (json['attachments'] as List?)
          ?.map((a) => TaskAttachment.fromJson(a))
          .toList(),
      timelineTasks: (json['timelineTasks'] as List?)
          ?.map((tt) => TimelineTask.fromJson(tt))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectId': projectId,
      'assignedToId': assignedToId,
      'createdById': createdById,
      'status': status.toJson(),
      'priority': priority.toJson(),
      'progress': progress,
      'startDate': startDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Subtask {
  final String id;
  final String description;
  final bool isCompleted;
  final String taskId;
  final int? order;
  final String? createdById;
  final User? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subtask({
    required this.id,
    required this.description,
    required this.isCompleted,
    required this.taskId,
    this.order,
    this.createdById,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Subtask copyWith({
    String? id,
    String? description,
    bool? isCompleted,
    String? taskId,
    int? order,
    String? createdById,
    User? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subtask(
      id: id ?? this.id,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      taskId: taskId ?? this.taskId,
      order: order ?? this.order,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      taskId: json['taskId'] as String,
      order: json['order'] as int?,
      createdById: json['createdById'] as String?,
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'isCompleted': isCompleted,
      'taskId': taskId,
      'order': order,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TaskComment {
  final String id;
  final String content;
  final String taskId;
  final String userId;
  final User? user;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskComment({
    required this.id,
    required this.content,
    required this.taskId,
    required this.userId,
    this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  TaskComment copyWith({
    String? id,
    String? content,
    String? taskId,
    String? userId,
    User? user,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskComment(
      id: id ?? this.id,
      content: content ?? this.content,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id'] as String,
      content: json['content'] as String,
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'taskId': taskId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TaskAttachment {
  final String id;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int? fileSize;
  final String taskId;
  final String uploadedById;
  final User? uploadedBy;
  final DateTime createdAt;

  TaskAttachment({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    this.fileSize,
    required this.taskId,
    required this.uploadedById,
    this.uploadedBy,
    required this.createdAt,
  });

  TaskAttachment copyWith({
    String? id,
    String? fileName,
    String? fileUrl,
    String? fileType,
    int? fileSize,
    String? taskId,
    String? uploadedById,
    User? uploadedBy,
    DateTime? createdAt,
  }) {
    return TaskAttachment(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      taskId: taskId ?? this.taskId,
      uploadedById: uploadedById ?? this.uploadedById,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int?,
      taskId: json['taskId'] as String,
      uploadedById: json['uploadedById'] as String,
      uploadedBy:
          json['uploadedBy'] != null ? User.fromJson(json['uploadedBy']) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      'taskId': taskId,
      'uploadedById': uploadedById,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
