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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CreateTransactionScreen()));
        },
      ),
      body: financialState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (state) {
          final filteredTransactions = state.transactions.where((t) {
            final query = _searchController.text.toLowerCase();

            final matchesSearch =
                t.description.toLowerCase().contains(query) ||
                    t.transactionNo.toLowerCase().contains(query) ||
                    (t.project?.name.toLowerCase().contains(query) ?? false);

            final status = _mapFilterToStatus(_activeFilter);
            final matchesStatus = status == null || t.status == status;

            bool matchesDate = true;
            if (_selectedDate != null) {
              matchesDate =
                  t.transactionDate.year == _selectedDate!.year &&
                      t.transactionDate.month == _selectedDate!.month &&
                      t.transactionDate.day == _selectedDate!.day;
            }

            return matchesSearch && matchesStatus && matchesDate;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
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
                  ),
                ),
              ),

              _buildFundsCard(),

              const SizedBox(height: 16),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
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
                            border:
                                Border.all(color: AppColors.primaryBlue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
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

                    const Spacer(),

                    _buildStatusFilterToggle(),
                  ],
                ),
              ),
                    _buildStatusFilterToggle(),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const Divider(color: AppColors.primaryBlue),

              Expanded(
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
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _buildFundsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Text(
        "Funds Released: ₹20,00,000",
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildStatusFilterToggle() {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _activeFilter = value),
      itemBuilder: (context) => [
        'All',
        'Approved',
        'Pending',
        'Rejected',
        'Voided'
      ].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
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

  Widget _buildTransactionCard(Transaction tx) {
    Color statusColor;

    if (tx.status == TransactionStatus.approved) {
      statusColor = const Color(0xFF4CAF50);
    } else if (tx.status == TransactionStatus.pendingApproval) {
    } else if (tx.status == TransactionStatus.pendingApproval) {
      statusColor = const Color(0xFF3F51B5);
    } else {
    } else {
      statusColor = const Color(0xFFF44336);
    }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    LedgerDetailsScreen(transaction: tx))),
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          tx.project?.name.toUpperCase() ?? "GLOBAL TRANSACTION",
          style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 11),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              _formatCurrency(tx.totalAmount),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(tx.description),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  tx.type.name.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM yyyy')
                      .format(tx.transactionDate),
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            )
          ],
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4)),
          child: Text(
            tx.status.name.toUpperCase(),
            style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 9),
          ),
        ),
      ),
    );
  }
}