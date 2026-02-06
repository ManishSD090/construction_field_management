import 'package:construction_erp/models/user.dart';

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

  final ClientStats? stats;

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
    this.stats,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      // Use toString() to handle potential nulls or incorrect types (like int IDs)
      id: json['id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',

      // Core fields with fallbacks
      companyName: json['companyName']?.toString() ?? 'Unknown Company',
      contactPerson: json['contactPerson']?.toString() ?? 'No Contact',
      phone: json['phone']?.toString() ?? '',

      // Nullable fields don't need ?? fallbacks, but should avoid "as String"
      email: json['email']?.toString(),
      gstNumber: json['gstNumber']?.toString(),
      address: json['address']?.toString(),

      // Boolean safety
      isActive: json['isActive'] is bool
          ? json['isActive'] as bool
          : (json['isActive']?.toString().toLowerCase() == 'true'),

      // Date safety using tryParse to prevent crashes on bad strings
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),

      createdById: json['createdById']?.toString(),

      // Nested object safety: check if it's actually a Map
      createdBy: (json['createdBy'] != null &&
              json['createdBy'] is Map<String, dynamic>)
          ? User.fromJson(json['createdBy'] as Map<String, dynamic>)
          : null,
      stats: (json['stats'] != null && json['stats'] is Map<String, dynamic>)
          ? ClientStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
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
  String toString() =>
      'Client(id: $id, companyName: $companyName, contactPerson: $contactPerson)';
}

class ClientStats {
  final int projects;
  final int invoices;
  final int payments;

  ClientStats({this.projects = 0, this.invoices = 0, this.payments = 0});

  factory ClientStats.fromJson(Map<String, dynamic> json) {
    return ClientStats(
      projects: json['projects'] ?? 0,
      invoices: json['invoices'] ?? 0,
      payments: json['payments'] ?? 0,
    );
  }
}

class ClientState {
  final List<Client> clients;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  ClientState({
    this.clients = const [],
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  ClientState copyWith({
    List<Client>? clients,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ClientState(
      clients: clients ?? this.clients,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
