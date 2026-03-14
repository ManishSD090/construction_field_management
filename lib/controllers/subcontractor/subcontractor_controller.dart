import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/models/contractor.dart';
import 'package:construction_erp/controllers/core_providers.dart';

final subcontractorControllerProvider =
    AsyncNotifierProvider<SubcontractorController, SubcontractorState>(() {
  return SubcontractorController();
});

final contractorProjectDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final controller = ref.read(subcontractorControllerProvider.notifier);
  return controller.getContractorProjectById(id);
});

class SubcontractorController extends AsyncNotifier<SubcontractorState> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _basePath = '/subcontractors';

  // Persistent Filters
  String _currentSearch = '';
  String? _currentType;
  String? _currentStatus;
  String? _currentWorkType;
  bool? _isVerified;

  @override
  Future<SubcontractorState> build() async {
    return _fetchPage(page: 1, isRefresh: true);
  }

  // ==========================================================================
  // FETCH & PAGINATION
  // ==========================================================================

  Future<SubcontractorState> _fetchPage({
    required int page,
    required bool isRefresh,
  }) async {
    final response = await _dioClient.dio.get(_basePath, queryParameters: {
      'page': page,
      'limit': 10,
      if (_currentSearch.isNotEmpty) 'search': _currentSearch,
      if (_currentType != null) 'type': _currentType,
      if (_currentStatus != null) 'status': _currentStatus,
      if (_currentWorkType != null) 'workType': _currentWorkType,
      if (_isVerified != null) 'verified': _isVerified,
    });

    final data = response.data;
    final List<dynamic> listJson = data['data'];
    final pagination = data['pagination'];

    final newItems = listJson.map((json) => Contractor.fromJson(json)).toList();
    final bool hasMore = page < pagination['pages'];

    if (isRefresh) {
      return SubcontractorState(
        subcontractors: newItems,
        currentPage: page,
        hasMore: hasMore,
      );
    } else {
      final currentList = state.value?.subcontractors ?? [];
      return state.value!.copyWith(
        subcontractors: [...currentList, ...newItems],
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

  Future<void> refresh({
    String? search,
    String? type,
    String? status,
    String? workType,
    bool? verified,
  }) async {
    if (search != null) _currentSearch = search;
    if (type != null) _currentType = type;
    if (status != null) _currentStatus = status;
    if (workType != null) _currentWorkType = workType;
    if (verified != null) _isVerified = verified;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(page: 1, isRefresh: true));
  }

  // ==========================================================================
  // CORE CRUD
  // ==========================================================================

  Future<void> createSubcontractor(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post(_basePath, data: payload);
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<List<ContractorProject>> getContractorProjectsByProjectId(
      String projectId,
      {String search = ''}) async {
    try {
      final response = await _dioClient.dio.get(
        '$_basePath/$projectId/contractorProjectsByProjectId',
        queryParameters: {
          if (search.isNotEmpty) 'search': search,
        },
      );

      final List<dynamic> listJson = response.data['data'];
      return listJson.map((json) => ContractorProject.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches a specific Contractor Project by its unique ID
  /// This maps to the backend endpoint: GET /projects/:contractorProjectId
  Future<Map<String, dynamic>> getContractorProjectById(
      String contractorProjectId) async {
    try {
      final response = await _dioClient.dio.get(
        '$_basePath/projects/$contractorProjectId',
      );

      // We return the raw map here because the backend response
      // contains complex 'summary' and 'include' objects that
      // might exceed the standard ContractorProject model.
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createContractorProject(String contractorId, String projectId,
      Map<String, dynamic> payload) async {
    await _dioClient.dio
        .post('$_basePath/$contractorId/$projectId', data: payload);
  }

  /// Updates a specific Contractor Project association (e.g., budget, duration)
  /// PATCH /subcontractors/projects/:contractorProjectId
  Future<void> updateContractorProject(
      String contractorProjectId, Map<String, dynamic> updates) async {
    try {
      await _dioClient.dio.patch(
        '$_basePath/projects/$contractorProjectId',
        data: updates,
      );

      // Invalidate the specific details provider so the UI updates automatically
      ref.invalidate(contractorProjectDetailsProvider(contractorProjectId));
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes/Removes a subcontractor from a project
  /// DELETE /subcontractors/projects/:contractorProjectId
  Future<void> deleteContractorProject(String contractorProjectId) async {
    try {
      await _dioClient.dio.delete(
        '$_basePath/projects/$contractorProjectId',
      );

      // Optionally refresh the main list if this deletion affects the dashboard
      // await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSubcontractor(
      String id, Map<String, dynamic> updates) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.put('$_basePath/$id', data: updates);
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<void> deleteSubcontractor(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.delete('$_basePath/$id');
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<Contractor> getSubcontractorDetails(String id) async {
    final response = await _dioClient.dio.get('$_basePath/$id');
    return Contractor.fromJson(response.data['data']);
  }

  // ==========================================================================
  // STATUS & COMPLIANCE (BACKEND PATCH ROUTES)
  // ==========================================================================

  Future<void> verifySubcontractor(
      String id, bool isVerified, String? notes) async {
    await _dioClient.dio.patch('$_basePath/$id/verify', data: {
      'isVerified': isVerified,
      'verificationNotes': notes,
    });
  }

  Future<void> blacklistSubcontractor(String id, String reason) async {
    await _dioClient.dio.patch('$_basePath/$id/blacklist', data: {
      'blacklistReason': reason,
    });
  }

  Future<void> unblacklistSubcontractor(String id) async {
    await _dioClient.dio.patch('$_basePath/$id/unblacklist');
    // Refresh the list to reflect status changes
    await refresh();
  }

  // ==========================================================================
  // WORKER & PROJECT OPERATIONS
  // ==========================================================================

  Future<Map<String, dynamic>> getContractorWorkers(String contractorId,
      {int page = 1, String search = ''}) async {
    final response = await _dioClient.dio.get(
      '$_basePath/$contractorId/workers',
      queryParameters: {
        'page': page,
        'search': search,
      },
    );
    return response.data; // Returns data and pagination info
  }

  Future<void> addWorker(
      String contractorId, Map<String, dynamic> workerData) async {
    await _dioClient.dio
        .post('$_basePath/$contractorId/workers', data: workerData);
  }

  Future<void> assignToProject(
      String contractorId, Map<String, dynamic> projectData) async {
    await _dioClient.dio
        .post('$_basePath/$contractorId/projects', data: projectData);
  }

  Future<void> createWorkAssignment(
      String contractorProjectId, Map<String, dynamic> payload) async {
    await _dioClient.dio.post(
      '$_basePath/projects/$contractorProjectId/assignments',
      data: payload,
    );
  }

  /// Verify that an assigned task is completed
  Future<void> verifyWorkCompletion(
      String assignmentId, Map<String, dynamic> payload) async {
    await _dioClient.dio.patch(
      '$_basePath/assignments/$assignmentId/verify',
      data: payload,
    );
  }

  // ==========================================================================
  // FINANCIALS & REVIEWS
  // ==========================================================================

  Future<void> createPayment(
      String contractorProjectId, Map<String, dynamic> paymentData) async {
    await _dioClient.dio.post(
        '$_basePath/projects/$contractorProjectId/payments',
        data: paymentData);
  }

  Future<void> approveContractorPayment(
      String paymentId, bool isProcessed) async {
    await _dioClient.dio.patch(
      '$_basePath/payments/$paymentId/approve',
      data: {'isProcessed': isProcessed},
    );
  }

  /// Finance department processing (transaction IDs, receipts)
  Future<void> processContractorPayment(
      String paymentId, Map<String, dynamic> payload) async {
    await _dioClient.dio.patch(
      '$_basePath/payments/$paymentId/process',
      data: payload,
    );
  }

  /// Get payment history for a specific contractor
  Future<Map<String, dynamic>> getContractorPayments(String contractorId,
      {int page = 1}) async {
    final response = await _dioClient.dio.get(
      '$_basePath/$contractorId/payments',
      queryParameters: {'page': page},
    );
    return response.data;
  }

  Future<void> submitReview(String contractorId, String projectId,
      Map<String, dynamic> reviewData) async {
    await _dioClient.dio.post(
        '$_basePath/$contractorId/projects/$projectId/reviews',
        data: reviewData);
  }

  Future<void> approveContractorReview(String reviewId, bool isApproved) async {
    await _dioClient.dio.patch(
      '$_basePath/reviews/$reviewId/approve',
      data: {'isApproved': isApproved},
    );
  }

  Future<Map<String, dynamic>> getGlobalStatistics() async {
    final response = await _dioClient.dio.get('$_basePath/statistics');
    return response.data['data'];
  }

  // ==========================================================================
  // NEW MISSING ENDPOINTS
  // ==========================================================================

  Future<Map<String, dynamic>> getSubcontractorDashboardStats() async {
    final response = await _dioClient.dio.get('$_basePath/dashboard/stats');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getSubcontractorsByWorkType(
      String workType) async {
    final response = await _dioClient.dio.get('$_basePath/work-type/$workType');
    return response.data;
  }

  Future<Map<String, dynamic>> getContractorProjectsByContractorId(
      String contractorId,
      {int page = 1,
      String search = '',
      String? status,
      String? workType,
      String? startDate,
      String? endDate}) async {
    final response = await _dioClient.dio.get(
      '$_basePath/$contractorId/contractorProjectsByContractorId',
      queryParameters: {
        'page': page,
        if (search.isNotEmpty) 'search': search,
        if (status != null) 'status': status,
        if (workType != null) 'workType': workType,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getAllProjectsWithSubcontractors({
    int page = 1,
    String search = '',
    String? projectStatus,
    String? contractorStatus,
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dioClient.dio.get(
      '$_basePath/projects/all',
      queryParameters: {
        'page': page,
        if (search.isNotEmpty) 'search': search,
        if (projectStatus != null) 'projectStatus': projectStatus,
        if (contractorStatus != null) 'contractorStatus': contractorStatus,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getContractorAssignments(
      String contractorProjectId,
      {int page = 1,
      String search = '',
      String? status,
      String? startDate,
      String? endDate,
      String? workerId}) async {
    final response = await _dioClient.dio.get(
      '$_basePath/projects/$contractorProjectId/assignments',
      queryParameters: {
        'page': page,
        if (search.isNotEmpty) 'search': search,
        if (status != null) 'status': status,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (workerId != null) 'workerId': workerId,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getAssignmentById(String assignmentId) async {
    final response =
        await _dioClient.dio.get('$_basePath/assignments/$assignmentId');
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

  Future<Map<String, dynamic>> getSubcontractorWorkersForAttendance({
    String? contractorId,
    String? projectId,
  }) async {
    final response = await _dioClient.dio.get(
      '$_basePath/workers/for-attendance',
      queryParameters: {
        if (contractorId != null) 'contractorId': contractorId,
        if (projectId != null) 'projectId': projectId,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getSubcontractorWorkerDetails(
      String workerId) async {
    final response = await _dioClient.dio.get('$_basePath/workers/$workerId');
    return response.data['data'];
  }
}
