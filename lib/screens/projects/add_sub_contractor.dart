import 'dart:async';
import 'package:construction_erp/screens/sub_contractor/create_sub_contractor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/subcontractor/subcontractor_controller.dart';
import 'package:construction_erp/models/contractor.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:intl/intl.dart';

class AddSubContractorScreen extends ConsumerStatefulWidget {
  final String projectId; // The main project we are assigning to
  const AddSubContractorScreen({super.key, required this.projectId});

  @override
  ConsumerState<AddSubContractorScreen> createState() =>
      _AddSubContractorScreenState();
}

class _AddSubContractorScreenState
    extends ConsumerState<AddSubContractorScreen> {
  // State for Expandable List and Search
  int? _expandedIndex;
  Timer? _debounce;
  final _searchController = TextEditingController();

  // Assignment Form Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _scopeController = TextEditingController();
  final _termsController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _amountController = TextEditingController();
  final _advanceController = TextEditingController();
  final _retentionController = TextEditingController();
  final _payTermsController = TextEditingController();

  // Form State Values
  WorkType? _selectedWorkType;
  DateTime? _rawStartDate;
  DateTime? _rawEndDate;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
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

  // Handle Search with Debounce (500ms)
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(subcontractorControllerProvider.notifier).refresh(search: query);
    });
  }

  void _toggleExpand(int index, Contractor contractor) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
        // Pre-select first work type if available
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
    _termsController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _amountController.clear();
    _advanceController.clear();
    _retentionController.clear();
    _payTermsController.clear();
    _rawStartDate = null;
    _rawEndDate = null;
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subcontractorControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Assign Sub-contractor",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateSubContractorScreen()));
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 18),
        label: const Text(
          "Create Sub-Contractor",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
      body: Column(
        children: [
          // --- Search Header ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: "Search by name or work type...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // --- Subcontractor List ---
          Expanded(
            child: subState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
              data: (state) {
                if (state.subcontractors.isEmpty) {
                  return const Center(child: Text("No subcontractors found."));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              : AppColors.primaryBlue.withValues(alpha: 0.5),
                          width: isExpanded ? 1.5 : 1,
                        ),
                        color: isExpanded
                            ? AppColors.primaryBlue.withOpacity(0.02)
                            : Colors.white,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              contractor.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Type: ${contractor.type.name} • Rating: ${contractor.rating} ⭐",
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: isExpanded
                                  ? AppColors.primaryBlue
                                  : Colors.grey,
                            ),
                            onTap: () => _toggleExpand(index, contractor),
                          ),
                          if (isExpanded) _buildAssignmentForm(contractor),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 35),
        ],
      ),
    );
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
                child:
                    _buildDatePicker("Start Date", _startDateController, true),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDatePicker("End Date", _endDateController, false),
              ),
            ],
          ),
          _buildLabel("Financials"),
          _buildTextField(_amountController, "Contract Amount (₹)",
              inputType: TextInputType.number),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_advanceController, "Advance (Opt)",
                    inputType: TextInputType.number),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(_retentionController, "Retention (Opt)",
                    inputType: TextInputType.number),
              ),
            ],
          ),
          _buildLabel("Terms & Payments"),
          _buildTextField(_payTermsController, "Payment Milestone Terms"),
          _buildTextField(_termsController, "General Terms & Conditions"),
          const SizedBox(height: 24),
          _buildSubmitButton(contractor.id),
        ],
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
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
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0A6ED1))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primaryBlue, width: 2)),
        ),
      ),
    );
  }

  Widget _buildWorkTypeDropdown(List<WorkType> options) {
    return DropdownButtonFormField<WorkType>(
      initialValue: _selectedWorkType,
      items: options
          .map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.name.toUpperCase(),
                    style: const TextStyle(fontSize: 14)),
              ))
          .toList(),
      onChanged: (val) => setState(() => _selectedWorkType = val),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0A6ED1))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.primaryBlue, width: 2)),
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
          style: const TextStyle(fontSize: 14),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
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
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF0A6ED1))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primaryBlue, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(String contractorId) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: () => _handleAssignment(contractorId),
        child: const Text(
          "Confirm Assignment",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _handleAssignment(String contractorId) async {
    // Basic validation
    if (_titleController.text.isEmpty || _rawStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Title and Start Date")),
      );
      return;
    }

    final payload = {
      "title": _titleController.text,
      "description": _descController.text,
      "workType": _selectedWorkType?.toJson(), // Correct SCREAMING_SNAKE_CASE
      "scopeOfWork": _scopeController.text,
      "terms": _termsController.text,
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
          .createContractorProject(contractorId, widget.projectId, payload);

      // Invalidate both the list and the details to ensure fresh data
      ref.invalidate(subcontractorControllerProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Sub-contractor Assigned Successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }
}
