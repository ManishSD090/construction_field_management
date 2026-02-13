import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/models/task.dart'; // Assuming these models exist

// ==========================================================================
// PROVIDERS
// ==========================================================================

final taskControllerProvider =
    AsyncNotifierProvider<TaskController, TaskState>(() {
  return TaskController();
});

final taskDetailsProvider =
    FutureProvider.family<Task, String>((ref, id) async {
  final controller = ref.read(taskControllerProvider.notifier);
  return controller.getTaskById(id);
});

final taskCommentsProvider =
    FutureProvider.family<List<TaskComment>, String>((ref, taskId) async {
  final controller = ref.read(taskControllerProvider.notifier);
  return controller.getTaskComments(taskId);
});

class TaskController extends AsyncNotifier<TaskState> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _basePath = '/tasks';

  String _currentSearch = '';
  String? _currentStatus;
  String? _currentPriority;
  String? _currentProjectId;

  @override
  Future<TaskState> build() async {
    return _fetchPage(page: 1, isRefresh: true);
  }

  Future<TaskState> _fetchPage({
    required int page,
    required bool isRefresh,
  }) async {
    final response = await _dioClient.dio.get(_basePath, queryParameters: {
      'page': page,
      'limit': 15,
      if (_currentSearch.isNotEmpty) 'search': _currentSearch,
      if (_currentStatus != null) 'status': _currentStatus,
      if (_currentPriority != null) 'priority': _currentPriority,
      if (_currentProjectId != null) 'projectId': _currentProjectId,
    });

    final data = response.data;
    final List<dynamic> listJson = data['data'];
    final pagination = data['pagination'];

    final newItems = listJson.map((json) => Task.fromJson(json)).toList();
    final bool hasMore = page < (pagination['pages'] ?? 1);

    return TaskState(
      tasks:
          isRefresh ? newItems : [...(state.value?.tasks ?? []), ...newItems],
      currentPage: page,
      hasMore: hasMore,
      isLoadingMore: false,
      isRefreshing: false,
    );
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
    state = await AsyncValue.guard(() => _fetchPage(
          page: currentState.currentPage + 1,
          isRefresh: false,
        ));
  }

  Future<void> refresh(
      {String? search,
      String? status,
      String? priority,
      String? projectId}) async {
    if (search != null) _currentSearch = search;
    if (status != null) _currentStatus = status;
    if (priority != null) _currentPriority = priority;
    if (projectId != null) _currentProjectId = projectId;

    final currentState = state.value;
    state = currentState != null
        ? AsyncValue.data(currentState.copyWith(isRefreshing: true))
        : const AsyncValue.loading();

    state = await AsyncValue.guard(() => _fetchPage(page: 1, isRefresh: true));
  }

  Future<void> bulkUpdateSubtasks(
      String taskId, List<Map<String, dynamic>> updates) async {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(isRefreshing: true));
    }

    await _dioClient.dio.put('$_basePath/subtasks/bulk', data: {
      'taskId': taskId,
      'updates': updates,
    });

    ref.invalidate(taskDetailsProvider(taskId));
    state = await AsyncValue.guard(() => _fetchPage(page: 1, isRefresh: true));
  }

  Future<void> updateTaskStatus(String id, String status, int progress) async {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(isRefreshing: true));
    }
    await _dioClient.dio
        .put('$_basePath/$id', data: {'status': status, 'progress': progress});
    ref.invalidate(taskDetailsProvider(id));
    state = await AsyncValue.guard(() => _fetchPage(page: 1, isRefresh: true));
  }

  Future<void> createSubtask(String taskId, String description) async {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(isRefreshing: true));
    }
    await _dioClient.dio.post('$_basePath/subtasks',
        data: {'taskId': taskId, 'description': description});
    ref.invalidate(taskDetailsProvider(taskId));
    state = await AsyncValue.guard(() => _fetchPage(page: 1, isRefresh: true));
  }

  Future<void> updateSubtask(
      String subtaskId, String taskId, Map<String, dynamic> updates) async {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(isRefreshing: true));
    }
    await _dioClient.dio.put('$_basePath/subtasks/$subtaskId', data: updates);
    ref.invalidate(taskDetailsProvider(taskId));
    state = await AsyncValue.guard(() => _fetchPage(page: 1, isRefresh: true));
  }

  Future<Task> getTaskById(String id) async {
    final response = await _dioClient.dio.get('$_basePath/$id');
    return Task.fromJson(response.data['data']);
  }

  Future<List<TaskComment>> getTaskComments(String taskId) async {
    final response = await _dioClient.dio.get('$_basePath/$taskId/comments');
    final List<dynamic> list = response.data['data'];
    return list.map((e) => TaskComment.fromJson(e)).toList();
  }
}
