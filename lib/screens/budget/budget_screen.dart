import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/models/budget.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/controllers/finance/financial_controller.dart';
import 'package:construction_erp/screens/budget/budget_revision_screen.dart';
import 'package:construction_erp/screens/budget/create_budget_screen.dart';

// ==========================================
// 1. VIEWER SCREEN (Read-Only View)
// ==========================================
class BudgetScreen extends ConsumerStatefulWidget {
  final Project project;

  const BudgetScreen({super.key, required this.project});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  String _projectName = "";
  String _managerName = "";
  Budget? _selectedBudget;

  @override
  void initState() {
    super.initState();
    _projectName = widget.project.name;
    _managerName = widget.project.createdBy?.name ?? "Project Manager";
  }

  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(projectBudgetsProvider(widget.project.id));

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Project Budgets",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: 'Create New Budget Version',
            onPressed: _handleCreateNewBudget,
          ),
        ],
      ),
      body: budgetsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(
          child: Text('Error loading budgets: $err',
              style: const TextStyle(color: Colors.white)),
        ),
        data: (budgets) {
          if (budgets.isEmpty) {
            return _buildEmptyState();
          }

          // Sync selection
          if (_selectedBudget != null) {
            try {
              _selectedBudget =
                  budgets.firstWhere((b) => b.id == _selectedBudget!.id);
            } catch (_) {
              _selectedBudget = null;
            }
          }

          _selectedBudget ??= budgets.firstWhere(
            (b) => b.isActive || b.status == BudgetStatus.active,
            orElse: () => budgets.first,
          );

          final categories = _selectedBudget?.categories ?? [];
          final double totalAmount = _selectedBudget?.totalApproved ?? 0.0;

          final canEdit = _selectedBudget?.status == BudgetStatus.draft ||
              _selectedBudget?.status == BudgetStatus.rejected;

          return Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _projectName,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (canEdit)
                                    InkWell(
                                      onTap: () async {
                                        final didUpdate = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditBudgetScreen(
                                              budget: _selectedBudget!,
                                            ),
                                          ),
                                        );
                                        if (didUpdate == true) {
                                          ref.invalidate(projectBudgetsProvider(
                                              widget.project.id));
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Icon(Icons.edit,
                                            size: 16, color: Colors.grey),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(_managerName,
                                  style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 20),

                              // Budget Selector
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade50,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Budget>(
                                    value: _selectedBudget,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down,
                                        color: AppColors.primaryBlue),
                                    items: budgets.map((b) {
                                      return DropdownMenuItem(
                                        value: b,
                                        child: Text(
                                          "${b.name} (${b.status.toDisplayString()})",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedBudget = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),

                              // Categories List
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                color: Colors.grey.shade50,
                                child: const Row(
                                  children: [
                                    SizedBox(
                                        width: 30,
                                        child: Text("Sr.",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12))),
                                    Expanded(
                                        child: Text("Category",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12))),
                                    SizedBox(width: 8),
                                    Expanded(
                                        child: Text("Sub-Category",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12))),
                                    SizedBox(width: 8),
                                    SizedBox(
                                        width: 80,
                                        child: Text("Amount",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12))),
                                    SizedBox(width: 32),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, thickness: 1),

                              if (categories.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Center(
                                      child: Text("No items in this budget")),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: categories.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 15),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 8),
                                  itemBuilder: (context, index) {
                                    final item = categories[index];
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                            width: 30,
                                            child: Text(
                                                "${index + 1}".padLeft(2, '0'),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey))),
                                        Expanded(
                                          child: Text(
                                            item.category.toDisplayString(),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primaryBlue),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: Text(item.subCategory ?? "-",
                                                style: const TextStyle(
                                                    fontSize: 12))),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            _currencyFormat
                                                .format(item.allocatedAmount),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        const SizedBox(width: 32),
                                      ],
                                    );
                                  },
                                ),
                              const Divider(thickness: 1),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 30),
                                    const Expanded(
                                        child: Text("Total",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    Expanded(
                                        child: Text(
                                            categories.length.toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        _currencyFormat.format(totalAmount),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.primaryBlue),
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Action buttons logic
                      _buildActionButtons(_selectedBudget!),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No budgets found for this project.",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleCreateNewBudget,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Create First Budget",
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue),
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons(Budget budget) {
    // 1. ACTIVE BUDGET ACTIONS
    if (budget.status == BudgetStatus.active) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Management Actions",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildIconButton(
                    label: "Transfer",
                    icon: Icons.swap_horiz,
                    onTap: () => _handleTransferFunds(budget),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildIconButton(
                    label: "Revisions",
                    icon: Icons.history_edu,
                    onTap: () => _handleViewRevisions(budget),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildIconButton(
                    label: "Audit",
                    icon: Icons.list_alt,
                    onTap: () => _handleViewAudit(budget),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // 2. APPROVED (BUT NOT ACTIVE) ACTIONS
    if (budget.status == BudgetStatus.approved) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black12))),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed: () => _handleUpdateStatus(budget, BudgetStatus.active),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text("Activate Budget",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        ),
      );
    }

    // 3. DRAFT / REJECTED ACTIONS
    if (budget.status == BudgetStatus.draft ||
        budget.status == BudgetStatus.rejected) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black12))),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleDeleteBudget(budget),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Delete Budget",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    _handleUpdateStatus(budget, BudgetStatus.pendingApproval),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Submit Approval",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildIconButton(
      {required String label,
      required IconData icon,
      required VoidCallback onTap,
      Color color = AppColors.primaryBlue}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // --- LOGIC HANDLERS ---

  Future<void> _handleCreateNewBudget() async {
    final didCreate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateBudgetScreen(
          project: widget.project,
          copyFromBudget:
              _selectedBudget, // Pass the current active budget to auto-fill
        ),
      ),
    );
    if (didCreate == true) {
      ref.invalidate(projectBudgetsProvider(widget.project.id));
    }
  }

  Future<void> _handleTransferFunds(Budget budget) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TransferFundsDialog(budget: budget),
    );
    if (result == true) {
      ref.invalidate(projectBudgetsProvider(widget.project.id));
      ref.invalidate(budgetDetailsProvider(budget.id));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Funds transferred successfully")));
    }
  }

  Future<void> _handleViewAudit(Budget budget) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetAuditScreen(budget: budget),
      ),
    );
  }

  Future<void> _handleViewRevisions(Budget budget) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetRevisionsScreen(budget: budget),
      ),
    );
    // Refresh the budget when returning in case revisions were applied
    ref.invalidate(projectBudgetsProvider(widget.project.id));
    ref.invalidate(budgetDetailsProvider(budget.id));
  }

  Future<void> _handleUpdateStatus(
      Budget budget, BudgetStatus newStatus) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator()));
      await ref.read(financialControllerProvider.notifier).updateBudgetStatus(
            budgetId: budget.id,
            projectId: widget.project.id,
            status: newStatus,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _handleDeleteBudget(Budget budget) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Budget?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => const Center(child: CircularProgressIndicator()));
        await ref
            .read(financialControllerProvider.notifier)
            .deleteBudget(budget.id, widget.project.id);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }
}

// ==========================================
// 2. TRANSFER FUNDS DIALOG
// ==========================================

class TransferFundsDialog extends ConsumerStatefulWidget {
  final Budget budget;
  const TransferFundsDialog({super.key, required this.budget});

  @override
  ConsumerState<TransferFundsDialog> createState() =>
      _TransferFundsDialogState();
}

class _TransferFundsDialogState extends ConsumerState<TransferFundsDialog> {
  int? _fromCategoryIndex;
  int? _toCategoryIndex;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitTransfer() async {
    if (_fromCategoryIndex == null || _toCategoryIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Please select both source and destination categories.')));
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid transfer amount.')));
      return;
    }

    final categories = widget.budget.categories ?? [];
    final fromCategory = categories[_fromCategoryIndex!];
    final toCategory = categories[_toCategoryIndex!];

    // Fallback calculation in case remainingAmount is incorrectly 0
    final double availableAmount = fromCategory.remainingAmount > 0
        ? fromCategory.remainingAmount
        : (fromCategory.allocatedAmount -
            fromCategory.spentAmount -
            fromCategory.committedAmount);

    if (amount > availableAmount) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Insufficient funds. Max available: $availableAmount')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(financialControllerProvider.notifier)
          .transferBudgetAmount(widget.budget.id, fromCategory.id, {
        'toCategoryId': toCategory.id,
        'amount': amount,
        'description': _reasonController.text.trim().isNotEmpty
            ? _reasonController.text.trim()
            : 'Internal budget transfer',
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Transfer failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.budget.categories ?? [];
    final NumberFormat currencyFormat = NumberFormat.compact(locale: 'en_IN');

    return AlertDialog(
      title: const Text("Transfer Funds",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("From Category",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              initialValue: _fromCategoryIndex,
              isExpanded: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
              hint: const Text("Select Source", style: TextStyle(fontSize: 13)),
              items: categories.asMap().entries.map((entry) {
                final c = entry.value;

                // Fallback calculation in case remainingAmount is incorrectly 0
                final double availableAmount = c.remainingAmount > 0
                    ? c.remainingAmount
                    : (c.allocatedAmount - c.spentAmount - c.committedAmount);

                final hasFunds = availableAmount > 0;
                final title =
                    "${c.category.toDisplayString()}${c.subCategory != null && c.subCategory!.isNotEmpty ? ' - ${c.subCategory}' : ''}";

                return DropdownMenuItem<int>(
                  value: entry.key,
                  enabled:
                      hasFunds, // Disables the option if there are no funds
                  child: Text(
                    hasFunds ? title : "$title (No Funds)",
                    style: TextStyle(
                      fontSize: 13,
                      color: hasFunds ? Colors.black87 : Colors.grey.shade400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _fromCategoryIndex = val;
                  if (_toCategoryIndex == val) _toCategoryIndex = null;
                });
              },
            ),

            // Dynamic Visual Indicator for Available Amount
            if (_fromCategoryIndex != null)
              Builder(builder: (context) {
                final selectedCategory = categories[_fromCategoryIndex!];
                final double displayAvailableAmount =
                    selectedCategory.remainingAmount > 0
                        ? selectedCategory.remainingAmount
                        : (selectedCategory.allocatedAmount -
                            selectedCategory.spentAmount -
                            selectedCategory.committedAmount);

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.green.shade700, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          "Available to Transfer:",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Text(
                          currencyFormat.format(displayAvailableAmount),
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 16),
            const Text("To Category",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              initialValue: _toCategoryIndex,
              isExpanded: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
              hint: const Text("Select Destination",
                  style: TextStyle(fontSize: 13)),
              items: categories
                  .asMap()
                  .entries
                  .where((entry) =>
                      entry.key !=
                      _fromCategoryIndex) // Can't transfer to itself
                  .map((entry) {
                final c = entry.value;
                final title =
                    "${c.category.toDisplayString()}${c.subCategory != null && c.subCategory!.isNotEmpty ? ' - ${c.subCategory}' : ''}";
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(title,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (val) => setState(() => _toCategoryIndex = val),
            ),
            const SizedBox(height: 16),
            const Text("Transfer Amount",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: "₹ ",
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Reason (Optional)",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _reasonController,
              maxLines: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "e.g. Reallocating for material shortage",
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitTransfer,
          style:
              ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text("Transfer",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ==========================================
// 3. EDIT SCREEN (Draft/Rejected Management)
// ==========================================

class _EditableBudgetRow {
  String? id;
  BudgetCategory? category;
  final TextEditingController subCategoryController;
  final TextEditingController amountController;
  bool isNew;

  _EditableBudgetRow({
    this.id,
    this.category,
    String? subCategory,
    double? amount,
    this.isNew = false,
  })  : subCategoryController = TextEditingController(text: subCategory ?? ''),
        amountController = TextEditingController(
            text:
                amount != null && amount > 0 ? amount.toStringAsFixed(0) : '');

  void dispose() {
    subCategoryController.dispose();
    amountController.dispose();
  }
}

class EditBudgetScreen extends ConsumerStatefulWidget {
  final Budget budget;

  const EditBudgetScreen({super.key, required this.budget});

  @override
  ConsumerState<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends ConsumerState<EditBudgetScreen> {
  late List<_EditableBudgetRow> _rows;
  final List<String> _deletedCategoryIds = [];

  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _rows = (widget.budget.categories ?? []).map((c) {
      final row = _EditableBudgetRow(
        id: c.id,
        category: c.category,
        subCategory: c.subCategory,
        amount: c.allocatedAmount,
        isNew: false,
      );
      _setupRowListeners(row);
      return row;
    }).toList();

    if (_rows.isEmpty) _addNewItem();
  }

  @override
  void dispose() {
    for (var row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _setupRowListeners(_EditableBudgetRow row) {
    row.amountController.addListener(() => setState(() {}));
  }

  double get _totalAmount {
    return _rows.fold(0, (sum, row) {
      final amount =
          double.tryParse(row.amountController.text.replaceAll(',', '')) ?? 0;
      return sum + amount;
    });
  }

  void _addNewItem() {
    setState(() {
      final newRow = _EditableBudgetRow(isNew: true);
      _setupRowListeners(newRow);
      _rows.add(newRow);
    });
  }

  void _removeRow(int index) {
    final row = _rows[index];
    if (_rows.length > 1) {
      setState(() {
        if (!row.isNew && row.id != null) {
          _deletedCategoryIds.add(row.id!);
        }
        row.dispose();
        _rows.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must have at least one budget item.')),
      );
    }
  }

  Future<void> _handleSave() async {
    for (var row in _rows) {
      if (row.category == null || row.amountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Please ensure all rows have a category and amount')),
        );
        return;
      }
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save Changes?"),
        content:
            const Text("Are you sure you want to save these modifications?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Save")),
        ],
      ),
    );

    if (confirm == true) {
      await _processSaveToBackend();
    }
  }

  Future<void> _processSaveToBackend() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()));

    try {
      final controller = ref.read(financialControllerProvider.notifier);
      final budgetId = widget.budget.id;

      for (final catId in _deletedCategoryIds) {
        await controller.deleteBudgetCategory(budgetId, catId);
      }

      for (var row in _rows) {
        final payload = {
          'category': row.category!.toJson(),
          'subCategory': row.subCategoryController.text.trim(),
          'allocatedAmount': double.tryParse(row.amountController.text) ?? 0.0,
        };

        if (row.isNew) {
          await controller.addBudgetCategory(budgetId, payload);
        } else if (row.id != null) {
          await controller.updateBudgetCategory(budgetId, row.id!, payload);
        }
      }

      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Changes Saved",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.check, color: Colors.white, size: 40)),
            ],
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
      Navigator.pop(context, true);
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
            onPressed: () => Navigator.pop(context)),
        title: Text("Edit ${widget.budget.name}",
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18)),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(
                left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
            child: Row(
              children: [
                SizedBox(
                    width: 30,
                    child: Text("Sr.",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text("Category",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold))),
                SizedBox(width: 8),
                Expanded(
                    child: Text("Sub-Category",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold))),
                SizedBox(width: 8),
                SizedBox(
                    width: 80,
                    child: Text("Amount",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold))),
                SizedBox(width: 32),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.primaryBlue, thickness: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rows.length + 1,
              itemBuilder: (context, index) {
                if (index == _rows.length) return _buildAddButton();
                final row = _rows[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 30,
                          height: 40,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("${index + 1}".padLeft(2, '0'),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54)))),
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue.shade200),
                              borderRadius: BorderRadius.circular(4)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<BudgetCategory>(
                              value: row.category,
                              isExpanded: true,
                              hint: const Text('Select',
                                  style: TextStyle(fontSize: 11)),
                              icon: const Icon(Icons.arrow_drop_down, size: 16),
                              items: BudgetCategory.values.map((cat) {
                                return DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat.toDisplayString(),
                                        style: const TextStyle(fontSize: 11),
                                        overflow: TextOverflow.ellipsis));
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => row.category = val),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _buildTextField(
                              controller: row.subCategoryController,
                              hint: "Sub-Category")),
                      const SizedBox(width: 8),
                      SizedBox(
                          width: 80,
                          child: _buildTextField(
                              controller: row.amountController,
                              hint: "0",
                              isNumber: true)),
                      SizedBox(
                          width: 32,
                          height: 40,
                          child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: AppColors.alertRed, size: 20),
                              onPressed: () => _removeRow(index))),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.primaryBlue, thickness: 1),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 30),
                    const Expanded(
                        child: Text("Total",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text(_rows.length.toString(),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    SizedBox(
                        width: 80,
                        child: Text(_currencyFormat.format(_totalAmount),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87))),
                    const SizedBox(width: 32),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        elevation: 0),
                    child: const Text("Save Changes",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hint,
      bool isNumber = false}) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.blue.shade200)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: Row(
        children: [
          SizedBox(
              width: 30,
              child: Text((_rows.length + 1).toString().padLeft(2, '0'),
                  style: const TextStyle(color: Colors.grey, fontSize: 12))),
          Expanded(
            child: InkWell(
              onTap: _addNewItem,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.add_circle_outline,
                    color: AppColors.primaryBlue),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: SizedBox()),
          const SizedBox(width: 8),
          const SizedBox(width: 80),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

// ==========================================
// 4. BUDGET AUDIT SCREEN (Added functionality)
// ==========================================
class BudgetAuditScreen extends ConsumerStatefulWidget {
  final Budget budget;
  const BudgetAuditScreen({super.key, required this.budget});

  @override
  ConsumerState<BudgetAuditScreen> createState() => _BudgetAuditScreenState();
}

class _BudgetAuditScreenState extends ConsumerState<BudgetAuditScreen> {
  late Future<List<dynamic>> _auditFuture;

  @override
  void initState() {
    super.initState();
    _auditFuture = ref
        .read(financialControllerProvider.notifier)
        .getBudgetAuditTrail(widget.budget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text("Budget Audit Trail",
            style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _auditFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading audit trail: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }

          final logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return const Center(
              child: Text("No audit logs found for this budget.",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final log = logs[index];
              final date = log['timestamp'] != null
                  ? DateFormat('dd MMM yyyy, hh:mm a')
                      .format(DateTime.parse(log['timestamp']))
                  : 'Unknown Date';
              final action =
                  log['action']?.toString().replaceAll('_', ' ') ?? 'ACTION';
              final userName = log['user']?['name'] ?? 'System / Unknown User';

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
                          action,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.primaryBlue),
                        ),
                        Text(
                          date,
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(userName, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
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
// 5. HELPERS
// ==========================================

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter(
      {this.color = Colors.black, this.strokeWidth = 1.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = size.width;
    double y = size.height;

    Path topPath =
        getDashedPath(a: const Offset(0, 0), b: Offset(x, 0), gap: gap);
    Path rightPath = getDashedPath(a: Offset(x, 0), b: Offset(x, y), gap: gap);
    Path bottomPath = getDashedPath(a: Offset(0, y), b: Offset(x, y), gap: gap);
    Path leftPath =
        getDashedPath(a: const Offset(0, 0), b: Offset(0, y), gap: gap);

    canvas.drawPath(topPath, dashedPaint);
    canvas.drawPath(rightPath, dashedPaint);
    canvas.drawPath(bottomPath, dashedPaint);
    canvas.drawPath(leftPath, dashedPaint);
  }

  Path getDashedPath(
      {required Offset a, required Offset b, required double gap}) {
    Size size = Size(b.dx - a.dx, b.dy - a.dy);
    Path path = Path();
    path.moveTo(a.dx, a.dy);
    bool shouldDraw = true;

    double radians = atan2(b.dy - a.dy, b.dx - a.dx);
    double distance = sqrt(pow(b.dx - a.dx, 2) + pow(b.dy - a.dy, 2));

    for (double i = 0; i < distance; i += gap) {
      if (shouldDraw) {
        path.relativeLineTo(gap * cos(radians), gap * sin(radians));
      } else {
        path.relativeMoveTo(gap * cos(radians), gap * sin(radians));
      }
      shouldDraw = !shouldDraw;
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
