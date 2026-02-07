import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/enums.dart';

final userControllerProvider =
    AsyncNotifierProvider<UserController, UserState>(() {
  return UserController();
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
        if (user != null) {
          state = AsyncValue.data(state.value!.copyWith(currentUser: user));
        }
      });
    });

    // 2. Initialize with the current auth value if it exists
    final initialUser = ref.read(authControllerProvider).value;
    return UserState(currentUser: initialUser);
  }

  // ==========================================================================
  // PROFILE & DASHBOARD METHODS
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

  // ==========================================================================
  // DIRECTORY / USER LIST METHODS
  // ==========================================================================

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

    if (page == 1) {
      return state.value!.copyWith(
        userList: newUsers,
        currentPage: page,
        hasMore: hasMore,
        isLoadingMore: false,
      );
    } else {
      return state.value!.copyWith(
        userList: [...state.value!.userList, ...newUsers],
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
        currentState.isLoadingMore) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
    state = await AsyncValue.guard(
        () => _fetchUserPage(page: currentState.currentPage + 1));
  }

  // ==========================================================================
  // ACTIONS (ADMIN & SELF)
  // ==========================================================================

  /// Matches POST /users
  Future<void> createEmployee(Map<String, dynamic> data) async {
    // Guard the call to handle duplicate entry (409) or validation (400) errors
    await AsyncValue.guard(() async {
      await _dioClient.dio.post(_basePath, data: data);

      // Re-fetch page 1 to show the new employee in the directory
      final refreshedState = await _fetchUserPage(page: 1);
      state = AsyncValue.data(refreshedState);
    });
  }

  /// Update User Details (Self or Admin)
  /// Matches PUT /users/:id
  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    // Keep the previous state to avoid losing the list during the transition
    final previousState = state.value;
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // 1. Perform the update
      await _dioClient.dio.put('$_basePath/$id', data: updates);

      // 2. If the user updated THEIR OWN profile, we must refresh the Auth/Profile
      if (previousState?.currentUser?.id == id) {
        // We use the profile endpoint which returns the full user object
        await ref.read(authControllerProvider.notifier).fetchAndSyncProfile();
      }

      // 3. Re-fetch the current page to get the full, updated user list from the server
      final refreshedState =
          await _fetchUserPage(page: previousState?.currentPage ?? 1);

      // 4. Return the new state with the updated list and the newly synced currentUser
      return refreshedState.copyWith(
        currentUser: ref.read(authControllerProvider).value,
      );
    });
  }

  /// Matches DELETE /users/:id
  Future<void> deleteUser(String id) async {
    // We don't necessarily want to put the whole app in a loading state for a delete
    // but we can guard the execution.
    await AsyncValue.guard(() async {
      await _dioClient.dio.delete('$_basePath/$id');

      // Update local state immediately to remove the user from the list
      if (state.value != null) {
        final updatedList =
            state.value!.userList.where((u) => u.id != id).toList();
        state = AsyncValue.data(state.value!.copyWith(userList: updatedList));
      }
    });
  }

  /// Bulk Delete Users using the existing single-delete API
  /// This iterates through the list of IDs and performs concurrent deletions
  Future<void> bulkDeleteUsers(List<String> ids) async {
    if (ids.isEmpty) return;

    // Use guard to handle potential errors during the process
    await AsyncValue.guard(() async {
      // Perform all delete requests concurrently for better performance
      await Future.wait(
        ids.map((id) => _dioClient.dio.delete('$_basePath/$id')),
        eagerError: false, // Continue even if one delete fails
      );

      // After API calls, update the local state once
      if (state.value != null) {
        final updatedList =
            state.value!.userList.where((u) => !ids.contains(u.id)).toList();

        state = AsyncValue.data(state.value!.copyWith(userList: updatedList));
      }
    });
  }

  /// Toggle Employee Status (Activate/Deactivate)
  /// Matches PATCH /users/:id/status
  Future<void> toggleUserStatus(String id, bool isActive) async {
    // Note: We avoid setting state to loading() here to prevent the whole list
    // from flickering/disappearing during a simple toggle.
    await AsyncValue.guard(() async {
      await _dioClient.dio.patch(
        '$_basePath/$id/status',
        data: {'isActive': isActive},
      );

      if (state.value != null) {
        final updatedList = state.value!.userList.map((u) {
          if (u.id == id) {
            // Assuming your User model has a copyWith
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

  /// Update Employee Role
  /// Matches PATCH /users/:id/role
  Future<void> updateUserRole(String id, String roleId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.patch(
        '$_basePath/$id/role',
        data: {'roleId': roleId},
      );

      // Refresh the directory list to reflect the new role
      return _fetchUserPage(page: state.value?.currentPage ?? 1);
    });
  }
}
