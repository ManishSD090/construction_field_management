import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/finance/financial_controller.dart';
import 'package:construction_erp/models/transaction.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/screens/transactions/ledger_details_screen.dart';
import 'package:construction_erp/screens/transactions/create_ledger_screen.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  DateTime? _selectedDate;
  String _activeFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Maps UI filter strings to TransactionStatus enums
  TransactionStatus? _mapFilterToStatus(String filter) {
    switch (filter) {
      case 'Approved':
        return TransactionStatus.approved;
      case 'Pending':
        return TransactionStatus.pendingApproval;
      case 'Rejected':
        return TransactionStatus.rejected;
      case 'Voided':
        return TransactionStatus.voided;
      default:
        return null;
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 2)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final financialState = ref.watch(financialControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          "Transaction Ledger",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                ref.read(financialControllerProvider.notifier).refresh(),
          )
        ],
      ),
      body: financialState.when(
        data: (state) {
          // Client-side filtering logic combining search, status, and date
          final filteredTransactions = state.transactions.where((t) {
            final query = _searchController.text.toLowerCase();
            final matchesSearch = t.description.toLowerCase().contains(query) ||
                t.transactionNo.toLowerCase().contains(query) ||
                (t.project?.name.toLowerCase().contains(query) ?? false) ||
                (t.counterpartyName?.toLowerCase().contains(query) ?? false);

            final status = _mapFilterToStatus(_activeFilter);
            final matchesStatus = status == null || t.status == status;

            bool matchesDate = true;
            if (_selectedDate != null) {
              matchesDate = t.transactionDate.year == _selectedDate!.year &&
                  t.transactionDate.month == _selectedDate!.month &&
                  t.transactionDate.day == _selectedDate!.day;
            }

            return matchesSearch && matchesStatus && matchesDate;
          }).toList();

          return Column(
            children: [
              // --- Search Bar ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Search Project, ID or Details...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // --- Summary Totals ---
              _buildSummaryHeader(filteredTransactions),

              // --- Filters Row ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildDatePicker(),
                    const Spacer(),
                    _buildStatusFilterToggle(),
                  ],
                ),
              ),

              const Divider(thickness: 1, height: 1),

              // --- Transaction List ---
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(financialControllerProvider.notifier).refresh(),
                  child: filteredTransactions.isEmpty
                      ? const Center(child: Text("No transactions found"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final tx = filteredTransactions[index];
                            return _buildTransactionCard(tx);
                          },
                        ),
                ),
              ),

              // --- Bottom Action Button ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateTransactionScreen(),
                      ),
                    ).then((_) => ref
                        .read(financialControllerProvider.notifier)
                        .refresh()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Log New Entry",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildSummaryHeader(List<Transaction> txs) {
    // Aggregates approved income and expenses for the current view
    double totalIncome = txs
        .where((t) =>
            t.status == TransactionStatus.approved &&
            (t.type == TransactionType.income ||
                t.type == TransactionType.pettyCashReplenishment))
        .fold(0.0, (sum, t) => sum + t.totalAmount);

    double totalExpense = txs
        .where((t) =>
            t.status == TransactionStatus.approved &&
            t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.totalAmount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Income",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  _formatCurrency(totalIncome),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 30, color: Colors.white24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Expense",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  _formatCurrency(totalExpense),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              _selectedDate == null
                  ? "Select Date"
                  : DateFormat('dd/MM/yy').format(_selectedDate!),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today,
                size: 14, color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterToggle() {
    return PopupMenuButton<String>(
      onSelected: (String value) => setState(() => _activeFilter = value),
      itemBuilder: (context) => [
        'All',
        'Approved',
        'Pending',
        'Rejected',
        'Voided'
      ].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _activeFilter != 'All'
              ? AppColors.primaryBlue.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(_activeFilter, style: const TextStyle(fontSize: 12)),
            const Icon(Icons.tune, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction tx) {
    Color statusColor = tx.status == TransactionStatus.approved
        ? AppColors.successGreen
        : (tx.status == TransactionStatus.pendingApproval
            ? Colors.orange
            : AppColors.alertRed);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LedgerDetailsScreen(transaction: tx),
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Name Shown Prominently
            Text(
              tx.project?.name.toUpperCase() ?? "GLOBAL TRANSACTION",
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatCurrency(tx.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tx.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              tx.description,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  tx.type.name.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM yyyy').format(tx.transactionDate),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
