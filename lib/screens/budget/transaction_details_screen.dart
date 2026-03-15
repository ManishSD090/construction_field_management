import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/finance/financial_controller.dart';
import 'package:construction_erp/models/budget.dart';
import 'package:construction_erp/models/enums.dart';

class TransactionDetailsScreen extends ConsumerStatefulWidget {
  final BudgetTransaction transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  ConsumerState<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState
    extends ConsumerState<TransactionDetailsScreen> {
  bool _isProcessing = false;

  // --- ACTIONS ---

  Future<void> _handleStatusUpdate(BudgetTransactionStatus newStatus) async {
    setState(() => _isProcessing = true);
    try {
      await ref
          .read(financialControllerProvider.notifier)
          .updateBudgetTransactionStatus(
            widget.transaction.id,
            newStatus,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Transaction marked as ${newStatus.name.toUpperCase()}')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.alertRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showConversionDialog() async {
    final amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    final taxController = TextEditingController(text: "0");

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Convert to Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                "Confirm the final spent amount and taxes for this commitment."),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Actual Amount", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: taxController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Tax Amount", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final amt = double.tryParse(amountController.text) ??
                  widget.transaction.amount;
              final tax = double.tryParse(taxController.text) ?? 0;
              Navigator.pop(context);
              await _handleConversion(amt, tax);
            },
            child: const Text("Confirm Payment"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConversion(double actualAmount, double taxAmount) async {
    setState(() => _isProcessing = true);
    try {
      await ref
          .read(financialControllerProvider.notifier)
          .convertCommitmentToExpense(
        widget.transaction.id,
        {
          'actualAmount': actualAmount,
          'taxAmount': taxAmount,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Commitment successfully converted to Expense'),
              backgroundColor: AppColors.successGreen),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.alertRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text(
          "Transaction Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 16),
                _buildDetailsCard(),
                const SizedBox(height: 16),
                if (widget.transaction.referenceType != null &&
                    widget.transaction.referenceType!.isNotEmpty)
                  _buildReferenceCard(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = widget.transaction.status;
    final type = widget.transaction.transactionType;

    // A Transfer is internal and usually "DISBURSED" immediately.
    // If it is already DISBURSED, we shouldn't allow simple "Cancellation"
    // because the funds have already moved. Users should create a new transfer instead.
    if (type == BudgetTransactionType.transfer &&
        status == BudgetTransactionStatus.disbursed) {
      return const Center(
        child: Text(
          "This transfer is finalized. To change it, perform a new transfer.",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
        ),
      );
    }

    bool canCancel = status == BudgetTransactionStatus.pending ||
        status == BudgetTransactionStatus.committed;
    bool canApprove = status == BudgetTransactionStatus.pending;
    bool canConvert = type == BudgetTransactionType.commitment &&
        status == BudgetTransactionStatus.committed;

    if (!canCancel && !canApprove && !canConvert) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text("Actions",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54)),
        ),
        Row(
          children: [
            if (canConvert)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _showConversionDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white),
                  label: const Text("Pay / Finalize",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            if (canApprove) ...[
              if (canConvert) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _handleStatusUpdate(
                          BudgetTransactionStatus.committed),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.done_all, color: Colors.white),
                  label: const Text("Approve",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            if (canCancel) ...[
              if (canConvert || canApprove) const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _handleStatusUpdate(
                          BudgetTransactionStatus.cancelled),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.alertRed,
                    side: const BorderSide(color: AppColors.alertRed),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text("Cancel",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    final formatter = NumberFormat("#,##,000.00");
    Color badgeColor = Colors.grey;
    if (widget.transaction.status == BudgetTransactionStatus.committed) {
      badgeColor = Colors.orange;
    }
    if (widget.transaction.status == BudgetTransactionStatus.disbursed) {
      badgeColor = AppColors.successGreen;
    }
    if (widget.transaction.status == BudgetTransactionStatus.cancelled) {
      badgeColor = AppColors.alertRed;
    }

    String iconStr = '₹';
    if (widget.transaction.transactionType == BudgetTransactionType.transfer) {
      iconStr = '⇄';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: badgeColor.withOpacity(0.5)),
            ),
            child: Text(
              widget.transaction.status.name.toUpperCase(),
              style: TextStyle(
                  color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            child: Text(
              iconStr,
              style: const TextStyle(
                  fontSize: 28,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "${widget.transaction.currency} ${formatter.format(widget.transaction.amount)}",
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            widget.transaction.transactionType.name.toUpperCase(),
            style: const TextStyle(
                fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    String categoryName = 'UNCATEGORIZED';
    if (widget.transaction.category != null) {
      categoryName = widget.transaction.category!.category.name.toUpperCase();
    }

    String destinationName = '';
    if (widget.transaction.transactionType == BudgetTransactionType.transfer &&
        widget.transaction.transferToCategory != null) {
      destinationName =
          widget.transaction.transferToCategory!.category.name.toUpperCase();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Transaction Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 30),
          _buildDetailRow("Transaction No", widget.transaction.transactionNo),
          const SizedBox(height: 16),
          _buildDetailRow(
              "Date",
              DateFormat('dd MMM yyyy, hh:mm a')
                  .format(widget.transaction.transactionDate)),
          const SizedBox(height: 16),
          if (widget.transaction.transactionType ==
              BudgetTransactionType.transfer) ...[
            _buildDetailRow("From Category", categoryName),
            const SizedBox(height: 16),
            _buildDetailRow("To Category", destinationName),
          ] else ...[
            _buildDetailRow("Budget Category", categoryName),
          ],
          const SizedBox(height: 16),
          _buildDetailRow("Description", widget.transaction.description),
          if (widget.transaction.createdBy != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
                "Created By", widget.transaction.createdBy!.name ?? 'Unknown'),
          ]
        ],
      ),
    );
  }

  Widget _buildReferenceCard() {
    String refTypeName = widget.transaction.referenceType!.replaceAll('_', ' ');

    if (widget.transaction.referenceType == 'MATERIAL_REQUEST') {
      refTypeName = 'Material Request';
    }
    if (widget.transaction.referenceType == 'PURCHASE_ORDER') {
      refTypeName = 'Purchase Order';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.link, color: Colors.blueGrey),
              SizedBox(width: 8),
              Text("Linked Request",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey)),
            ],
          ),
          const Divider(height: 30),
          _buildDetailRow("Source", refTypeName),
          const SizedBox(height: 16),
          _buildDetailRow(
              "Reference No.",
              widget.transaction.referenceNo ??
                  widget.transaction.referenceId ??
                  'N/A'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Future implementation: Navigate to the source request screen
              },
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: const Text("View Request Document"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
