import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/enums.dart';

class Message {
  final String id;
  final String senderId;
  final User? sender;
  final String receiverId;
  final User? receiver;
  final String? projectId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.senderId,
    this.sender,
    required this.receiverId,
    this.receiver,
    this.projectId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      receiverId: json['receiverId'] as String,
      receiver:
          json['receiver'] != null ? User.fromJson(json['receiver']) : null,
      projectId: json['projectId'] as String?,
      content: json['content'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'sender': sender?.toJson(),
      'receiverId': receiverId,
      'receiver': receiver?.toJson(),
      'projectId': projectId,
      'content': content,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'Message(id: $id, senderId: $senderId, receiverId: $receiverId)';
}

class Notification {
  final String id;
  final String userId;
  final User? user;
  final String title;
  final String message;
  final String type;
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    this.user,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    required this.isRead,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      relatedId: json['relatedId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'user': user?.toJson(),
      'title': title,
      'message': message,
      'type': type,
      'relatedId': relatedId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Notification(id: $id, userId: $userId, type: $type)';
}

class Document {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final String fileUrl;
  final String fileType;
  final int? fileSize;
  final DocumentType documentType;
  final String uploadedById;
  final User? uploadedBy;
  final bool isPublic;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Document({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.fileUrl,
    required this.fileType,
    this.fileSize,
    required this.documentType,
    required this.uploadedById,
    this.uploadedBy,
    required this.isPublic,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      fileUrl: json['fileUrl'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int?,
      // Use the static helper to handle case-insensitive mapping
      documentType:
          DocumentType.fromJson(json['documentType'] as String? ?? 'OTHER'),
      uploadedById: json['uploadedById'] as String,
      uploadedBy:
          json['uploadedBy'] != null ? User.fromJson(json['uploadedBy']) : null,
      isPublic: json['isPublic'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      // Convert back to UPPERCASE for the API
      'documentType': documentType.toJson(),
      'uploadedById': uploadedById,
      'uploadedBy': uploadedBy?.toJson(),
      'isPublic': isPublic,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'Document(id: $id, title: $title, projectId: $projectId)';
}
