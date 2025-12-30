import 'package:construction_erp/models/role.dart';
import 'package:construction_erp/models/company.dart';
import 'package:construction_erp/models/enums.dart';

class User {
  final String id;
  final String? companyId;
  final Company? company;
  final String roleId;
  final Role? role;
  final UserType userType;

  final String? email;
  final String phone;
  final String password;
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
  final DateTime? lastLogin;

  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? createdById;
  final User? createdBy;

  final UserSettings? settings;

  User({
    required this.id,
    this.companyId,
    this.company,
    required this.roleId,
    this.role,
    required this.userType,
    this.email,
    required this.phone,
    required this.password,
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
    this.lastLogin,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.createdBy,
    this.settings,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      companyId: json['companyId'] as String?,
      company:
          json['company'] != null ? Company.fromJson(json['company']) : null,
      roleId: json['roleId'] as String,
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      userType: UserType.fromJson(json['userType'] as String? ?? 'EMPLOYEE'),
      email: json['email'] as String?,
      phone: json['phone'] as String,
      password: json['password'] as String,
      employeeId: json['employeeId'] as String?,
      name: json['name'] as String,
      designation: json['designation'] as String?,
      department: json['department'] as String?,
      employeeStatus: EmployeeStatus.fromJson(
          json['employeeStatus'] as String? ?? 'ACTIVE'),
      defaultLocation: AttendanceLocation.values.byName(
          (json['defaultLocation'] as String? ?? 'OFFICE').toLowerCase()),
      salaryType:
          SalaryType.fromJson(json['salaryType'] as String? ?? 'MONTHLY'),
      salary: (json['salary'] as num?)?.toDouble(),
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      dateOfJoining: json['dateOfJoining'] != null
          ? DateTime.parse(json['dateOfJoining'])
          : null,
      address: json['address'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      emergencyPhone: json['emergencyPhone'] as String?,
      profilePicture: json['profilePicture'] as String?,
      aadharNumber: json['aadharNumber'] as String?,
      panNumber: json['panNumber'] as String?,
      bankAccount: json['bankAccount'] as String?,
      ifscCode: json['ifscCode'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      resetPasswordToken: json['resetPasswordToken'] as String?,
      resetPasswordExpiry: json['resetPasswordExpiry'] != null
          ? DateTime.parse(json['resetPasswordExpiry'])
          : null,
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'] as String?,
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'])
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
      'settings': settings?.toJson(),
    };
  }
}

class UserSettings {
  final String id;
  final String userId;
  final User? user;
  final String? theme;
  final String? language;
  final Map<String, dynamic>? notifications;
  final Map<String, dynamic>? dashboardLayout;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettings({
    required this.id,
    required this.userId,
    this.user,
    this.theme,
    this.language,
    this.notifications,
    this.dashboardLayout,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'] as String,
      userId: json['userId'] as String,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      theme: json['theme'] as String? ?? 'light',
      language: json['language'] as String? ?? 'en',
      notifications: json['notifications'] != null
          ? Map<String, dynamic>.from(json['notifications'])
          : null,
      dashboardLayout: json['dashboardLayout'] != null
          ? Map<String, dynamic>.from(json['dashboardLayout'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
