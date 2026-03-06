import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/enums.dart';

// UserState model assumed to be defined elsewhere with copyWith support
// If it's not defined, ensure it handles userList, currentPage, hasMore, etc.

final userControllerProvider =
    AsyncNotifierProvider<UserController, UserState>(() {
  return UserController();
});

final userDetailProvider =
    FutureProvider.autoDispose.family<User, String>((ref, id) async {
  // Use the notifier to trigger the API-based fetch
  return await ref.read(userControllerProvider.notifier).fetchUserById(id);
});

class UserController extends AsyncNotifier<UserState> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _basePath = '/users';

  // Filters for Directory
  String _searchQuery = '';
  String? _department;
  String? _status;

  @override
  Future<UserState> build() async {
    // 1. Listen to AuthController
    // When the authenticated user changes, update our local UserState
    ref.listen<AsyncValue<User?>>(authControllerProvider, (previous, next) {
      next.whenData((user) {
        if (user != null && state.value != null) {
          state = AsyncValue.data(state.value!.copyWith(currentUser: user));
        }
      });
    });

    // 2. Initialize with the current auth value if it exists
    final initialUser = ref.read(authControllerProvider).value;
    return UserState(currentUser: initialUser);
  }

  // ==========================================================================
  // FETCH & REFRESH METHODS
  // ==========================================================================

  /// Refresh the user list (Page 1) while maintaining or updating filters
  Future<void> refresh(
      {String? search, String? department, String? status}) async {
    if (search != null) _searchQuery = search;
    if (department != null) _department = department;
    if (status != null) _status = status;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _fetchUserPage(page: 1);
    });
  }

  /// Fetch or Refresh the list of all users (Paginated)
  Future<void> fetchUsers(
      {String? search, String? department, String? status}) async {
    _searchQuery = search ?? _searchQuery;
    _department = department ?? _department;
    _status = status ?? _status;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _fetchUserPage(page: 1);
    });
  }

  /// Internal helper for pagination
  Future<UserState> _fetchUserPage({required int page}) async {
    final response = await _dioClient.dio.get(_basePath, queryParameters: {
      'page': page,
      'limit': 10,
      if (_searchQuery.isNotEmpty) 'search': _searchQuery,
      if (_department != null) 'department': _department,
      if (_status != null) 'status': _status,
    });

    final List<dynamic> listJson = response.data['data'];
    final pagination = response.data['pagination'];
    final newUsers = listJson.map((json) => User.fromJson(json)).toList();
    final bool hasMore = page < (pagination['pages'] ?? 1);

    final currentVal = state.value ?? UserState();

    if (page == 1) {
      return currentVal.copyWith(
        userList: newUsers,
        currentPage: page,
        hasMore: hasMore,
        isLoadingMore: false,
      );
    } else {
      return currentVal.copyWith(
        userList: [...currentVal.userList, ...newUsers],
        currentPage: page,
        hasMore: hasMore,
        isLoadingMore: false,
      );
    }
  }

  /// Load next page for the user directory
  Future<void> loadMoreUsers() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
    state = await AsyncValue.guard(
        () => _fetchUserPage(page: currentState.currentPage + 1));
  }

  // ==========================================================================
  // PROFILE & INDIVIDUAL FETCH
  // ==========================================================================

  /// Fetch the currently logged-in user's profile/dashboard
  Future<void> fetchMyDashboard() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await _dioClient.dio.get('$_basePath/dashboard/me');
      final user = User.fromJson(response.data['data']);
      return state.value!.copyWith(currentUser: user);
    });
  }

  /// Fetch a single employee's full details by ID
  Future<User> fetchUserById(String id) async {
    final response = await _dioClient.dio.get('$_basePath/$id');

    if (response.data['success'] == true) {
      return User.fromJson(response.data['data']);
    } else {
      throw Exception(
          response.data['message'] ?? 'Failed to fetch employee details');
    }
  }

  // ==========================================================================
  // ACTIONS (ADMIN & SELF)
  // ==========================================================================

  Future<void> createEmployee(Map<String, dynamic> data) async {
    await AsyncValue.guard(() async {
      await _dioClient.dio.post(_basePath, data: data);
      final refreshedState = await _fetchUserPage(page: 1);
      state = AsyncValue.data(refreshedState);
    });
  }

  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    final previousState = state.value;
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _dioClient.dio.put('$_basePath/$id', data: updates);

      if (previousState?.currentUser?.id == id) {
        await ref.read(authControllerProvider.notifier).fetchAndSyncProfile();
      }

      final refreshedState =
          await _fetchUserPage(page: previousState?.currentPage ?? 1);

      return refreshedState.copyWith(
        currentUser: ref.read(authControllerProvider).value,
      );
    });
  }

  Future<void> deleteUser(String id) async {
    await AsyncValue.guard(() async {
      await _dioClient.dio.delete('$_basePath/$id');

      if (state.value != null) {
        final updatedList =
            state.value!.userList.where((u) => u.id != id).toList();
        state = AsyncValue.data(state.value!.copyWith(userList: updatedList));
      }
    });
  }

  Future<void> bulkDeleteUsers(List<String> ids) async {
    if (ids.isEmpty) return;

    await AsyncValue.guard(() async {
      await Future.wait(
        ids.map((id) => _dioClient.dio.delete('$_basePath/$id')),
        eagerError: false,
      );

      if (state.value != null) {
        final updatedList =
            state.value!.userList.where((u) => !ids.contains(u.id)).toList();
        state = AsyncValue.data(state.value!.copyWith(userList: updatedList));
      }
    });
  }

  Future<void> toggleUserStatus(String id, bool isActive) async {
    await AsyncValue.guard(() async {
      await _dioClient.dio.patch(
        '$_basePath/$id/status',
        data: {'isActive': isActive},
      );

      if (state.value != null) {
        final updatedList = state.value!.userList.map((u) {
          if (u.id == id) {
            return u.copyWith(
                isActive: isActive,
                employeeStatus:
                    isActive ? EmployeeStatus.active : EmployeeStatus.inactive);
          }
          return u;
        }).toList();

        state = AsyncValue.data(state.value!.copyWith(userList: updatedList));
      }
    });
  }

  Future<void> updateUserRole(String id, String roleId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.patch(
        '$_basePath/$id/role',
        data: {'roleId': roleId},
      );
      return _fetchUserPage(page: state.value?.currentPage ?? 1);
    });
  }
}
