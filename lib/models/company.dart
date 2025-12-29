class CompanySettings {
  final String id;
  final String companyId;

  final String currency;
  final double taxPercent;
  final double workingHours;
  final double overtimeRate;

  final int casualLeaves;
  final int sickLeaves;
  final int earnedLeaves;

  final String projectPrefix;
  final String invoicePrefix;
  final String dprPrefix;
  final String materialPrefix;

  final bool enableStockAlerts;
  final double lowStockThreshold;

  final DateTime createdAt;
  final DateTime updatedAt;

  CompanySettings({
    required this.id,
    required this.companyId,
    required this.currency,
    required this.taxPercent,
    required this.workingHours,
    required this.overtimeRate,
    required this.casualLeaves,
    required this.sickLeaves,
    required this.earnedLeaves,
    required this.projectPrefix,
    required this.invoicePrefix,
    required this.dprPrefix,
    required this.materialPrefix,
    required this.enableStockAlerts,
    required this.lowStockThreshold,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanySettings.fromJson(Map<String, dynamic> json) {
    return CompanySettings(
      id: json['id'],
      companyId: json['companyId'],
      currency: json['currency'] ?? 'INR',
      taxPercent: (json['taxPercent'] ?? 18).toDouble(),
      workingHours: (json['workingHours'] ?? 8).toDouble(),
      overtimeRate: (json['overtimeRate'] ?? 1.5).toDouble(),
      casualLeaves: json['casualLeaves'] ?? 12,
      sickLeaves: json['sickLeaves'] ?? 12,
      earnedLeaves: json['earnedLeaves'] ?? 15,
      projectPrefix: json['projectPrefix'] ?? 'PROJ',
      invoicePrefix: json['invoicePrefix'] ?? 'INV',
      dprPrefix: json['dprPrefix'] ?? 'DPR',
      materialPrefix: json['materialPrefix'] ?? 'MAT',
      enableStockAlerts: json['enableStockAlerts'] ?? true,
      lowStockThreshold: (json['lowStockThreshold'] ?? 10).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
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

  // ================= HELPER METHODS =================

  // Generate prefixed IDs for projects, invoices, DPRs, materials
  String projectId(String number) => '$projectPrefix-$number';
  String invoiceId(String number) => '$invoicePrefix-$number';
  String dprId(String number) => '$dprPrefix-$number';
  String materialId(String number) => '$materialPrefix-$number';

  // Check if stock alerts are enabled
  bool isStockAlertEnabled() => enableStockAlerts;
}

class Company {
  final String id;
  final String name;
  final String? registrationNumber;
  final String? gstNumber;

  final String? officeAddress;
  final double? officeLatitude;
  final double? officeLongitude;
  final double officeGeofence;

  final String? phone;
  final String? email;
  final String? website;
  final String? logo;

  final String? bankName;
  final String? bankAccount;
  final String? bankIfsc;
  final String? bankBranch;

  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String? createdById;

  final CompanySettings? settings;

  Company({
    required this.id,
    required this.name,
    this.registrationNumber,
    this.gstNumber,
    this.officeAddress,
    this.officeLatitude,
    this.officeLongitude,
    required this.officeGeofence,
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
    this.settings,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      registrationNumber: json['registrationNumber'],
      gstNumber: json['gstNumber'],
      officeAddress: json['officeAddress'],
      officeLatitude: json['officeLatitude']?.toDouble(),
      officeLongitude: json['officeLongitude']?.toDouble(),
      officeGeofence: (json['officeGeofence'] ?? 100).toDouble(),
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      logo: json['logo'],
      bankName: json['bankName'],
      bankAccount: json['bankAccount'],
      bankIfsc: json['bankIfsc'],
      bankBranch: json['bankBranch'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'],
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
      'settings': settings?.toJson(),
    };
  }

  // ================= HELPER METHODS =================

  // Check if office coordinates exist
  bool hasOfficeLocation() {
    return officeLatitude != null && officeLongitude != null;
  }

  // Get a formatted office address with coordinates
  String officeInfo() {
    if (officeAddress != null) {
      return "$officeAddress (Lat: ${officeLatitude ?? '-'}, Lng: ${officeLongitude ?? '-'})";
    }
    return "Office info not available";
  }

  // Check if banking info is complete
  bool hasBankingDetails() {
    return bankName != null && bankAccount != null && bankIfsc != null;
  }

  // Check if GST and registration info exist
  bool hasLegalInfo() {
    return registrationNumber != null && gstNumber != null;
  }

  // Shortcut to generate project/invoice IDs using company settings
  String generateProjectId(String number) => settings?.projectId(number) ?? number;
  String generateInvoiceId(String number) => settings?.invoiceId(number) ?? number;
  String generateDPRId(String number) => settings?.dprId(number) ?? number;
  String generateMaterialId(String number) => settings?.materialId(number) ?? number;
}
