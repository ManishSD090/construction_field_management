import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/finance/financial_controller.dart';
import 'package:construction_erp/models/budget.dart';
import 'package:construction_erp/models/enums.dart';

import 'package:construction_erp/screens/budget/add_record_screen.dart';
// Import the new details screen
import 'package:construction_erp/screens/budget/transaction_details_screen.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  final String budgetId;
  final String projectId; // Added projectId to fetch cashbox data

  const TransactionHistoryScreen({
    super.key,
    required this.budgetId,
    required this.projectId,
  });

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  // State
  int _selectedTabIndex = 0; // 0: Commitments, 1: Expenses, 2: Transfers
  DateTime? _selectedDate;
  String _selectedStatusFilter = 'All';

  // Data
  List<BudgetTransaction> _allTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTransactions();
    });
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      final txs = await ref
          .read(financialControllerProvider.notifier)
          .getBudgetTransactions(widget.budgetId);

      setState(() {
        _allTransactions = txs;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load transactions: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Filtering Logic based on Budget Schema Workflow
  List<BudgetTransaction> get _filteredTransactions {
    BudgetTransactionType currentType;
    if (_selectedTabIndex == 0) {
      currentType = BudgetTransactionType.commitment;
    } else if (_selectedTabIndex == 1) {
      currentType = BudgetTransactionType.expense;
    } else {
      currentType = BudgetTransactionType.transfer;
    }

    return _allTransactions.where((tx) {
      bool typeMatches = tx.transactionType == currentType;

      bool dateMatches = true;
      if (_selectedDate != null) {
        dateMatches = tx.transactionDate.year == _selectedDate!.year &&
            tx.transactionDate.month == _selectedDate!.month &&
            tx.transactionDate.day == _selectedDate!.day;
      }

      bool statusMatches = true;
      if (_selectedTabIndex == 0 && _selectedStatusFilter != 'All') {
        statusMatches =
            tx.status.name.toUpperCase() == _selectedStatusFilter.toUpperCase();
      }

      return typeMatches && dateMatches && statusMatches;
    }).toList();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(primary: AppColors.primaryBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showAddTransactionOptions() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Add New Record",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.alertRed.withOpacity(0.1),
                      child: const Icon(Icons.receipt_long,
                          color: AppColors.alertRed),
                    ),
                    title: const Text('Log General Expense'),
                    subtitle: const Text('Directly record a spent amount'),
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRecordScreen(
                            budgetId: widget.budgetId,
                            initialType: RecordType.expense,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.withOpacity(0.1),
                      child: const Icon(Icons.assignment, color: Colors.orange),
                    ),
                    title: const Text('Create General Commitment'),
                    subtitle: const Text('Reserve budget for future spending'),
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRecordScreen(
                            budgetId: widget.budgetId,
                            initialType: RecordType.commitment,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                      child: const Icon(Icons.swap_horiz,
                          color: AppColors.primaryBlue),
                    ),
                    title: const Text('Transfer Funds'),
                    subtitle: const Text('Move funds between categories'),
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRecordScreen(
                            budgetId: widget.budgetId,
                            initialType: RecordType.transfer,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Budget Transactions",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 0. Project Cashbox Banner
          _buildCashboxBanner(),

          // 1. Custom Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _buildTabButton("Commitments", 0),
                _buildTabButton("Expenses", 1),
                _buildTabButton("Transfers", 2),
              ],
            ),
          ),

          // 2. Date & Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Date Picker Button
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryBlue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedDate == null
                              ? "Select Date"
                              : DateFormat('MMM dd, yyyy')
                                  .format(_selectedDate!),
                          style: TextStyle(
                            color: _selectedDate == null
                                ? Colors.grey
                                : Colors.black,
                            fontSize: 13,
                            fontWeight: _selectedDate != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_selectedDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _selectedDate = null),
                            child: const Icon(Icons.close,
                                color: AppColors.alertRed, size: 16),
                          )
                        else
                          const Icon(Icons.calendar_today,
                              color: AppColors.primaryBlue, size: 16),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Filter Button (Only visible on Commitments Tab)
                if (_selectedTabIndex == 0)
                  PopupMenuButton<String>(
                    onSelected: (val) =>
                        setState(() => _selectedStatusFilter = val),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'All', child: Text("All")),
                      const PopupMenuItem(
                          value: 'Pending', child: Text("Pending")),
                      const PopupMenuItem(
                          value: 'Committed', child: Text("Committed")),
                      const PopupMenuItem(
                          value: 'Disbursed', child: Text("Disbursed")),
                      const PopupMenuItem(
                          value: 'Cancelled', child: Text("Cancelled")),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(20),
                        color: _selectedStatusFilter != 'All'
                            ? AppColors.primaryBlue.withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      child: const Row(
                        children: [
                          Text("Filter", style: TextStyle(fontSize: 13)),
                          SizedBox(width: 4),
                          Icon(Icons.tune, size: 16),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 24, thickness: 1),

          // 3. Transaction List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchTransactions,
                    child: _filteredTransactions.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                  child: Text("No transactions found",
                                      style: TextStyle(color: Colors.grey))),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final tx = _filteredTransactions[index];
                              return _buildTransactionCard(tx);
                            },
                          ),
                  ),
          ),

          // 4. Create Action Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showAddTransactionOptions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Add Record",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== WIDGET COMPONENTS ==================

  Widget _buildCashboxBanner() {
    final cashboxAsync = ref.watch(projectCashboxProvider(widget.projectId));

    return cashboxAsync.when(
      data: (cashbox) {
        final formatter = NumberFormat("#,##,000.00");
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Project Cashbox Balance",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  Icon(
                      cashbox.isActive
                          ? Icons.account_balance_wallet
                          : Icons.lock_outline,
                      color: Colors.white70,
                      size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "${cashbox.currency} ${formatter.format(cashbox.currentBalance)}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) =>
          const SizedBox.shrink(), // Hide if failed/unauthorized
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            _selectedDate = null; // Reset filters on tab switch
            _selectedStatusFilter = 'All';
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textGrey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Formatting helper for Request/Reference tags
  String _formatReferenceType(String? refType) {
    if (refType == null) return '';
    switch (refType) {
      case 'MATERIAL_REQUEST':
        return 'Material Request';
      case 'PURCHASE_ORDER':
        return 'Purchase Order';
      case 'CONTRACTOR_PAYMENT':
        return 'Contractor Pay';
      case 'PAYROLL':
        return 'Payroll';
      case 'EXPENSE':
        return 'General Expense';
      default:
        return refType.replaceAll('_', ' ');
    }
  }

  Widget _buildTransactionCard(BudgetTransaction tx) {
    final formatter = NumberFormat("#,##,000.00");
    String amountString = "₹${formatter.format(tx.amount)}";

    Color amountColor = AppColors.primaryBlue;
    if (tx.transactionType == BudgetTransactionType.expense) {
      amountColor = AppColors.alertRed;
    } else if (tx.transactionType == BudgetTransactionType.commitment) {
      if (tx.status == BudgetTransactionStatus.disbursed) {
        amountColor = AppColors.successGreen;
      } else if (tx.status == BudgetTransactionStatus.cancelled) {
        amountColor = AppColors.alertRed;
      }
    } else if (tx.transactionType == BudgetTransactionType.transfer) {
      amountColor = Colors.orange; // Make transfer amounts distinctly colored
    }

    Color badgeColor = Colors.grey;
    if (tx.status == BudgetTransactionStatus.committed) {
      badgeColor = Colors.orange;
    }
    if (tx.status == BudgetTransactionStatus.disbursed) {
      badgeColor = AppColors.successGreen;
    }
    if (tx.status == BudgetTransactionStatus.cancelled) {
      badgeColor = AppColors.alertRed;
    }

    // 1. Build accurate base Category Name (Strictly Main Category only)
    String categoryName = 'UNCATEGORIZED';
    if (tx.category != null) {
      categoryName = tx.category!.category.name.toUpperCase();
    }

    // 2. Widget logic for Category Name vs From->To visual for transfers
    Widget sourceDestinationWidget;

    if (tx.transactionType == BudgetTransactionType.transfer) {
      String fromCat = categoryName;
      String toCat = "UNKNOWN";

      if (tx.transferToCategory != null) {
        toCat = tx.transferToCategory!.category.name.toUpperCase();
      }

      sourceDestinationWidget = Row(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                fromCat,
                style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                toCat,
                style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    } else {
      sourceDestinationWidget = Text(
        categoryName,
        style: const TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: 12),
        overflow: TextOverflow.ellipsis,
      );
    }

    // Identify if this transaction has a linked request
    bool hasRequestLink =
        tx.referenceType != null && tx.referenceType!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Open Details Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailsScreen(transaction: tx),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('d MMM yyyy').format(tx.transactionDate),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tx.status.name.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  tx.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Show Request Badge if available
                if (hasRequestLink) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border:
                          Border.all(color: Colors.blueGrey.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.link,
                            size: 12, color: Colors.blueGrey),
                        const SizedBox(width: 4),
                        Text(
                          _formatReferenceType(tx.referenceType),
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: sourceDestinationWidget),
                    const SizedBox(width: 8),
                    Text(
                      amountString,
                      style: TextStyle(
                          color: amountColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
