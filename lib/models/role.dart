import 'package:construction_erp/models/permission.dart';

class RolePermission {
  final String id;
  final String roleId;
  final String permissionId;
  final Map<String, dynamic>? constraints;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? grantedById;

  // The actual permission definition
  final Permission? permission;

  RolePermission({
    required this.id,
    required this.roleId,
    required this.permissionId,
    this.constraints,
    required this.createdAt,
    required this.updatedAt,
    this.grantedById,
    this.permission,
  });

  factory RolePermission.fromJson(Map<String, dynamic> json) {
    return RolePermission(
      id: json['id'] as String,
      roleId: json['roleId'] as String,
      permissionId: json['permissionId'] as String,
      // Handle Prisma Json type as a Map in Dart
      constraints: json['constraints'] != null
          ? Map<String, dynamic>.from(json['constraints'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      grantedById: json['grantedById'] as String?,
      // Map the nested permission object if it exists in the query result
      permission: json['permission'] != null
          ? Permission.fromJson(json['permission'])
          : null,
    );
  }
}

class Role {
  final String id;
  final String name;
  final String? description;
  final String? companyId;
  final bool isSystemAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdById;

  final List<RolePermission> rolePermissions;

  Role({
    required this.id,
    required this.name,
    this.description,
    this.companyId,
    required this.isSystemAdmin,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.rolePermissions = const [],
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      companyId: json['companyId'] as String?,
      isSystemAdmin: json['isSystemAdmin'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'] as String?,
      rolePermissions: json['rolePermissions'] != null
          ? (json['rolePermissions'] as List)
              .map((rp) => RolePermission.fromJson(rp))
              .toList()
          : [],
    );
  }

  List<Permission> get permissions => rolePermissions
      .where((rp) => rp.permission != null)
      .map((rp) => rp.permission!)
      .toList();

  @override
  String toString() =>
      'Role(name: $name, permissionsCount: ${rolePermissions.length})';
}
