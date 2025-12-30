import 'package:construction_erp/models/user.dart';

class AuditLog {
  final String id;
  final String? userId;
  final User? user;
  final String action;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;
  final DateTime timestamp;

  AuditLog({
    required this.id,
    this.userId,
    this.user,
    required this.action,
    required this.entityType,
    this.entityId,
    this.oldData,
    this.newData,
    required this.timestamp,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      action: json['action'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String?,
      oldData: json['oldData'] != null
          ? Map<String, dynamic>.from(json['oldData'])
          : null,
      newData: json['newData'] != null
          ? Map<String, dynamic>.from(json['newData'])
          : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'user': user?.toJson(),
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'oldData': oldData,
      'newData': newData,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // ================= HELPER METHODS =================

  // Create a log for creation action
  static AuditLog createLog({
    required String id,
    String? userId,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? newData,
  }) {
    return AuditLog(
      id: id,
      userId: userId,
      action: 'CREATE',
      entityType: entityType,
      entityId: entityId,
      oldData: null,
      newData: newData,
      timestamp: DateTime.now(),
    );
  }

  // Create a log for update action
  static AuditLog updateLog({
    required String id,
    String? userId,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  }) {
    return AuditLog(
      id: id,
      userId: userId,
      action: 'UPDATE',
      entityType: entityType,
      entityId: entityId,
      oldData: oldData,
      newData: newData,
      timestamp: DateTime.now(),
    );
  }

  // Create a log for delete action
  static AuditLog deleteLog({
    required String id,
    String? userId,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? oldData,
  }) {
    return AuditLog(
      id: id,
      userId: userId,
      action: 'DELETE',
      entityType: entityType,
      entityId: entityId,
      oldData: oldData,
      newData: null,
      timestamp: DateTime.now(),
    );
  }

  // Pretty print log for debugging
  @override
  String toString() {
    return toJson().toString();
  }
}
