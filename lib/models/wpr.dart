import 'package:construction_erp/models/enums.dart'; 

class WeeklyProgressReport {
  final String id;
  final String reportNo;
  final String projectId;
  final DateTime weekStartDate; 
  final DateTime weekEndDate;   
  final DateTime? createdAt;    
  final String? description;    
  
  final Map<String, dynamic>? aggregatedData;

  final TaskStatus status; // This should now be recognized

  WeeklyProgressReport({
    required this.id,
    required this.reportNo,
    required this.projectId,
    required this.weekStartDate,
    required this.weekEndDate,
    this.createdAt,
    this.description,
    this.aggregatedData,
    required this.status,
  });

  factory WeeklyProgressReport.fromJson(Map<String, dynamic> json) {
    return WeeklyProgressReport(
      id: (json['id'] ?? '').toString(),
      reportNo: (json['reportNo'] ?? 'N/A').toString(),
      projectId: (json['projectId'] ?? '').toString(),
      weekStartDate: DateTime.tryParse(json['weekStartDate'] ?? '') ?? DateTime.now(),
      weekEndDate: DateTime.tryParse(json['weekEndDate'] ?? '') ?? DateTime.now(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      description: json['description'],
      aggregatedData: json['aggregatedData'] is Map<String, dynamic> 
          ? json['aggregatedData'] 
          : null,
      // 🚨 Make sure TaskStatus.values.byName or a similar helper is used if fromJson isn't defined
      status: _parseStatus(json['status']),
    );
  }

 static TaskStatus _parseStatus(String? status) {
    if (status == null) return TaskStatus.values.first; // Fallback to the first available enum value
    
    return TaskStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == status.toUpperCase(),
      // If no match found, don't hardcode .TODO, just return the first one (usually TODO/Planned)
      orElse: () => TaskStatus.values.first, 
    );
  }
}