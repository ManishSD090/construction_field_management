import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/approval/approval_controller.dart';

class BudgetApprovalDetailsScreen extends ConsumerStatefulWidget {
  final BudgetApprovalItem approvalItem;

  const BudgetApprovalDetailsScreen({super.key, required this.approvalItem});

  @override
  ConsumerState<BudgetApprovalDetailsScreen> createState() =>
      _BudgetApprovalDetailsScreenState();
}

class _BudgetApprovalDetailsScreenState
    extends ConsumerState<BudgetApprovalDetailsScreen> {
  final TextEditingController _remarksController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _processApproval(bool isApproved) async {
    if (!isApproved && _remarksController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter a reason for rejection.')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      if (widget.approvalItem.revision != null) {
        // ✅ APPROVING A BUDGET REVISION (Hits your /revisions/:id/approve-reject route)
        await ref
            .read(approvalControllerProvider.notifier)
            .approveRejectBudgetRevision(
              revisionId: widget.approvalItem.revision!.id,
              isApproved: isApproved,
              reason: _remarksController.text.isNotEmpty
                  ? _remarksController.text
                  : null,
            );
      } else {
        // ✅ APPROVING A BASE BUDGET (Hits your /budgets/approvals/:id/approve route)
        await ref.read(approvalControllerProvider.notifier).approveRejectBudget(
              budgetId: widget.approvalItem.budget.id,
              isApproved: isApproved,
              reason: _remarksController.text.isNotEmpty
                  ? _remarksController.text
                  : null,
            );
      }

      _showStatusDialog(isApproved: isApproved);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showStatusDialog({required bool isApproved}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isApproved ? "Approved" : "Rejected",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? const Color(0xFF009688)
                        : const Color(0xFFEF5350),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(isApproved ? Icons.check : Icons.close,
                      color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final budget = widget.approvalItem.budget;
    final revision = widget.approvalItem.revision;

    final bool isRevision = revision != null;
    final String displayTitle =
        isRevision ? "REV: ${budget.name}" : budget.name;
    final String labelText = isRevision ? "Budget Revision" : "Base Budget";

    final currencyFormatter =
        NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

    final List<Widget> particularsList = [];

    if (isRevision) {
      final changes = revision.categoryChanges;
      int index = 1;
      changes.forEach((categoryId, changeData) {
        double amount = 0;
        if (changeData is num) {
          amount = changeData.toDouble();
        } else if (changeData is Map && changeData['change'] != null) {
          amount = (changeData['change'] as num).toDouble();
        }

        particularsList.add(_buildParticularRow(
          sr: "${index++}".padLeft(2, '0'),
          name: "Category Update",
          amountText:
              "${amount >= 0 ? '+' : ''}${currencyFormatter.format(amount)}",
          isHighlight: true,
        ));
      });
    } else {
      final categories = budget.categories ?? [];
      for (int i = 0; i < categories.length; i++) {
        final cat = categories[i];
        particularsList.add(_buildParticularRow(
          sr: "${i + 1}".padLeft(2, '0'),
          name: cat.category.name.replaceAll('_', ' '),
          amountText: currencyFormatter.format(cat.allocatedAmount),
        ));
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Budget Approvals",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayTitle,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(budget.project?.name ?? "Unknown Project",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(labelText,
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      AppColors.primaryBlue.withOpacity(0.8))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text("Manager: ${budget.createdBy?.name ?? 'System'}",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
                if (isRevision && revision.reason.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text("Reason: ${revision.reason}",
                        style: TextStyle(
                            color: Colors.orange.shade800,
                            fontStyle: FontStyle.italic)),
                  )
                ],
                const SizedBox(height: 20),
                const Row(
                  children: [
                    SizedBox(
                        width: 40,
                        child: Text("Sr.",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(
                        child: Text("Category",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13))),
                    Text("Amount",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(thickness: 1, color: Colors.grey),
                const SizedBox(height: 8),
                if (particularsList.isEmpty)
                  const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                          child: Text("No category details found.",
                              style: TextStyle(color: Colors.grey))))
                else
                  Column(children: particularsList),
                const SizedBox(height: 16),
                const Divider(thickness: 1, color: Colors.grey),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Allocation:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                        currencyFormatter.format(isRevision
                            ? revision.newTotal
                            : budget.totalApproved),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primaryBlue)),
                  ],
                ),
                const SizedBox(height: 60),
                const Text("Remarks",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _remarksController,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Approval/Reject Remarks",
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0D6EFD))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0D6EFD))),
                  ),
                ),
                const SizedBox(height: 20),
                _isProcessing
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () => _processApproval(true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0),
                                child: const Text("Approve",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () => _processApproval(false),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF5350),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0),
                                child: const Text("Reject",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                            ),
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

  Widget _buildParticularRow(
      {required String sr,
      required String name,
      required String amountText,
      bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
              width: 40,
              child: Text(sr,
                  style: const TextStyle(fontSize: 13, color: Colors.black87))),
          Expanded(
              child: Text(name,
                  style: const TextStyle(fontSize: 13, color: Colors.black87))),
          Text(amountText,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                  color: isHighlight ? Colors.green : Colors.black87)),
        ],
      ),
    );
  }
}
