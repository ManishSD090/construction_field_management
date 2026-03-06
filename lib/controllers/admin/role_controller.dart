import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/models/role.dart'; // Ensure this model exists

final roleControllerProvider =
    AsyncNotifierProvider<RoleController, RoleState>(() {
  return RoleController();
});

final roleDetailProvider =
    FutureProvider.autoDispose.family<Role, String>((ref, id) async {
  final dio = ref.read(dioClientProvider).dio;
  final response = await dio.get('/roles/$id');

  if (response.data['success'] == true) {
    return Role.fromJson(response.data['data']);
  } else {
    throw Exception(response.data['message'] ?? 'Failed to load role');
  }
});

class RoleController extends AsyncNotifier<RoleState> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _basePath = '/roles';

  String _searchQuery = '';

  @override
  Future<RoleState> build() async {
    return _fetchRoles(page: 1);
  }

  // ==========================================================================
  // FETCH & PAGINATION
  // ==========================================================================

  Future<RoleState> _fetchRoles({required int page}) async {
    final response = await _dioClient.dio.get(_basePath, queryParameters: {
      'page': page,
      'limit': 10,
      if (_searchQuery.isNotEmpty) 'search': _searchQuery,
    });

    // Check for successful response structure
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      final pagination = response.data['pagination'];

      // Mapping JSON to Role models
      final newRoles = data.map((json) => Role.fromJson(json)).toList();
      final bool hasMore = page < (pagination['pages'] ?? 1);

      if (page == 1) {
        return RoleState(
          roles: newRoles,
          currentPage: page,
          hasMore: hasMore,
        );
      } else {
        final currentList = state.value?.roles ?? [];
        return state.value!.copyWith(
          roles: [...currentList, ...newRoles],
          currentPage: page,
          hasMore: hasMore,
          isLoadingMore: false,
        );
      }
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch roles');
    }
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    // Using guard to catch errors and keep the previous list intact if fetch fails
    final nextState = await AsyncValue.guard(
        () => _fetchRoles(page: currentState.currentPage + 1));
    if (nextState.hasError) {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    } else {
      state = nextState;
    }
  }

  Future<void> refresh({String? search}) async {
    if (search != null) _searchQuery = search;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRoles(page: 1));
  }

  // ==========================================================================
  // MANAGEMENT ACTIONS
  // ==========================================================================

  /// Create a new role with initial permissions
  Future<void> createRole(
      String name, String description, List<String> permissions) async {
    await _dioClient.dio.post(_basePath, data: {
      'name': name,
      'description': description,
      'permissions': permissions,
    });
    await refresh();
  }

  /// Update Role Metadata
  Future<void> updateRole(String id, String name, String description) async {
    await _dioClient.dio.put('$_basePath/$id', data: {
      'name': name,
      'description': description,
    });

    // Optimistic local update
    if (state.value != null) {
      final updatedList = state.value!.roles.map((r) {
        return r.id == id
            ? r.copyWith(name: name, description: description)
            : r;
      }).toList();
      state = AsyncValue.data(state.value!.copyWith(roles: updatedList));
    }
  }

  /// Delete Role (Hard delete via Transaction in backend)
  Future<void> deleteRole(String id) async {
    await _dioClient.dio.delete('$_basePath/$id');
    if (state.value != null) {
      final updatedList = state.value!.roles.where((r) => r.id != id).toList();
      state = AsyncValue.data(state.value!.copyWith(roles: updatedList));
    }
  }

  /// Bulk Delete Roles using the existing single-delete API
  /// This iterates through the list of IDs and performs concurrent deletions.
  /// Note: Backend will prevent deletion if role has users assigned.
  Future<void> bulkDeleteRoles(List<String> ids) async {
    if (ids.isEmpty) return;

    // Use guard to handle errors and maintain state integrity
    await AsyncValue.guard(() async {
      // Perform all delete requests concurrently
      await Future.wait(
        ids.map((id) => _dioClient.dio.delete('$_basePath/$id')),
        eagerError: false, // Continue even if one fails (e.g., role has users)
      );

      return _fetchRoles(page: 1);
    });
  }

  /// Bulk Update Role Permissions
  Future<void> updatePermissions(
      String roleId, List<String> permissionCodes) async {
    await _dioClient.dio.put(
      '$_basePath/$roleId/permissions',
      data: {'permissions': permissionCodes},
    );
    // Refreshing the whole list might be overkill here, but ensures data integrity
    // if other users are editing roles simultaneously.
    await refresh();
  }
}
