import 'package:construction_erp/models/enums.dart';

class Contractor {
  final String id;
  final String companyId;
  final String contractorId;
  final String name;
  final ContractorType type;
  final List<WorkType> workTypes;
  final String contactPerson;
  final String? email;
  final String phone;
  final String? altPhone;
  final String? address;
  final String? registrationNumber;
  final String? gstNumber;
  final String? panNumber;
  final String? aadharNumber;
  final String? bankName;
  final String? bankAccount;
  final String? bankBranch;
  final String? ifscCode;
  final int maxWorkers;
  final double rating;
  final ContractorStatus? status;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  final ContractorFinancials? financialSummary;

  Contractor({
    required this.id,
    required this.companyId,
    required this.contractorId,
    required this.name,
    required this.type,
    required this.workTypes,
    required this.contactPerson,
    this.email,
    required this.phone,
    this.altPhone,
    this.address,
    this.registrationNumber,
    this.gstNumber,
    this.panNumber,
    this.aadharNumber,
    this.bankName,
    this.bankAccount,
    this.bankBranch,
    this.ifscCode,
    this.maxWorkers = 10,
    this.rating = 5.0,
    this.status,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.financialSummary,
  });

  /// Factory for creating a Contractor from a JSON map with null-safety
  factory Contractor.fromJson(Map<String, dynamic>? json) {
    if (json == null) throw Exception("Cannot parse null JSON as Contractor");

    return Contractor(
      id: json['id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      contractorId: json['contractorId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Contractor',
      // Safe Enum parsing using our custom fromJson
      type: ContractorType.fromJson(json['type'] as String?),
      workTypes: (json['workTypes'] as List?)
              ?.map((e) => WorkType.fromJson(e?.toString()))
              .toList() ??
          [],
      contactPerson: json['contactPerson']?.toString() ?? '',
      email: json['email']?.toString(), // Remains nullable
      phone: json['phone']?.toString() ?? '',
      altPhone: json['altPhone']?.toString(),
      address: json['address']?.toString(),
      registrationNumber: json['registrationNumber']?.toString(),
      gstNumber: json['gstNumber']?.toString(),
      panNumber: json['panNumber']?.toString(),
      aadharNumber: json['aadharNumber']?.toString(),
      bankName: json['bankName']?.toString(),
      bankAccount: json['bankAccount']?.toString(),
      bankBranch: json['bankBranch']?.toString(),
      ifscCode: json['bankIfsc']?.toString(),
      // Handle numeric null-safety and defaults
      maxWorkers: (json['maxWorkers'] as num?)?.toInt() ?? 10,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      status: json['status'] != null
          ? ContractorStatus.fromJson(json['status'] as String?)
          : null,
      isVerified: json['isVerified'] as bool? ?? false,
      // DateTime parsing with fallback to 'now' if invalid or null
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      financialSummary: json['financialSummary'] != null
          ? ContractorFinancials.fromJson(json['financialSummary'])
          : null,
    );
  }

  /// Converts object to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'contractorId': contractorId,
      'name': name,
      'type': type.toJson(),
      'workTypes': workTypes.map((e) => e.toJson()).toList(),
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'altPhone': altPhone,
      'address': address,
      'registrationNumber': registrationNumber,
      'gstNumber': gstNumber,
      'panNumber': panNumber,
      'aadharNumber': aadharNumber,
      'bankName': bankName,
      'bankAccount': bankAccount,
      'bankBranch': bankBranch,
      'bankIfsc': ifscCode,
      'maxWorkers': maxWorkers,
      'rating': rating,
      'status': status?.toJson(),
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'financialSummary': financialSummary?.toJson(),
    };
  }
}

class ContractorWorker {
  final String id;
  final String contractorId;
  final String name;
  final String? phone;
  final String? aadharNumber;
  final String skill;
  final String? experience;
  final String wageType;
  final double wageRate;
  final String? photo;
  final String? aadharCopy;
  final bool isAvailable;
  final bool isActive;
  final String? currentAssignmentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContractorWorker({
    required this.id,
    required this.contractorId,
    required this.name,
    this.phone,
    this.aadharNumber,
    required this.skill,
    this.experience,
    this.wageType = "DAILY",
    required this.wageRate,
    this.photo,
    this.aadharCopy,
    this.isAvailable = true,
    this.isActive = true,
    this.currentAssignmentId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory for creating a ContractorWorker from a JSON map with null-safety
  factory ContractorWorker.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception("Cannot parse null JSON as ContractorWorker");
    }

    return ContractorWorker(
      id: json['id']?.toString() ?? '',
      contractorId: json['contractorId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Worker',
      phone: json['phone']?.toString(),
      aadharNumber: json['aadharNumber']?.toString(),
      skill: json['skill']?.toString() ?? 'General',
      experience: json['experience']?.toString(),
      wageType: json['wageType']?.toString() ?? 'DAILY',
      // Safe numeric conversion for double
      wageRate: (json['wageRate'] as num?)?.toDouble() ?? 0.0,
      photo: json['photo']?.toString(),
      aadharCopy: json['aadharCopy']?.toString(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      isActive: json['isActive'] as bool? ?? true,
      currentAssignmentId: json['currentAssignmentId']?.toString(),
      // DateTime parsing with fallback to 'now'
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Converts the ContractorWorker object to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractorId': contractorId,
      'name': name,
      'phone': phone,
      'aadharNumber': aadharNumber,
      'skill': skill,
      'experience': experience,
      'wageType': wageType,
      'wageRate': wageRate,
      'photo': photo,
      'aadharCopy': aadharCopy,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'currentAssignmentId': currentAssignmentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ContractorProject {
  final String id;
  final String companyId;
  final String projectId;
  final String contractorId;
  final String projectCode;
  final String title;
  final String? description;
  final WorkType workType;
  final String? scopeOfWork;
  final String? terms;
  final DateTime startDate;
  final DateTime endDate;
  final int? estimatedDuration;
  final double contractAmount;
  final double? advanceAmount;
  final double? retentionAmount;
  final String? paymentTerms;
  final TaskStatus status;
  final int? progress;
  final bool isCompleted;
  final DateTime? completedAt;
  final double? qualityRating;
  final double? safetyRating;
  final String? completionNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  final Contractor? contractor;

  ContractorProject({
    required this.id,
    required this.companyId,
    required this.projectId,
    required this.contractorId,
    required this.projectCode,
    required this.title,
    this.description,
    required this.workType,
    this.scopeOfWork,
    this.terms,
    required this.startDate,
    required this.endDate,
    this.estimatedDuration,
    required this.contractAmount,
    this.advanceAmount = 0,
    this.retentionAmount = 0,
    this.paymentTerms,
    this.status = TaskStatus.todo,
    this.progress = 0,
    this.isCompleted = false,
    this.completedAt,
    this.qualityRating,
    this.safetyRating,
    this.completionNotes,
    required this.createdAt,
    required this.updatedAt,
    this.contractor,
  });

  factory ContractorProject.fromJson(Map<String, dynamic>? json) {
    if (json == null) throw Exception("Project JSON is null");
    return ContractorProject(
      id: json['id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      contractorId: json['contractorId']?.toString() ?? '',
      projectCode: json['projectCode']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      workType: WorkType.fromJson(json['workType']?.toString()),
      scopeOfWork: json['scopeOfWork']?.toString(),
      terms: json['terms']?.toString(),
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ??
          DateTime.now(),
      estimatedDuration: (json['estimatedDuration'] as num?)?.toInt(),
      contractAmount: (json['contractAmount'] as num?)?.toDouble() ?? 0.0,
      advanceAmount: (json['advanceAmount'] as num?)?.toDouble() ?? 0.0,
      retentionAmount: (json['retentionAmount'] as num?)?.toDouble() ?? 0.0,
      paymentTerms: json['paymentTerms']?.toString(),
      status: TaskStatus.fromJson(json['status']?.toString()),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      qualityRating: (json['qualityRating'] as num?)?.toDouble(),
      safetyRating: (json['safetyRating'] as num?)?.toDouble(),
      completionNotes: json['completionNotes']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      contractor: json['contractor'] != null
          ? Contractor.fromJson(json['contractor'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'projectId': projectId,
      'contractorId': contractorId,
      'projectCode': projectCode,
      'title': title,
      'description': description,
      'workType': workType.toJson(),
      'scopeOfWork': scopeOfWork,
      'terms': terms,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'estimatedDuration': estimatedDuration,
      'contractAmount': contractAmount,
      'advanceAmount': advanceAmount,
      'retentionAmount': retentionAmount,
      'paymentTerms': paymentTerms,
      'status': status.toJson(),
      'progress': progress,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'qualityRating': qualityRating,
      'safetyRating': safetyRating,
      'completionNotes': completionNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ContractorPayment {
  final String id;
  final String contractorProjectId;
  final String contractorId;
  final String paymentNo;
  final String? reference;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String? transactionId;
  final String? description;
  final DateTime? periodFrom;
  final DateTime? periodTo;
  final PaymentStatus status;
  final bool isProcessed;
  final DateTime? processedAt;
  final String? invoiceCopy;
  final String? receiptCopy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContractorPayment({
    required this.id,
    required this.contractorProjectId,
    required this.contractorId,
    required this.paymentNo,
    this.reference,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.transactionId,
    this.description,
    this.periodFrom,
    this.periodTo,
    this.status = PaymentStatus.pending,
    this.isProcessed = false,
    this.processedAt,
    this.invoiceCopy,
    this.receiptCopy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContractorPayment.fromJson(Map<String, dynamic>? json) {
    if (json == null) throw Exception("Payment JSON is null");
    return ContractorPayment(
      id: json['id']?.toString() ?? '',
      contractorProjectId: json['contractorProjectId']?.toString() ?? '',
      contractorId: json['contractorId']?.toString() ?? '',
      paymentNo: json['paymentNo']?.toString() ?? '',
      reference: json['reference']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: DateTime.tryParse(json['paymentDate']?.toString() ?? '') ??
          DateTime.now(),
      paymentMethod: json['paymentMethod']?.toString() ?? 'CASH',
      transactionId: json['transactionId']?.toString(),
      description: json['description']?.toString(),
      periodFrom: json['periodFrom'] != null
          ? DateTime.tryParse(json['periodFrom'].toString())
          : null,
      periodTo: json['periodTo'] != null
          ? DateTime.tryParse(json['periodTo'].toString())
          : null,
      status: PaymentStatus.fromJson(json['status']?.toString()),
      isProcessed: json['isProcessed'] as bool? ?? false,
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'].toString())
          : null,
      invoiceCopy: json['invoiceCopy']?.toString(),
      receiptCopy: json['receiptCopy']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractorProjectId': contractorProjectId,
      'contractorId': contractorId,
      'paymentNo': paymentNo,
      'reference': reference,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'description': description,
      'periodFrom': periodFrom?.toIso8601String(),
      'periodTo': periodTo?.toIso8601String(),
      'status': status.toJson(),
      'isProcessed': isProcessed,
      'processedAt': processedAt?.toIso8601String(),
      'invoiceCopy': invoiceCopy,
      'receiptCopy': receiptCopy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class SubcontractorState {
  final List<Contractor> subcontractors;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  SubcontractorState({
    this.subcontractors = const [],
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  SubcontractorState copyWith({
    List<Contractor>? subcontractors,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return SubcontractorState(
      subcontractors: subcontractors ?? this.subcontractors,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ContractorFinancials {
  final double totalPaid;
  final double pendingAmount;
  final double totalContract;

  ContractorFinancials({
    required this.totalPaid,
    required this.pendingAmount,
    required this.totalContract,
  });

  factory ContractorFinancials.fromJson(Map<String, dynamic>? json) {
    if (json == null) throw Exception("ContractorStats JSON is null");
    return ContractorFinancials(
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0.0,
      totalContract: (json['totalContract'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPaid': totalPaid,
      'pendingAmount': pendingAmount,
      'totalContract': totalContract,
    };
  }
}
