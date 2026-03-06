import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/subcontractor/subcontractor_controller.dart';
import 'package:construction_erp/models/enums.dart';

class EditSubContractorScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> subContractorData;

  const EditSubContractorScreen({super.key, required this.subContractorData});

  @override
  ConsumerState<EditSubContractorScreen> createState() =>
      _EditSubContractorScreenState();
}

class _EditSubContractorScreenState
    extends ConsumerState<EditSubContractorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic Information
  late TextEditingController _nameController;
  late TextEditingController _contactPersonController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _altPhoneController;
  late TextEditingController _addressController;

  // Legal/Tax
  late TextEditingController _regNumController;
  late TextEditingController _gstNumController;
  late TextEditingController _panNumController;
  late TextEditingController _aadharNumController;

  // Bank Details
  late TextEditingController _bankNameController;
  late TextEditingController _bankAccController;
  late TextEditingController _ifscController;
  late TextEditingController _branchController;

  // Rates & Capacity
  late TextEditingController _maxWorkersController;
  late TextEditingController _maxMachinesController;
  late TextEditingController _hourlyRateController;
  late TextEditingController _dailyRateController;

  ContractorType _selectedType = ContractorType.labor;
  final List<WorkType> _selectedWorkTypes = [];

  @override
  void initState() {
    super.initState();
    final data = widget.subContractorData;

    // Mapping passed data to controllers
    _nameController = TextEditingController(text: data['name']);
    _contactPersonController =
        TextEditingController(text: data['contactPerson']);
    _emailController = TextEditingController(text: data['email']);
    _phoneController = TextEditingController(text: data['phone']);
    _altPhoneController = TextEditingController(text: data['altPhone']);
    _addressController = TextEditingController(text: data['address']);

    _regNumController = TextEditingController(text: data['registrationNumber']);
    _gstNumController = TextEditingController(text: data['gstNumber']);
    _panNumController = TextEditingController(text: data['panNumber']);
    _aadharNumController = TextEditingController(text: data['aadharNumber']);

    _bankNameController = TextEditingController(text: data['bankName']);
    _bankAccController = TextEditingController(text: data['bankAccount']);
    _ifscController = TextEditingController(text: data['bankIfsc']);
    _branchController = TextEditingController(text: data['bankBranch']);

    _maxWorkersController =
        TextEditingController(text: data['maxWorkers']?.toString() ?? "10");
    _maxMachinesController =
        TextEditingController(text: data['maxMachines']?.toString() ?? "10");
    _hourlyRateController =
        TextEditingController(text: data['hourlyRate']?.toString() ?? "");
    _dailyRateController =
        TextEditingController(text: data['dailyRate']?.toString() ?? "");

    // Handle Enums
    if (data['type'] != null) {
      _selectedType =
          ContractorType.values.byName(data['type'].toString().toLowerCase());
    }

    if (data['workTypes'] != null && data['workTypes'] is List) {
      for (var type in data['workTypes']) {
        _selectedWorkTypes.add(WorkType.fromJson(type.toString()));
      }
    }
  }

  @override
  void dispose() {
    // Dispose all 18 controllers
    _nameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _addressController.dispose();
    _regNumController.dispose();
    _gstNumController.dispose();
    _panNumController.dispose();
    _aadharNumController.dispose();
    _bankNameController.dispose();
    _bankAccController.dispose();
    _ifscController.dispose();
    _branchController.dispose();
    _maxWorkersController.dispose();
    _maxMachinesController.dispose();
    _hourlyRateController.dispose();
    _dailyRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Sub-contractor",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Basic Information"),
              _buildTextField(_nameController, "Company Name",
                  isRequired: true),
              _buildDropdownType(),
              _buildWorkTypeChips(),
              _buildTextField(_contactPersonController, "Contact Person"),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(_phoneController, "Phone",
                          inputType: TextInputType.phone, isRequired: true)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildTextField(_altPhoneController, "Alt Phone",
                          inputType: TextInputType.phone)),
                ],
              ),
              _buildTextField(_emailController, "Email ID",
                  inputType: TextInputType.emailAddress),
              _buildTextField(_addressController, "Office Address",
                  maxLines: 2),
              _buildSectionHeader("Legal & Tax Details"),
              _buildTextField(_regNumController, "Registration Number"),
              _buildTextField(_gstNumController, "GST Number"),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(_panNumController, "PAN Number")),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildTextField(
                          _aadharNumController, "Aadhar Number")),
                ],
              ),
              _buildSectionHeader("Bank Account Details"),
              _buildTextField(_bankNameController, "Bank Name"),
              _buildTextField(_bankAccController, "Account Number",
                  inputType: TextInputType.number),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(_ifscController, "IFSC Code")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(_branchController, "Branch")),
                ],
              ),
              _buildSectionHeader("Capacity & Rates"),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          _maxWorkersController, "Max Workers",
                          inputType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildTextField(
                          _maxMachinesController, "Max Machines",
                          inputType: TextInputType.number)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          _hourlyRateController, "Hourly Rate (₹)",
                          inputType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildTextField(
                          _dailyRateController, "Daily Rate (₹)",
                          inputType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 30),
              _buildSubmitButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- Reuse UI Helpers from Create Screen ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue)),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isRequired = false,
      TextInputType inputType = TextInputType.text,
      int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: AppColors.primaryBlue.withOpacity(0.4))),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        validator: (value) =>
            isRequired && (value == null || value.isEmpty) ? "Required" : null,
      ),
    );
  }

  Widget _buildDropdownType() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<ContractorType>(
        initialValue: _selectedType,
        decoration: InputDecoration(
            labelText: "Contractor Type",
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        items: ContractorType.values
            .map((t) =>
                DropdownMenuItem(value: t, child: Text(t.name.toUpperCase())))
            .toList(),
        onChanged: (val) => setState(() => _selectedType = val!),
      ),
    );
  }

  Widget _buildWorkTypeChips() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Work Types",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: WorkType.values.map((type) {
              final isSelected = _selectedWorkTypes.contains(type);
              return FilterChip(
                label: Text(type.name,
                    style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : Colors.black)),
                selected: isSelected,
                selectedColor: AppColors.primaryBlue,
                onSelected: (val) {
                  setState(() => val
                      ? _selectedWorkTypes.add(type)
                      : _selectedWorkTypes.remove(type));
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25))),
        onPressed: _handleUpdate,
        child: const Text("Update Profile",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final updates = {
      "name": _nameController.text,
      "type": _selectedType.name.toUpperCase(),
      "workTypes": _selectedWorkTypes.map((e) => e.toJson()).toList(),
      "contactPerson": _contactPersonController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      "altPhone": _altPhoneController.text,
      "address": _addressController.text,
      "registrationNumber": _regNumController.text,
      "gstNumber": _gstNumController.text,
      "panNumber": _panNumController.text,
      "aadharNumber": _aadharNumController.text,
      "bankName": _bankNameController.text,
      "bankAccount": _bankAccController.text,
      "bankIfsc": _ifscController.text,
      "bankBranch": _branchController.text,
      "maxWorkers": int.tryParse(_maxWorkersController.text) ?? 10,
      "maxMachines": int.tryParse(_maxMachinesController.text) ?? 10,
      "hourlyRate": double.tryParse(_hourlyRateController.text) ?? 0.0,
      "dailyRate": double.tryParse(_dailyRateController.text) ?? 0.0,
    };

    try {
      await ref
          .read(subcontractorControllerProvider.notifier)
          .updateSubcontractor(widget.subContractorData['id'], updates);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Sub-contractor Updated Successfully!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Update Failed: $e")));
    }
  }
}
