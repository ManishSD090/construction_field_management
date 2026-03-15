import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/finance/financial_controller.dart';
import 'package:construction_erp/controllers/project/project_controller.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/models/budget.dart';
import 'package:construction_erp/models/project.dart';

class CreateTransactionScreen extends ConsumerStatefulWidget {
  final String? initialProjectId;

  const CreateTransactionScreen({super.key, this.initialProjectId});

  @override
  ConsumerState<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState
    extends ConsumerState<CreateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  // State
  TransactionType _selectedType = TransactionType.expense;
  String? _selectedProjectId;

  // Controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _counterpartyController = TextEditingController();

  // Budget Linking State
  bool _isBudgetSyncEnabled = false;
  String? _activeBudgetId;
  List<BudgetCategoryAllocation> _availableBudgetCategories = [];
  BudgetCategoryAllocation? _selectedBudgetCategory;
  bool _isLoadingBudgetInfo = false;

  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.initialProjectId;
    if (_selectedProjectId != null) {
      _loadBudgetInfoForProject(_selectedProjectId!);
    }

    _amountController.addListener(() => setState(() {}));
    _taxController.addListener(() => setState(() {}));
  }

  // --- Logic ---

  Future<void> _loadBudgetInfoForProject(String projectId) async {
    setState(() {
      _isLoadingBudgetInfo = true;
      _activeBudgetId = null;
      _availableBudgetCategories = [];
      _selectedBudgetCategory = null;
    });

    try {
      final budget = await ref
          .read(financialControllerProvider.notifier)
          .getActiveBudget(projectId);
      if (budget != null) {
        final categories = await ref
            .read(financialControllerProvider.notifier)
            .getBudgetCategories(budget.id);
        if (mounted) {
          setState(() {
            _activeBudgetId = budget.id;
            _availableBudgetCategories = categories;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading budget: $e");
    } finally {
      if (mounted) setState(() => _isLoadingBudgetInfo = false);
    }
  }

  double get _totalAmount {
    final amt = double.tryParse(_amountController.text) ?? 0;
    final tax = double.tryParse(_taxController.text) ?? 0;
    return amt + tax;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a project")));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final data = {
        'projectId': _selectedProjectId,
        'type': _selectedType
            .toJson(), // Using the enum's toJson() method for proper formatting
        'amount': double.parse(_amountController.text),
        'taxAmount': double.tryParse(_taxController.text) ?? 0,
        'totalAmount': _totalAmount,
        'description': _descriptionController.text,
        'category': _categoryController.text,
        'counterpartyName': _counterpartyController.text,
        'transactionDate': _selectedDate.toIso8601String(),
        'sourceType': 'DIRECT',
        'currency': 'INR',
        // Backend Budget Sync logic
        if (_isBudgetSyncEnabled && _selectedBudgetCategory != null) ...{
          'budgetId': _activeBudgetId,
          'budgetCategoryId': _selectedBudgetCategory!.id,
        }
      };

      await ref
          .read(financialControllerProvider.notifier)
          .createLedgerTransaction(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Transaction entry created"),
              backgroundColor: AppColors.successGreen),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error: $e"), backgroundColor: AppColors.alertRed));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Create Ledger Entry",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
      ),
      body: projectsState.when(
        data: (state) => _buildForm(state.projects),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error loading projects: $e")),
      ),
    );
  }

  Widget _buildForm(List<Project> projects) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildLabel("Transaction Type"),
          _buildTypeSelector(),
          const SizedBox(height: 24),

          _buildLabel("Select Project"),
          DropdownButtonFormField<String>(
            initialValue: _selectedProjectId,
            decoration: _inputDeco("Select Project"),
            items: projects
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedProjectId = val);
                _loadBudgetInfoForProject(val);
              }
            },
            validator: (val) => val == null ? "Required" : null,
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Amount"),
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDeco("0.00", prefix: "₹ "),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      validator: (val) =>
                          val == null || val.isEmpty ? "Required" : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Tax"),
                    TextFormField(
                      controller: _taxController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDeco("0.00"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTotalSummary(),
          const SizedBox(height: 24),

          _buildLabel("Category (Ledger)"),
          TextFormField(
            controller: _categoryController,
            decoration: _inputDeco("e.g. Office Rent, Vendor Payment"),
            validator: (val) => val == null || val.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 20),

          _buildLabel(_selectedType == TransactionType.income
              ? "Received From"
              : "Paid To"),
          TextFormField(
            controller: _counterpartyController,
            decoration: _inputDeco("Vendor or Person name"),
          ),

          // --- Budget Integration ---
          if (_selectedType == TransactionType.expense &&
              _selectedProjectId != null) ...[
            const SizedBox(height: 12),
            _buildBudgetSyncSection(),
          ],

          const SizedBox(height: 20),
          _buildLabel("Description"),
          TextFormField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: _inputDeco("Specific details..."),
          ),

          const SizedBox(height: 20),
          _buildLabel("Date"),
          _buildDatePicker(),

          const SizedBox(height: 40),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Log Transaction",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Final Amount",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text("₹ ${NumberFormat("#,##,000.00").format(_totalAmount)}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                  fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBudgetSyncSection() {
    if (_isLoadingBudgetInfo) return const LinearProgressIndicator();
    if (_activeBudgetId == null) {
      return const Text(
          "No active budget found for this project. Cannot sync expense.",
          style: TextStyle(color: Colors.grey, fontSize: 11));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Deduct from Project Budget",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          value: _isBudgetSyncEnabled,
          activeThumbColor: AppColors.primaryBlue,
          onChanged: (val) => setState(() => _isBudgetSyncEnabled = val),
        ),
        if (_isBudgetSyncEnabled) ...[
          _buildLabel("Budget Category"),
          DropdownButtonFormField<BudgetCategoryAllocation>(
            initialValue: _selectedBudgetCategory,
            isExpanded: true,
            decoration: _inputDeco("Select Category"),
            items: _availableBudgetCategories
                .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text("${c.category.name} - ${c.subCategory ?? ''}",
                        style: const TextStyle(fontSize: 12))))
                .toList(),
            onChanged: (val) => setState(() => _selectedBudgetCategory = val),
            validator: (val) => _isBudgetSyncEnabled && val == null
                ? "Required for sync"
                : null,
          ),
          if (_selectedBudgetCategory != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4),
              child: Text(
                  "Available in Budget: ₹ ${NumberFormat("#,##,000").format(_selectedBudgetCategory!.remainingAmount)}",
                  style: TextStyle(
                      color: _selectedBudgetCategory!.remainingAmount <
                              _totalAmount
                          ? Colors.red
                          : Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ],
    );
  }

  Widget _buildTypeSelector() {
    final types = [
      TransactionType.income,
      TransactionType.expense,
      TransactionType.pettyCashIssue,
      TransactionType.pettyCashSettlement,
      TransactionType.pettyCashReplenishment
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((t) {
        bool isSelected = t == _selectedType;
        return InkWell(
          onTap: () => setState(() {
            _selectedType = t;
            if (t != TransactionType.expense) _isBudgetSyncEnabled = false;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              t.name.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toUpperCase(),
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontSize: 9,
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now());
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const Icon(Icons.calendar_today,
                color: AppColors.primaryBlue, size: 18),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, {String? prefix}) {
    return InputDecoration(
      prefixText: prefix,
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 4),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black54)),
      );
}
