import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/models/timeline.dart';
import 'package:construction_erp/models/enums.dart';
// ==========================================================================
// PROVIDERS
// ==========================================================================

final timelineControllerProvider =
    AsyncNotifierProvider<TimelineController, TimelineState>(() {
  return TimelineController();
});

// Provider for fetching specific timeline details (deeply nested data)
final timelineDetailsProvider =
    FutureProvider.family<Timeline, String>((ref, id) async {
  final controller = ref.read(timelineControllerProvider.notifier);
  return controller.getTimelineById(id);
});

// Provider for Gantt Chart Data
final timelineGanttProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final controller = ref.read(timelineControllerProvider.notifier);
  return controller.getGanttData(id);
});

// Provider for Critical Path Analysis
final timelineCriticalPathProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final controller = ref.read(timelineControllerProvider.notifier);
  return controller.getCriticalPath(id);
});

// ==========================================================================
// STATE CLASS
// ==========================================================================

class TimelineState {
  final List<Timeline> timelines;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final Map<String, dynamic>? statistics;

  TimelineState({
    this.timelines = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.statistics,
  });

  TimelineState copyWith({
    List<Timeline>? timelines,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    Map<String, dynamic>? statistics,
  }) {
    return TimelineState(
      timelines: timelines ?? this.timelines,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      statistics: statistics ?? this.statistics,
    );
  }
}

// ==========================================================================
// CONTROLLER
// ==========================================================================

class TimelineController extends AsyncNotifier<TimelineState> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _basePath = '/timelines';

  // Persistent Filters
  String _currentSearch = '';
  String? _currentProjectId;
  String? _currentStatus; // Uses TimelineStatus string
  bool? _isArchived;
  bool? _isBaseline;
  bool? _createdByMe;

  @override
  Future<TimelineState> build() async {
    return _fetchPage(page: 1, isRefresh: true);
  }

  // ==========================================================================
  // FETCH & PAGINATION
  // ==========================================================================

  Future<TimelineState> _fetchPage({
    required int page,
    required bool isRefresh,
  }) async {
    final response = await _dioClient.dio.get(_basePath, queryParameters: {
      'page': page,
      'limit': 10,
      if (_currentSearch.isNotEmpty) 'search': _currentSearch,
      if (_currentProjectId != null) 'projectId': _currentProjectId,
      if (_currentStatus != null) 'status': _currentStatus,
      if (_isArchived != null) 'isArchived': _isArchived,
      if (_isBaseline != null) 'isBaseline': _isBaseline,
      if (_createdByMe != null) 'createdByMe': _createdByMe,
    });

    final data = response.data;
    final List<dynamic> listJson = data['data'];
    final pagination = data['pagination'];
    final stats = data['stats']; // Backend sends aggregation stats

    final newItems = listJson.map((json) => Timeline.fromJson(json)).toList();
    final bool hasMore = page < (pagination['pages'] ?? 1);

    if (isRefresh) {
      return TimelineState(
        timelines: newItems,
        currentPage: page,
        hasMore: hasMore,
        statistics: stats,
      );
    } else {
      final currentList = state.value?.timelines ?? [];
      return state.value!.copyWith(
        timelines: [...currentList, ...newItems],
        currentPage: page,
        hasMore: hasMore,
        isLoadingMore: false,
        statistics: stats ?? state.value?.statistics,
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

  Future<void> refresh({
    String? search,
    String? projectId,
    TimelineStatus? status,
    bool? isArchived,
    bool? isBaseline,
    bool? createdByMe,
  }) async {
    if (search != null) _currentSearch = search;
    if (projectId != null) _currentProjectId = projectId;
    if (status != null) _currentStatus = status.toJson();
    if (isArchived != null) _isArchived = isArchived;
    if (isBaseline != null) _isBaseline = isBaseline;
    if (createdByMe != null) _createdByMe = createdByMe;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(page: 1, isRefresh: true));
  }

  // ==========================================================================
  // CORE TIMELINE CRUD
  // ==========================================================================

  /// POST /timelines
  Future<void> createTimeline(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post(_basePath, data: payload);
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  /// GET /timelines/:id
  Future<Timeline> getTimelineById(String id) async {
    try {
      final response = await _dioClient.dio.get('$_basePath/$id');
      var timeline = Timeline.fromJson(response.data['data']);

      // Fix for duplicate tasks: Filter tasks to only include those belonging to the
      // latest version returned in timelineVersions (which corresponds to currentVersion).
      if (timeline.timelineTasks != null &&
          timeline.timelineVersions != null &&
          timeline.timelineVersions!.isNotEmpty) {
        // The backend sorts timelineVersions desc by versionNumber, so first is active/latest
        final activeVersionId = timeline.timelineVersions!.first.id;

        final filteredTasks = timeline.timelineTasks!
            .where((t) => t.timelineVersionId == activeVersionId)
            .toList();

        timeline = timeline.copyWith(timelineTasks: filteredTasks);
      }

      return timeline;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT /timelines/:id
  Future<void> updateTimeline(String id, Map<String, dynamic> updates) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.put('$_basePath/$id', data: updates);
      // Refresh list to show updated status/dates
      return _fetchPage(page: 1, isRefresh: true);
    });
    // Invalidate details provider to force refresh on detail screens
    ref.invalidate(timelineDetailsProvider(id));
  }

  /// Orchestrated flow to update Timeline, bulk update existing tasks, and create new ones
  Future<void> saveEditedTimeline({
    required String timelineId,
    required Map<String, dynamic> headerUpdates,
    required List<Map<String, dynamic>> taskUpdates,
    required List<Map<String, dynamic>> newTasks,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. Update Timeline Header
      if (headerUpdates.isNotEmpty) {
        await _dioClient.dio.put('$_basePath/$timelineId', data: headerUpdates);
      }

      // 2. Bulk Update Existing Tasks
      if (taskUpdates.isNotEmpty) {
        await _dioClient.dio.put('$_basePath/$timelineId/tasks/bulk', data: {
          'updates': taskUpdates,
        });
      }

      // 3. Create New Tasks
      // Assuming new tasks need to be created sequentially since there is no bulk create endpoint for NEW tasks.
      if (newTasks.isNotEmpty) {
        for (final newTaskPayload in newTasks) {
          await _dioClient.dio
              .post('$_basePath/$timelineId/tasks/new', data: newTaskPayload);
        }
      }

      // Refresh list view
      return _fetchPage(page: 1, isRefresh: true);
    });

    // Invalidate the specific timeline details to ensure fresh data on UI
    ref.invalidate(timelineDetailsProvider(timelineId));
  }

  /// DELETE /timelines/:id
  Future<void> deleteTimeline(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.delete('$_basePath/$id');
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  // ==========================================================================
  // WORKFLOW ACTIONS
  // ==========================================================================

  /// POST /timelines/:id/submit
  Future<void> submitForApproval(
      String id, String approverId, String comments) async {
    await _dioClient.dio.post(
      '$_basePath/$id/submit',
      data: {'approverId': approverId, 'comments': comments},
    );
    ref.invalidate(timelineDetailsProvider(id));
    await refresh();
  }

  /// POST /timelines/:id/approve-reject
  Future<void> approveRejectTimeline(
      String id, bool isApproved, String? reason) async {
    await _dioClient.dio.post(
      '$_basePath/$id/approve-reject',
      data: {
        'action': isApproved ? 'approve' : 'reject',
        'rejectionReason': reason
      },
    );
    ref.invalidate(timelineDetailsProvider(id));
    await refresh();
  }

  /// POST /timelines/:id/lock-unlock
  Future<void> lockUnlockTimeline(String id, bool lock, String? reason) async {
    await _dioClient.dio.post(
      '$_basePath/$id/lock-unlock',
      data: {'action': lock ? 'lock' : 'unlock', 'lockReason': reason},
    );
    ref.invalidate(timelineDetailsProvider(id));
    await refresh();
  }

  /// POST /timelines/:id/archive-restore
  Future<void> archiveRestoreTimeline(
      String id, bool archive, String? reason) async {
    await _dioClient.dio.post(
      '$_basePath/$id/archive-restore',
      data: {
        'action': archive ? 'archive' : 'restore',
        'archiveReason': reason
      },
    );
    ref.invalidate(timelineDetailsProvider(id));
    await refresh();
  }

  // ==========================================================================
  // VERSION MANAGEMENT
  // ==========================================================================

  /// POST /timelines/:id/versions
  Future<void> createVersion(
      String timelineId, Map<String, dynamic> payload) async {
    await _dioClient.dio.post('$_basePath/$timelineId/versions', data: payload);
    ref.invalidate(timelineDetailsProvider(timelineId));
  }

  /// GET /timelines/:id/versions
  Future<List<TimelineVersion>> getTimelineVersions(String timelineId) async {
    final response =
        await _dioClient.dio.get('$_basePath/$timelineId/versions');
    final List<dynamic> list = response.data['data'];
    return list.map((e) => TimelineVersion.fromJson(e)).toList();
  }

  /// GET /timelines/:id/versions/:versionNumber
  Future<TimelineVersion> getTimelineVersionById(
      String timelineId, int versionNumber) async {
    final response = await _dioClient.dio
        .get('$_basePath/$timelineId/versions/$versionNumber');
    return TimelineVersion.fromJson(response.data['data']);
  }

  /// PUT /timelines/:id/versions/:versionNumber
  Future<void> updateTimelineVersion(String timelineId, int versionNumber,
      Map<String, dynamic> payload) async {
    await _dioClient.dio
        .put('$_basePath/$timelineId/versions/$versionNumber', data: payload);
    // Invalidate details and relevant caches
    ref.invalidate(timelineDetailsProvider(timelineId));
  }

  /// DELETE /timelines/:id/versions/:versionNumber
  Future<void> deleteTimelineVersion(
      String timelineId, int versionNumber) async {
    await _dioClient.dio
        .delete('$_basePath/$timelineId/versions/$versionNumber');
    ref.invalidate(timelineDetailsProvider(timelineId));
  }

  /// POST /timelines/:id/versions/:versionNumber/submit
  Future<void> submitVersionForApproval(String timelineId, int versionNumber,
      Map<String, dynamic> payload) async {
    await _dioClient.dio.post(
        '$_basePath/$timelineId/versions/$versionNumber/submit',
        data: payload);
    ref.invalidate(timelineDetailsProvider(timelineId));
  }

  /// POST /timelines/:id/versions/:versionNumber/approve-reject
  Future<void> approveRejectVersion(String timelineId, int versionNumber,
      bool isApproved, String? reason) async {
    await _dioClient.dio.post(
      '$_basePath/$timelineId/versions/$versionNumber/approve-reject',
      data: {
        'action': isApproved ? 'approve' : 'reject',
        'rejectionReason': reason
      },
    );
    ref.invalidate(timelineDetailsProvider(timelineId));
    await refresh(); // Refresh list to update status badges
  }

  /// POST /timelines/:id/versions/:version/set-baseline
  Future<void> setVersionAsBaseline(
      String timelineId, int versionNumber) async {
    await _dioClient.dio
        .post('$_basePath/$timelineId/versions/$versionNumber/set-baseline');
    ref.invalidate(timelineDetailsProvider(timelineId));
  }

  /// GET /timelines/:id/compare/:v1/:v2
  Future<Map<String, dynamic>> compareVersions(
      String timelineId, int v1, int v2) async {
    final response =
        await _dioClient.dio.get('$_basePath/$timelineId/compare/$v1/$v2');
    return response.data['data'];
  }

  // ==========================================================================
  // TASK MANAGEMENT
  // ==========================================================================

  /// POST /timelines/:id/tasks/new (Creates Task & TimelineEntry)
  Future<void> createTaskAndAddToTimeline(
      String timelineId, Map<String, dynamic> payload) async {
    await _dioClient.dio
        .post('$_basePath/$timelineId/tasks/new', data: payload);
    // Refresh details to show new task in Gantt/List
    ref.invalidate(timelineDetailsProvider(timelineId));
    ref.invalidate(timelineGanttProvider(timelineId));
  }

  /// POST /timelines/:id/tasks (Adds existing task)
  Future<void> addTaskToTimeline(
      String timelineId, Map<String, dynamic> payload) async {
    await _dioClient.dio.post('$_basePath/$timelineId/tasks', data: payload);
    ref.invalidate(timelineDetailsProvider(timelineId));
  }

  /// POST /timelines/:id/tasks/bulk
  Future<void> bulkAddTasks(
      String timelineId, List<Map<String, dynamic>> tasks) async {
    await _dioClient.dio.post('$_basePath/$timelineId/tasks/bulk', data: {
      'tasks': tasks,
    });
    ref.invalidate(timelineDetailsProvider(timelineId));
  }

  /// PUT /timelines/:id/tasks/bulk
  Future<void> bulkUpdateTimelineTasks(
      String timelineId, List<Map<String, dynamic>> updates) async {
    await _dioClient.dio.put('$_basePath/$timelineId/tasks/bulk', data: {
      'updates': updates,
    });
    ref.invalidate(timelineDetailsProvider(timelineId));
  }

  /// PUT /timelines/:id/tasks/:taskId
  Future<void> updateTimelineTaskDetails(
      String timelineId, String taskId, Map<String, dynamic> payload) async {
    await _dioClient.dio
        .put('$_basePath/$timelineId/tasks/$taskId', data: payload);
    ref.invalidate(timelineDetailsProvider(timelineId));
  }

  /// PATCH /timelines/:id/tasks/:taskId/status
  Future<void> updateTaskStatus(
      String timelineId, String taskId, String status, String? notes) async {
    await _dioClient.dio.patch(
      '$_basePath/$timelineId/tasks/$taskId/status',
      data: {'timelineStatus': status, 'notes': notes},
    );
    ref.invalidate(timelineDetailsProvider(timelineId));
  }

  /// DELETE /timelines/:id/tasks/:taskId
  Future<void> removeTaskFromTimeline(String timelineId, String taskId) async {
    await _dioClient.dio.delete('$_basePath/$timelineId/tasks/$taskId');
    ref.invalidate(timelineDetailsProvider(timelineId));
  }

  /// GET /timelines/:id/calendar
  Future<Map<String, dynamic>> getTimelineCalendar(
      String timelineId, int year, int month,
      {String? versionId}) async {
    final response = await _dioClient.dio.get(
      '$_basePath/$timelineId/calendar',
      queryParameters: {
        'year': year,
        'month': month,
        if (versionId != null) 'timelineVersionId': versionId,
      },
    );
    return response.data['data'];
  }

  // ==========================================================================
  // ANALYSIS & REPORTS
  // ==========================================================================

  /// GET /timelines/:id/gantt
  Future<Map<String, dynamic>> getGanttData(String timelineId) async {
    final response = await _dioClient.dio.get('$_basePath/$timelineId/gantt');
    return response.data['data'];
  }

  /// GET /timelines/:id/critical-path
  Future<Map<String, dynamic>> getCriticalPath(String timelineId) async {
    final response =
        await _dioClient.dio.get('$_basePath/$timelineId/critical-path');
    return response.data['data'];
  }

  /// GET /timelines/project/:projectId/summary
  Future<Map<String, dynamic>> getProjectTimelineSummary(
      String projectId) async {
    final response =
        await _dioClient.dio.get('$_basePath/project/$projectId/summary');
    return response.data['data'];
  }

  /// GET /timelines/delayed
  Future<Map<String, dynamic>> getDelayedTimelines() async {
    final response = await _dioClient.dio.get('$_basePath/delayed');
    return response.data['data'];
  }

  /// GET /timelines/upcoming-milestones
  Future<Map<String, dynamic>> getUpcomingMilestones({int days = 30}) async {
    final response = await _dioClient.dio.get(
      '$_basePath/upcoming-milestones',
      queryParameters: {'days': days},
    );
    return response.data['data'];
  }
}
