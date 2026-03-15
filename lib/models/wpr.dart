import 'package:construction_erp/models/enums.dart';

class WeeklyProgressReport {
  final String id;
  final String reportNo;
  final String projectId;
  final DateTime startDate;
  final DateTime endDate;
  final String workDescription;
  
  // Aggregated Data
  final double avgWorkers;
  final double avgStaff;
  final double totalBudgetUsed;
  final double totalLaborCost;
  final double totalMaterialCost;
  final double totalEquipmentCost;
  
  final List<dynamic> tasks;
  final List<dynamic> materials;
  final List<dynamic> equipments;
  
  final String? nextWeekPlan;
  final String? nextWeekNotes;
  final TaskStatus status;

  WeeklyProgressReport({
    required this.id,
    required this.reportNo,
    required this.projectId,
    required this.startDate,
    required this.endDate,
    required this.workDescription,
    required this.avgWorkers,
    required this.avgStaff,
    required this.totalBudgetUsed,
    required this.totalLaborCost,
    required this.totalMaterialCost,
    required this.totalEquipmentCost,
    required this.tasks,
    required this.materials,
    required this.equipments,
    this.nextWeekPlan,
    this.nextWeekNotes,
    required this.status,
  });

  factory WeeklyProgressReport.fromJson(Map<String, dynamic> json) {
    return WeeklyProgressReport(
      id: (json['id'] ?? '').toString(),
      reportNo: (json['reportNo'] ?? 'N/A').toString(),
      projectId: (json['projectId'] ?? '').toString(),
      // Use tryParse to prevent crashes if the date string is malformed
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      workDescription: json['workDescription'] ?? '',
      
      // Safety casting for numeric values
      avgWorkers: _toDouble(json['avgWorkers']),
      avgStaff: _toDouble(json['avgStaff']),
      totalBudgetUsed: _toDouble(json['totalBudgetUsed']),
      totalLaborCost: _toDouble(json['totalLaborCost']),
      totalMaterialCost: _toDouble(json['totalMaterialCost']),
      totalEquipmentCost: _toDouble(json['totalEquipmentCost']),
      
      tasks: json['tasks'] is List ? json['tasks'] : [],
      materials: json['materials'] is List ? json['materials'] : [],
      equipments: json['equipments'] is List ? json['equipments'] : [],
      
      nextWeekPlan: json['nextWeekPlan'],
      nextWeekNotes: json['nextWeekNotes'],
      status: TaskStatus.fromJson(json['status'] as String? ?? 'TODO'),
    );
  }

  // Helper to safely convert various types (int, String, null) to double
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}