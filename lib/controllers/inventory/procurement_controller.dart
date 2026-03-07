import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/controllers/core_providers.dart';
// Assuming you have these models defined based on your Prisma schema
import 'package:construction_erp/models/procurement.dart';

// ==========================================================================
// STATE CLASS
// ==========================================================================

class ProcurementState {
  final List<PurchaseOrder> purchaseOrders;
  final List<MaterialRequest> materialRequests;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  ProcurementState({
    this.purchaseOrders = const [],
    this.materialRequests = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  ProcurementState copyWith({
    List<PurchaseOrder>? purchaseOrders,
    List<MaterialRequest>? materialRequests,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return ProcurementState(
      purchaseOrders: purchaseOrders ?? this.purchaseOrders,
      materialRequests: materialRequests ?? this.materialRequests,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

// ==========================================================================
// PROVIDERS
// ==========================================================================

/// Main controller provider for the Procurement module
final procurementControllerProvider =
    AsyncNotifierProvider<ProcurementController, ProcurementState>(() {
  return ProcurementController();
});

/// Fetches specific PO details (includes nested items, receipts, payments)
final poDetailsProvider =
    FutureProvider.family<PurchaseOrder, String>((ref, id) async {
  final controller = ref.read(procurementControllerProvider.notifier);
  return controller.getPurchaseOrderById(id);
});

/// Fetches specific Material Request details
final materialRequestDetailsProvider =
    FutureProvider.family<MaterialRequest, String>((ref, id) async {
  final controller = ref.read(procurementControllerProvider.notifier);
  return controller.getMaterialRequestById(id);
});

/// Fetches PO Timeline
final poTimelineProvider =
    FutureProvider.family<List<dynamic>, String>((ref, id) async {
  final controller = ref.read(procurementControllerProvider.notifier);
  return controller.getPOTimeline(id);
});

// ==========================================================================
// CONTROLLER
// ==========================================================================

class ProcurementController extends AsyncNotifier<ProcurementState> {
  DioClient get _dioClient => ref.read(dioClientProvider);

  static const String _poPath = '/purchase-orders';
  static const String _mrPath = '/material-requests';

  // Active Filters
  String _currentSearch = '';
  String? _currentStatus;
  String? _currentProjectId;

  @override
  Future<ProcurementState> build() async {
    return _fetchCombinedPage(page: 1, isRefresh: true);
  }

  // --- PRIVATE UTILITIES ---

  /// Optimistically updates a local PO without full list refresh
  void _updateLocalPO(
      String id, PurchaseOrder Function(PurchaseOrder) updateFn) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedList = currentState.purchaseOrders.map((po) {
      if (po.id == id) return updateFn(po);
      return po;
    }).toList();

    state = AsyncValue.data(currentState.copyWith(purchaseOrders: updatedList));
  }

  /// Optimistically updates a local Material Request without full list refresh
  void _updateLocalMR(
      String id, MaterialRequest Function(MaterialRequest) updateFn) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedList = currentState.materialRequests.map((mr) {
      if (mr.id == id) return updateFn(mr);
      return mr;
    }).toList();

    state =
        AsyncValue.data(currentState.copyWith(materialRequests: updatedList));
  }

  Future<ProcurementState> _fetchCombinedPage(
      {required int page, required bool isRefresh}) async {
    final query = {
      'page': page,
      'limit': 10,
      if (_currentSearch.isNotEmpty) 'search': _currentSearch,
      if (_currentStatus != null) 'status': _currentStatus,
      if (_currentProjectId != null) 'projectId': _currentProjectId,
    };

    // Parallel fetching for dashboard performance
    final results = await Future.wait([
      _dioClient.dio.get(_poPath, queryParameters: query),
      _dioClient.dio.get(_mrPath, queryParameters: query),
    ]);

    final posJson = results[0].data['data'] as List;
    final mrsJson = results[1].data['data'] as List;

    final poPagination = results[0].data['pagination'];
    final mrPagination = results[1].data['pagination'];

    final pos = posJson.map((e) => PurchaseOrder.fromJson(e)).toList();
    final mrs = mrsJson.map((e) => MaterialRequest.fromJson(e)).toList();

    // Has more if either list hasn't reached its max pages
    final bool hasMorePos = page < (poPagination['pages'] ?? 1);
    final bool hasMoreMrs = page < (mrPagination['pages'] ?? 1);

    return ProcurementState(
      purchaseOrders:
          isRefresh ? pos : [...(state.value?.purchaseOrders ?? []), ...pos],
      materialRequests:
          isRefresh ? mrs : [...(state.value?.materialRequests ?? []), ...mrs],
      currentPage: page,
      hasMore: hasMorePos || hasMoreMrs,
      isLoadingMore: false,
      isRefreshing: false,
    );
  }

  // ==========================================================================
  // PAGINATION & REFRESH
  // ==========================================================================

  Future<void> refresh(
      {String? search, String? status, String? projectId}) async {
    if (search != null) _currentSearch = search;
    if (status != null) _currentStatus = status;
    if (projectId != null) _currentProjectId = projectId;

    final currentState = state.value;
    state = currentState != null
        ? AsyncValue.data(currentState.copyWith(isRefreshing: true))
        : const AsyncValue.loading();

    state = await AsyncValue.guard(
        () => _fetchCombinedPage(page: 1, isRefresh: true));
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
    state = await AsyncValue.guard(() => _fetchCombinedPage(
          page: currentState.currentPage + 1,
          isRefresh: false,
        ));
  }

  // ==========================================================================
  // MATERIAL REQUEST ACTIONS
  // ==========================================================================

  Future<void> createMaterialRequest(Map<String, dynamic> data) async {
    await _dioClient.dio.post(_mrPath, data: data);
    refresh(); // Refresh list to show new request
  }

  /// Check inventory stock globally and locally before deciding to order/transfer
  Future<Map<String, dynamic>> checkMaterialStock(
      String materialId, String projectId, double quantity) async {
    final response = await _dioClient.dio.post('$_mrPath/check-stock', data: {
      'materialId': materialId,
      'projectId': projectId,
      'quantity': quantity,
    });
    return response.data['data']; // Returns recommendation & stock levels
  }

  /// Update MR status (Handles APPROVED, REJECTED, and crucially DELIVERED which posts to inventory)
  Future<void> updateMRStatus(String id, String status, {String? notes}) async {
    final response = await _dioClient.dio.patch('$_mrPath/$id/status', data: {
      'status': status,
      if (notes != null) 'notes': notes,
    });

    final updated = MaterialRequest.fromJson(response.data['data']);
    _updateLocalMR(id, (_) => updated);
    ref.invalidate(materialRequestDetailsProvider(id));
  }

  /// Initiates an InventoryTransfer from Global to Project Stock
  Future<void> fulfillRequestFromStock(String requestId) async {
    await _dioClient.dio.post('$_mrPath/fulfill-transfer', data: {
      'requestId': requestId,
    });
    ref.invalidate(materialRequestDetailsProvider(requestId));
    refresh();
  }

  // ==========================================================================
  // PURCHASE ORDER CORE ACTIONS
  // ==========================================================================

  Future<void> createPurchaseOrder(Map<String, dynamic> data) async {
    await _dioClient.dio.post(_poPath, data: data);
    refresh();
  }

  Future<void> updatePurchaseOrder(
      String poId, Map<String, dynamic> data) async {
    final response = await _dioClient.dio.put('$_poPath/$poId', data: data);
    final updated = PurchaseOrder.fromJson(response.data['data']);
    _updateLocalPO(poId, (_) => updated);
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> deletePurchaseOrder(String poId) async {
    await _dioClient.dio.delete('$_poPath/$poId');
    refresh();
  }

  // ==========================================================================
  // PURCHASE ORDER WORKFLOW
  // ==========================================================================

  Future<void> submitPOForApproval(String poId) async {
    final response = await _dioClient.dio.post('$_poPath/$poId/submit');
    final updated = PurchaseOrder.fromJson(response.data['data']);
    _updateLocalPO(poId, (_) => updated);
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> approveRejectPO(String poId,
      {required bool approved, String? notes, String? rejectionReason}) async {
    final response =
        await _dioClient.dio.post('$_poPath/$poId/approve-reject', data: {
      'approved': approved,
      'approvalNotes': notes,
      'rejectionReason': rejectionReason,
    });
    final updated = PurchaseOrder.fromJson(response.data['data']);
    _updateLocalPO(poId, (_) => updated);
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> markAsOrdered(String poId, DateTime orderDate,
      {String? notes}) async {
    final response = await _dioClient.dio.post('$_poPath/$poId/order', data: {
      'orderDate': orderDate.toIso8601String(),
      'notes': notes,
    });
    final updated = PurchaseOrder.fromJson(response.data['data']);
    _updateLocalPO(poId, (_) => updated);
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> cancelPO(String poId, String cancellationReason) async {
    final response = await _dioClient.dio.post('$_poPath/$poId/cancel', data: {
      'cancellationReason': cancellationReason,
    });
    final updated = PurchaseOrder.fromJson(response.data['data']);
    _updateLocalPO(poId, (_) => updated);
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> closePO(String poId, {String? closureNotes}) async {
    final response = await _dioClient.dio.post('$_poPath/$poId/close', data: {
      'closureNotes': closureNotes,
    });
    final updated = PurchaseOrder.fromJson(response.data['data']);
    _updateLocalPO(poId, (_) => updated);
    ref.invalidate(poDetailsProvider(poId));
  }

  // ==========================================================================
  // PURCHASE ORDER ITEMS
  // ==========================================================================

  Future<void> addPOItem(String poId, Map<String, dynamic> data) async {
    await _dioClient.dio.post('$_poPath/$poId/items', data: data);
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> updatePOItem(
      String itemId, String poId, Map<String, dynamic> data) async {
    await _dioClient.dio.put('$_poPath/items/$itemId', data: data);
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> removePOItem(String itemId, String poId) async {
    await _dioClient.dio.delete('$_poPath/items/$itemId');
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> updateReceivedQuantity(
      String itemId, String poId, double receivedQuantity,
      {String? notes}) async {
    await _dioClient.dio.patch('$_poPath/items/$itemId/receive', data: {
      'receivedQuantity': receivedQuantity,
      'notes': notes,
    });
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> closePOItem(String itemId, String poId, {String? notes}) async {
    await _dioClient.dio.patch('$_poPath/items/$itemId/close', data: {
      'notes': notes,
    });
    ref.invalidate(poDetailsProvider(poId));
  }

  // ==========================================================================
  // GOODS RECEIPT & STOCK
  // ==========================================================================

  Future<void> createGoodsReceipt(
      String poId, Map<String, dynamic> data) async {
    // Add the poId to the payload before submitting
    final payload = {...data, 'purchaseOrderId': poId};
    await _dioClient.dio.post('$_poPath/goods-receipts', data: payload);
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> quickReceivePO(String poId,
      {String? deliveryChallanNo, String? notes}) async {
    await _dioClient.dio.post('$_poPath/$poId/quick-receive', data: {
      'deliveryChallanNo': deliveryChallanNo,
      'notes': notes,
    });
    ref.invalidate(poDetailsProvider(poId));
    refresh();
  }

  Future<void> acceptAllReceiptItems(String receiptId, String poId,
      {String? qualityRating, String? notes}) async {
    await _dioClient.dio
        .post('$_poPath/goods-receipts/$receiptId/accept-all', data: {
      'qualityRating': qualityRating,
      'notes': notes,
    });
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> rejectAllReceiptItems(String receiptId, String poId,
      {String? rejectionReason, String? returnVoucherNo, String? notes}) async {
    await _dioClient.dio
        .post('$_poPath/goods-receipts/$receiptId/reject-all', data: {
      'rejectionReason': rejectionReason,
      'returnVoucherNo': returnVoucherNo,
      'notes': notes,
    });
    ref.invalidate(poDetailsProvider(poId));
  }

  /// Highly Critical: Posts the accepted GR items to Project Inventory and hits the Budget
  Future<void> updateStockFromReceipt(String receiptId, String poId) async {
    await _dioClient.dio
        .post('$_poPath/goods-receipts/$receiptId/update-stock');
    ref.invalidate(poDetailsProvider(poId));
  }

  // --- GOODS RECEIPT INDIVIDUAL ITEMS ---

  Future<void> acceptReceiptItem(String itemId, String poId,
      {String? qualityRating, String? notes}) async {
    await _dioClient.dio
        .patch('$_poPath/goods-receipt-items/$itemId/accept', data: {
      'qualityRating': qualityRating,
      'notes': notes,
    });
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> rejectReceiptItem(String itemId, String poId,
      {String? rejectionReason, String? returnVoucherNo}) async {
    await _dioClient.dio
        .patch('$_poPath/goods-receipt-items/$itemId/reject', data: {
      'rejectionReason': rejectionReason,
      'returnVoucherNo': returnVoucherNo,
    });
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> returnReceiptItem(String itemId, String poId,
      {required double returnQuantity,
      required String returnReason,
      String? returnVoucherNo}) async {
    await _dioClient.dio
        .patch('$_poPath/goods-receipt-items/$itemId/return', data: {
      'returnQuantity': returnQuantity,
      'returnReason': returnReason,
      'returnVoucherNo': returnVoucherNo,
    });
    ref.invalidate(poDetailsProvider(poId));
  }

  // ==========================================================================
  // PAYMENTS
  // ==========================================================================

  /// Record an Advance or Final payment against a PO
  Future<void> recordPayment(String poId, Map<String, dynamic> data,
      {bool isAdvance = false}) async {
    final endpoint =
        isAdvance ? '$_poPath/$poId/advance' : '$_poPath/$poId/final-payment';
    await _dioClient.dio.post(endpoint, data: data);

    ref.invalidate(poDetailsProvider(poId));
    refresh();
  }

  Future<void> approvePOPayment(String paymentId, String poId,
      {String? approvalNotes}) async {
    await _dioClient.dio.patch('$_poPath/payments/$paymentId/approve', data: {
      'approvalNotes': approvalNotes,
    });
    ref.invalidate(poDetailsProvider(poId));
  }

  // ==========================================================================
  // DOCUMENTS
  // ==========================================================================

  Future<void> uploadPODocument(
      String poId, String filePath, String title, String documentType,
      {String? description}) async {
    final formData = FormData.fromMap({
      'title': title,
      'documentType': documentType,
      if (description != null) 'description': description,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    await _dioClient.dio.post('$_poPath/$poId/documents', data: formData);
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> deletePODocument(String documentId, String poId) async {
    await _dioClient.dio.delete('$_poPath/documents/$documentId');
    ref.invalidate(poDetailsProvider(poId));
  }

  // ==========================================================================
  // COMMENTS
  // ==========================================================================

  Future<void> addPOComment(String poId, String content,
      {bool isInternal = false}) async {
    await _dioClient.dio.post('$_poPath/$poId/comments', data: {
      'content': content,
      'isInternal': isInternal,
    });
    ref.invalidate(poDetailsProvider(poId));
  }

  Future<void> deletePOComment(String commentId, String poId) async {
    await _dioClient.dio.delete('$_poPath/comments/$commentId');
    ref.invalidate(poDetailsProvider(poId));
  }

  // ==========================================================================
  // FETCHERS (Used by FutureProviders)
  // ==========================================================================

  Future<PurchaseOrder> getPurchaseOrderById(String id) async {
    final response = await _dioClient.dio.get('$_poPath/$id');
    return PurchaseOrder.fromJson(response.data['data']);
  }

  Future<MaterialRequest> getMaterialRequestById(String id) async {
    final response = await _dioClient.dio.get('$_mrPath/$id');
    return MaterialRequest.fromJson(response.data['data']);
  }

  Future<List<dynamic>> getPOTimeline(String poId) async {
    final response = await _dioClient.dio.get('$_poPath/$poId/timeline');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getPOAuditTrail(String poId) async {
    final response = await _dioClient.dio.get('$_poPath/audit/$poId');
    return response.data['data'];
  }
}
