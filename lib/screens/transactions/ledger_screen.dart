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
        title: const Text("Transaction Ledger",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                ref.read(financialControllerProvider.notifier).refresh(),
          )
        ],
      ),
      body: financialState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (state) {
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
                        borderSide: BorderSide.none),
                  ),
                ),
              ),

              // --- Income and Expense Summary Cards ---
              _buildSummaryHeader(state.transactions),

              const SizedBox(height: 16),

              // --- Date Picker and Filter Row ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // FIXED WIDTH CALENDAR BOX
                    SizedBox(
                      width: 150,
                      child: InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryBlue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? "MM/DD/YYYY"
                                    : DateFormat('dd/MM/yyyy')
                                        .format(_selectedDate!),
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 13),
                              ),
                              const Icon(Icons.calendar_month_outlined,
                                  color: AppColors.primaryBlue, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(), // Pushes filter button to the right

                    _buildStatusFilterToggle(),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const Divider(color: AppColors.primaryBlue, thickness: 1),

              // --- Dynamic Transaction List ---
              Expanded(
                child: filteredTransactions.isEmpty
                    ? const Center(child: Text("No transactions found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = filteredTransactions[index];
                          // Pass the entire transaction object to the card builder
                          return _buildTransactionCard(tx);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeader(List<Transaction> txs) {
    double totalIncome = txs
        .where((t) =>
            t.status == TransactionStatus.approved &&
            (t.type == TransactionType.income ||
                t.type == TransactionType.pettyCashReplenishment))
        .fold(0, (sum, t) => sum + t.totalAmount);

    double totalExpense = txs
        .where((t) =>
            t.status == TransactionStatus.approved &&
            t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.totalAmount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Income Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_downward, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text("Total Income",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(totalIncome),
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Expense Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.red, size: 16),
                      SizedBox(width: 4),
                      Text("Total Expense",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(totalExpense),
                    style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
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
            const SizedBox(width: 4),
            const Icon(Icons.tune, size: 14),
          ],
        ),
      ),
    );
  }

  // Accepts the Transaction object rather than individual string fields
  Widget _buildTransactionCard(Transaction tx) {
    Color statusColor;
    if (tx.status == TransactionStatus.approved) {
      statusColor = const Color(0xFF4CAF50);
    } else if (tx.status == TransactionStatus.pendingApproval) {
      statusColor = const Color(0xFF3F51B5);
    } else {
      statusColor = const Color(0xFFF44336);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade100, width: 1)),
      child: ListTile(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => LedgerDetailsScreen(transaction: tx))),
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
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatCurrency(tx.totalAmount),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    // Note: Ensure your Enum has an extension or simply use .name
                    tx.status.name.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 9),
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
            Text(tx.description,
                style: const TextStyle(color: Colors.black87, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  tx.type.name.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(DateFormat('dd MMM yyyy').format(tx.transactionDate),
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
