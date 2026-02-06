import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/models/role.dart'; // Ensure this model exists

final roleControllerProvider =
    AsyncNotifierProvider<RoleController, RoleState>(() {
  return RoleController();
});

class RoleController extends AsyncNotifier<RoleState> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _basePath = '/roles';

  // Persistent search filter
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

    final List<dynamic> data = response.data['data'];
    final pagination = response.data['pagination'];

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
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
    state = await AsyncValue.guard(
        () => _fetchRoles(page: currentState.currentPage + 1));
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
