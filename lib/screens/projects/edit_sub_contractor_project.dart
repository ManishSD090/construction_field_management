import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/subcontractor/subcontractor_controller.dart';
import 'package:construction_erp/models/enums.dart';

class EditContractorProjectScreen extends ConsumerStatefulWidget {
  final String contractorProjectId;

  const EditContractorProjectScreen({
    super.key,
    required this.contractorProjectId,
  });

  @override
  ConsumerState<EditContractorProjectScreen> createState() =>
      _EditContractorProjectScreenState();
}

class _EditContractorProjectScreenState
    extends ConsumerState<EditContractorProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _scopeController;
  late TextEditingController _termsController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _amountController;
  late TextEditingController _advanceController;
  late TextEditingController _retentionController;
  late TextEditingController _payTermsController;

  WorkType? _selectedWorkType;
  DateTime? _rawStartDate;
  DateTime? _rawEndDate;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _scopeController = TextEditingController();
    _termsController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _amountController = TextEditingController();
    _advanceController = TextEditingController();
    _retentionController = TextEditingController();
    _payTermsController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _scopeController.dispose();
    _termsController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _amountController.dispose();
    _advanceController.dispose();
    _retentionController.dispose();
    _payTermsController.dispose();
    super.dispose();
  }

  void _initializeData(Map<String, dynamic> data) {
    if (_isInitialized) return;

    _titleController.text = data['title'] ?? '';
    _descController.text = data['description'] ?? '';
    _scopeController.text = data['scopeOfWork'] ?? '';
    _termsController.text = data['terms'] ?? '';
    _payTermsController.text = data['paymentTerms'] ?? '';
    _amountController.text = data['contractAmount']?.toString() ?? '';
    _advanceController.text = data['advanceAmount']?.toString() ?? '';
    _retentionController.text = data['retentionAmount']?.toString() ?? '';

    if (data['startDate'] != null) {
      _rawStartDate = DateTime.parse(data['startDate']);
      _startDateController.text =
          DateFormat('yyyy-MM-dd').format(_rawStartDate!);
    }
    if (data['endDate'] != null) {
      _rawEndDate = DateTime.parse(data['endDate']);
      _endDateController.text = DateFormat('yyyy-MM-dd').format(_rawEndDate!);
    }

    // Handle Enum Mapping (Ensure your WorkType.values.byName matches backend string)
    if (data['workType'] != null) {
      try {
        _selectedWorkType =
            WorkType.values.byName(data['workType'].toString().toLowerCase());
      } catch (_) {}
    }

    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync =
        ref.watch(contractorProjectDetailsProvider(widget.contractorProjectId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Project Assignment",
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
        //
      ),
      body: projectAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (data) {
          _initializeData(data);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Assignment Details"),
                  _buildTextField(_titleController, "Title"),
                  _buildTextField(_descController, "Description"),
                  _buildLabel("Work Type"),
                  _buildWorkTypeDropdown(),
                  _buildLabel("Scope & Terms"),
                  _buildTextField(_scopeController, "Scope of Work",
                      maxLines: 3),
                  _buildTextField(_payTermsController, "Payment Terms"),
                  Row(
                    children: [
                      Expanded(
                          child: _buildDatePicker(
                              "Start Date", _startDateController, true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildDatePicker(
                              "End Date", _endDateController, false)),
                    ],
                  ),
                  _buildLabel("Financials"),
                  _buildTextField(_amountController, "Total Amount (₹)",
                      inputType: TextInputType.number),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Reuse your existing UI helpers here (modified for brevity)
  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black54)),
      );

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryBlue)),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
      String label, TextEditingController controller, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: isStart
                  ? (_rawStartDate ?? DateTime.now())
                  : (_rawEndDate ?? DateTime.now()),
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
            );
            if (date != null) {
              setState(() {
                controller.text = DateFormat('yyyy-MM-dd').format(date);
                if (isStart) {
                  _rawStartDate = date;
                } else {
                  _rawEndDate = date;
                }
              });
            }
          },
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_today,
                size: 18, color: AppColors.primaryBlue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkTypeDropdown() {
    return DropdownButtonFormField<WorkType>(
      initialValue: _selectedWorkType,
      items: WorkType.values
          .map((t) =>
              DropdownMenuItem(value: t, child: Text(t.name.toUpperCase())))
          .toList(),
      onChanged: (val) => setState(() => _selectedWorkType = val),
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: _handleUpdate,
        child: const Text("Save Changes",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    final payload = {
      "title": _titleController.text,
      "description": _descController.text,
      "workType": _selectedWorkType?.name.toUpperCase(),
      "scopeOfWork": _scopeController.text,
      "startDate": _rawStartDate?.toIso8601String(),
      "endDate": _rawEndDate?.toIso8601String(),
      "contractAmount": double.tryParse(_amountController.text) ?? 0.0,
      "advanceAmount": double.tryParse(_advanceController.text),
      "retentionAmount": double.tryParse(_retentionController.text),
      "paymentTerms": _payTermsController.text,
    };

    try {
      await ref
          .read(subcontractorControllerProvider.notifier)
          .updateContractorProject(widget.contractorProjectId, payload);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Update Successful")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Update Failed: $e")));
    }
  }

  Future<void> _confirmDelete() async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Assignment?"),
        content: const Text(
            "This will remove the sub-contractor from this project. This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Remove", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (proceed == true) {
      await ref
          .read(subcontractorControllerProvider.notifier)
          .deleteContractorProject(widget.contractorProjectId);
      if (mounted) {
        Navigator.pop(context); // Pop back to list
      }
    }
  }
}
