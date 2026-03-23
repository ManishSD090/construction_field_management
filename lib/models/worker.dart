class Worker {
  final String id;
  final String workerId;
  final String name;
  final String? designation;
  final double dailyWageRate;
  final String workerType;
  String? currentStatus; // PRESENT, ABSENT, etc.
  String multiplier;

  Worker({
    required this.id,
    required this.workerId,
    required this.name,
    this.workerType = 'SITE_STAFF', // Default to SITE_STAFF
    this.designation,
    this.dailyWageRate = 600.0,
    this.currentStatus,
    this.multiplier = 'x1.0',
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id']?.toString() ?? '',
      workerId: json['workerId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      workerType: json['workerType']?.toString() ?? 'SITE_STAFF',
      designation: json['designation']?.toString(),
      dailyWageRate: (json['dailyWageRate'] as num?)?.toDouble() ?? 600.0,
      currentStatus: json['todayAttendance']?['status'],
    );
  }
}