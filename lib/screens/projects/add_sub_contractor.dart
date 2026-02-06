import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/subcontractor/subcontractor_controller.dart';
import 'package:construction_erp/models/contractor.dart';
import 'package:construction_erp/models/enums.dart'; // Assuming your enums are here
import 'package:intl/intl.dart';

class CreateSubContractorScreen extends ConsumerStatefulWidget {
  final String projectId; // The main project we are assigning to
  const CreateSubContractorScreen({super.key, required this.projectId});

  @override
  ConsumerState<CreateSubContractorScreen> createState() =>
      _CreateSubContractorScreenState();
}

class _CreateSubContractorScreenState
    extends ConsumerState<CreateSubContractorScreen> {
  int? _expandedIndex;

  // Assignment Form Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _scopeController = TextEditingController();
  final _termsController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _durationController = TextEditingController();
  final _amountController = TextEditingController();
  final _advanceController = TextEditingController();
  final _retentionController = TextEditingController();
  final _payTermsController = TextEditingController();

  WorkType? _selectedWorkType;
  DateTime? _rawStartDate;
  DateTime? _rawEndDate;

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subcontractorControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Assign Sub-contractor",
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: subState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (state) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.subcontractors.length,
          itemBuilder: (context, index) {
            final contractor = state.subcontractors[index];
            final isExpanded = _expandedIndex == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isExpanded
                        ? AppColors.primaryBlue
                        : Colors.grey.shade300),
                color: isExpanded
                    ? AppColors.primaryBlue.withOpacity(0.02)
                    : Colors.white,
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(contractor.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "Type: ${contractor.type.name} • Rating: ${contractor.rating}"),
                    trailing: Icon(isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down),
                    onTap: () => _toggleExpand(index, contractor),
                  ),
                  if (isExpanded) _buildAssignmentForm(contractor),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _toggleExpand(int index, Contractor contractor) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
        _selectedWorkType =
            contractor.workTypes.isNotEmpty ? contractor.workTypes.first : null;
        _clearForm();
      }
    });
  }

  void _clearForm() {
    _titleController.clear();
    _descController.clear();
    _scopeController.clear();
    _amountController.clear();
    // ... clear others
  }

  Widget _buildAssignmentForm(Contractor contractor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          _buildLabel("Project Assignment Details"),
          _buildTextField(_titleController, "Title (e.g. Foundation Work)"),
          _buildTextField(_descController, "Short Description"),
          _buildLabel("Work Type"),
          _buildWorkTypeDropdown(contractor.workTypes),
          _buildLabel("Scope of Work"),
          _buildTextField(_scopeController, "Define specific scope...",
              maxLines: 3),
          Row(
            children: [
              Expanded(
                  child: _buildDatePicker(
                      "Start Date", _startDateController, true)),
              const SizedBox(width: 10),
              Expanded(
                  child:
                      _buildDatePicker("End Date", _endDateController, false)),
            ],
          ),
          _buildLabel("Financials"),
          _buildTextField(_amountController, "Contract Amount",
              inputType: TextInputType.number),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(_advanceController, "Advance (Opt)",
                      inputType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildTextField(
                      _retentionController, "Retention (Opt)",
                      inputType: TextInputType.number)),
            ],
          ),
          _buildLabel("Terms & Payments"),
          _buildTextField(_payTermsController, "Payment Milestone Terms"),
          _buildTextField(_termsController, "General Terms & Conditions"),
          const SizedBox(height: 20),
          _buildSubmitButton(contractor.id),
        ],
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black54)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
      ),
    );
  }

  Widget _buildWorkTypeDropdown(List<WorkType> options) {
    return DropdownButtonFormField<WorkType>(
      value: _selectedWorkType,
      items: options
          .map((t) =>
              DropdownMenuItem(value: t, child: Text(t.name.toUpperCase())))
          .toList(),
      onChanged: (val) => setState(() => _selectedWorkType = val),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              setState(() {
                controller.text = DateFormat('yyyy-MM-dd').format(date);
                if (isStart)
                  _rawStartDate = date;
                else
                  _rawEndDate = date;
              });
            }
          },
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(String contractorId) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: () => _handleAssignment(contractorId),
        child: const Text("Confirm Assignment",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _handleAssignment(String contractorId) async {
    final payload = {
      "title": _titleController.text,
      "description": _descController.text,
      "workType": _selectedWorkType?.toJson(),
      "scopeOfWork": _scopeController.text,
      "terms": _termsController.text,
      "startDate": _rawStartDate?.toIso8601String(),
      "endDate": _rawEndDate?.toIso8601String(),
      "contractAmount": double.tryParse(_amountController.text) ?? 0.0,
      "advanceAmount": double.tryParse(_advanceController.text),
      "retentionAmount": double.tryParse(_retentionController.text),
      "paymentTerms": _payTermsController.text,
    };

    await ref
        .read(subcontractorControllerProvider.notifier)
        .createContractorProject(contractorId, widget.projectId, payload);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sub-contractor Assigned Successfully!")));
  }
}
