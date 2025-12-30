import 'package:construction_erp/models/user.dart';

class Company {
  final String id;
  final String name;
  final String? registrationNumber;
  final String? gstNumber;

  // --- Office Location (For Office Staff Attendance) ---
  final String? officeAddress;
  final double? officeLatitude;
  final double? officeLongitude;
  final double officeGeofence; // Radius in meters

  // Contact & Branding
  final String? phone;
  final String? email;
  final String? website;
  final String? logo;

  // Banking
  final String? bankName;
  final String? bankAccount;
  final String? bankIfsc;
  final String? bankBranch;

  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? createdById;
  final User? createdBy;

  final CompanySettings? settings;

  Company({
    required this.id,
    required this.name,
    this.registrationNumber,
    this.gstNumber,
    this.officeAddress,
    this.officeLatitude,
    this.officeLongitude,
    this.officeGeofence = 100,
    this.phone,
    this.email,
    this.website,
    this.logo,
    this.bankName,
    this.bankAccount,
    this.bankIfsc,
    this.bankBranch,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.createdBy,
    this.settings,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      name: json['name'] as String,
      registrationNumber: json['registrationNumber'] as String?,
      gstNumber: json['gstNumber'] as String?,
      officeAddress: json['officeAddress'] as String?,
      officeLatitude: json['officeLatitude'] != null
          ? (json['officeLatitude'] as num).toDouble()
          : null,
      officeLongitude: json['officeLongitude'] != null
          ? (json['officeLongitude'] as num).toDouble()
          : null,
      officeGeofence: json['officeGeofence'] != null
          ? (json['officeGeofence'] as num).toDouble()
          : 100,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      logo: json['logo'] as String?,
      bankName: json['bankName'] as String?,
      bankAccount: json['bankAccount'] as String?,
      bankIfsc: json['bankIfsc'] as String?,
      bankBranch: json['bankBranch'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'] as String?,
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      settings: json['settings'] != null
          ? CompanySettings.fromJson(json['settings'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'registrationNumber': registrationNumber,
      'gstNumber': gstNumber,
      'officeAddress': officeAddress,
      'officeLatitude': officeLatitude,
      'officeLongitude': officeLongitude,
      'officeGeofence': officeGeofence,
      'phone': phone,
      'email': email,
      'website': website,
      'logo': logo,
      'bankName': bankName,
      'bankAccount': bankAccount,
      'bankIfsc': bankIfsc,
      'bankBranch': bankBranch,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
      'settings': settings?.toJson(),
    };
  }

  @override
  String toString() => 'Company(id: $id, name: $name, email: $email)';
}

class CompanySettings {
  final String id;
  final String companyId;
  final Company? company;
  final String? currency;
  final double? taxPercent;
  final double? workingHours;
  final double? overtimeRate;
  final int? casualLeaves;
  final int? sickLeaves;
  final int? earnedLeaves;
  final String? projectPrefix;
  final String? invoicePrefix;
  final String? dprPrefix;
  final String? materialPrefix;
  final bool enableStockAlerts;
  final double? lowStockThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanySettings({
    required this.id,
    required this.companyId,
    this.company,
    this.currency,
    this.taxPercent,
    this.workingHours,
    this.overtimeRate,
    this.casualLeaves,
    this.sickLeaves,
    this.earnedLeaves,
    this.projectPrefix,
    this.invoicePrefix,
    this.dprPrefix,
    this.materialPrefix,
    required this.enableStockAlerts,
    this.lowStockThreshold,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanySettings.fromJson(Map<String, dynamic> json) {
    return CompanySettings(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      company:
          json['company'] != null ? Company.fromJson(json['company']) : null,
      currency: json['currency'] as String? ?? 'INR',
      taxPercent: json['taxPercent'] != null
          ? (json['taxPercent'] as num).toDouble()
          : 18,
      workingHours: json['workingHours'] != null
          ? (json['workingHours'] as num).toDouble()
          : 8,
      overtimeRate: json['overtimeRate'] != null
          ? (json['overtimeRate'] as num).toDouble()
          : 1.5,
      casualLeaves: json['casualLeaves'] as int? ?? 12,
      sickLeaves: json['sickLeaves'] as int? ?? 12,
      earnedLeaves: json['earnedLeaves'] as int? ?? 15,
      projectPrefix: json['projectPrefix'] as String? ?? 'PROJ',
      invoicePrefix: json['invoicePrefix'] as String? ?? 'INV',
      dprPrefix: json['dprPrefix'] as String? ?? 'DPR',
      materialPrefix: json['materialPrefix'] as String? ?? 'MAT',
      enableStockAlerts: json['enableStockAlerts'] as bool? ?? true,
      lowStockThreshold: json['lowStockThreshold'] != null
          ? (json['lowStockThreshold'] as num).toDouble()
          : 10,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'company': company?.toJson(),
      'currency': currency,
      'taxPercent': taxPercent,
      'workingHours': workingHours,
      'overtimeRate': overtimeRate,
      'casualLeaves': casualLeaves,
      'sickLeaves': sickLeaves,
      'earnedLeaves': earnedLeaves,
      'projectPrefix': projectPrefix,
      'invoicePrefix': invoicePrefix,
      'dprPrefix': dprPrefix,
      'materialPrefix': materialPrefix,
      'enableStockAlerts': enableStockAlerts,
      'lowStockThreshold': lowStockThreshold,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'CompanySettings(companyId: $companyId, currency: $currency)';
}
