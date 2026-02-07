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

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      // Use null-aware operators and defaults to prevent crashes
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      module: json['module']?.toString() ?? 'General',
      description: json['description']?.toString(),
      category: json['category']?.toString(),

      // tryParse prevents crashes if the date string is null or malformed
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

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
    _allPermissions = List.from(permissions);
    _userPermissionCodes = permissions.map((p) => p.code).toSet();
  }

  static void initFromCodes(List<String>? codes) {
    if (codes == null) {
      _userPermissionCodes = {};
    } else {
      _userPermissionCodes = codes.toSet();
    }
  }

  static bool can(String code) => _userPermissionCodes.contains(code);

  static bool canAny(List<String> codes) =>
      codes.any((c) => _userPermissionCodes.contains(c));

  static Set<String> get activePermissionCodes => _userPermissionCodes;

  static List<Permission> get allPermissions => _allPermissions;

  static void clear() {
    _userPermissionCodes.clear();
    _allPermissions.clear();
  }
}
