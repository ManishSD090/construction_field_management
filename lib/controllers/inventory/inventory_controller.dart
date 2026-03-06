import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/models/material.dart';
import 'package:construction_erp/models/inventory.dart';
import 'package:construction_erp/models/equipment.dart';
import 'package:construction_erp/models/enums.dart';

// ==========================================================================
// PROVIDERS
// ==========================================================================

final inventoryControllerProvider =
    AsyncNotifierProvider<InventoryController, InventoryState>(() {
  return InventoryController();
});

// Provider for specific Material details
final materialDetailsProvider =
    FutureProvider.family<Material, String>((ref, id) async {
  final controller = ref.read(inventoryControllerProvider.notifier);
  return controller.getMaterialById(id);
});

// Provider for specific Equipment details
final equipmentDetailsProvider =
    FutureProvider.family<Equipment, String>((ref, id) async {
  final controller = ref.read(inventoryControllerProvider.notifier);
  return controller.getEquipmentById(id);
});

// Provider for Project-specific inventory (Raw Data)
final projectInventoryProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, projectId) async {
  final controller = ref.read(inventoryControllerProvider.notifier);
  return controller.getProjectInventoryRaw(projectId);
});

// ==========================================================================
// STATE CLASS
// ==========================================================================

class InventoryState {
  final List<Inventory> inventoryItems;
  final List<Material> materialMaster;
  final List<Equipment> equipmentList;
  final List<InventoryTransfer> transfers;

  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final Map<String, dynamic> summary;

  InventoryState({
    this.inventoryItems = const [],
    this.materialMaster = const [],
    this.equipmentList = const [],
    this.transfers = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.summary = const {},
  });

  InventoryState copyWith({
    List<Inventory>? inventoryItems,
    List<Material>? materialMaster,
    List<Equipment>? equipmentList,
    List<InventoryTransfer>? transfers,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    Map<String, dynamic>? summary,
  }) {
    return InventoryState(
      inventoryItems: inventoryItems ?? this.inventoryItems,
      materialMaster: materialMaster ?? this.materialMaster,
      equipmentList: equipmentList ?? this.equipmentList,
      transfers: transfers ?? this.transfers,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      summary: summary ?? this.summary,
    );
  }
}

// ==========================================================================
// CONTROLLER
// ==========================================================================

class InventoryController extends AsyncNotifier<InventoryState> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _basePath = '/inventory';

  // Persistent Filters
  String _currentSearch = '';
  InventoryLocation _currentLocation = InventoryLocation.global;
  String? _projectId;

  @override
  Future<InventoryState> build() async {
    return _fetchPage(page: 1, isRefresh: true);
  }

  // ==========================================================================
  // FETCH & PAGINATION
  // ==========================================================================

  Future<InventoryState> _fetchPage({
    required int page,
    required bool isRefresh,
  }) async {
    final queryParams = {
      'page': page,
      'limit': 20,
      if (_currentSearch.isNotEmpty) 'search': _currentSearch,
    };

    final response = await _dioClient.dio.get(
      _currentLocation == InventoryLocation.global
          ? '$_basePath/global'
          : '$_basePath/project/$_projectId',
      queryParameters: queryParams,
    );

    final data = response.data;
    final List materialsRaw = data['data']?['materials'] ?? [];
    final List equipmentRaw = data['data']?['equipment'] ?? [];
    final summary = data['data']?['summary'] ?? {};
    final pagination = data['pagination'] ?? {};

    final newInventory =
        materialsRaw.map((i) => Inventory.fromJson(i)).toList();
    final newEquipment =
        equipmentRaw.map((e) => Equipment.fromJson(e)).toList();
    final bool hasMore = page < (pagination['totalPages'] ?? 1);

    if (isRefresh) {
      return InventoryState(
        inventoryItems: newInventory,
        equipmentList: newEquipment,
        summary: summary,
        currentPage: page,
        hasMore: hasMore,
      );
    } else {
      final currentList = state.value?.inventoryItems ?? [];
      final currentEqList = state.value?.equipmentList ?? [];
      return state.value!.copyWith(
        inventoryItems: [...currentList, ...newInventory],
        equipmentList: [...currentEqList, ...newEquipment],
        currentPage: page,
        hasMore: hasMore,
        isLoadingMore: false,
        summary: summary,
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

  Future<void> refresh({String? search}) async {
    if (search != null) _currentSearch = search;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(page: 1, isRefresh: true));
  }

  // ==========================================================================
  // VIEW MODE TOGGLES (Global vs Project)
  // ==========================================================================

  Future<void> switchToGlobalView() async {
    _currentLocation = InventoryLocation.global;
    _projectId = null;
    await refresh();
  }

  Future<void> switchToProjectView(String projectId) async {
    _currentLocation = InventoryLocation.project;
    _projectId = projectId;
    await refresh();
  }

  // ==========================================================================
  // MATERIAL MASTER ACTIONS
  // ==========================================================================

  Future<List<Material>> getAllMaterials(
      {int page = 1, int limit = 20, String? search}) async {
    final response =
        await _dioClient.dio.get('$_basePath/materials', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final List data = response.data['data'] ?? [];
    return data.map((m) => Material.fromJson(m)).toList();
  }

  Future<Material> getMaterialById(String id) async {
    final response = await _dioClient.dio.get('$_basePath/materials/$id');
    return Material.fromJson(response.data['data'] ?? {});
  }

  Future<void> createMaterialMaster(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post('$_basePath/materials', data: payload);
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<void> updateMaterialMaster(
      String id, Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.patch('$_basePath/materials/$id', data: payload);
      return _fetchPage(page: 1, isRefresh: true);
    });
    ref.invalidate(materialDetailsProvider(id));
  }

  Future<void> deleteMaterialMaster(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.delete('$_basePath/materials/$id');
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  // ==========================================================================
  // PROJECT INVENTORY UTILS
  // ==========================================================================

  Future<Map<String, dynamic>> getProjectInventoryRaw(String projectId) async {
    final response = await _dioClient.dio.get('$_basePath/project/$projectId');
    return response.data['data'] ?? {};
  }

  Future<void> addMaterialToProject(
      String projectId, Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio
          .post('$_basePath/project/$projectId/materials', data: payload);
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<void> addBulkMaterialsToProject(
      String projectId, List<Map<String, dynamic>> items) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post('$_basePath/project/$projectId/materials/bulk',
          data: {'items': items});
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<void> removeMaterialFromProject(
      String projectId, String materialId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio
          .delete('$_basePath/project/$projectId/materials/$materialId');
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<List<Map<String, dynamic>>> getProjectMaterialBatches(
      String projectId, String materialId) async {
    final response = await _dioClient.dio
        .get('$_basePath/project/$projectId/material/$materialId/batches');
    return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
  }

  // ==========================================================================
  // STOCK ACTIONS
  // ==========================================================================

  Future<void> addOpeningStock(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post('$_basePath/global/add-stock', data: payload);
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<void> addBulkStock(List<Map<String, dynamic>> items) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio
          .post('$_basePath/global/add-stock/bulk', data: {'items': items});
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  // ==========================================================================
  // EQUIPMENT ACTIONS
  // ==========================================================================

  Future<Map<String, dynamic>> getAllEquipment(
      {int page = 1,
      int limit = 20,
      String? status,
      String? ownershipType,
      String? search}) async {
    final response =
        await _dioClient.dio.get('$_basePath/equipment', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
      if (ownershipType != null) 'ownershipType': ownershipType,
      if (search != null) 'search': search,
    });

    final List data = response.data['data'] ?? [];
    return {
      'equipment': data.map((e) => Equipment.fromJson(e)).toList(),
      'summary': response.data['summary'] ?? {},
      'pagination': response.data['pagination'] ?? {},
    };
  }

  Future<Equipment> getEquipmentById(String id) async {
    final response = await _dioClient.dio.get('$_basePath/equipment/$id');
    return Equipment.fromJson(response.data['data'] ?? {});
  }

  Future<void> createEquipment(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post('$_basePath/equipment', data: payload);
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<void> updateEquipment(String id, Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.patch('$_basePath/equipment/$id', data: payload);
      return _fetchPage(page: 1, isRefresh: true);
    });
    ref.invalidate(equipmentDetailsProvider(id));
  }

  Future<void> deleteEquipment(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.delete('$_basePath/equipment/$id');
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<void> assignEquipment(String id, Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio
          .post('$_basePath/equipment/$id/assign', data: payload);
      return _fetchPage(page: 1, isRefresh: true);
    });
    ref.invalidate(equipmentDetailsProvider(id));
  }

  Future<void> releaseEquipment(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post('$_basePath/equipment/$id/release');
      return _fetchPage(page: 1, isRefresh: true);
    });
    ref.invalidate(equipmentDetailsProvider(id));
  }

  // ==========================================================================
  // TRANSFER ACTIONS
  // ==========================================================================

  Future<Map<String, dynamic>> getTransfers({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    String? fromLocation,
    String? toLocation,
  }) async {
    final response =
        await _dioClient.dio.get('$_basePath/transfers', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
      if (search != null) 'search': search,
      if (fromLocation != null) 'fromLocation': fromLocation,
      if (toLocation != null) 'toLocation': toLocation,
    });

    final List data = response.data['data'] ?? [];
    return {
      'transfers': data.map((t) => InventoryTransfer.fromJson(t)).toList(),
      'pagination': response.data['pagination'] ?? {},
    };
  }

  Future<void> initiateTransfer(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.post('$_basePath/transfers', data: payload);
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  Future<void> completeTransfer(String id, {String? notes}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _dioClient.dio.patch('$_basePath/transfers/$id/status', data: {
        'status': 'COMPLETED',
        if (notes != null) 'notes': notes,
      });
      return _fetchPage(page: 1, isRefresh: true);
    });
  }

  // ==========================================================================
  // REPORTS
  // ==========================================================================

  Future<Map<String, dynamic>> getValuationReport() async {
    final response = await _dioClient.dio.get('$_basePath/reports/valuation');
    return response.data;
  }

  // Update this method in your inventory_controller.dart
  Future<List<Map<String, dynamic>>> getLowStockReport(
      {String? projectId}) async {
    final response = await _dioClient.dio
        .get('$_basePath/reports/low-stock', queryParameters: {
      if (projectId != null) 'projectId': projectId,
    });
    return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
  }

  Future<List<StockTransaction>> getMovementReport(
      {String? materialId,
      String? transactionType,
      String? projectId,
      String? startDate,
      String? endDate}) async {
    final response = await _dioClient.dio
        .get('$_basePath/reports/movement', queryParameters: {
      if (materialId != null) 'materialId': materialId,
      if (transactionType != null) 'transactionType': transactionType,
      if (projectId != null) 'projectId': projectId,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    final List data = response.data['data'] ?? [];
    return data.map((t) => StockTransaction.fromJson(t)).toList();
  }

  Future<List<Map<String, dynamic>>> getConsumptionReport(
      {String? projectId, String? startDate, String? endDate}) async {
    final response = await _dioClient.dio
        .get('$_basePath/reports/consumption', queryParameters: {
      if (projectId != null) 'projectId': projectId,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
  }
}
