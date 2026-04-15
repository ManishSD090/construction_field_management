import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/models/dpr.dart';
import 'package:construction_erp/models/wpr.dart'; 
import 'package:construction_erp/models/enums.dart';

class WprData {
  final Map<String, dynamic> projectInfo;
  final Map<String, dynamic> weekInfo;
  final Map<String, dynamic> weather;
  final String description;
  final Map<String, dynamic> attendance;
  final List<dynamic> subcontractors;
  final Map<String, dynamic> progress;
  final List<dynamic> tasks;
  final Map<String, dynamic> materials;
  final List<dynamic> equipment;
  final Map<String, dynamic> budget;
  final List<dynamic> photos;
  final List<dynamic> documents;
  final List<dynamic> nextWeekPlanning;
  final String notes;

  WprData({
    required this.projectInfo,
    required this.weekInfo,
    required this.weather,
    required this.description,
    required this.attendance,
    required this.subcontractors,
    required this.progress,
    required this.tasks,
    required this.materials,
    required this.equipment,
    required this.budget,
    required this.photos,
    required this.documents,
    required this.nextWeekPlanning,
    required this.notes,
  });

  factory WprData.fromJson(Map<String, dynamic> json) {
    return WprData(
      projectInfo: json['projectInfo'] ?? {},
      weekInfo: json['weekInfo'] ?? {},
      weather: json['weather'] ?? {},
      description: json['description'] ?? 'No description available',
      attendance: json['attendance'] ?? {},
      subcontractors: json['subcontractors'] ?? [],
      progress: json['progress'] ?? {},
      tasks: json['tasks'] ?? [],
      materials: json['materials'] ?? {},
      equipment: json['equipment'] ?? [],
      budget: json['budget'] ?? {},
      photos: json['photos'] ?? [],
      documents: json['documents'] ?? [],
      nextWeekPlanning: json['nextWeekPlanning'] ?? [],
      notes: json['notes'] ?? '',
    );
  }
}

final projectInspectionSummaryProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dioClient = ref.read(dioClientProvider);
  final response = await dioClient.dio.get('/wpr/summary');
  return response.data['data'] as List<dynamic>;
});

final pendingInspectionDprProvider = FutureProvider.autoDispose.family<List<DailyProgressReport>, String>((ref, projectId) async {
  if (projectId.isEmpty) return [];
  
  final dioClient = ref.read(dioClientProvider);
  final response = await dioClient.dio.get(
    '/dpr/project/$projectId',
    queryParameters: {
      'page': 1,
      'limit': 100,
      'status': 'REVIEW', 
    },
    data: {}, // 🚨 Bypass backend crash on 'undefined' body
  );
  
  final List<dynamic> listJson = response.data['data']['dprs'] ?? [];
  return listJson.map((json) => DailyProgressReport.fromJson(json)).toList();
});

final dprDetailsProvider = FutureProvider.autoDispose.family<DailyProgressReport, String>((ref, dprId) async {
  final dioClient = ref.read(dioClientProvider);
  final response = await dioClient.dio.get('/dpr/$dprId');
  return DailyProgressReport.fromJson(response.data['data']);
});

final wprReportProvider = FutureProvider.autoDispose.family<WprData, String>((ref, projectId) async {
  final dioClient = ref.read(dioClientProvider);
  final response = await dioClient.dio.get('/wpr', queryParameters: {'projectId': projectId});
  return WprData.fromJson(response.data['data']);
});

final inspectionActionProvider = AsyncNotifierProvider<InspectionActionController, void>(() {
  return InspectionActionController();
});

class InspectionActionController extends AsyncNotifier<void> {
  DioClient get _dioClient => ref.read(dioClientProvider);

  @override
  FutureOr<void> build() {}

  Future<void> approveRejectDPR({required String dprId, required bool isApproved, String? comments}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      
      final statusStr = isApproved ? 'COMPLETED' : 'IN_PROGRESS';
      
      final payload = {
        'status': statusStr, 
        if (comments != null && comments.isNotEmpty) 'comments': comments,
        
        'params': { 'id': dprId },
        'body': {
          'status': statusStr,
          if (comments != null && comments.isNotEmpty) 'comments': comments,
        }
      };

      await _dioClient.dio.patch('/dpr/$dprId/approve', data: payload);
      
      ref.invalidate(pendingInspectionDprProvider);
      ref.invalidate(dprDetailsProvider);
      ref.invalidate(projectInspectionSummaryProvider);
    });
  }
}