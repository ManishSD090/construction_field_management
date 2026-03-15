import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/finance/financial_controller.dart';
import 'package:construction_erp/models/transaction.dart';
import 'package:construction_erp/models/enums.dart';

class LedgerDetailsScreen extends ConsumerStatefulWidget {
  final Transaction transaction;

  const LedgerDetailsScreen({super.key, required this.transaction});

  @override
  ConsumerState<LedgerDetailsScreen> createState() =>
      _LedgerDetailsScreenState();
}

class _LedgerDetailsScreenState extends ConsumerState<LedgerDetailsScreen> {
  bool _isProcessing = false;

  Future<void> _performAction(
      Future<void> Function() action, String successMsg) async {
    setState(() => _isProcessing = true);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(successMsg),
            backgroundColor: AppColors.successGreen));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error: $e"), backgroundColor: AppColors.alertRed));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showReasonDialog(
      {required String title, required Function(String) onSubmit}) async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter reason...")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onSubmit(controller.text);
              },
              child: const Text("Submit")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final f = NumberFormat("#,##,000.00");

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text("Transaction Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAmountHeader(tx, f),
              const SizedBox(height: 16),
              _buildDetailedBreakdown(tx, f),
              const SizedBox(height: 16),
              _buildFinancialInfo(tx),

              if (tx.sourceType == TransactionSourceType.purchaseOrder) ...[
                const SizedBox(height: 16),
                _buildLinkedSourceCard(tx),
              ],

              // Budget Sync Info (if applicable)
              if (tx.budgetId != null) ...[
                const SizedBox(height: 16),
                _buildBudgetSyncCard(tx),
              ],

              const SizedBox(height: 24),
              if (tx.status == TransactionStatus.pendingApproval)
                _buildPendingActions(tx),
              if (tx.status == TransactionStatus.approved)
                _buildApprovedActions(tx),
              const SizedBox(height: 40),
            ],
          ),
          if (_isProcessing) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildAmountHeader(Transaction tx, NumberFormat f) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(tx.type.toDisplayString().toUpperCase(),
              style: const TextStyle(
                  color: Colors.grey,
                  letterSpacing: 1.2,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("₹${f.format(tx.totalAmount)}",
              style:
                  const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _statusChip(tx.status),
        ],
      ),
    );
  }

  Widget _statusChip(TransactionStatus status) {
    Color color = status == TransactionStatus.approved
        ? Colors.green
        : (status == TransactionStatus.pendingApproval
            ? Colors.orange
            : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5))),
      child: Text(status.toDisplayString().toUpperCase(),
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }

  Widget _buildDetailedBreakdown(Transaction tx, NumberFormat f) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _row("Base Amount", "₹${f.format(tx.amount)}"),
          const SizedBox(height: 12),
          _row("Tax Amount", "₹${f.format(tx.taxAmount)}"),
          const Divider(height: 24),
          _row("Total Amount", "₹${f.format(tx.totalAmount)}", bold: true),
        ],
      ),
    );
  }

  Widget _buildFinancialInfo(Transaction tx) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Financial Info",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _row("Transaction ID", tx.transactionNo),
          _row("Date",
              DateFormat('dd MMM yyyy, hh:mm a').format(tx.transactionDate)),
          _row("Counterparty", tx.counterpartyName ?? "N/A"),
          _row("Project", tx.project?.name ?? "N/A"),
          _row("Category", tx.category ?? "General"),
          _row("Description", tx.description),
          if (tx.rejectionReason != null)
            _row("Rejection Reason", tx.rejectionReason!, color: Colors.red),
          if (tx.voidReason != null)
            _row("Void Reason", tx.voidReason!, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildBudgetSyncCard(Transaction tx) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.1))),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.sync, size: 16, color: Colors.green),
            SizedBox(width: 8),
            Text("Budget Sync Enabled",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.green))
          ]),
          SizedBox(height: 12),
          Text(
              "This expense will automatically update the project budget upon approval.",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLinkedSourceCard(Transaction tx) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.link, size: 16, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text("Linked Procurement",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.primaryBlue))
          ]),
          const SizedBox(height: 12),
          _row("Source", tx.sourceType.name.replaceAll('_', ' ').toUpperCase()),
          _row("Ref No.", tx.referenceNo ?? "N/A"),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                      fontSize: 13,
                      color: color))),
        ],
      ),
    );
  }

  Widget _buildPendingActions(Transaction tx) {
    return Row(
      children: [
        Expanded(
            child: ElevatedButton(
          onPressed: () => _performAction(
              () => ref
                  .read(financialControllerProvider.notifier)
                  .approveLedgerTransaction(tx.id),
              "Transaction Approved"),
          style:
              ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen),
          child: const Text("Approve", style: TextStyle(color: Colors.white)),
        )),
        const SizedBox(width: 12),
        Expanded(
            child: OutlinedButton(
          onPressed: () => _showReasonDialog(
              title: "Reject Transaction",
              onSubmit: (r) => _performAction(
                  () => ref
                      .read(financialControllerProvider.notifier)
                      .rejectLedgerTransaction(tx.id, rejectionReason: r),
                  "Transaction Rejected")),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.alertRed),
          child: const Text("Reject"),
        )),
      ],
    );
  }

  Widget _buildApprovedActions(Transaction tx) {
    return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showReasonDialog(
              title: "Void Transaction",
              onSubmit: (r) => _performAction(
                  () => ref
                      .read(financialControllerProvider.notifier)
                      .voidLedgerTransaction(tx.id, voidReason: r),
                  "Transaction Voided")),
          icon: const Icon(Icons.block),
          label: const Text("Void Transaction"),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.alertRed),
        ));
  }
}
