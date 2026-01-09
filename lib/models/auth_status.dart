class AuthActionStatus {
  final bool needsPassword;
  final bool needsVerification;
  final bool emailVerified;
  final bool phoneVerified;
  final String accountStatus; // 'SETUP_REQUIRED', 'ACTIVE', 'INACTIVE'
  final String? email;
  final String? phone;

  AuthActionStatus({
    required this.needsPassword,
    required this.needsVerification,
    required this.emailVerified,
    required this.phoneVerified,
    required this.accountStatus,
    this.email,
    this.phone,
  });

  factory AuthActionStatus.fromJson(Map<String, dynamic> json) {
    return AuthActionStatus(
      needsPassword: json['needsPassword'] ?? false,
      needsVerification: json['needsVerification'] ?? false,
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      accountStatus: json['accountStatus'] ?? 'INACTIVE',
      email: json['email'],
      phone: json['phone'],
    );
  }

  // Helper to know if we are good to go
  bool get isFullyActive =>
      !needsPassword && !needsVerification && accountStatus == 'ACTIVE';
}
