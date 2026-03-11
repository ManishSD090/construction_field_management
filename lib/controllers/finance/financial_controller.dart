import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/models/budget.dart';
import 'package:construction_erp/models/transaction.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/models/project.dart';

// ==========================================================================
// STATE CLASS
// ==========================================================================

class FinancialState {
  final List<Budget> budgets;
  final List<Transaction> transactions;

  // Budget Pagination
  final int budgetPage;
  final bool hasMoreBudgets;
  final bool isLoadingMoreBudgets;

  // Transaction Pagination
  final int transactionPage;
  final bool hasMoreTransactions;
  final bool isLoadingMoreTransactions;

  // Global States
  final bool isRefreshing;

  FinancialState({
    this.budgets = const [],
    this.transactions = const [],
    this.budgetPage = 1,
    this.hasMoreBudgets = true,
    this.isLoadingMoreBudgets = false,
    this.transactionPage = 1,
    this.hasMoreTransactions = true,
    this.isLoadingMoreTransactions = false,
    this.isRefreshing = false,
  });

  FinancialState copyWith({
    List<Budget>? budgets,
    List<Transaction>? transactions,
    int? budgetPage,
    bool? hasMoreBudgets,
    bool? isLoadingMoreBudgets,
    int? transactionPage,
    bool? hasMoreTransactions,
    bool? isLoadingMoreTransactions,
    bool? isRefreshing,
  }) {
    return FinancialState(
      budgets: budgets ?? this.budgets,
      transactions: transactions ?? this.transactions,
      budgetPage: budgetPage ?? this.budgetPage,
      hasMoreBudgets: hasMoreBudgets ?? this.hasMoreBudgets,
      isLoadingMoreBudgets: isLoadingMoreBudgets ?? this.isLoadingMoreBudgets,
      transactionPage: transactionPage ?? this.transactionPage,
      hasMoreTransactions: hasMoreTransactions ?? this.hasMoreTransactions,
      isLoadingMoreTransactions:
          isLoadingMoreTransactions ?? this.isLoadingMoreTransactions,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

// ==========================================================================
// PROVIDERS
// ==========================================================================

final financialControllerProvider =
    AsyncNotifierProvider<FinancialController, FinancialState>(() {
  return FinancialController();
});

final budgetDetailsProvider =
    FutureProvider.family<Budget, String>((ref, id) async {
  final controller = ref.read(financialControllerProvider.notifier);
  return controller.getBudgetById(id);
});

final activeProjectBudgetProvider =
    FutureProvider.family<Budget?, String>((ref, projectId) async {
  final controller = ref.read(financialControllerProvider.notifier);
  return controller.getActiveBudget(projectId);
});

final projectBudgetsProvider =
    FutureProvider.family<List<Budget>, String>((ref, projectId) async {
  final controller = ref.read(financialControllerProvider.notifier);
  return controller.getProjectBudgets(projectId);
});

final projectCashboxProvider =
    FutureProvider.family<ProjectCashbox, String>((ref, projectId) async {
  final controller = ref.read(financialControllerProvider.notifier);
  return controller.getProjectCashbox(projectId);
});

// ==========================================================================
// CONTROLLER
// ==========================================================================

class FinancialController extends AsyncNotifier<FinancialState> {
  DioClient get _dioClient => ref.read(dioClientProvider);
  static const String _budgetsPath = '/budgets';
  static const String _transactionsPath = '/transactions';

  // Current filters for the primary state lists
  String? _currentProjectId;
  BudgetStatus? _currentBudgetStatus;
  TransactionType? _currentTransactionType;

  @override
  Future<FinancialState> build() async {
    await Future.wait([
      _fetchBudgetsPage(page: 1, isRefresh: true),
      _fetchTransactionsPage(page: 1, isRefresh: true),
    ]);
    return state.value ?? FinancialState();
  }

  // ==========================================================================
  // PRIVATE UTILITIES
  // ==========================================================================

  void _updateLocalBudget(String budgetId, Budget Function(Budget) updateFn) {
    final currentState = state.value;
    if (currentState == null) return;
    final updatedBudgets = currentState.budgets
        .map((b) => b.id == budgetId ? updateFn(b) : b)
        .toList();
    state = AsyncValue.data(currentState.copyWith(budgets: updatedBudgets));
  }

  /// Updates a single transaction in the local Riverpod state without a network refresh
  void _updateLocalTransaction(
      String txId, Transaction Function(Transaction) updateFn) {
    final currentState = state.value;
    if (currentState == null) return;
    final updatedTxs = currentState.transactions
        .map((t) => t.id == txId ? updateFn(t) : t)
        .toList();
    state = AsyncValue.data(currentState.copyWith(transactions: updatedTxs));
  }

  // ==========================================================================
  // PAGINATION & REFRESH
  // ==========================================================================

  Future<void> _fetchBudgetsPage(
      {required int page, required bool isRefresh}) async {
    final response = await _dioClient.dio.get(_budgetsPath, queryParameters: {
      'page': page,
      'limit': 15,
      if (_currentProjectId != null) 'projectId': _currentProjectId,
      if (_currentBudgetStatus != null)
        'status': _currentBudgetStatus!.toJson(),
    });
    final List<dynamic> listJson = response.data['data'];
    final pagination = response.data['pagination'];
    final newItems = listJson.map((json) => Budget.fromJson(json)).toList();
    final bool hasMore = page < (pagination['pages'] ?? 1);

    final currentState = state.value ?? FinancialState();
    state = AsyncValue.data(currentState.copyWith(
      budgets: isRefresh ? newItems : [...currentState.budgets, ...newItems],
      budgetPage: page,
      hasMoreBudgets: hasMore,
      isLoadingMoreBudgets: false,
      isRefreshing: false,
    ));
  }

  Future<void> _fetchTransactionsPage(
      {required int page, required bool isRefresh}) async {
    final response =
        await _dioClient.dio.get(_transactionsPath, queryParameters: {
      'page': page,
      'limit': 15,
      if (_currentProjectId != null) 'projectId': _currentProjectId,
      if (_currentTransactionType != null)
        'type': _currentTransactionType!.toJson(),
    });
    final List<dynamic> listJson = response.data['data'];
    final pagination = response.data['pagination'];
    final newItems =
        listJson.map((json) => Transaction.fromJson(json)).toList();
    final bool hasMore = page < (pagination['pages'] ?? 1);

    final currentState = state.value ?? FinancialState();
    state = AsyncValue.data(currentState.copyWith(
      transactions:
          isRefresh ? newItems : [...currentState.transactions, ...newItems],
      transactionPage: page,
      hasMoreTransactions: hasMore,
      isLoadingMoreTransactions: false,
      isRefreshing: false,
    ));
  }

  Future<void> refresh(
      {String? projectId,
      BudgetStatus? budgetStatus,
      TransactionType? txType}) async {
    if (projectId != null) _currentProjectId = projectId;
    if (budgetStatus != null) _currentBudgetStatus = budgetStatus;
    if (txType != null) _currentTransactionType = txType;
    state = AsyncValue.data(state.value!.copyWith(isRefreshing: true));
    await Future.wait([
      _fetchBudgetsPage(page: 1, isRefresh: true),
      _fetchTransactionsPage(page: 1, isRefresh: true),
    ]);
  }

  // ==========================================================================
  // MODULE 1: BUDGET CORE (CRUD & PROJECT SPECIFIC)
  // ==========================================================================

  Future<void> createBudget(Map<String, dynamic> budgetData) async {
    final response = await _dioClient.dio.post(_budgetsPath, data: budgetData);
    if (budgetData['projectId'] != null) {
      ref.invalidate(projectBudgetsProvider(budgetData['projectId']));
    }
    await refresh();
  }

  Future<List<Budget>> getAllBudgets({Map<String, dynamic>? filters}) async {
    final response =
        await _dioClient.dio.get(_budgetsPath, queryParameters: filters);
    final List<dynamic> data = response.data['data'];
    return data.map((json) => Budget.fromJson(json)).toList();
  }

  Future<Budget> getBudgetById(String id) async {
    final response = await _dioClient.dio.get('$_budgetsPath/$id');
    return Budget.fromJson(response.data['data']);
  }

  Future<void> updateBudget(
      String budgetId, Map<String, dynamic> updates, String projectId) async {
    final response =
        await _dioClient.dio.put('$_budgetsPath/$budgetId', data: updates);
    final updated = Budget.fromJson(response.data['data']);
    _updateLocalBudget(budgetId, (_) => updated);
    ref.invalidate(budgetDetailsProvider(budgetId));
    ref.invalidate(projectBudgetsProvider(projectId));
  }

  Future<void> deleteBudget(String budgetId, String projectId) async {
    await _dioClient.dio.delete('$_budgetsPath/$budgetId');
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(
        budgets: currentState.budgets.where((b) => b.id != budgetId).toList(),
      ));
    }
    ref.invalidate(projectBudgetsProvider(projectId));
  }

  Future<void> updateBudgetStatus({
    required String budgetId,
    required String projectId,
    required BudgetStatus status,
    String? approvalNotes,
    String? rejectionReason,
  }) async {
    final response =
        await _dioClient.dio.patch('$_budgetsPath/$budgetId/status', data: {
      'status': status.toJson(),
      if (approvalNotes != null) 'approvalNotes': approvalNotes,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    });
    final updated = Budget.fromJson(response.data['data']);
    _updateLocalBudget(budgetId, (_) => updated);
    ref.invalidate(budgetDetailsProvider(budgetId));
    ref.invalidate(projectBudgetsProvider(projectId));
    if (status == BudgetStatus.active) {
      ref.invalidate(activeProjectBudgetProvider(projectId));
    }
  }

  Future<List<Budget>> getProjectBudgets(String projectId) async {
    final response =
        await _dioClient.dio.get('$_budgetsPath/projects/$projectId/budgets');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => Budget.fromJson(json)).toList();
  }

  Future<Budget?> getActiveBudget(String projectId) async {
    try {
      final response = await _dioClient.dio
          .get('$_budgetsPath/projects/$projectId/active-budget');
      if (response.data['data'] == null) return null;
      return Budget.fromJson(response.data['data']);
    } catch (e) {
      return null;
    }
  }

  Future<List<Budget>> searchBudgets(String query,
      {BudgetStatus? status, String? projectId}) async {
    final response =
        await _dioClient.dio.get('$_budgetsPath/search', queryParameters: {
      'q': query,
      if (status != null) 'status': status.toJson(),
      if (projectId != null) 'projectId': projectId,
    });
    final List<dynamic> data = response.data['data'];
    return data.map((json) => Budget.fromJson(json)).toList();
  }

  // ==========================================================================
  // MODULE 2: BUDGET CATEGORIES
  // ==========================================================================

  Future<List<BudgetCategoryAllocation>> getBudgetCategories(
      String budgetId) async {
    final response =
        await _dioClient.dio.get('$_budgetsPath/$budgetId/categories');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => BudgetCategoryAllocation.fromJson(json)).toList();
  }

  Future<BudgetCategoryAllocation> getBudgetCategoryById(
      String budgetId, String categoryId) async {
    final response = await _dioClient.dio
        .get('$_budgetsPath/$budgetId/categories/$categoryId');
    return BudgetCategoryAllocation.fromJson(response.data['data']);
  }

  Future<void> addBudgetCategory(
      String budgetId, Map<String, dynamic> categoryData) async {
    await _dioClient.dio
        .post('$_budgetsPath/$budgetId/categories', data: categoryData);
    ref.invalidate(budgetDetailsProvider(budgetId));
  }

  Future<void> updateBudgetCategory(
      String budgetId, String categoryId, Map<String, dynamic> updates) async {
    await _dioClient.dio
        .put('$_budgetsPath/$budgetId/categories/$categoryId', data: updates);
    ref.invalidate(budgetDetailsProvider(budgetId));
  }

  Future<void> deleteBudgetCategory(String budgetId, String categoryId) async {
    await _dioClient.dio
        .delete('$_budgetsPath/$budgetId/categories/$categoryId');
    ref.invalidate(budgetDetailsProvider(budgetId));
  }

  Future<void> transferBudgetAmount(String budgetId, String categoryId,
      Map<String, dynamic> transferData) async {
    await _dioClient.dio.post(
        '$_budgetsPath/$budgetId/categories/$categoryId/transfer',
        data: transferData);
    ref.invalidate(budgetDetailsProvider(budgetId));
  }

  // ==========================================================================
  // MODULE 3: BUDGET TRANSACTIONS
  // ==========================================================================

  Future<List<BudgetTransaction>> getBudgetTransactions(String budgetId,
      {Map<String, dynamic>? params}) async {
    final response = await _dioClient.dio
        .get('$_budgetsPath/$budgetId/transactions', queryParameters: params);
    final List<dynamic> data = response.data['data'];
    return data.map((json) => BudgetTransaction.fromJson(json)).toList();
  }

  Future<List<BudgetTransaction>> getBudgetCommitments(String budgetId) async {
    final response = await _dioClient.dio
        .get('$_budgetsPath/$budgetId/transactions/commitments');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => BudgetTransaction.fromJson(json)).toList();
  }

  Future<List<BudgetTransaction>> getBudgetExpenses(String budgetId) async {
    final response = await _dioClient.dio
        .get('$_budgetsPath/$budgetId/transactions/expenses');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => BudgetTransaction.fromJson(json)).toList();
  }

  Future<void> createCommitment(Map<String, dynamic> data) async {
    await _dioClient.dio.post('$_budgetsPath/transactions/commit', data: data);
    if (data['budgetId'] != null) {
      ref.invalidate(budgetDetailsProvider(data['budgetId']));
    }
  }

  Future<void> createExpenseTransaction(Map<String, dynamic> data) async {
    await _dioClient.dio.post('$_budgetsPath/transactions/expense', data: data);
    if (data['budgetId'] != null) {
      ref.invalidate(budgetDetailsProvider(data['budgetId']));
    }
  }

  Future<void> transferBetweenCategories(Map<String, dynamic> data) async {
    await _dioClient.dio
        .post('$_budgetsPath/transactions/transfer', data: data);
    if (data['budgetId'] != null) {
      ref.invalidate(budgetDetailsProvider(data['budgetId']));
    }
  }

  Future<void> updateBudgetTransactionStatus(
      String transactionId, BudgetTransactionStatus status,
      {String? notes}) async {
    await _dioClient.dio
        .patch('$_budgetsPath/transactions/$transactionId/status', data: {
      'status': status.toJson(),
      'notes': notes,
    });
  }

  Future<void> convertCommitmentToExpense(
      String transactionId, Map<String, dynamic> data) async {
    await _dioClient.dio
        .patch('$_budgetsPath/transactions/$transactionId/convert', data: data);
  }

  // ==========================================================================
  // MODULE 4: BUDGET REVISIONS
  // ==========================================================================

  Future<List<BudgetRevision>> getBudgetRevisions(String budgetId,
      {BudgetRevisionStatus? status}) async {
    final response = await _dioClient.dio.get(
      '$_budgetsPath/$budgetId/revisions',
      queryParameters: {
        if (status != null) 'status': status.toJson(),
      },
    );
    final List<dynamic> data = response.data['data'];
    return data.map((json) => BudgetRevision.fromJson(json)).toList();
  }

  Future<void> createBudgetRevision(
      String budgetId, Map<String, dynamic> revisionData) async {
    await _dioClient.dio
        .post('$_budgetsPath/$budgetId/revisions', data: revisionData);
    ref.invalidate(budgetDetailsProvider(budgetId));
  }

  Future<void> submitRevisionForApproval(
      String revisionId, Map<String, dynamic> data) async {
    await _dioClient.dio
        .post('$_budgetsPath/revisions/$revisionId/submit', data: data);
  }

  Future<void> approveRejectRevision(
      String revisionId, Map<String, dynamic> data) async {
    await _dioClient.dio
        .post('$_budgetsPath/revisions/$revisionId/approve-reject', data: data);
  }

  Future<void> applyRevision(String budgetId, String revisionId) async {
    await _dioClient.dio.post('$_budgetsPath/revisions/$revisionId/apply');
    ref.invalidate(budgetDetailsProvider(budgetId));
  }

  // ==========================================================================
  // MODULE 5: BUDGET ALERTS & FORECASTS
  // ==========================================================================

  Future<List<BudgetAlert>> getBudgetAlerts(String budgetId,
      {bool? resolved}) async {
    final response = await _dioClient.dio
        .get('$_budgetsPath/$budgetId/alerts', queryParameters: {
      if (resolved != null) 'resolved': resolved,
    });
    final List<dynamic> data = response.data['data'];
    return data.map((json) => BudgetAlert.fromJson(json)).toList();
  }

  Future<void> resolveAlert(String alertId, Map<String, dynamic> data) async {
    await _dioClient.dio
        .post('$_budgetsPath/alerts/$alertId/resolve', data: data);
  }

  Future<List<BudgetForecast>> getBudgetForecasts(String budgetId) async {
    final response =
        await _dioClient.dio.get('$_budgetsPath/$budgetId/forecasts');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => BudgetForecast.fromJson(json)).toList();
  }

  Future<void> createForecast(
      String budgetId, Map<String, dynamic> data) async {
    await _dioClient.dio.post('$_budgetsPath/$budgetId/forecasts', data: data);
  }

  Future<Map<String, dynamic>> getVarianceAnalysis(String budgetId,
      {Map<String, dynamic>? params}) async {
    final response = await _dioClient.dio
        .get('$_budgetsPath/$budgetId/variance', queryParameters: params);
    return response.data['data'];
  }

  // ==========================================================================
  // MODULE 6: DASHBOARD & REPORTS
  // ==========================================================================

  Future<Map<String, dynamic>> getBudgetSummary(
      {Map<String, dynamic>? params}) async {
    final response = await _dioClient.dio
        .get('$_budgetsPath/dashboard/summary', queryParameters: params);
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getProjectBudgetStatus(String projectId,
      {Map<String, dynamic>? params}) async {
    final response = await _dioClient.dio.get(
        '$_budgetsPath/dashboard/project/$projectId/status',
        queryParameters: params);
    return response.data['data'];
  }

  Future<List<dynamic>> getBudgetUtilizationReport(
      {Map<String, dynamic>? params}) async {
    final response = await _dioClient.dio
        .get('$_budgetsPath/reports/utilization', queryParameters: params);
    return response.data['data'];
  }

  Future<List<dynamic>> getBudgetVarianceReport(
      {Map<String, dynamic>? params}) async {
    final response = await _dioClient.dio
        .get('$_budgetsPath/reports/variance', queryParameters: params);
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getCategorySpendingReport(
      {Map<String, dynamic>? params}) async {
    final response = await _dioClient.dio.get(
        '$_budgetsPath/reports/category-spending',
        queryParameters: params);
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getCommitmentTrackingReport(
      {Map<String, dynamic>? params}) async {
    final response = await _dioClient.dio.get(
        '$_budgetsPath/reports/commitment-tracking',
        queryParameters: params);
    return response.data['data'];
  }

  // ==========================================================================
  // MODULE 7: MATERIAL REQUEST INTEGRATION
  // ==========================================================================

  Future<Map<String, dynamic>> checkBudgetAvailability({
    required String projectId,
    required BudgetCategory category,
    required double estimatedCost,
  }) async {
    final response = await _dioClient.dio
        .get('$_budgetsPath/material-requests/budget-check', queryParameters: {
      'projectId': projectId,
      'category': category.toJson(),
      'estimatedCost': estimatedCost,
    });
    return response.data['data'];
  }

  Future<void> commitBudgetToRequest({
    required String requestId,
    required String budgetId,
    required String categoryId,
    double? estimatedCost,
  }) async {
    await _dioClient.dio.post(
        '$_budgetsPath/material-requests/$requestId/commit-budget',
        data: {
          'budgetId': budgetId,
          'categoryId': categoryId,
          if (estimatedCost != null) 'estimatedCost': estimatedCost,
        });
  }

  Future<Map<String, dynamic>> getBudgetStatusForRequest(
      String requestId) async {
    final response = await _dioClient.dio
        .get('$_budgetsPath/material-requests/$requestId/budget-status');
    return response.data['data'];
  }

  Future<void> createPOFromRequest(
      String requestId, Map<String, dynamic> poData) async {
    await _dioClient.dio.post(
        '$_budgetsPath/material-requests/$requestId/create-po',
        data: {'poData': poData});
  }

  // ==========================================================================
  // MODULE 8: APPROVALS & AUDIT
  // ==========================================================================

  Future<Map<String, dynamic>> getPendingBudgetApprovals(
      {Map<String, dynamic>? params}) async {
    final response = await _dioClient.dio
        .get('$_budgetsPath/approvals/pending', queryParameters: params);
    return response.data['data'];
  }

  Future<void> approveBudget(String budgetId, {String? approvalNotes}) async {
    await _dioClient.dio.post('$_budgetsPath/approvals/$budgetId/approve',
        data: {'approvalNotes': approvalNotes});
    await refresh();
  }

  Future<void> rejectBudget(String budgetId,
      {required String rejectionReason}) async {
    await _dioClient.dio.post('$_budgetsPath/approvals/$budgetId/reject',
        data: {'rejectionReason': rejectionReason});
    await refresh();
  }

  Future<List<dynamic>> getBudgetAuditTrail(String budgetId,
      {Map<String, dynamic>? params}) async {
    final response = await _dioClient.dio
        .get('$_budgetsPath/audit/$budgetId', queryParameters: params);
    return response.data['data'];
  }

  // ==========================================================================
  // MODULE 9: LEDGER TRANSACTIONS (STRONGLY TYPED)
  // ==========================================================================

  Future<void> createLedgerTransaction(
      Map<String, dynamic> transactionData) async {
    final response =
        await _dioClient.dio.post(_transactionsPath, data: transactionData);
    final newTransaction = Transaction.fromJson(response.data['data']);

    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(
        transactions: [newTransaction, ...currentState.transactions],
      ));
    }
  }

  Future<void> approveLedgerTransaction(String transactionId,
      {String? approvalNotes}) async {
    final response = await _dioClient.dio.patch(
        '$_transactionsPath/$transactionId/approve',
        data: {'approvalNotes': approvalNotes});

    final updatedTx = Transaction.fromJson(response.data['data']);
    _updateLocalTransaction(transactionId, (_) => updatedTx);

    if (updatedTx.projectId.isNotEmpty) {
      ref.invalidate(projectCashboxProvider(updatedTx.projectId));
    }
  }

  Future<void> rejectLedgerTransaction(String transactionId,
      {required String rejectionReason}) async {
    final response = await _dioClient.dio.patch(
      '$_transactionsPath/$transactionId/reject',
      data: {'rejectionReason': rejectionReason},
    );

    final updatedTx = Transaction.fromJson(response.data['data']);
    _updateLocalTransaction(transactionId, (_) => updatedTx);
  }

  Future<void> voidLedgerTransaction(String transactionId,
      {required String voidReason}) async {
    final response = await _dioClient.dio.patch(
      '$_transactionsPath/$transactionId/void',
      data: {'voidReason': voidReason},
    );

    final updatedTx = Transaction.fromJson(response.data['data']);
    _updateLocalTransaction(transactionId, (_) => updatedTx);

    if (updatedTx.projectId.isNotEmpty) {
      ref.invalidate(projectCashboxProvider(updatedTx.projectId));
    }
  }

  Future<void> updatePendingLedgerTransaction(
      String transactionId, Map<String, dynamic> updates) async {
    final response = await _dioClient.dio.put(
      '$_transactionsPath/$transactionId',
      data: updates,
    );

    final updatedTx = Transaction.fromJson(response.data['data']);
    _updateLocalTransaction(transactionId, (_) => updatedTx);
  }

  Future<ProjectCashbox> getProjectCashbox(String projectId) async {
    final response = await _dioClient.dio
        .get('$_transactionsPath/cashbox/project/$projectId');
    return ProjectCashbox.fromJson(response.data['data']);
  }

  // --- REPORTS & STATEMENTS ---

  Future<Map<String, dynamic>> getProjectTransactionSummary(String projectId,
      {Map<String, dynamic>? params}) async {
    final response = await _dioClient.dio.get(
      '$_transactionsPath/summary/project/$projectId',
      queryParameters: params,
    );
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getProjectCashboxStatement(String projectId,
      {Map<String, dynamic>? params}) async {
    final response = await _dioClient.dio.get(
      '$_transactionsPath/cashbox/project/$projectId/statement',
      queryParameters: params,
    );

    final data = response.data['data'];

    return {
      'project':
          data['project'] != null ? Project.fromJson(data['project']) : null,
      'cashbox': ProjectCashbox.fromJson(data['cashbox']),
      'statement': (data['statement'] as List)
          .map((e) => {
                'transaction': Transaction.fromJson(e),
                'delta': (e['delta'] as num).toDouble(),
                'runningBalance': (e['runningBalance'] as num).toDouble(),
              })
          .toList(),
    };
  }
}
