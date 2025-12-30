import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/models/user.dart';

class Expense {
  final String id;
  final String? expenseNo;
  final String projectId;
  final ExpenseCategory category;
  final String description;
  final double amount;
  final String? billNo;
  final DateTime? billDate;
  final String? paidTo;
  final PaymentMethod paymentMethod;
  final String? approvedById;
  final User? approvedBy;
  final TaskStatus status;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdById;
  final User? createdBy;

  Expense({
    required this.id,
    this.expenseNo,
    required this.projectId,
    required this.category,
    required this.description,
    required this.amount,
    this.billNo,
    this.billDate,
    this.paidTo,
    required this.paymentMethod,
    this.approvedById,
    this.approvedBy,
    required this.status,
    this.attachmentUrl,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.createdBy,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      expenseNo: json['expenseNo'] as String?,
      projectId: json['projectId'] as String,
      category:
          ExpenseCategory.fromJson(json['category'] as String? ?? 'OTHER'),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      billNo: json['billNo'] as String?,
      billDate:
          json['billDate'] != null ? DateTime.parse(json['billDate']) : null,
      paidTo: json['paidTo'] as String?,
      paymentMethod:
          PaymentMethod.fromJson(json['paymentMethod'] as String? ?? 'CASH'),
      approvedById: json['approvedById'] as String?,
      approvedBy:
          json['approvedBy'] != null ? User.fromJson(json['approvedBy']) : null,
      status: TaskStatus.values
          .byName(json['status']?.toString().toLowerCase() ?? 'todo'),
      attachmentUrl: json['attachmentUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdById: json['createdById'] as String?,
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expenseNo': expenseNo,
      'projectId': projectId,
      'category': category.toJson(),
      'description': description,
      'amount': amount,
      'billNo': billNo,
      'billDate': billDate?.toIso8601String(),
      'paidTo': paidTo,
      'paymentMethod': paymentMethod.toJson(),
      'approvedById': approvedById,
      'approvedBy': approvedBy?.toJson(),
      'status': status.name.toUpperCase(),
      'attachmentUrl': attachmentUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
    };
  }
}

class Invoice {
  final String id;
  final String invoiceNo;
  final String projectId;
  final String? clientId;
  final double subtotal;
  final double taxAmount;
  final double? discount;
  final double totalAmount;
  final InvoiceStatus status;
  final DateTime issueDate;
  final DateTime? dueDate;
  final String createdById;
  final User? createdBy;
  final String? approvedById;
  final User? approvedBy;
  final DateTime? approvedAt;
  final double? paidAmount;
  final String? notes;
  final String? terms;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<InvoiceItem>? items;
  final List<Payment>? payments;

  Invoice({
    required this.id,
    required this.invoiceNo,
    required this.projectId,
    this.clientId,
    required this.subtotal,
    required this.taxAmount,
    this.discount,
    required this.totalAmount,
    required this.status,
    required this.issueDate,
    this.dueDate,
    required this.createdById,
    this.createdBy,
    this.approvedById,
    this.approvedBy,
    this.approvedAt,
    this.paidAmount,
    this.notes,
    this.terms,
    required this.createdAt,
    required this.updatedAt,
    this.items,
    this.payments,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      invoiceNo: json['invoiceNo'] as String,
      projectId: json['projectId'] as String,
      clientId: json['clientId'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: InvoiceStatus.fromJson(json['status'] as String? ?? 'DRAFT'),
      issueDate: DateTime.parse(json['issueDate']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdById: json['createdById'] as String,
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      approvedById: json['approvedById'] as String?,
      approvedBy:
          json['approvedBy'] != null ? User.fromJson(json['approvedBy']) : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      terms: json['terms'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      items: (json['items'] as List?)
          ?.map((i) => InvoiceItem.fromJson(i))
          .toList(),
      payments:
          (json['payments'] as List?)?.map((p) => Payment.fromJson(p)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNo': invoiceNo,
      'projectId': projectId,
      'clientId': clientId,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discount': discount,
      'totalAmount': totalAmount,
      'status': status.toJson(),
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
      'approvedById': approvedById,
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt?.toIso8601String(),
      'paidAmount': paidAmount,
      'notes': notes,
      'terms': terms,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items?.map((i) => i.toJson()).toList(),
      'payments': payments?.map((p) => p.toJson()).toList(),
    };
  }
}

class InvoiceItem {
  final String id;
  final String invoiceId;
  final String description;
  final double quantity;
  final String? unit;
  final double rate;
  final double? taxPercent;
  final DateTime createdAt;

  InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.description,
    required this.quantity,
    this.unit,
    required this.rate,
    this.taxPercent,
    required this.createdAt,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'nos',
      rate: (json['rate'] as num).toDouble(),
      taxPercent: (json['taxPercent'] as num?)?.toDouble() ?? 18,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'taxPercent': taxPercent,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Payment {
  final String id;
  final String? paymentNo;
  final String invoiceId;
  final String? clientId;
  final double amount;
  final DateTime paymentDate;
  final PaymentMethod paymentMethod;
  final String? transactionId;
  final String? referenceNo;
  final String? receivedById;
  final User? receivedBy;
  final String? notes;
  final DateTime createdAt;
  final String? createdById;
  final User? createdBy;

  Payment({
    required this.id,
    this.paymentNo,
    required this.invoiceId,
    this.clientId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.transactionId,
    this.referenceNo,
    this.receivedById,
    this.receivedBy,
    this.notes,
    required this.createdAt,
    this.createdById,
    this.createdBy,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      paymentNo: json['paymentNo'] as String?,
      invoiceId: json['invoiceId'] as String,
      clientId: json['clientId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate']),
      paymentMethod:
          PaymentMethod.fromJson(json['paymentMethod'] as String? ?? 'CASH'),
      transactionId: json['transactionId'] as String?,
      referenceNo: json['referenceNo'] as String?,
      receivedById: json['receivedById'] as String?,
      receivedBy:
          json['receivedBy'] != null ? User.fromJson(json['receivedBy']) : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      createdById: json['createdById'] as String?,
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentNo': paymentNo,
      'invoiceId': invoiceId,
      'clientId': clientId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod.toJson(),
      'transactionId': transactionId,
      'referenceNo': referenceNo,
      'receivedById': receivedById,
      'receivedBy': receivedBy?.toJson(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'createdById': createdById,
      'createdBy': createdBy?.toJson(),
    };
  }
}
