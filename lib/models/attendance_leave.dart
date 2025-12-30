import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/models/user.dart';

class Attendance {
  final String id;
  final String userId;
  final User? user;
  final AttendanceLocation locationType;
  final String? projectId;
  final DateTime date;
  final AttendanceStatus status;

  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkInAccuracy;
  final double? distanceFromBase;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final double? workingHours;
  final double? overtimeHours;

  final bool isVerified;
  final String? verificationNotes;
  final String? markedById;
  final User? markedBy;

  final LeaveType? leaveType;
  final String? leaveReason;
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    required this.id,
    required this.userId,
    this.user,
    required this.locationType,
    this.projectId,
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInAccuracy,
    this.distanceFromBase,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.workingHours,
    this.overtimeHours,
    required this.isVerified,
    this.verificationNotes,
    this.markedById,
    this.markedBy,
    this.leaveType,
    this.leaveReason,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      userId: json['userId'] as String,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      locationType: AttendanceLocation.fromJson(
          json['locationType'] as String? ?? 'OFFICE'),
      projectId: json['projectId'] as String?,
      date: DateTime.parse(json['date']),
      status: AttendanceStatus.fromJson(json['status'] as String? ?? 'PRESENT'),
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime'])
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'])
          : null,
      checkInLatitude: (json['checkInLatitude'] as num?)?.toDouble(),
      checkInLongitude: (json['checkInLongitude'] as num?)?.toDouble(),
      checkInAccuracy: (json['checkInAccuracy'] as num?)?.toDouble(),
      distanceFromBase: (json['distanceFromBase'] as num?)?.toDouble(),
      checkOutLatitude: (json['checkOutLatitude'] as num?)?.toDouble(),
      checkOutLongitude: (json['checkOutLongitude'] as num?)?.toDouble(),
      workingHours: (json['workingHours'] as num?)?.toDouble() ?? 0,
      overtimeHours: (json['overtimeHours'] as num?)?.toDouble() ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      verificationNotes: json['verificationNotes'] as String?,
      markedById: json['markedById'] as String?,
      markedBy:
          json['markedBy'] != null ? User.fromJson(json['markedBy']) : null,
      leaveType: json['leaveType'] != null
          ? LeaveType.fromJson(json['leaveType'])
          : null,
      leaveReason: json['leaveReason'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'user': user?.toJson(),
      'locationType': locationType.toJson(),
      'projectId': projectId,
      'date': date.toIso8601String(),
      'status': status.toJson(),
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'checkInLatitude': checkInLatitude,
      'checkInLongitude': checkInLongitude,
      'checkInAccuracy': checkInAccuracy,
      'distanceFromBase': distanceFromBase,
      'checkOutLatitude': checkOutLatitude,
      'checkOutLongitude': checkOutLongitude,
      'workingHours': workingHours,
      'overtimeHours': overtimeHours,
      'isVerified': isVerified,
      'verificationNotes': verificationNotes,
      'markedById': markedById,
      'markedBy': markedBy?.toJson(),
      'leaveType': leaveType?.toJson(),
      'leaveReason': leaveReason,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Leave {
  final String id;
  final String? leaveId;
  final String userId;
  final User? user;
  final LeaveType type;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final TaskStatus status;
  final String? approvedById;
  final User? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Leave({
    required this.id,
    this.leaveId,
    required this.userId,
    this.user,
    required this.type,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.status,
    this.approvedById,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.attachmentUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'] as String,
      leaveId: json['leaveId'] as String?,
      userId: json['userId'] as String,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      type: LeaveType.fromJson(json['type'] as String? ?? 'CASUAL_LEAVE'),
      reason: json['reason'] as String,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalDays: json['totalDays'] as int,
      status: TaskStatus.values.byName(json['status'] as String? ?? 'todo'),
      approvedById: json['approvedById'] as String?,
      approvedBy:
          json['approvedBy'] != null ? User.fromJson(json['approvedBy']) : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leaveId': leaveId,
      'userId': userId,
      'user': user?.toJson(),
      'type': type.toJson(),
      'reason': reason,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'status': status.name,
      'approvedById': approvedById,
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'attachmentUrl': attachmentUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
