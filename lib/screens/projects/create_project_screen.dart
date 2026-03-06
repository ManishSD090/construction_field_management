import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/project/project_controller.dart';
import 'package:construction_erp/controllers/client/client_controller.dart';
import 'package:construction_erp/models/enums.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _budgetController = TextEditingController();
  final _advancedController = TextEditingController();
  final _contractValueController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  // String? _selectedClientId;
  Priority _selectedPriority = Priority.medium;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _budgetController.dispose();
    _advancedController.dispose();
    _contractValueController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateProject() async {
    if (_nameController.text.isEmpty || _startDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Project name and start date are required")),
      );
      return;
    }

    final payload = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      'latitude': double.tryParse(_latController.text) ?? 0.0,
      'longitude': double.tryParse(_lngController.text) ?? 0.0,
      'startDate': _startDateController.text,
      'estimatedEndDate': _endDateController.text,
      'estimatedBudget': double.tryParse(_budgetController.text) ?? 0.0,
      'advanceReceived': double.tryParse(_advancedController.text) ?? 0.0,
      'contractValue': double.tryParse(_contractValueController.text),
      // 'clientId': _selectedClientId,
      'priority': _selectedPriority.toJson(), // Uses your enum's toJson()
      'projectId':
          'PROJ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    };

    try {
      await ref.read(projectControllerProvider.notifier).createProject(payload);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientState = ref.watch(clientControllerProvider);
    final projectState = ref.watch(projectControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Create Project",
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Project Name"),
              _buildTextField(controller: _nameController, hint: "Enter name"),
              const SizedBox(height: 15),
              _buildLabel("Description"),
              _buildTextField(
                  controller: _descriptionController,
                  hint: "Project details...",
                  maxLines: 3),
              const SizedBox(height: 15),
              // _buildLabel("Client Name"),
              // clientState.when(
              //   data: (state) => _buildClientDropdown(state),
              //   loading: () => const LinearProgressIndicator(),
              //   error: (err, _) => const Text("Error loading clients"),
              // ),
              // const SizedBox(height: 15),
              _buildLabel("Location Address"),
              _buildTextField(
                  controller: _locationController, hint: "Enter full address"),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        _buildLabel("Latitude"),
                        _buildTextField(
                            controller: _latController,
                            hint: "0.0000",
                            keyboardType: TextInputType.number),
                      ])),
                  const SizedBox(width: 15),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        _buildLabel("Longitude"),
                        _buildTextField(
                            controller: _lngController,
                            hint: "0.0000",
                            keyboardType: TextInputType.number),
                      ])),
                ],
              ),
              const SizedBox(height: 15),
              _buildLabel("Priority"),
              _buildPriorityDropdown(),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        _buildLabel("Start Date"),
                        _buildDatePicker(_startDateController),
                      ])),
                  const SizedBox(width: 15),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        _buildLabel("End Date"),
                        _buildDatePicker(_endDateController),
                      ])),
                ],
              ),
              const SizedBox(height: 15),
              _buildLabel("Contract Value"),
              _buildTextField(
                  controller: _contractValueController,
                  hint: "Contract Value",
                  keyboardType: TextInputType.number),
              const SizedBox(height: 15),
              _buildLabel("Estimated Budget"),
              _buildTextField(
                  controller: _budgetController,
                  hint: "Total Amount",
                  keyboardType: TextInputType.number),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      projectState.isLoading ? null : _handleCreateProject,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25))),
                  child: projectState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Create Project",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Priority Dropdown ---
  Widget _buildPriorityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Priority>(
          value: _selectedPriority,
          isExpanded: true,
          items: Priority.values
              .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p.name.toUpperCase()), // Capitalizing label
                  ))
              .toList(),
          onChanged: (val) => setState(() => _selectedPriority = val!),
        ),
      ),
    );
  }

  // --- Paginated Client Dropdown ---
  // Widget _buildClientDropdown(ClientState state) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
  //     ),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         value: _selectedClientId,
  //         hint: const Text("Select Client"),
  //         isExpanded: true,
  //         items: [
  //           ...state.clients.map((c) =>
  //               DropdownMenuItem(value: c.id, child: Text(c.companyName))),
  //           if (state.hasMore)
  //             const DropdownMenuItem(
  //                 value: 'load_more',
  //                 child: Text("Load more clients...",
  //                     style: TextStyle(color: AppColors.primaryBlue))),
  //         ],
  //         onChanged: (val) {
  //           if (val == 'load_more') {
  //             ref.read(clientControllerProvider.notifier).loadNextPage();
  //           } else {
  //             setState(() => _selectedClientId = val);
  //           }
  //         },
  //       ),
  //     ),
  //   );
  // }

  // --- Helper UI Widgets ---
  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)));

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hint,
      TextInputType keyboardType = TextInputType.text,
      int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDatePicker(TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100));
        if (picked != null) {
          setState(
              () => controller.text = picked.toIso8601String().split('T')[0]);
        }
      },
      decoration: InputDecoration(
        hintText: "YYYY-MM-DD",
        suffixIcon: const Icon(Icons.calendar_month, size: 20),
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
    );
  }
}
