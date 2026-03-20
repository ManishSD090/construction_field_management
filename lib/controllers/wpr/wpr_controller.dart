import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/models/wpr.dart'; 

final wprControllerProvider = AsyncNotifierProvider<WPRController, List<WeeklyProgressReport>>(() {
  return WPRController();
});

class WPRController extends AsyncNotifier<List<WeeklyProgressReport>> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  
  static const String _basePath = '/wpr';

  @override
  Future<List<WeeklyProgressReport>> build() async {
    // We return an empty list here instead of calling _fetchWPRs() 
    // to prevent the "Project ID is required" 400 Bad Request error on app boot.
    // The UI handles list fetching dynamically using wprListProvider.
    return [];
  }

  // =========================================================================
  // 1. MATCHES BACKEND: getWeeklyProgressReport
  // =========================================================================
  /// Fetches the aggregated preview of the last 7 days to pre-fill the Create WPR screen
  Future<Map<String, dynamic>> getWeeklyPreview(String projectId, DateTime weekDate) async {
    final response = await _dioClient.dio.get(
      _basePath, 
      queryParameters: {
        'projectId': projectId,
        'weekDate': weekDate.toIso8601String(),
      },
    );
    
    // Return the full response so the UI can check the 'hasData' flag
    return response.data;
  }

  // =========================================================================
  // 2. MATCHES BACKEND: getProjectsWPRSummary
  // =========================================================================
  /// Gets the WPR summary across multiple projects (or all company projects)
  Future<Map<String, dynamic>> getProjectsWPRSummary(DateTime weekDate, {String? projectIds}) async {
    final response = await _dioClient.dio.get(
      '$_basePath/summary', // Adjust if your backend route is named differently
      queryParameters: {
        'weekDate': weekDate.toIso8601String(),
        if (projectIds != null) 'projectIds': projectIds,
      },
    );
    return response.data;
  }

  // =========================================================================
  // 3. MATCHES BACKEND: compareWPR
  // =========================================================================
  /// Compares the data between two different weeks for the same project
  Future<Map<String, dynamic>> compareWPR(String projectId, DateTime week1Date, DateTime week2Date) async {
    final response = await _dioClient.dio.get(
      '$_basePath/compare', // Adjust if your backend route is named differently
      queryParameters: {
        'projectId': projectId,
        'week1Date': week1Date.toIso8601String(),
        'week2Date': week2Date.toIso8601String(),
      },
    );
    return response.data;
  }

  // =========================================================================
  // 4. MATCHES BACKEND: exportWPRAsPDF
  // =========================================================================
  /// Requests the backend to prepare or return PDF export data for a WPR
  Future<Map<String, dynamic>> exportWPRAsPDF(String projectId, DateTime weekDate) async {
    final response = await _dioClient.dio.get(
      '$_basePath/export', // Adjust if your backend route is named differently
      queryParameters: {
        'projectId': projectId,
        'weekDate': weekDate.toIso8601String(),
      },
    );
    return response.data;
  }

  // =========================================================================
  // SAVING / CREATING THE WPR
  // =========================================================================
  Future<void> createWPR(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    
    // Save the WPR to the database (assuming you build a POST route in Node.js)
    await _dioClient.dio.post(_basePath, data: payload);
    
    // Reset state to empty so the UI providers can trigger a fresh reload
    state = const AsyncValue.data([]);
  }

  Future<void> refresh() async {
    state = const AsyncValue.data([]);
  }

  Future<void> updateWPR(String wprId, Map<String, dynamic> data) async {
    try {
      final dioClient = ref.read(dioClientProvider);
      
      // We use PATCH here to update only specific fields
      final response = await dioClient.dio.patch(
        '/wpr/$wprId',
        data: data,
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to update WPR');
      }
    } catch (e) {
      print('Error in updateWPR: $e');
      rethrow;
    }
  }
}

