import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/controllers/core_providers.dart';

// ==========================================================================
// STATE CLASS
// ==========================================================================

class DashboardState {
  final Map<String, dynamic>? summary;
  final List<dynamic> recentActivities;
  final Map<String, dynamic>? transactionTrends;
  final Map<String, dynamic>? projectDistribution;

  // Pagination for activities
  final int currentActivityPage;
  final bool hasMoreActivities;
  final bool isLoadingMore;

  DashboardState({
    this.summary,
    this.recentActivities = const [],
    this.transactionTrends,
    this.projectDistribution,
    this.currentActivityPage = 1,
    this.hasMoreActivities = false,
    this.isLoadingMore = false,
  });

  DashboardState copyWith({
    Map<String, dynamic>? summary,
    List<dynamic>? recentActivities,
    Map<String, dynamic>? transactionTrends,
    Map<String, dynamic>? projectDistribution,
    int? currentActivityPage,
    bool? hasMoreActivities,
    bool? isLoadingMore,
  }) {
    return DashboardState(
      summary: summary ?? this.summary,
      recentActivities: recentActivities ?? this.recentActivities,
      transactionTrends: transactionTrends ?? this.transactionTrends,
      projectDistribution: projectDistribution ?? this.projectDistribution,
      currentActivityPage: currentActivityPage ?? this.currentActivityPage,
      hasMoreActivities: hasMoreActivities ?? this.hasMoreActivities,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// ==========================================================================
// PROVIDERS
// ==========================================================================

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardState>(() {
  return DashboardController();
});

// A localized provider if you just need to grab specific stats quickly without the whole state
final dashboardSummaryProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.read(dioClientProvider).dio;
  final response = await dio.get('/dashboard/summary');

  if (response.data['success'] == true) {
    return response.data['data'];
  } else {
    throw Exception(response.data['message'] ?? 'Failed to load summary');
  }
});

// ==========================================================================
// CONTROLLER
// ==========================================================================

class DashboardController extends AsyncNotifier<DashboardState> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _basePath = '/dashboard';

  String _activityFilterType = ''; // e.g., 'TRANSACTION', 'CHECK_IN'

  @override
  Future<DashboardState> build() async {
    return _fetchInitialDashboardData();
  }

  // ==========================================================================
  // FETCH & INITIALIZATION
  // ==========================================================================

  Future<DashboardState> _fetchInitialDashboardData() async {
    // 1. If we have a filter applied, we shouldn't use the root endpoint for activities
    // because the root endpoint returns unfiltered activities.
    if (_activityFilterType.isNotEmpty) {
      final results = await Future.wait([
        _dioClient.dio.get('$_basePath/summary'),
        _dioClient.dio.get('$_basePath/charts/transactions/trends'),
        _dioClient.dio.get('$_basePath/charts/projects/distribution'),
        _fetchActivitiesData(page: 1),
      ]);

      final summaryRes = results[0] as Response;
      final trendsRes = results[1] as Response;
      final distRes = results[2] as Response;
      final activitiesData = results[3] as Map<String, dynamic>;

      return DashboardState(
        summary:
            summaryRes.data['success'] == true ? summaryRes.data['data'] : null,
        transactionTrends:
            trendsRes.data['success'] == true ? trendsRes.data['data'] : null,
        projectDistribution:
            distRes.data['success'] == true ? distRes.data['data'] : null,
        recentActivities: activitiesData['activities'],
        currentActivityPage: 1,
        hasMoreActivities: activitiesData['hasMore'],
        isLoadingMore: false,
      );
    }

    // 2. Default Initial Load: Use the heavily optimized getAdminDashboard ('/') endpoint
    // This fetches Quick Actions AND Recent Activities in one go!
    final results = await Future.wait([
      _dioClient.dio.get('$_basePath/'),
      _dioClient.dio.get('$_basePath/charts/transactions/trends'),
      _dioClient.dio.get('$_basePath/charts/projects/distribution'),
    ]);

    final adminDashboardRes = results[0];
    final trendsRes = results[1];
    final distRes = results[2];

    Map<String, dynamic>? quickActions;
    List<dynamic> initialActivities = [];
    bool hasMoreActivities = false;

    if (adminDashboardRes.data['success'] == true) {
      final data = adminDashboardRes.data['data'];
      quickActions = data['quickActions'];
      initialActivities = data['recentActivity'] ?? [];

      // The root endpoint returns top 10 activities by default.
      // If we got 10, assume there might be more to paginate.
      hasMoreActivities = initialActivities.length == 10;
    }

    return DashboardState(
      summary: quickActions != null
          ? {'quickActions': quickActions}
          : null, // Wrap to match summary endpoint structure
      transactionTrends:
          trendsRes.data['success'] == true ? trendsRes.data['data'] : null,
      projectDistribution:
          distRes.data['success'] == true ? distRes.data['data'] : null,
      recentActivities: initialActivities,
      currentActivityPage: 1,
      hasMoreActivities: hasMoreActivities,
      isLoadingMore: false,
    );
  }

  // ==========================================================================
  // ACTIVITY PAGINATION & FILTERING
  // ==========================================================================

  Future<Map<String, dynamic>> _fetchActivitiesData({required int page}) async {
    final response =
        await _dioClient.dio.get('$_basePath/activities', queryParameters: {
      'page': page,
      'limit': 10,
      if (_activityFilterType.isNotEmpty) 'type': _activityFilterType,
    });

    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      final pagination = response.data['pagination'];

      final bool hasMore = page < (pagination['pages'] ?? 1);

      return {
        'activities': data,
        'hasMore': hasMore,
      };
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch activities');
    }
  }

  Future<void> loadMoreActivities() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMoreActivities ||
        currentState.isLoadingMore) {
      return;
    }

    // Set loading state
    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentActivityPage + 1;
      final newData = await _fetchActivitiesData(page: nextPage);

      final newActivities = newData['activities'] as List<dynamic>;
      final hasMore = newData['hasMore'] as bool;

      state = AsyncValue.data(currentState.copyWith(
        recentActivities: [...currentState.recentActivities, ...newActivities],
        currentActivityPage: nextPage,
        hasMoreActivities: hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }

  // ==========================================================================
  // REFRESH & UPDATES
  // ==========================================================================

  Future<void> refresh({String? activityTypeFilter}) async {
    if (activityTypeFilter != null) {
      _activityFilterType = activityTypeFilter;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchInitialDashboardData());
  }

  /// Refreshes just the summary cards without rebuilding the entire UI/Charts
  Future<void> refreshSummaryOnly() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final response = await _dioClient.dio.get('$_basePath/summary');
      if (response.data['success'] == true) {
        state = AsyncValue.data(
            currentState.copyWith(summary: response.data['data']));
      }
    } catch (e) {
      print('Failed to refresh summary: $e');
    }
  }
}
