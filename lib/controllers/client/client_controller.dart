import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core Imports
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/core/dio_client.dart';

// Models
import 'package:construction_erp/models/client.dart';

// Assuming you have a ClientState similar to your ProjectState

final clientControllerProvider =
    AsyncNotifierProvider<ClientController, ClientState>(() {
  return ClientController();
});

class ClientController extends AsyncNotifier<ClientState> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _basePath = '/clients';

  // Persistent Filters
  String _currentSearch = '';
  bool? _currentIsActive;

  @override
  Future<ClientState> build() async {
    return _fetchPage(page: 1, isRefresh: true);
  }

  // ==========================================================================
  // FETCH & PAGINATION
  // ==========================================================================

  Future<ClientState> _fetchPage({
    required int page,
    required bool isRefresh,
  }) async {
    final response = await _dioClient.dio.get(_basePath, queryParameters: {
      'page': page,
      'limit': 10,
      if (_currentSearch.isNotEmpty) 'search': _currentSearch,
      if (_currentIsActive != null) 'isActive': _currentIsActive.toString(),
    });

    final data = response.data;
    final List<dynamic> listJson = data['data'];
    final pagination = data['pagination'];

    final newClients = listJson.map((json) => Client.fromJson(json)).toList();
    final bool hasMore = page < pagination['pages'];

    if (isRefresh) {
      return ClientState(
        clients: newClients,
        currentPage: page,
        hasMore: hasMore,
      );
    } else {
      final currentList = state.value?.clients ?? [];
      return state.value!.copyWith(
        clients: [...currentList, ...newClients],
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

  Future<void> refresh({String? search, bool? isActive}) async {
    if (search != null) _currentSearch = search;
    if (isActive != null) _currentIsActive = isActive;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(page: 1, isRefresh: true));
  }

  // ==========================================================================
  // CLIENT CRUD
  // ==========================================================================

  Future<void> createClient(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post(_basePath, data: payload);
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<void> updateClient(String id, Map<String, dynamic> updates) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.put('$_basePath/$id', data: updates);
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<void> deleteClient(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.delete('$_basePath/$id');
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  /// Toggle Active/Inactive Status
  Future<void> toggleStatus(String id, bool isActive) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio
          .patch('$_basePath/$id/status', data: {'isActive': isActive});
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  // ==========================================================================
  // DETAILS & ANALYTICS
  // ==========================================================================

  Future<Client> getClientDetails(String id) async {
    final response = await _dioClient.dio.get('$_basePath/$id');
    return Client.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> getClientStatistics(String id) async {
    final response = await _dioClient.dio.get('$_basePath/$id/statistics');
    return response.data['data'];
  }

  /// Fetch paginated projects belonging to a specific client
  Future<List<dynamic>> getClientProjects(String id, {int page = 1}) async {
    final response = await _dioClient.dio
        .get('$_basePath/$id/projects', queryParameters: {'page': page});
    return response.data['data'];
  }

  /// Fetch paginated invoices for a specific client
  Future<List<dynamic>> getClientInvoices(String id, {int page = 1}) async {
    final response = await _dioClient.dio
        .get('$_basePath/$id/invoices', queryParameters: {'page': page});
    return response.data['data'];
  }

  /// Fetch paginated payments for a specific client
  Future<List<dynamic>> getClientPayments(String id, {int page = 1}) async {
    final response = await _dioClient.dio
        .get('$_basePath/$id/payments', queryParameters: {'page': page});
    return response.data['data'];
  }
}
