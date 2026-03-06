import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/controllers/project/project_controller.dart';
import 'package:intl/intl.dart';

class EditProjectScreen extends ConsumerStatefulWidget {
  final Project project;
  const EditProjectScreen({super.key, required this.project});

  @override
  ConsumerState<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends ConsumerState<EditProjectScreen> {
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _locationController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _budgetController;
  late TextEditingController _advanceController;
  late TextEditingController _contractValueController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  // State for Dropdowns
  late Priority _selectedPriority;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing project data
    _nameController = TextEditingController(text: widget.project.name);
    _descController =
        TextEditingController(text: widget.project.description ?? "");
    _locationController = TextEditingController(text: widget.project.location);
    _latController =
        TextEditingController(text: widget.project.latitude.toString());
    _lngController =
        TextEditingController(text: widget.project.longitude.toString());
    _budgetController =
        TextEditingController(text: widget.project.estimatedBudget.toString());
    _advanceController = TextEditingController(
        text: (widget.project.advanceReceived ?? 0).toString());
    _contractValueController = TextEditingController(
        text: (widget.project.contractValue ?? 0).toString());

    // Formatting dates for the UI
    _startDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(widget.project.startDate));
    _endDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(widget.project.estimatedEndDate));

    _selectedPriority = widget.project.priority;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _budgetController.dispose();
    _advanceController.dispose();
    _contractValueController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _updateProject() async {
    final updates = {
      'name': _nameController.text,
      'description': _descController.text,
      'location': _locationController.text,
      'latitude': double.tryParse(_latController.text) ?? 0.0,
      'longitude': double.tryParse(_lngController.text) ?? 0.0,
      'estimatedBudget': double.tryParse(_budgetController.text) ?? 0.0,
      'advanceReceived': double.tryParse(_advanceController.text) ?? 0.0,
      'contractValue': double.tryParse(_contractValueController.text) ?? 0.0,
      'startDate': _startDateController.text,
      'estimatedEndDate': _endDateController.text,
      'priority': _selectedPriority.toJson(),
    };

    try {
      // Call the controller's update method
      await ref
          .read(projectControllerProvider.notifier)
          .updateProject(widget.project.id, updates);

      if (mounted) {
        Navigator.pop(context); // Close Dialog
        Navigator.pop(context); // Go back to details
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Project Updated Successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error updating project: $e"),
              backgroundColor: AppColors.alertRed),
        );
      }
    }
  }

  // --- UI HELPERS ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87)),
    );
  }

  InputDecoration _inputDecor(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0A6ED1))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
      suffixIcon: suffixIcon,
      fillColor: Colors.white,
      filled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
        title: const Text("Edit Project",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Project Name"),
            TextFormField(
                controller: _nameController,
                decoration: _inputDecor("Project Name")),
            _buildLabel("Description"),
            TextFormField(
                controller: _descController,
                decoration: _inputDecor("Project Description"),
                maxLines: 3),
            _buildLabel("Location"),
            TextFormField(
                controller: _locationController,
                decoration: _inputDecor("Project Location")),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Latitude"),
                      TextFormField(
                          controller: _latController,
                          decoration: _inputDecor("Lat"),
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Longitude"),
                      TextFormField(
                          controller: _lngController,
                          decoration: _inputDecor("Lng"),
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            _buildLabel("Priority"),
            DropdownButtonFormField<Priority>(
              initialValue: _selectedPriority,
              decoration: _inputDecor("Select Priority"),
              items: Priority.values
                  .map((p) => DropdownMenuItem(
                      value: p, child: Text(p.name.toUpperCase())))
                  .toList(),
              onChanged: (val) => setState(() => _selectedPriority = val!),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Start date"),
                      TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        decoration: _inputDecor("Select Date",
                            suffixIcon: const Icon(Icons.calendar_month,
                                color: AppColors.primaryBlue)),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100));
                          if (picked != null) {
                            setState(() => _startDateController.text =
                                DateFormat('yyyy-MM-dd').format(picked));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("End date"),
                      TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        decoration: _inputDecor("Select Date",
                            suffixIcon: const Icon(Icons.calendar_month,
                                color: AppColors.primaryBlue)),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100));
                          if (picked != null) {
                            setState(() => _endDateController.text =
                                DateFormat('yyyy-MM-dd').format(picked));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Estimated budget"),
                      TextFormField(
                          controller: _budgetController,
                          decoration: _inputDecor("Budget"),
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Advanced received"),
                      TextFormField(
                          controller: _advanceController,
                          decoration: _inputDecor("Advance"),
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            _buildLabel("Contract Value"),
            TextFormField(
                controller: _contractValueController,
                decoration: _inputDecor("Contract Value"),
                keyboardType: TextInputType.number),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 160,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: projectState.isLoading
                      ? null
                      : () => _showConfirmationDialog(),
                  child: projectState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Update Project",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Edit"),
        content: const Text("Are you sure you want to update this project?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(onPressed: _updateProject, child: const Text("Yes")),
        ],
      ),
    );
  }
}
