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
      constraints: json['constraints'] != null
          ? Map<String, dynamic>.from(json['constraints'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      grantedById: json['grantedById'] as String?,
      permission: json['permission'] != null
          ? Permission.fromJson(json['permission'])
          : null,
    );
  }

  /// Converts the RolePermission instance into a Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleId': roleId,
      'permissionId': permissionId,
      // Map<String, dynamic> is natively supported by json.encode
      'constraints': constraints,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'grantedById': grantedById,
      // Only include the permission JSON if the object is present
      'permission': permission?.toJson(),
    };
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

  /// Converts the Role instance into a Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'companyId': companyId,
      'isSystemAdmin': isSystemAdmin,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdById': createdById,
      // Map each RolePermission object back to JSON
      'rolePermissions': rolePermissions.map((rp) => rp.toJson()).toList(),
    };
  }

  List<Permission> get permissions => rolePermissions
      .where((rp) => rp.permission != null)
      .map((rp) => rp.permission!)
      .toList();

  @override
  String toString() =>
      'Role(name: $name, permissionsCount: ${rolePermissions.length})';
}
