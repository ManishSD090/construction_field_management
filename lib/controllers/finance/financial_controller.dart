import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/dio_client.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/models/budget.dart';
import 'package:construction_erp/models/transaction.dart';
import 'package:construction_erp/models/enums.dart';

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

// Fetches full details for a single budget
final budgetDetailsProvider =
    FutureProvider.family<Budget, String>((ref, id) async {
  final controller = ref.read(financialControllerProvider.notifier);
  return controller.getBudgetById(id);
});

// Fetches the active budget for a specific project
final activeProjectBudgetProvider =
    FutureProvider.family<Budget?, String>((ref, projectId) async {
  final controller = ref.read(financialControllerProvider.notifier);
  return controller.getActiveBudget(projectId);
});

// Fetches the cashbox details for a specific project
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

  // Current filters
  String? _currentProjectId;
  BudgetStatus? _currentBudgetStatus;
  TransactionType? _currentTransactionType;

  @override
  Future<FinancialState> build() async {
    // Initially fetch the first page of both budgets and transactions
    await Future.wait([
      _fetchBudgetsPage(page: 1, isRefresh: true),
      _fetchTransactionsPage(page: 1, isRefresh: true),
    ]);
    return state.value ?? FinancialState();
  }

  // --- PRIVATE UTILITIES (Local Updates) ---

  void _updateLocalBudget(String budgetId, Budget Function(Budget) updateFn) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedBudgets = currentState.budgets.map((b) {
      if (b.id == budgetId) return updateFn(b);
      return b;
    }).toList();

    state = AsyncValue.data(currentState.copyWith(
      budgets: updatedBudgets,
      isRefreshing: false,
    ));
  }

  void _updateLocalTransaction(
      String txId, Transaction Function(Transaction) updateFn) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedTxs = currentState.transactions.map((t) {
      if (t.id == txId) return updateFn(t);
      return t;
    }).toList();

    state = AsyncValue.data(currentState.copyWith(
      transactions: updatedTxs,
      isRefreshing: false,
    ));
  }

  // --- PAGINATION & FETCHING ---

  Future<void> _fetchBudgetsPage(
      {required int page, required bool isRefresh}) async {
    final response = await _dioClient.dio.get(_budgetsPath, queryParameters: {
      'page': page,
      'limit': 15,
      if (_currentProjectId != null) 'projectId': _currentProjectId,
      if (_currentBudgetStatus != null) 'status': _currentBudgetStatus!.name,
    });

    final data = response.data;
    final List<dynamic> listJson = data['data'];
    final pagination = data['pagination'];

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
        'type': _currentTransactionType!.name,
    });

    final data = response.data;
    final List<dynamic> listJson = data['data'];
    final pagination = data['pagination'];

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

  Future<void> loadNextBudgetPage() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMoreBudgets ||
        currentState.isLoadingMoreBudgets) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingMoreBudgets: true));
    await AsyncValue.guard(() =>
        _fetchBudgetsPage(page: currentState.budgetPage + 1, isRefresh: false));
  }

  Future<void> loadNextTransactionPage() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMoreTransactions ||
        currentState.isLoadingMoreTransactions) return;

    state =
        AsyncValue.data(currentState.copyWith(isLoadingMoreTransactions: true));
    await AsyncValue.guard(() => _fetchTransactionsPage(
        page: currentState.transactionPage + 1, isRefresh: false));
  }

  Future<void> refresh(
      {String? projectId,
      BudgetStatus? budgetStatus,
      TransactionType? txType}) async {
    if (projectId != null) _currentProjectId = projectId;
    if (budgetStatus != null) _currentBudgetStatus = budgetStatus;
    if (txType != null) _currentTransactionType = txType;

    final currentState = state.value;
    state = currentState != null
        ? AsyncValue.data(currentState.copyWith(isRefreshing: true))
        : const AsyncValue.loading();

    await Future.wait([
      _fetchBudgetsPage(page: 1, isRefresh: true),
      _fetchTransactionsPage(page: 1, isRefresh: true),
    ]);
  }

  // ==========================================================================
  // PHASE 1: PLANNING (BUDGET CREATION & APPROVAL)
  // ==========================================================================

  Future<Budget> getBudgetById(String id) async {
    final response = await _dioClient.dio.get('$_budgetsPath/$id');
    return Budget.fromJson(response.data['data']);
  }

  Future<Budget?> getActiveBudget(String projectId) async {
    try {
      final response = await _dioClient.dio
          .get('$_budgetsPath/projects/$projectId/active-budget');
      if (response.data['data'] == null) return null;
      return Budget.fromJson(response.data['data']);
    } catch (e) {
      return null; // Return null if 404 or no active budget
    }
  }

  Future<void> createBudget(Map<String, dynamic> budgetData) async {
    await _dioClient.dio.post(_budgetsPath, data: budgetData);
    // Refresh budgets list to show the new DRAFT
    await _fetchBudgetsPage(page: 1, isRefresh: true);
  }

  Future<void> approveBudget(String budgetId, {String? approvalNotes}) async {
    final response = await _dioClient.dio.post(
      '$_budgetsPath/approvals/$budgetId/approve',
      data: {'approvalNotes': approvalNotes},
    );

    final updatedBudget = Budget.fromJson(response.data['data']);
    _updateLocalBudget(budgetId, (_) => updatedBudget);
    ref.invalidate(budgetDetailsProvider(budgetId));

    // Also invalidate active budget for the project since this is now active
    if (updatedBudget.projectId.isNotEmpty) {
      ref.invalidate(activeProjectBudgetProvider(updatedBudget.projectId));
    }
  }

  // ==========================================================================
  // PHASE 2: PROCUREMENT & COMMITMENTS
  // ==========================================================================

  /// Checks if there's enough budget available for a material request BEFORE creating it
  Future<Map<String, dynamic>> checkBudgetAvailability({
    required String projectId,
    required String category,
    required double estimatedCost,
  }) async {
    final response = await _dioClient.dio.get(
      '$_budgetsPath/material-requests/budget-check',
      queryParameters: {
        'projectId': projectId,
        'category': category,
        'estimatedCost': estimatedCost,
      },
    );
    return response
        .data['data']; // Returns { isAvailable, remainingAmount, etc. }
  }

  /// Commits the budget to a specific material request, reserving the funds
  Future<void> commitBudgetToRequest({
    required String requestId,
    required String budgetId,
    required String categoryId,
    required double estimatedCost,
  }) async {
    await _dioClient.dio.post(
      '$_budgetsPath/material-requests/$requestId/commit-budget',
      data: {
        'budgetId': budgetId,
        'categoryId': categoryId,
        'estimatedCost': estimatedCost,
      },
    );
    // Refresh budget details to reflect new commitment
    ref.invalidate(budgetDetailsProvider(budgetId));
  }

  /// Generates a Purchase Order directly from a requested/committed material request
  Future<void> createPOFromRequest(
      String requestId, Map<String, dynamic> poData) async {
    await _dioClient.dio.post(
      '$_budgetsPath/material-requests/$requestId/create-po',
      data: {'poData': poData},
    );
    // Might need to invalidate PO list provider if one exists in the future
  }

  // ==========================================================================
  // PHASE 3: EXECUTION & EXPENSES
  // ==========================================================================

  /// Converts a locked commitment into an actual budget expense (e.g. after Goods Receipt)
  Future<void> convertCommitmentToExpense({
    required String transactionId, // The budgetTransactionId of the commitment
    required String budgetId,
    required double actualAmount,
    double? taxAmount,
    String? expenseId,
  }) async {
    await _dioClient.dio.patch(
      '$_budgetsPath/transactions/$transactionId/convert',
      data: {
        'actualAmount': actualAmount,
        'taxAmount': taxAmount,
        'expenseId': expenseId,
      },
    );
    ref.invalidate(budgetDetailsProvider(budgetId));
  }

  // ==========================================================================
  // PHASE 4: CASH MOVEMENT (LEDGER TRANSACTIONS)
  // ==========================================================================

  Future<void> createLedgerTransaction(
      Map<String, dynamic> transactionData) async {
    final response =
        await _dioClient.dio.post(_transactionsPath, data: transactionData);
    final newTransaction = Transaction.fromJson(response.data['data']);

    // Add to top of transactions list
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
      data: {'approvalNotes': approvalNotes},
    );

    final updatedTx = Transaction.fromJson(response.data['data']);
    _updateLocalTransaction(transactionId, (_) => updatedTx);

    // Invalidate project cashbox since balance likely changed
    if (updatedTx.projectId.isNotEmpty) {
      ref.invalidate(projectCashboxProvider(updatedTx.projectId));
    }
  }

  Future<ProjectCashbox> getProjectCashbox(String projectId) async {
    final response = await _dioClient.dio
        .get('$_transactionsPath/cashbox/project/$projectId');
    return ProjectCashbox.fromJson(response.data['data']);
  }

  // ==========================================================================
  // PHASE 5: ADJUSTMENTS & TRANSFERS
  // ==========================================================================

  Future<void> transferBetweenCategories({
    required String budgetId,
    required String fromCategoryId,
    required String toCategoryId,
    required double amount,
    String? description,
  }) async {
    await _dioClient.dio.post(
      '$_budgetsPath/transactions/transfer',
      data: {
        'budgetId': budgetId,
        'fromCategoryId': fromCategoryId,
        'toCategoryId': toCategoryId,
        'amount': amount,
        'description': description,
      },
    );
    ref.invalidate(budgetDetailsProvider(budgetId));
  }

  Future<void> createBudgetRevision(
      String budgetId, Map<String, dynamic> revisionData) async {
    await _dioClient.dio
        .post('$_budgetsPath/$budgetId/revisions', data: revisionData);
    ref.invalidate(budgetDetailsProvider(budgetId));
  }

  Future<void> applyRevision(String budgetId, String revisionId) async {
    await _dioClient.dio.post('$_budgetsPath/revisions/$revisionId/apply');
    ref.invalidate(budgetDetailsProvider(budgetId));
  }
}
