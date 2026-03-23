import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core Imports
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/core/dio_client.dart';

// Models (Assuming these exist based on your backend schema)
import 'package:construction_erp/models/project.dart';

final projectControllerProvider =
    AsyncNotifierProvider<ProjectController, ProjectState>(() {
  return ProjectController();
});

class ProjectController extends AsyncNotifier<ProjectState> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _basePath = '/projects';

  // Persistent Filters for the Project list
  String _currentSearch = '';
  String? _currentStatus;
  String? _currentPriority;

  @override
  Future<ProjectState> build() async {
    return _fetchPage(page: 1, isRefresh: true);
  }

  // ==========================================================================
  // FETCH & PAGINATION
  // ==========================================================================

  Future<ProjectState> _fetchPage({
    required int page,
    required bool isRefresh,
  }) async {
    final response = await _dioClient.dio.get(_basePath, queryParameters: {
      'page': page,
      'limit': 10,
      if (_currentSearch.isNotEmpty) 'search': _currentSearch,
      if (_currentStatus != null) 'status': _currentStatus,
      if (_currentPriority != null) 'priority': _currentPriority,
    });

    final data = response.data;
    final List<dynamic> listJson = data['data'];
    final pagination = data['pagination'];

    final newProjects = listJson.map((json) => Project.fromJson(json)).toList();
    final bool hasMore = page < pagination['pages'];

    if (isRefresh) {
      return ProjectState(
        projects: newProjects,
        currentPage: page,
        hasMore: hasMore,
      );
    } else {
      final currentList = state.value?.projects ?? [];
      return state.value!.copyWith(
        projects: [...currentList, ...newProjects],
        currentPage: page,
        hasMore: hasMore,
        isLoadingMore: false,
      );
    }
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
    state = await AsyncValue.guard(() => _fetchPage(
          page: currentState.currentPage + 1,
          isRefresh: false,
        ));
  }

  Future<void> refresh(
      {String? search, String? status, String? priority}) async {
    if (search != null) _currentSearch = search;
    if (status != null) _currentStatus = status;
    if (priority != null) _currentPriority = priority;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(page: 1, isRefresh: true));
  }

  // ==========================================================================
  // PROJECT CRUD
  // ==========================================================================

  Future<void> createProject(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post(_basePath, data: payload);
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<void> updateProject(String id, Map<String, dynamic> updates) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.put('$_basePath/$id', data: updates);
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<void> deleteProject(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.delete('$_basePath/$id');
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  /// Get specific project details (including stats, recent DPRs, etc.)
  Future<Project> getProjectDetails(String id) async {
    final response = await _dioClient.dio.get('$_basePath/$id');
    return Project.fromJson(response.data['data']);
  }

  // ==========================================================================
  // TEAM & SETTINGS (NEW ENDPOINTS)
  // ==========================================================================

  /// Assign team members to project
  Future<void> assignTeam(
      String projectId, List<Map<String, dynamic>> assignments) async {
    await _dioClient.dio.post('$_basePath/$projectId/team', data: {
      'assignments': assignments,
    });
  }

  /// Fetches the list of users assigned to a specific project (Project Team)
  Future<List<dynamic>> getProjectTeam(String projectId, {DateTime? date}) async {
    try {
      // Note: Assuming your base path for projects is '/projects'
      final response = await _dioClient.dio.get(
        '$_basePath/$projectId/team',
        queryParameters: date != null ? {'date': date.toIso8601String()} : null,
      );

      // Returns a list of ProjectAssignment objects, which include the nested 'user' data
      return response.data['data'] as List<dynamic>;
    } catch (e) {
      // console.error('Failed to fetch project team: $e');
      rethrow;
    }
  }

  /// Get project settings (Geofencing, Attendance Windows, etc.)
  Future<Map<String, dynamic>> getSettings(String projectId) async {
    final response = await _dioClient.dio.get('$_basePath/$projectId/settings');
    return response.data['data'];
  }

  /// Update project settings
  Future<void> updateSettings(
      String projectId, Map<String, dynamic> settings) async {
    await _dioClient.dio.put('$_basePath/$projectId/settings', data: settings);
  }

  /// Fetch Statistics for the Project Dashboard
  Future<Map<String, dynamic>> getStatistics(String projectId) async {
    final response =
        await _dioClient.dio.get('$_basePath/$projectId/statistics');
    return response.data['data'];
  }
}
