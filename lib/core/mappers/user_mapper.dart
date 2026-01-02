import 'package:construction_erp/database/database.dart'; // Import Drift classes
import 'package:construction_erp/models/index.dart';

// EXTENSION 1: UserEntity (DB) -> User (Domain)
extension UserEntityMapper on UserEntity {
  User toDomain() {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      // password: '',
      roleId: roleId,
      companyId: companyId,
      employeeId: employeeId,
      designation: designation,
      department: department,
      profilePicture: profilePicture,

      permissions: permissions ?? [],

      userType: UserType.fromJson(userType),
      employeeStatus: EmployeeStatus.fromJson(employeeStatus),
      defaultLocation: AttendanceLocation.fromJson(defaultLocation),
      salaryType: SalaryType.fromJson(salaryType),
      company: Company.fromJson({
        'id': companyId,
        'name': companyName,
      }),
      role: Role.fromJson({
        'id': roleId,
        'name': roleName,
        'isSystemAdmin': isSystemAdmin,
      }),
      settings: UserSettings.fromJson({
        'userId': id,
        'theme': theme,
        'language': language,
      }),
      lastLogin: lastLogin,
      isActive: true,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

// EXTENSION 2: User (Domain) -> UserEntity (DB)
extension UserDomainMapper on User {
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email ?? '',
      phone: phone,
      roleId: roleId,
      companyId: companyId,
      employeeId: employeeId,
      designation: designation,
      department: department,
      profilePicture: profilePicture,
      permissions: permissions ?? [],
      userType: userType.toJson(),
      employeeStatus: employeeStatus.toJson(),
      defaultLocation: defaultLocation.toJson(),
      salaryType: salaryType.toJson(),
      companyName: company?.name,
      roleName: role?.name,
      isSystemAdmin: role?.isSystemAdmin ?? false,
      theme: settings?.theme,
      language: settings?.language,
      lastLogin: lastLogin,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
