// Import from new organized model files
import 'package:construction_erp/models/index.dart';

// Legacy UserModel - Use User from user_settings.dart instead
// This file is kept for backward compatibility during migration
class UserModel {
  final String id;
  final String? companyId;
  final Role? role;
  final String roleId;

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

  final String? refreshToken;
  final String? resetPasswordToken;
  final DateTime? resetPasswordExpiry;
  final DateTime? lastLogin;

  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? createdById;

  final UserSettings? settings;

  // --- Relations ---
  final List<UserModel>? createdUsers;

  final List<Task>? createdTasks;
  final List<Task>? assignedTasks;
  final List<TaskComment>? taskComments;
  final List<TaskAttachment>? taskAttachments;

  final List<Attendance>? attendances;
  final List<Attendance>? markedAttendances;
  final List<Leave>? leaves;
  final List<Leave>? approvedLeaves;

  final List<DailyProgressReport>? preparedDPRs;
  final List<DailyProgressReport>? approvedDPRs;
  final List<DPRPhoto>? dprPhotos;

  final List<Expense>? createdExpenses;
  final List<Expense>? approvedExpenses;
  final List<Invoice>? createdInvoices;
  final List<Invoice>? approvedInvoices;
  final List<Payment>? createdPayments;
  final List<Payment>? paymentsReceived;

  final List<Material>? createdMaterials;
  final List<MaterialRequest>? materialRequests;
  final List<MaterialRequest>? approvedMaterials;
  final List<MaterialRequest>? orderedMaterials;
  final List<StockTransaction>? stockTransactions;

  final List<Message>? sentMessages;
  final List<Message>? receivedMessages;
  final List<Notification>? notifications;

  final List<Document>? documentsUploaded;

  final List<RolePermission>? grantedPermissions;
  final List<AuditLog>? auditLogs;

  final List<Client>? createdClients;
  final List<Project>? createdProjects;
  final List<Company>? createdCompanies;

  final List<Subtask>? subtasks;
  final List<Milestone>? milestones;

  UserModel({
    required this.id,
    this.companyId,
    this.role,
    required this.roleId,
    this.userType = UserType.EMPLOYEE,
    this.email,
    required this.phone,
    required this.password,
    this.employeeId,
    required this.name,
    this.designation,
    this.department,
    this.employeeStatus = EmployeeStatus.ACTIVE,
    this.defaultLocation = AttendanceLocation.OFFICE,
    this.salaryType = SalaryType.MONTHLY,
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
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.settings,
    this.createdUsers,
    this.createdTasks,
    this.assignedTasks,
    this.taskComments,
    this.taskAttachments,
    this.attendances,
    this.markedAttendances,
    this.leaves,
    this.approvedLeaves,
    this.preparedDPRs,
    this.approvedDPRs,
    this.dprPhotos,
    this.createdExpenses,
    this.approvedExpenses,
    this.createdInvoices,
    this.approvedInvoices,
    this.createdPayments,
    this.paymentsReceived,
    this.createdMaterials,
    this.materialRequests,
    this.approvedMaterials,
    this.orderedMaterials,
    this.stockTransactions,
    this.sentMessages,
    this.receivedMessages,
    this.notifications,
    this.documentsUploaded,
    this.grantedPermissions,
    this.auditLogs,
    this.createdClients,
    this.createdProjects,
    this.createdCompanies,
    this.subtasks,
    this.milestones,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      companyId: json['companyId'] as String?,
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
      settings: json['settings'] != null ? UserSettings.fromJson(json['settings']) : null,
    );
  }

  List<Permission> get permissions => role?.permissions ?? [];

  bool can(String code) =>
      role?.isSystemAdmin ?? false || permissions.any((p) => p.code == code);

  bool canAny(List<String> codes) =>
      role?.isSystemAdmin ?? false || permissions.any((p) => codes.contains(p.code));

  void initPermissionManager() {
    PermissionManager.initFromModels(permissions);
  }
}
