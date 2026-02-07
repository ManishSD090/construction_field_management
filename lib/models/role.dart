import 'package:construction_erp/models/permission.dart';

class RolePermission {
  final String? id;
  final String? roleId;
  final String? permissionId;
  final Map<String, dynamic>? constraints;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? grantedById;
  final Permission? permission;

  RolePermission({
    this.id,
    this.roleId,
    this.permissionId,
    this.constraints,
    this.createdAt,
    this.updatedAt,
    this.grantedById,
    this.permission,
  });

  factory RolePermission.fromJson(Map<String, dynamic> json) {
    return RolePermission(
      id: json['id']?.toString(),
      roleId: json['roleId']?.toString(),
      permissionId: json['permissionId']?.toString(),
      constraints: json['constraints'] != null
          ? Map<String, dynamic>.from(json['constraints'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      grantedById: json['grantedById']?.toString(),
      permission: json['permission'] != null
          ? Permission.fromJson(json['permission'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleId': roleId,
      'permissionId': permissionId,
      'constraints': constraints,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'grantedById': grantedById,
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
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdById;
  final List<RolePermission> rolePermissions;
  final Map<String, dynamic>? stats;

  Role({
    required this.id,
    required this.name,
    this.description,
    this.companyId,
    required this.isSystemAdmin,
    this.createdAt,
    this.updatedAt,
    this.createdById,
    this.rolePermissions = const [],
    this.stats,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    // 1. Handle Permissions logic
    // The log shows the key is "permissions"
    final permissionsData = json['rolePermissions'] ?? json['permissions'];
    List<RolePermission> parsedPermissions = [];

    if (permissionsData != null && permissionsData is List) {
      for (var item in permissionsData) {
        if (item is Map<String, dynamic>) {
          // If the object contains 'code', it's a Permission object
          if (item.containsKey('code')) {
            parsedPermissions.add(RolePermission(
              id: item['id']?.toString() ?? '',
              roleId: json['id']?.toString(),
              permission: Permission.fromJson(item),
            ));
          } else {
            parsedPermissions.add(RolePermission.fromJson(item));
          }
        }
      }
    }

    return Role(
      // CRITICAL: Ensure required strings have defaults
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Role',
      description: json['description']?.toString(),
      companyId: json['companyId']?.toString(),
      isSystemAdmin: json['isSystemAdmin'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      createdById: json['createdById']?.toString(),
      rolePermissions: parsedPermissions,
      stats: json['stats'] != null
          ? Map<String, dynamic>.from(json['stats'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'companyId': companyId,
      'isSystemAdmin': isSystemAdmin,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdById': createdById,
      'rolePermissions': rolePermissions.map((rp) => rp.toJson()).toList(),
      'stats': stats,
    };
  }

  List<Permission> get permissions => rolePermissions
      .where((rp) => rp.permission != null)
      .map((rp) => rp.permission!)
      .toList();

  Role copyWith({
    String? id,
    String? name,
    String? description,
    bool? isSystemAdmin,
    List<RolePermission>? rolePermissions,
    Map<String, dynamic>? stats,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isSystemAdmin: isSystemAdmin ?? this.isSystemAdmin,
      rolePermissions: rolePermissions ?? this.rolePermissions,
      stats: stats ?? this.stats,
      companyId: companyId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdById: createdById,
    );
  }
}

class RoleState {
  final List<Role> roles;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  RoleState({
    this.roles = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  RoleState copyWith({
    List<Role>? roles,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return RoleState(
      roles: roles ?? this.roles,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
