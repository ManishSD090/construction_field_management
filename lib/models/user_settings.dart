import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/models/role.dart';
import 'package:construction_erp/models/company.dart';

class User {
  final String id;

  // --- Multi-Tenancy Link ---
  final String? companyId;
  final Company? company;

  final String roleId;
  final Role? role;

  final UserType userType;

  // Login Credentials
  final String? email;
  final String phone;
  final String password;
  final String? employeeId;

  final String name;

  // Professional Details
  final String? designation;
  final String? department;
  final EmployeeStatus employeeStatus;

  // Attendance Settings
  final AttendanceLocation defaultLocation;

  final SalaryType salaryType;
  final double? salary;
  final double? hourlyRate;

  // Personal Details
  final DateTime? dateOfBirth;
  final DateTime? dateOfJoining;
  final String? address;
  final String? emergencyContact;
  final String? emergencyPhone;

  // Identification
  final String? profilePicture;
  final String? aadharNumber;
  final String? panNumber;
  final String? bankAccount;
  final String? ifscCode;

  // Auth Meta
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
      company: json['company'] != null ? Company.fromJson(json['company']) : null,
      roleId: json['roleId'] as String,
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      userType: UserType.values.byName(json['userType'] as String? ?? 'EMPLOYEE'),
      email: json['email'] as String?,
      phone: json['phone'] as String,
      password: json['password'] as String,
      employeeId: json['employeeId'] as String?,
      name: json['name'] as String,
      designation: json['designation'] as String?,
      department: json['department'] as String?,
      employeeStatus: EmployeeStatus.values.byName(json['employeeStatus'] as String? ?? 'ACTIVE'),
      defaultLocation: AttendanceLocation.values.byName(json['defaultLocation'] as String? ?? 'OFFICE'),
      salaryType: SalaryType.values.byName(json['salaryType'] as String? ?? 'MONTHLY'),
      salary: json['salary'] != null ? (json['salary'] as num).toDouble() : null,
      hourlyRate: json['hourlyRate'] != null ? (json['hourlyRate'] as num).toDouble() : null,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      dateOfJoining: json['dateOfJoining'] != null ? DateTime.parse(json['dateOfJoining']) : null,
      address: json['address'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      emergencyPhone: json['emergencyPhone'] as String?,
      profilePicture: json['profilePicture'] as String?,
      aadharNumber: json['aadharNumber'] as String?,
      panNumber: json['panNumber'] as String?,
      bankAccount: json['bankAccount'] as String?,
      ifscCode: json['ifscCode'] as String?,
      refreshToken: json['refreshToken'] as String?,
      resetPasswordToken: json['resetPasswordToken'] as String?,
      resetPasswordExpiry: json['resetPasswordExpiry'] != null ? DateTime.parse(json['resetPasswordExpiry']) : null,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'] as String?,
      createdBy: json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      settings: json['settings'] != null ? UserSettings.fromJson(json['settings']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'company': company?.toJson(),
      'roleId': roleId,
      'role': role?.toJson(),
      'userType': userType.name,
      'email': email,
      'phone': phone,
      'password': password,
      'employeeId': employeeId,
      'name': name,
      'designation': designation,
      'department': department,
      'employeeStatus': employeeStatus.name,
      'defaultLocation': defaultLocation.name,
      'salaryType': salaryType.name,
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

  @override
  String toString() => 'User(id: $id, name: $name, email: $email, phone: $phone)';
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

  @override
  String toString() => 'UserSettings(userId: $userId, theme: $theme, language: $language)';
}
