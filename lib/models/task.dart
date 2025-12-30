import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/enums.dart';

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

  final List<Subtask>? subtasks;
  final List<TaskComment>? comments;
  final List<TaskAttachment>? attachments;

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
    this.progress,
    this.startDate,
    this.dueDate,
    this.completedDate,
    this.estimatedHours,
    this.actualHours,
    required this.createdAt,
    required this.updatedAt,
    this.subtasks,
    this.comments,
    this.attachments,
  });

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
      progress: json['progress'] as int?,
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble(),
      actualHours: (json['actualHours'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      subtasks:
          (json['subtasks'] as List?)?.map((s) => Subtask.fromJson(s)).toList(),
      comments: (json['comments'] as List?)
          ?.map((c) => TaskComment.fromJson(c))
          .toList(),
      attachments: (json['attachments'] as List?)
          ?.map((a) => TaskAttachment.fromJson(a))
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
      'assignedTo': assignedTo?.toJson(),
      'createdById': createdById,
      'creator': creator?.toJson(),
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
      'subtasks': subtasks?.map((s) => s.toJson()).toList(),
      'comments': comments?.map((c) => c.toJson()).toList(),
      'attachments': attachments?.map((a) => a.toJson()).toList(),
    };
  }
}

class Subtask {
  final String id;
  final String description;
  final bool isCompleted;
  final String taskId;
  final String? createdById;
  final User? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subtask({
    required this.id,
    required this.description,
    required this.isCompleted,
    required this.taskId,
    this.createdById,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      taskId: json['taskId'] as String,
      createdById: json['createdById'] as String?,
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'isCompleted': isCompleted,
      'taskId': taskId,
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
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

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id'] as String,
      content: json['content'] as String,
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'taskId': taskId,
      'userId': userId,
      'user': user?.toJson(),
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
      createdAt: DateTime.parse(json['createdAt']),
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
      'uploadedBy': uploadedBy?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
