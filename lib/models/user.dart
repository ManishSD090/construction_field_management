import 'package:construction_erp/models/role.dart';
import 'package:construction_erp/models/company.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/models/project.dart'; // Make sure this path matches your project structure

class User {
  final String id;
  final String? companyId;
  final Company? company;
  final String roleId;
  final Role? role;
  final UserType userType;

  final String? email;
  final String phone;
  final String? password;
  final String? employeeId;
  final String name;

  final String? designation;
  final String? department;
  final EmployeeStatus employeeStatus;

  final AttendanceLocation defaultLocation;

  final SalaryType salaryType;
  final double? salary;
  final double? hourlyRate;

  final DateTime? dateOfBirth;
  final DateTime? dateOfJoining;
  final String? address;
  final String? emergencyContact;
  final String? emergencyPhone;

  final String? profilePicture;
  final String? aadharNumber;
  final String? panNumber;
  final String? bankAccount;
  final String? ifscCode;

  final String? accessToken;
  final String? refreshToken;
  final String? resetPasswordToken;
  final DateTime? resetPasswordExpiry;
  final bool? accountSetupCompleted;
  final DateTime? lastLogin;

  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? createdById;
  final User? createdBy;

  final UserSettings? settings;
  final List<String>? permissions;
  final UserStats? stats;

  // NEW: Added projectAssignments field
  final List<ProjectAssignment>? projectAssignments;

  User({
    required this.id,
    this.companyId,
    this.company,
    required this.roleId,
    this.role,
    required this.userType,
    this.email,
    required this.phone,
    this.password,
    this.employeeId,
    required this.name,
    this.designation,
    this.department,
    required this.employeeStatus,
    required this.defaultLocation,
    required this.salaryType,
    this.salary,
    this.hourlyRate,
    this.dateOfBirth,
    this.dateOfJoining,
    this.address,
    this.emergencyContact,
    this.emergencyPhone,
    this.profilePicture,
    this.aadharNumber,
    this.panNumber,
    this.bankAccount,
    this.ifscCode,
    this.accessToken,
    this.refreshToken,
    this.resetPasswordToken,
    this.resetPasswordExpiry,
    this.accountSetupCompleted,
    this.lastLogin,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.createdById,
    this.createdBy,
    this.settings,
    this.permissions,
    this.stats,
    this.projectAssignments, // NEW
  });

  User copyWith({
    String? id,
    String? companyId,
    Company? company,
    String? roleId,
    Role? role,
    UserType? userType,
    String? email,
    String? phone,
    String? password,
    String? employeeId,
    String? name,
    String? designation,
    String? department,
    EmployeeStatus? employeeStatus,
    AttendanceLocation? defaultLocation,
    SalaryType? salaryType,
    double? salary,
    double? hourlyRate,
    DateTime? dateOfBirth,
    DateTime? dateOfJoining,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
    String? profilePicture,
    String? aadharNumber,
    String? panNumber,
    String? bankAccount,
    String? ifscCode,
    String? accessToken,
    String? refreshToken,
    String? resetPasswordToken,
    DateTime? resetPasswordExpiry,
    bool? accountSetupCompleted,
    DateTime? lastLogin,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdById,
    User? createdBy,
    UserSettings? settings,
    List<String>? permissions,
    UserStats? stats,
    List<ProjectAssignment>? projectAssignments, // NEW
  }) {
    return User(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      company: company ?? this.company,
      roleId: roleId ?? this.roleId,
      role: role ?? this.role,
      userType: userType ?? this.userType,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      employeeStatus: employeeStatus ?? this.employeeStatus,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      salaryType: salaryType ?? this.salaryType,
      salary: salary ?? this.salary,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      dateOfJoining: dateOfJoining ?? this.dateOfJoining,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      profilePicture: profilePicture ?? this.profilePicture,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      panNumber: panNumber ?? this.panNumber,
      bankAccount: bankAccount ?? this.bankAccount,
      ifscCode: ifscCode ?? this.ifscCode,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      resetPasswordToken: resetPasswordToken ?? this.resetPasswordToken,
      resetPasswordExpiry: resetPasswordExpiry ?? this.resetPasswordExpiry,
      accountSetupCompleted:
          accountSetupCompleted ?? this.accountSetupCompleted,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      settings: settings ?? this.settings,
      permissions: permissions ?? this.permissions,
      stats: stats ?? this.stats,
      projectAssignments: projectAssignments ?? this.projectAssignments, // NEW
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    List<String>? extractPermissions() {
      if (json['role'] != null && json['role']['permissions'] != null) {
        return List<String>.from(json['role']['permissions']);
      }
      if (json['permissions'] != null) {
        return List<String>.from(json['permissions']);
      }
      return null;
    }

    return User(
      id: json['id']?.toString() ?? '',
      companyId: json['company']?['id']?.toString(),
      company:
          json['company'] != null ? Company.fromJson(json['company']) : null,
      roleId: json['role']?['id']?.toString() ?? '',
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      userType: UserType.fromJson(json['userType']?.toString() ?? 'EMPLOYEE'),
      email: json['email']?.toString(),
      phone: json['phone']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      employeeId: json['employeeId']?.toString(),
      name: json['name']?.toString() ?? '',
      designation: json['designation']?.toString(),
      department: json['department']?.toString(),
      employeeStatus: EmployeeStatus.fromJson(
        json['employeeStatus']?.toString() ?? 'ACTIVE',
      ),
      defaultLocation: AttendanceLocation.values.byName(
        (json['defaultLocation']?.toString() ?? 'OFFICE').toLowerCase(),
      ),
      salaryType:
          SalaryType.fromJson(json['salaryType']?.toString() ?? 'MONTHLY'),
      salary: (json['salary'] as num?)?.toDouble(),
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      dateOfJoining: json['dateOfJoining'] != null
          ? DateTime.parse(json['dateOfJoining'])
          : null,
      address: json['address']?.toString(),
      emergencyContact: json['emergencyContact']?.toString(),
      emergencyPhone: json['emergencyPhone']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      aadharNumber: json['aadharNumber']?.toString(),
      panNumber: json['panNumber']?.toString(),
      bankAccount: json['bankAccount']?.toString(),
      ifscCode: json['ifscCode']?.toString(),
      accessToken: json['accessToken']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
      resetPasswordToken: json['resetPasswordToken']?.toString(),
      resetPasswordExpiry: json['resetPasswordExpiry'] != null
          ? DateTime.parse(json['resetPasswordExpiry'])
          : null,
      accountSetupCompleted: json['accountSetupCompleted'] != null
          ? json['accountSetupCompleted'] as bool? ?? true
          : null,
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdById: json['createdById']?.toString(),
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'])
          : null,
      permissions: extractPermissions(),
      stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
      // NEW: Parse projectAssignments
      projectAssignments: json['projectAssignments'] != null
          ? (json['projectAssignments'] as List)
              .map((e) => ProjectAssignment.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'company': company?.toJson(),
      'roleId': roleId,
      'role': role?.toJson(),
      'userType': userType.toJson(),
      'email': email,
      'phone': phone,
      'password': password,
      'employeeId': employeeId,
      'name': name,
      'designation': designation,
      'department': department,
      'employeeStatus': employeeStatus.toJson(),
      'defaultLocation': defaultLocation.name.toUpperCase(),
      'salaryType': salaryType.toJson(),
      'salary': salary,
      'hourlyRate': hourlyRate,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'dateOfJoining': dateOfJoining?.toIso8601String(),
      'address': address,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'profilePicture': profilePicture,
      'aadharNumber': aadharNumber,
      'panNumber': panNumber,
      'bankAccount': bankAccount,
      'ifscCode': ifscCode,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'resetPasswordToken': resetPasswordToken,
      'resetPasswordExpiry': resetPasswordExpiry?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
      'settings': settings?.toJson(),
      'permissions': permissions,
      'stats': stats?.toJson(),
      // NEW: Serialize projectAssignments
      'projectAssignments': projectAssignments?.map((e) => e.toJson()).toList(),
    };
  }
}

// ... existing code ...
class UserSettings {
  final String? id;
  final String userId;
  final User? user;
  final String? theme;
  final String? language;
  final Map<String, dynamic>? notifications;
  final Map<String, dynamic>? dashboardLayout;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserSettings({
    this.id,
    required this.userId,
    this.user,
    this.theme,
    this.language,
    this.notifications,
    this.dashboardLayout,
    this.createdAt,
    this.updatedAt,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id']?.toString(),
      userId: json['userId']?.toString() ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      theme: json['theme']?.toString() ?? 'light',
      language: json['language']?.toString() ?? 'en',
      notifications: json['notifications'] != null
          ? Map<String, dynamic>.from(json['notifications'])
          : null,
      dashboardLayout: json['dashboardLayout'] != null
          ? Map<String, dynamic>.from(json['dashboardLayout'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'user': user?.toJson(),
      'theme': theme,
      'language': language,
      'notifications': notifications,
      'dashboardLayout': dashboardLayout,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class UserState {
  final User? currentUser;
  final List<User> userList;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  UserState({
    this.currentUser,
    this.userList = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  UserState copyWith({
    User? currentUser,
    List<User>? userList,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return UserState(
      currentUser: currentUser ?? this.currentUser,
      userList: userList ?? this.userList,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class UserStats {
  final int projects;
  final int tasks;
  final int attendanceLast30Days;
  final int? unreadNotifications;
  final int? upcomingLeaves;

  UserStats({
    this.projects = 0,
    this.tasks = 0,
    this.attendanceLast30Days = 0,
    this.unreadNotifications,
    this.upcomingLeaves,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      projects: json['projects'] as int? ?? 0,
      tasks: json['tasks'] as int? ?? 0,
      attendanceLast30Days: json['attendanceLast30Days'] as int? ?? 0,
      unreadNotifications: json['unreadNotifications'] as int?,
      upcomingLeaves: json['upcomingLeaves'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projects': projects,
      'tasks': tasks,
      'attendanceLast30Days': attendanceLast30Days,
      'unreadNotifications': unreadNotifications,
      'upcomingLeaves': upcomingLeaves,
    };
  }

  UserStats copyWith({
    int? projects,
    int? tasks,
    int? attendanceLast30Days,
    int? unreadNotifications,
    int? upcomingLeaves,
  }) {
    return UserStats(
      projects: projects ?? this.projects,
      tasks: tasks ?? this.tasks,
      attendanceLast30Days: attendanceLast30Days ?? this.attendanceLast30Days,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      upcomingLeaves: upcomingLeaves ?? this.upcomingLeaves,
    );
  }
}

// NEW: Added ProjectAssignment class based on the API response structure
class ProjectAssignment {
  final String id;
  final String userId;
  final String projectId;
  final String roleId;
  final String? designation;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isPrimary;
  final Project? project;
  final Role? role;

  ProjectAssignment({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.roleId,
    this.designation,
    this.startDate,
    this.endDate,
    this.isPrimary,
    this.project,
    this.role,
  });

  factory ProjectAssignment.fromJson(Map<String, dynamic> json) {
    return ProjectAssignment(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      roleId: json['roleId']?.toString() ?? '',
      designation: json['designation']?.toString(),
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isPrimary: json['isPrimary'] as bool?,
      project:
          json['project'] != null ? Project.fromJson(json['project']) : null,
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'projectId': projectId,
      'roleId': roleId,
      'designation': designation,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isPrimary': isPrimary,
      'project': project?.toJson(),
      'role': role?.toJson(),
    };
  }
}
