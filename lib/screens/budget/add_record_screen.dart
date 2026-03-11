import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/finance/financial_controller.dart';
import 'package:construction_erp/models/budget.dart';

enum RecordType { expense, commitment, transfer }

class AddRecordScreen extends ConsumerStatefulWidget {
  final String budgetId;
  final RecordType initialType;

  const AddRecordScreen({
    super.key,
    required this.budgetId,
    this.initialType = RecordType.expense,
  });

  @override
  ConsumerState<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends ConsumerState<AddRecordScreen> {
  // Controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  late RecordType _selectedRecordType;
  DateTime? _selectedDate;

  // Category Selection
  List<BudgetCategoryAllocation> _categories = [];
  bool _isLoadingCategories = true;

  String? _selectedCategoryId; // For Expense & Commitment
  String? _fromCategoryId; // For Transfer
  String? _toCategoryId; // For Transfer

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedRecordType = widget.initialType;
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);

    // Fetch categories when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCategories();
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await ref
          .read(financialControllerProvider.notifier)
          .getBudgetCategories(widget.budgetId);

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
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
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _submitRecord() async {
    // 1. Validation
    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    final double amount = double.parse(_amountController.text);

    if (_selectedRecordType == RecordType.transfer) {
      if (_fromCategoryId == null || _toCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please select both From and To categories')));
        return;
      }
      if (_fromCategoryId == _toCategoryId) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Cannot transfer to the same category')));
        return;
      }

      // Client-side funds check for Transfer
      try {
        final fromCat = _categories.firstWhere((c) => c.id == _fromCategoryId);
        if (amount > fromCat.remainingAmount) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Transfer amount exceeds available funds'),
              backgroundColor: AppColors.alertRed));
          return;
        }
      } catch (_) {}
    } else {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a budget category')));
        return;
      }

      // Client-side funds check for Expense/Commitment
      try {
        final selectedCat =
            _categories.firstWhere((c) => c.id == _selectedCategoryId);
        if (amount > selectedCat.remainingAmount) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Amount exceeds available category funds'),
              backgroundColor: AppColors.alertRed));
          return;
        }
      } catch (_) {}
    }

    // 2. Submission
    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(financialControllerProvider.notifier);

      // Generate default description based on Record Type
      String defaultDescription;
      if (_selectedRecordType == RecordType.transfer) {
        final fromCat = _categories.firstWhere((c) => c.id == _fromCategoryId);
        final toCat = _categories.firstWhere((c) => c.id == _toCategoryId);
        defaultDescription =
            'Transfer from ${_getCategoryDisplayName(fromCat)} to ${_getCategoryDisplayName(toCat)}';
      } else if (_selectedRecordType == RecordType.expense) {
        defaultDescription = 'General Expense';
      } else {
        defaultDescription = 'General Commitment';
      }

      final String description = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : defaultDescription;

      if (_selectedRecordType == RecordType.transfer) {
        await controller.transferBetweenCategories({
          'budgetId': widget.budgetId,
          'fromCategoryId': _fromCategoryId,
          'toCategoryId': _toCategoryId,
          'amount': amount,
          'description': description,
        });
      } else if (_selectedRecordType == RecordType.expense) {
        await controller.createExpenseTransaction({
          'budgetId': widget.budgetId,
          'categoryId': _selectedCategoryId,
          'amount': amount,
          'description': description,
        });
      } else if (_selectedRecordType == RecordType.commitment) {
        await controller.createCommitment({
          'budgetId': widget.budgetId,
          'categoryId': _selectedCategoryId,
          'amount': amount,
          'description': description,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Record added successfully!'),
              backgroundColor: AppColors.successGreen),
        );
        // Refresh the transaction history before popping
        await controller.getBudgetTransactions(widget.budgetId);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add record: $e'),
              backgroundColor: AppColors.alertRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Budget Record",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Record Type Segmented Control
                  _buildLabel("Record Type"),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _buildTypeButton("Expense", RecordType.expense),
                        _buildTypeButton("Commitment", RecordType.commitment),
                        _buildTypeButton("Transfer", RecordType.transfer),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Category Selection (Dynamic based on Record Type)
                  if (_selectedRecordType == RecordType.transfer) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _buildCategoryDropdown(
                                "From Category",
                                _fromCategoryId,
                                (val) =>
                                    setState(() => _fromCategoryId = val))),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildCategoryDropdown(
                                "To Category",
                                _toCategoryId,
                                (val) => setState(() => _toCategoryId = val))),
                      ],
                    ),
                  ] else ...[
                    _buildCategoryDropdown(
                        "Budget Category",
                        _selectedCategoryId,
                        (val) => setState(() => _selectedCategoryId = val)),
                  ],
                  const SizedBox(height: 20),

                  // 3. Amount Field
                  _buildLabel("Amount"),
                  TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: "Enter the amount",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.currency_rupee,
                          color: AppColors.primaryBlue, size: 20),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.primaryBlue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Date Field
                  _buildLabel("Transaction Date"),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.calendar_today,
                          color: AppColors.primaryBlue),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.primaryBlue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. Notes Field
                  _buildLabel("Description / Notes"),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Enter description (Optional)",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.all(12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.primaryBlue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 6. Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRecord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        disabledBackgroundColor:
                            AppColors.primaryBlue.withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text(
                              "Save Record",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ================== HELPER WIDGETS ==================

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14),
      ),
    );
  }

  Widget _buildTypeButton(String title, RecordType type) {
    final isSelected = _selectedRecordType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedRecordType = type;
          // Clear category selections on type switch to avoid confusion
          _selectedCategoryId = null;
          _fromCategoryId = null;
          _toCategoryId = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textGrey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  String _formatIndianCurrencyAbbreviated(double amount) {
    if (amount >= 10000000) {
      return "₹${(amount / 10000000).toStringAsFixed(2)} Cr";
    } else if (amount >= 100000) {
      return "₹${(amount / 100000).toStringAsFixed(2)} Lakh";
    } else if (amount >= 1000) {
      return "₹${(amount / 1000).toStringAsFixed(2)} K";
    } else {
      return "₹${amount.toStringAsFixed(2)}";
    }
  }

  String _getCategoryDisplayName(BudgetCategoryAllocation cat) {
    String displayName = cat.category.name.toUpperCase();
    if (cat.subCategory != null && cat.subCategory!.isNotEmpty) {
      displayName += " - ${cat.subCategory}";
    }
    return displayName;
  }

  Widget _buildAvailableFundsText(String? categoryId) {
    if (categoryId == null) return const SizedBox.shrink();

    try {
      final category = _categories.firstWhere((c) => c.id == categoryId);
      final formattedAmount =
          _formatIndianCurrencyAbbreviated(category.remainingAmount);

      return Padding(
        padding: const EdgeInsets.only(top: 6.0, left: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              category.remainingAmount > 0
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              size: 14,
              color: category.remainingAmount > 0
                  ? AppColors.successGreen
                  : AppColors.alertRed,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                "Available: $formattedAmount",
                style: TextStyle(
                  fontSize: 12,
                  color: category.remainingAmount > 0
                      ? AppColors.successGreen
                      : AppColors.alertRed,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildCategoryDropdown(
      String label, String? currentValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryBlue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint:
                  const Text("Select Category", style: TextStyle(fontSize: 14)),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.primaryBlue),
              value: currentValue,
              items: _categories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat.id,
                  child: Text(
                    _getCategoryDisplayName(cat),
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        // Display available funds below the dropdown if a value is selected
        if (currentValue != null) _buildAvailableFundsText(currentValue),
      ],
    );
  }
}
