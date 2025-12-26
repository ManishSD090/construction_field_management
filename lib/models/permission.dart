class Permission {
  final String id;
  final String code;
  final String name;
  final String module;
  final String? description;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Permission({
    required this.id,
    required this.code,
    required this.name,
    required this.module,
    this.description,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a Permission object from JSON (Prisma API response)
  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      module: json['module'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Method to convert Permission object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'module': module,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Permission(code: $code, name: $name, module: $module)';
  }
}

class PermissionManager {
  static Set<String> _userPermissionCodes = {};
  static List<Permission> _allPermissions = [];

  static void initFromModels(List<Permission> permissions) {
    _allPermissions = permissions;
    _userPermissionCodes = permissions.map((p) => p.code).toSet();
  }

  static void initFromCodes(List<String> codes) {
    _userPermissionCodes = codes.toSet();
  }

  /// Check if a user has a specific permission
  static bool can(String code) => _userPermissionCodes.contains(code);

  /// Check if user has ANY of the provided permissions
  static bool canAny(List<String> codes) =>
      codes.any((c) => _userPermissionCodes.contains(c));

  static List<Permission> get allPermissions => _allPermissions;

  static void clear() {
    _userPermissionCodes.clear();
    _allPermissions.clear();
  }
}
