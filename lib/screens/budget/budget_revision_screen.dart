import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/budget.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/controllers/finance/financial_controller.dart';

// ==========================================
// 1. REVISION LIST SCREEN
// ==========================================

class BudgetRevisionsScreen extends ConsumerStatefulWidget {
  final Budget budget;
  const BudgetRevisionsScreen({super.key, required this.budget});

  @override
  ConsumerState<BudgetRevisionsScreen> createState() =>
      _BudgetRevisionsScreenState();
}

class _BudgetRevisionsScreenState extends ConsumerState<BudgetRevisionsScreen> {
  late Future<List<BudgetRevision>> _revisionsFuture;
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadRevisions();
  }

  void _loadRevisions() {
    setState(() {
      _revisionsFuture = ref
          .read(financialControllerProvider.notifier)
          .getBudgetRevisions(widget.budget.id);
    });
  }

  Future<void> _handleApplyRevision(String revisionId) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator()));
      await ref
          .read(financialControllerProvider.notifier)
          .applyRevision(widget.budget.id, revisionId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Revision Applied Successfully")));
        _loadRevisions();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error Applying Revision: $e")));
      }
    }
  }

  Future<void> _handleSubmitRevision(String revisionId) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator()));
      await ref
          .read(financialControllerProvider.notifier)
          .submitRevisionForApproval(
              revisionId, {}); // Passing empty map as required
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Submitted for approval")));
        _loadRevisions();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error Submitting Revision: $e")));
      }
    }
  }

  Future<void> _navigateToCreate() async {
    final didCreate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRevisionScreen(budget: widget.budget),
      ),
    );
    if (didCreate == true) {
      _loadRevisions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text("Budget Revisions",
            style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text("New Revision", style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<List<BudgetRevision>>(
        future: _revisionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading revisions: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }

          final revisions = snapshot.data ?? [];

          if (revisions.isEmpty) {
            return const Center(
              child: Text("No revisions found for this budget.",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: revisions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final rev = revisions[index];

              // Resilient parsing to handle both Enum and String types seamlessly
              final String statusStr =
                  rev.status.toString().split('.').last.toUpperCase();

              String statusText;
              Color statusColor;

              if (statusStr == 'APPLIED') {
                statusText = "Applied";
                statusColor = Colors.green;
              } else if (statusStr == 'REJECTED') {
                statusText = "Rejected";
                statusColor = Colors.red;
              } else if (statusStr == 'APPROVED') {
                statusText = "Approved (Ready)";
                statusColor = AppColors.primaryBlue;
              } else if (statusStr == 'PENDING_APPROVAL' ||
                  statusStr == 'PENDINGAPPROVAL') {
                statusText = "Pending Approval";
                statusColor = Colors.orange;
              } else {
                statusText = "Draft";
                statusColor = Colors.grey.shade600;
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          rev.revisionNo,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.primaryBlue),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Reason: ${rev.reason}",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87),
                    ),

                    if (statusStr == 'REJECTED' &&
                        rev.rejectionReason != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          "Rejection Reason: ${rev.rejectionReason}",
                          style: TextStyle(
                              fontSize: 12, color: Colors.red.shade900),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Net Change:",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          (rev.changeAmount >= 0 ? "+" : "") +
                              _currencyFormat.format(rev.changeAmount),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: rev.changeAmount >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),

                    // Action Buttons conditionally rendered based purely on the new status
                    if (statusStr == 'DRAFT') ...[
                      const Divider(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _handleSubmitRevision(rev.id),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: const Text("Submit for Approval",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ] else if (statusStr == 'APPROVED') ...[
                      const Divider(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _handleApplyRevision(rev.id),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: const Text("Apply Revision",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// 2. CREATE REVISION SCREEN
// ==========================================

class _RevisionRowData {
  final BudgetCategoryAllocation categoryAllocation;
  final TextEditingController adjustmentController;
  double newAmount;

  _RevisionRowData({required this.categoryAllocation})
      : adjustmentController = TextEditingController(text: '0'),
        newAmount = categoryAllocation.allocatedAmount;
}

class CreateRevisionScreen extends ConsumerStatefulWidget {
  final Budget budget;
  const CreateRevisionScreen({super.key, required this.budget});

  @override
  ConsumerState<CreateRevisionScreen> createState() =>
      _CreateRevisionScreenState();
}

class _CreateRevisionScreenState extends ConsumerState<CreateRevisionScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final List<_RevisionRowData> _rows = [];
  // Assuming 'priceAdjustment' exists in your BudgetRevisionType enum
  BudgetRevisionType _revisionType = BudgetRevisionType.priceAdjustment;

  @override
  void initState() {
    super.initState();
    for (var cat in widget.budget.categories ?? []) {
      final row = _RevisionRowData(categoryAllocation: cat);
      row.adjustmentController.addListener(() {
        final adj = double.tryParse(row.adjustmentController.text) ?? 0;
        setState(() {
          row.newAmount = cat.allocatedAmount + adj;
        });
      });
      _rows.add(row);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    for (var row in _rows) {
      row.adjustmentController.dispose();
    }
    super.dispose();
  }

  double get _totalNewAmount =>
      _rows.fold(0.0, (sum, row) => sum + row.newAmount);
  double get _totalChange => _totalNewAmount - widget.budget.totalApproved;

  Future<void> _submitRevision() async {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter a reason for the revision')));
      return;
    }

    final Map<String, dynamic> categoryChanges = {};
    for (var row in _rows) {
      final change = double.tryParse(row.adjustmentController.text) ?? 0;
      if (change != 0) {
        categoryChanges[row.categoryAllocation.id] = {
          'previous': row.categoryAllocation.allocatedAmount,
          'new': row.newAmount,
          'change': change,
        };
      }
    }

    if (categoryChanges.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes detected in the budget.')));
      return;
    }

    final revisionData = {
      'revisionType': _revisionType.toJson(),
      'reason': _reasonController.text.trim(),
      'effectiveDate': DateTime.now().toIso8601String(),
      'previousTotal': widget.budget.totalApproved,
      'newTotal': _totalNewAmount,
      'changeAmount': _totalChange,
      'categoryChanges': categoryChanges,
    };

    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator()));
      await ref
          .read(financialControllerProvider.notifier)
          .createBudgetRevision(widget.budget.id, revisionData);
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context, true); // Returns true to trigger refresh
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Revision created successfully.')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text("Create Revision",
            style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<BudgetRevisionType>(
                  initialValue: _revisionType,
                  decoration: const InputDecoration(
                      labelText: "Revision Type", border: OutlineInputBorder()),
                  items: BudgetRevisionType.values
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(t.toDisplayString())))
                      .toList(),
                  onChanged: (val) => setState(() => _revisionType = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reasonController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: "Reason for Amendment *",
                      border: OutlineInputBorder(),
                      hintText: "e.g. Price escalation in steel"),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _rows.length,
              itemBuilder: (context, index) {
                final row = _rows[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                row.categoryAllocation.category
                                    .toDisplayString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue)),
                            Text(row.categoryAllocation.subCategory ?? "-",
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Current",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                            Text(
                                NumberFormat.compact().format(
                                    row.categoryAllocation.allocatedAmount),
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: row.adjustmentController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: "0",
                            prefixText: "+/- ",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: const Border(top: BorderSide(color: Colors.black12))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Net Change:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      (_totalChange >= 0 ? "+" : "") +
                          NumberFormat.currency(
                                  symbol: '₹',
                                  locale: 'en_IN',
                                  decimalDigits: 0)
                              .format(_totalChange),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _totalChange >= 0 ? Colors.green : Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitRevision,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text("Create Revision",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
