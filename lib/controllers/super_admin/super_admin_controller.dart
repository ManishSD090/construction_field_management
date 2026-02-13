import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core Imports
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/core/dio_client.dart';

// Models
import 'package:construction_erp/models/company.dart';
import 'package:construction_erp/models/user.dart';

// -----------------------------------------------------------------------------
// PROVIDER
// -----------------------------------------------------------------------------
final superAdminControllerProvider =
    AsyncNotifierProvider<SuperAdminController, CompanyState>(() {
  return SuperAdminController();
});

/// New Provider to fetch and cache dashboard data
final superAdminDashboardProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(superAdminControllerProvider.notifier).getDashboardData();
});

// -----------------------------------------------------------------------------
// CONTROLLER
// -----------------------------------------------------------------------------
class SuperAdminController extends AsyncNotifier<CompanyState> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _basePathCompanies = '/companies';
  static const String _basePathSuperAdmin = '/super-admin';

  // Internal state for persistent filtering
  String _currentSearch = '';
  String? _currentStatus; // 'active' or 'inactive'

  /// 1. Initialization
  @override
  Future<CompanyState> build() async {
    // Initial Load: Page 1, Clean State
    return _fetchPage(page: 1, isRefresh: true);
  }

  // ==========================================================================
  // FETCH & PAGINATION LOGIC
  // ==========================================================================

  /// Core fetcher used by both Initial Load and Infinite Scroll
  Future<CompanyState> _fetchPage({
    required int page,
    required bool isRefresh,
  }) async {
    final response =
        await _dioClient.dio.get(_basePathCompanies, queryParameters: {
      'page': page,
      'limit': 15,
      if (_currentSearch.isNotEmpty) 'search': _currentSearch,
      if (_currentStatus != null) 'status': _currentStatus,
    });

    final data = response.data;
    final List<dynamic> newItemsJson = data['data'];
    final pagination = data['pagination'];

    final newCompanies =
        newItemsJson.map((json) => Company.fromJson(json)).toList();

    final int totalPages = pagination['pages'];
    final bool hasMore = page < totalPages;

    if (isRefresh) {
      return CompanyState(
        companies: newCompanies,
        currentPage: page,
        hasMore: hasMore,
        isLoadingMore: false,
      );
    } else {
      final currentList = state.value?.companies ?? [];

      return state.value!.copyWith(
        companies: [...currentList, ...newCompanies],
        currentPage: page,
        hasMore: hasMore,
        isLoadingMore: false,
      );
    }
  }

  /// UI triggers this to load the next page
  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    state = await AsyncValue.guard(() async {
      return _fetchPage(
        page: currentState.currentPage + 1,
        isRefresh: false,
      );
    });
  }

  /// UI triggers this for Pull-to-Refresh or changing filters
  Future<void> searchAndRefresh({String? search, String? status}) async {
    if (search != null) _currentSearch = search;
    if (status != null) _currentStatus = status;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(page: 1, isRefresh: true));
  }

  // ==========================================================================
  // CRUD OPERATIONS
  // ==========================================================================

  /// PATCH /super-admin/profile
  Future<void> updateSuperAdminProfile(Map<String, dynamic> payload) async {
    await _dioClient.dio.patch('$_basePathSuperAdmin/profile', data: payload);
    ref.invalidate(authControllerProvider);
  }

  /// POST /companies/create
  Future<void> createCompany(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post('$_basePathCompanies/create', data: payload);
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  /// PUT /companies/:id
  Future<void> updateCompany(
      {required String id, required Map<String, dynamic> updates}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.put('$_basePathCompanies/$id', data: updates);
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  /// PATCH /companies/:id/status
  Future<void> toggleCompanyStatus(
      {required String id, required bool isActive}) async {
    try {
      await _dioClient.dio.patch('$_basePathCompanies/$id/status',
          data: {'isActive': isActive});
      final updatedState = await _fetchPage(page: 1, isRefresh: true);
      state = AsyncValue.data(updatedState);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// GET /companies/:id
  Future<Company> getCompanyById(String id) async {
    final response = await _dioClient.dio.get('$_basePathCompanies/$id');
    return Company.fromJson(response.data['data']);
  }

  // ==========================================================================
  // COMPANY ADMIN MANAGEMENT
  // ==========================================================================

  /// GET /companies/:companyId/admins
  Future<List<User>> getCompanyAdmins(String companyId) async {
    final response =
        await _dioClient.dio.get('$_basePathCompanies/$companyId/admins');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => User.fromJson(json)).toList();
  }

  /// POST /companies/:companyId/admins
  Future<void> addCompanyAdmin(
      {required String companyId,
      required Map<String, dynamic> adminData}) async {
    await _dioClient.dio
        .post('$_basePathCompanies/$companyId/admins', data: adminData);
  }

  /// NEW: Update existing company admin details
  Future<void> updateCompanyAdmin({
    required String companyId,
    required String adminId,
    required Map<String, dynamic> adminData,
  }) async {
    await _dioClient.dio.put(
      '$_basePathCompanies/$companyId/admins/$adminId',
      data: adminData,
    );
  }

  /// PUT /companies/:companyId/admins/:adminId/permissions
  Future<void> updateAdminPermissions({
    required String companyId,
    required String adminId,
    required List<String> permissions,
  }) async {
    await _dioClient.dio.put(
      '$_basePathCompanies/$companyId/admins/$adminId/permissions',
      data: {'permissions': permissions},
    );
  }

  // ==========================================================================
  // NEW DASHBOARD METHODS
  // ==========================================================================

  /// GET /super-admin/dashboard
  /// Returns both stats and recent activities
  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await _dioClient.dio.get('$_basePathSuperAdmin/dashboard');
    return response.data['data'];
  }

  /// GET /super-admin/dashboard/stats
  /// Returns only statistics (active companies, users, etc.)
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response =
        await _dioClient.dio.get('$_basePathSuperAdmin/dashboard/stats');
    return response.data['data'];
  }

  /// GET /super-admin/dashboard/recent-activities
  /// Returns the list of recent system activities
  Future<List<dynamic>> getRecentActivities() async {
    final response = await _dioClient.dio
        .get('$_basePathSuperAdmin/dashboard/recent-activities');
    return response.data['data'];
  }
}
