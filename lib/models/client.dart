import 'package:construction_erp/models/user_settings.dart';

class Client {
  final String id;
  final String companyId;

  final String companyName;
  final String contactPerson;
  final String? email;
  final String phone;
  final String? gstNumber;
  final String? address;

  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdById;
  final User? createdBy;

  Client({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.contactPerson,
    this.email,
    required this.phone,
    this.gstNumber,
    this.address,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.createdBy,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      companyName: json['companyName'] as String,
      contactPerson: json['contactPerson'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String,
      gstNumber: json['gstNumber'] as String?,
      address: json['address'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'] as String?,
      createdBy: json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'gstNumber': gstNumber,
      'address': address,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
    };
  }

  bool get hasGST => gstNumber != null && gstNumber!.isNotEmpty;

  bool get hasEmail => email != null && email!.isNotEmpty;

  bool get isDeactivated => !isActive;

  @override
  String toString() => 'Client(id: $id, companyName: $companyName, contactPerson: $contactPerson)';
