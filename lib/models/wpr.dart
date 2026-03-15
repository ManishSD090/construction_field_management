class WeeklyProgressReport {
  final String id;
  final String weekLabel; // e.g., "Sep 2025 - Week 4"
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String projectName;

  WeeklyProgressReport({
    required this.id,
    required this.weekLabel,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.projectName,
  });

  factory WeeklyProgressReport.fromJson(Map<String, dynamic> json) {
    return WeeklyProgressReport(
      id: json['id'] ?? '',
      weekLabel: json['weekLabel'] ?? 'Unknown Week',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'] ?? 'PENDING',
      projectName: json['project']?['name'] ?? 'Unknown Project',
    );
  }
}