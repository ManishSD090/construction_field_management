import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/models/budget.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/controllers/finance/financial_controller.dart';
import 'package:construction_erp/core/services/app_colors.dart';

class _BudgetRowData {
  BudgetCategory? category;
  final TextEditingController subCategoryController;
  final TextEditingController amountController;

  _BudgetRowData({this.category, String? subCategory, double? amount})
      : subCategoryController = TextEditingController(text: subCategory ?? ''),
        amountController = TextEditingController(
            text:
                amount != null && amount > 0 ? amount.toStringAsFixed(0) : '');

  void dispose() {
    subCategoryController.dispose();
    amountController.dispose();
  }
}

class CreateBudgetScreen extends ConsumerStatefulWidget {
  final Project project;
  final Budget? copyFromBudget; // Used to auto-fill data

  const CreateBudgetScreen({
    super.key,
    required this.project,
    this.copyFromBudget,
  });

  @override
  ConsumerState<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends ConsumerState<CreateBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  final List<_BudgetRowData> _rows = [];
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();

    // Auto-fill logic if cloning an existing budget
    if (widget.copyFromBudget != null) {
      _nameController.text = "${widget.copyFromBudget!.name} (New Version)";
      _descriptionController.text = widget.copyFromBudget!.description ?? "";

      final existingCategories = widget.copyFromBudget!.categories ?? [];

      if (existingCategories.isNotEmpty) {
        for (var cat in existingCategories) {
          final row = _BudgetRowData(
            category: cat.category,
            subCategory: cat.subCategory,
            amount:
                cat.allocatedAmount, // Copying the original allocated amount
          );
          _setupRowListeners(row);
          _rows.add(row);
        }
        _calculateTotal();
      } else {
        // Fallback to empty row if budget had no categories
        _addRow();
      }
    } else {
      // Standard empty initialization
      _addRow();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _setupRowListeners(_BudgetRowData row) {
    row.amountController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    double total = 0.0;
    for (var row in _rows) {
      final amount = double.tryParse(row.amountController.text) ?? 0.0;
      total += amount;
    }
    setState(() {
      _totalAmount = total;
    });
  }

  void _addRow() {
    setState(() {
      final newRow = _BudgetRowData();
      _setupRowListeners(newRow);
      _rows.add(newRow);
    });
  }

  void _removeRow(int index) {
    if (_rows.length > 1) {
      setState(() {
        _rows[index].dispose();
        _rows.removeAt(index);
        _calculateTotal();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must have at least one budget item.')),
      );
    }
  }

  Future<void> _submitBudget() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate table rows
    bool hasValidRow = false;
    List<Map<String, dynamic>> categories = [];

    for (var row in _rows) {
      if (row.category != null && row.amountController.text.isNotEmpty) {
        hasValidRow = true;
        categories.add({
          'category': row.category!.toJson().toUpperCase(),
          'subCategory': row.subCategoryController.text.trim(),
          'allocatedAmount': double.tryParse(row.amountController.text) ?? 0.0,
        });
      }
    }

    if (!hasValidRow) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least one valid budget item.')),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final budgetData = {
        'projectId': widget.project.id,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'startDate': _startDate.toIso8601String(),
        if (_endDate != null) 'endDate': _endDate!.toIso8601String(),
        'categories': categories,
      };

      await ref
          .read(financialControllerProvider.notifier)
          .createBudget(budgetData);

      // Close loading indicator and screen
      if (mounted) {
        Navigator.pop(context); // close dialog
        Navigator.pop(
            context, true); // close screen and pass "true" to trigger refresh
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating budget: $e')),
        );
      }
    }
  }

  // Helper to format enum string (e.g. equipmentRental -> Equipment Rental)
  String _formatEnumName(String name) {
    final spaced = name.replaceAll(RegExp(r'(?=[A-Z])'), ' ');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Budget Version'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Basic Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Budget Name *',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _startDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            child: Text(
                                DateFormat('dd MMM, yyyy').format(_startDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? _startDate,
                              firstDate: _startDate,
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _endDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            child: Text(
                                _endDate != null
                                    ? DateFormat('dd MMM, yyyy')
                                        .format(_endDate!)
                                    : 'Select Date',
                                style: TextStyle(
                                    color: _endDate == null
                                        ? Colors.grey.shade600
                                        : Colors.black87)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Table Headers
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
              child: Row(
                children: const [
                  SizedBox(
                      width: 30,
                      child: Text('Sr.',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('Category',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold))),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('Sub-Category',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold))),
                  SizedBox(width: 8),
                  SizedBox(
                      width: 80,
                      child: Text('Amount',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold))),
                  SizedBox(width: 32), // Space for delete icon
                ],
              ),
            ),
            const Divider(color: AppColors.primaryBlue, thickness: 1),

            // Table Rows
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _rows.length + 1, // +1 for the Add Row button
                itemBuilder: (context, index) {
                  if (index == _rows.length) {
                    // Add Row Button
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 30,
                              child: Text(
                                  (index + 1).toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12))),
                          Expanded(
                            child: InkWell(
                              onTap: _addRow,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.primaryBlue
                                          .withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
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

                  final row = _rows[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 40,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text((index + 1).toString().padLeft(2, '0'),
                                style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue.shade200),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<BudgetCategory>(
                                value: row.category,
                                isExpanded: true,
                                hint: const Text('Select',
                                    style: TextStyle(fontSize: 12)),
                                icon:
                                    const Icon(Icons.arrow_drop_down, size: 16),
                                items: BudgetCategory.values.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat,
                                    child: Text(_formatEnumName(cat.name),
                                        style: const TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() => row.category = val);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: row.subCategoryController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide:
                                      BorderSide(color: Colors.blue.shade200),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 0),
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          height: 40,
                          child: TextField(
                            controller: row.amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.blue.shade200),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 0),
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          height: 40,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.remove_circle_outline,
                                color: AppColors.alertRed, size: 20),
                            onPressed: () => _removeRow(index),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

            // Footer Totals
            const Divider(color: AppColors.primaryBlue, thickness: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const SizedBox(width: 30),
                  const Expanded(
                      child: Text('Total',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text(
                    _rows.length.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                  const SizedBox(width: 8),
                  SizedBox(
                      width: 80,
                      child: Text(
                        NumberFormat.currency(
                                symbol: '₹', locale: 'en_IN', decimalDigits: 0)
                            .format(_totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(width: 32),
                ],
              ),
            ),

            // Submit Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitBudget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Create Budget",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
