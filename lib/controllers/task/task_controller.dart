import 'dart:async';
import 'package:dio/dio.dart';
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

// Fetches attachments specifically for a given task (useful for dedicated galleries)
final taskAttachmentsProvider =
    FutureProvider.family<List<TaskAttachment>, String>((ref, taskId) async {
  final controller = ref.read(taskControllerProvider.notifier);
  final response =
      await controller.getPaginatedTaskAttachments(taskId, limit: 50);

  // Safely extract the list depending on whether the backend returns a flat array or nested pagination object
  List<dynamic> rawList = [];
  if (response['data'] is List) {
    rawList = response['data'];
  } else if (response['data'] is Map &&
      response['data']['attachments'] is List) {
    rawList = response['data']['attachments'];
  } else if (response['data'] is Map && response['data']['data'] is List) {
    rawList = response['data']['data'];
  }

  return rawList.map((e) => TaskAttachment.fromJson(e)).toList();
});

class TaskController extends AsyncNotifier<TaskState> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _basePath = '/tasks';
  static const String _attachmentsBasePath = '/task-attachments';

  String _currentSearch = '';
  String? _currentStatus;
  String? _currentPriority;
  String? _currentProjectId;

  @override
  Future<TaskState> build() async {
    return _fetchPage(page: 1, isRefresh: true);
  }

  // --- PRIVATE UTILITIES ---

  /// Helper to update a single task in the current list without a full refresh
  /// Optimized helper to update a single task while preserving existing relations
  void _updateLocalTask(String taskId, Task Function(Task) updateFn) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedTasks = currentState.tasks.map((task) {
      if (task.id == taskId) {
        // We pass the existing 'task' to the update function to allow merging
        return updateFn(task);
      }
      return task;
    }).toList();

    state = AsyncValue.data(currentState.copyWith(
      tasks: updatedTasks,
      isRefreshing: false,
    ));
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

  // --- PUBLIC ACTIONS ---

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

  // --- OPTIMIZED MUTATIONS (No full refresh) ---

  /// Updates general task details (assignee, dates, priority, etc.)
  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      // 1. Perform API Call
      final response = await _dioClient.dio.put(
        '$_basePath/$taskId',
        data: updates,
      );

      // 2. Parse the updated task data
      final updatedTaskData = Task.fromJson(response.data['data']);

      // 3. Update locally instantly.
      // Note: Since the backend update response doesn't `include` the nested
      // relations (like subtasks, comments), we merge the new data with the old relations.
      _updateLocalTask(taskId, (oldTask) {
        return updatedTaskData.copyWith(
          subtasks: oldTask.subtasks,
          comments: oldTask.comments,
          attachments: oldTask.attachments,
          creator: oldTask.creator,
          // If the update doesn't return the full assignedTo User object, preserve the old one
          // temporarily until the invalidate below triggers a fresh fetch.
          assignedTo: updatedTaskData.assignedTo ?? oldTask.assignedTo,
        );
      });

      // 4. Invalidate the task details provider.
      // Because the backend didn't return the populated `assignedTo` User object,
      // invalidating this provider forces the screen to cleanly fetch the updated full task.
      ref.invalidate(taskDetailsProvider(taskId));
    } catch (e) {
      // Re-throw the error so the UI can catch it and show a SnackBar
      rethrow;
    }
  }

  Future<void> bulkUpdateSubtasks(
      String taskId, List<Map<String, dynamic>> updates) async {
    // 1. Perform API Call
    final response =
        await _dioClient.dio.put('$_basePath/subtasks/bulk', data: {
      'taskId': taskId,
      'updates': updates,
    });

    // 2. Fetch the fresh task data for just this one task
    // (Better than refreshing the whole list of 50+ tasks)
    final updatedTask = Task.fromJson(response.data['data']);

    // 3. Update locally
    _updateLocalTask(taskId, (_) => updatedTask);

    // Invalidate details provider if someone else is watching it
    ref.invalidate(taskDetailsProvider(taskId));
  }

  Future<void> updateTaskStatus(String id, String status, int progress) async {
    final response = await _dioClient.dio
        .put('$_basePath/$id', data: {'status': status, 'progress': progress});

    final newTask = Task.fromJson(response.data['data']);

    // FIX: Merge the new status/info with the existing subtasks
    _updateLocalTask(id, (oldTask) {
      return newTask.copyWith(
        subtasks: (newTask.subtasks != null && newTask.subtasks!.isNotEmpty)
            ? newTask.subtasks
            : oldTask.subtasks,
        comments: newTask.comments ?? oldTask.comments,
        attachments: newTask.attachments ?? oldTask.attachments,
      );
    });

    ref.invalidate(taskDetailsProvider(id));
  }

  Future<void> createSubtask(String taskId, String description) async {
    final response = await _dioClient.dio.post('$_basePath/subtasks',
        data: {'taskId': taskId, 'description': description});

    // Usually the API returns the updated Task object or the new subtask
    // We fetch the updated task to ensure ID consistency
    final updatedTaskData = await getTaskById(taskId);
    _updateLocalTask(taskId, (_) => updatedTaskData);
    ref.invalidate(taskDetailsProvider(taskId));
  }

  Future<void> updateSubtask(
      String subtaskId, String taskId, Map<String, dynamic> updates) async {
    await _dioClient.dio.put('$_basePath/subtasks/$subtaskId', data: updates);

    // Manually update the subtask in the local state to be ultra-fast
    _updateLocalTask(taskId, (task) {
      final updatedSubtasks = task.subtasks?.map((s) {
        if (s.id == subtaskId) {
          // Merge updates locally
          if (updates.containsKey('isCompleted')) {
            return s.copyWith(isCompleted: updates['isCompleted']);
          }
          if (updates.containsKey('description')) {
            return s.copyWith(description: updates['description']);
          }
        }
        return s;
      }).toList();
      return task.copyWith(subtasks: updatedSubtasks);
    });

    ref.invalidate(taskDetailsProvider(taskId));
  }

  Future<void> deleteSubtask(String subtaskId, String taskId) async {
    await _dioClient.dio.delete('$_basePath/subtasks/$subtaskId');

    // Remove locally for instant UI update
    _updateLocalTask(taskId, (task) {
      final updatedSubtasks =
          task.subtasks?.where((s) => s.id != subtaskId).toList();
      return task.copyWith(subtasks: updatedSubtasks);
    });

    ref.invalidate(taskDetailsProvider(taskId));
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

  // --- ATTACHMENT MUTATIONS & QUERIES ---

  /// Uploads a file/photo to a task
  /// [filePath] is the local path of the file on the device
  Future<void> uploadTaskAttachment(String taskId, String filePath) async {
    // 1. Create FormData for multipart/form-data upload
    final formData = FormData.fromMap({
      'taskId': taskId,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    // 2. Perform API Call
    final response = await _dioClient.dio.post(
      '$_attachmentsBasePath/upload',
      data: formData,
    );

    // 3. Parse the new attachment
    final newAttachment = TaskAttachment.fromJson(response.data['data']);

    // 4. Update local state instantly (append the new attachment to the task)
    _updateLocalTask(taskId, (task) {
      final updatedAttachments = [...?task.attachments, newAttachment];
      return task.copyWith(attachments: updatedAttachments);
    });

    // 5. Invalidate both details and attachments providers
    ref.invalidate(taskDetailsProvider(taskId));
    ref.invalidate(taskAttachmentsProvider(taskId));
  }

  /// Deletes an attachment by ID
  Future<void> deleteTaskAttachment(String attachmentId, String taskId) async {
    // 1. Perform API Call
    await _dioClient.dio.delete('$_attachmentsBasePath/$attachmentId');

    // 2. Remove locally for instant UI update
    _updateLocalTask(taskId, (task) {
      final updatedAttachments =
          task.attachments?.where((a) => a.id != attachmentId).toList();
      return task.copyWith(attachments: updatedAttachments);
    });

    // 3. Invalidate both details and attachments providers
    ref.invalidate(taskDetailsProvider(taskId));
    ref.invalidate(taskAttachmentsProvider(taskId));
  }

  /// Fetches attachment statistics for a specific task
  Future<Map<String, dynamic>> getAttachmentStatistics(String taskId) async {
    final response = await _dioClient.dio
        .get('$_attachmentsBasePath/statistics/task/$taskId');
    return response.data['data'];
  }

  /// Fetches paginated attachments for a task (if you need a separate gallery view)
  /// Note: The task object already includes attachments, but this is useful if there are many.
  Future<Map<String, dynamic>> getPaginatedTaskAttachments(String taskId,
      {int page = 1, int limit = 20}) async {
    final response = await _dioClient.dio.get(
      '$_attachmentsBasePath/task/$taskId',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return response
        .data; // Contains { data: { attachments, categorized }, pagination }
  }

  /// Downloads an attachment to a local path
  /// You will typically use the 'path_provider' package to get the save directory
  Future<void> downloadTaskAttachment(
      String attachmentId, String savePath) async {
    await _dioClient.dio.download(
      '$_attachmentsBasePath/$attachmentId/download',
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          // You can log or update a state with download progress here
          // final progress = (received / total * 100).toStringAsFixed(0);
          // print('Downloading: $progress%');
        }
      },
    );
  }

  // ==========================================================================
  // WORKER & SUBTASK ASSIGNMENT METHODS
  // ==========================================================================

  /// Fetches all site staff (workers).
  /// workers assigned to the current project (`/worker/site-staff?projectId=...`).
  Future<List<dynamic>> getAllSiteStaff({String? projectId}) async {
    final response = await _dioClient.dio.get(projectId != null
        ? '/workers/site-staff?projectId=$projectId'
        : '/workers/site-staff');
    // Based on your backend, the data is inside response.data['data']
    return response.data['data'];
  }

  Future<List<dynamic>> getSubcontractorWorkersByProjectId(
    String projectId, {
    int page = 1,
    String search = '',
    String? status,
    String? skill,
  }) async {
    final response = await _dioClient.dio
        .get('/subcontractors/projects/$projectId/workers', queryParameters: {
      'page': page,
      'limit':
          100, // High limit to ensure we get them all for assignment dropdowns
      if (search.isNotEmpty) 'search': search,
      if (status != null) 'status': status,
      if (skill != null) 'skill': skill,
    });

    // Returning just the data list, but the backend also provides 'summary' and 'pagination'
    // if you ever need them by returning the full response.data instead.
    return response.data['data'];
  }

  /// Assigns a specific worker to a subtask.
  Future<void> assignSubtaskToWorker({
    required String workerId,
    required String subtaskId,
    required String taskId,
    required String projectId,
    String workerType = 'SITE_STAFF', // Can also be 'SUBCONTRACTOR'
  }) async {
    // TODO: When project assignment is implemented, ensure the worker is assigned
    // to the project before making this API call.
    await _dioClient.dio.post('/workers/subtask-assignments', data: {
      'workerId': workerId,
      'workerType': workerType,
      'subtaskId': subtaskId,
      'taskId': taskId,
      'projectId': projectId,
    });

    // Invalidate the task details provider so the UI refreshes to show the newly assigned worker
    ref.invalidate(taskDetailsProvider(taskId));
  }

  /// Removes a worker's assignment from a subtask
  Future<void> removeSubtaskAssignment(
      String assignmentId, String taskId) async {
    await _dioClient.dio.delete('/workers/subtask-assignments/$assignmentId');

    // Refresh the task details to reflect the removed assignment
    ref.invalidate(taskDetailsProvider(taskId));
  }

  /// Helper method to change a worker (Deletes old assignment, creates new one)
  Future<void> reassignSubtaskWorker({
    required String oldAssignmentId,
    required String newWorkerId,
    required String subtaskId,
    required String taskId,
    required String projectId,
    String workerType = 'SITE_STAFF',
  }) async {
    try {
      // 1. Remove the old assignment first (if it exists)
      if (oldAssignmentId.isNotEmpty) {
        await _dioClient.dio
            .delete('/worker/subtask-assignments/$oldAssignmentId');
      }

      // 2. Assign the new worker
      await _dioClient.dio.post('/worker/subtask-assignments', data: {
        'workerId': newWorkerId,
        'workerType': workerType,
        'subtaskId': subtaskId,
        'taskId': taskId,
        'projectId': projectId,
      });

      // 3. Refresh UI
      ref.invalidate(taskDetailsProvider(taskId));
    } catch (e) {
      // Handle error (e.g., if assignment fails, you might want to alert the user)
      rethrow;
    }
  }

  /// Fetches Subcontractor Workers (useful for assigning them to subtasks)
  Future<List<dynamic>> getSubcontractorWorkers(String projectId) async {
    // We can use your existing for-attendance endpoint which also filters by projectId
    // and returns the subcontractor worker details we need.
    final response = await _dioClient.dio
        .get('/subcontractors/workers/for-attendance', queryParameters: {
      'projectId': projectId,
    });

    return response.data['data'];
  }

  /// Fetches a flat list of tasks for dropdowns (bypasses pagination state)
  Future<List<Task>> getAllTasksForProject(String projectId) async {
    try {
      final response = await _dioClient.dio.get(
        _basePath, 
        queryParameters: {
          'projectId': projectId,
          'limit': 100, // High limit to ensure we get all tasks for the dropdown
          // 'status': 'IN_PROGRESS', // Optional: Only fetch active tasks!
        }
      );
      
      final List<dynamic> listJson = response.data['data'];
      return listJson.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching tasks for dropdown: $e");
      return [];
    }
  }
}
