import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/subcontractor/subcontractor_controller.dart';
import 'package:construction_erp/models/enums.dart';

class CreateSubContractorScreen extends ConsumerStatefulWidget {
  const CreateSubContractorScreen({super.key});

  @override
  ConsumerState<CreateSubContractorScreen> createState() =>
      _CreateSubContractorScreenState();
}

class _CreateSubContractorScreenState
    extends ConsumerState<CreateSubContractorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers based on your JSON reference
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Legal/Tax
  final _regNumController = TextEditingController();
  final _gstNumController = TextEditingController();
  final _panNumController = TextEditingController();
  final _aadharNumController = TextEditingController();

  // Bank Details
  final _bankNameController = TextEditingController();
  final _bankAccController = TextEditingController();
  final _ifscController = TextEditingController();
  final _branchController = TextEditingController();

  // Rates & Capacity
  final _maxWorkersController = TextEditingController(text: "300");
  final _maxMachinesController = TextEditingController(text: "50");
  final _hourlyRateController = TextEditingController();
  final _dailyRateController = TextEditingController();

  ContractorType _selectedType = ContractorType.labor;
  final List<WorkType> _selectedWorkTypes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("New Sub-contractor",
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
              _buildHeader("Basic Information"),
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
              const SizedBox(height: 20),
              _buildHeader("Legal & Tax Details"),
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
              const SizedBox(height: 20),
              _buildHeader("Bank Account Details"),
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
              const SizedBox(height: 20),
              _buildHeader("Capacity & Rates"),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Component Helpers ---

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
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
          labelStyle: const TextStyle(fontSize: 14),
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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: WorkType.values.map((type) {
              final isSelected = _selectedWorkTypes.contains(type);
              return FilterChip(
                label: Text(type.name[0].toUpperCase() + type.name.substring(1),
                    style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.black)),
                selected: isSelected,
                selectedColor: AppColors.primaryBlue,
                onSelected: (val) {
                  setState(() {
                    val
                        ? _selectedWorkTypes.add(type)
                        : _selectedWorkTypes.remove(type);
                  });
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: _submitForm,
        child: const Text("Create Sub-contractor",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
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
      "isVerified": false,
    };

    await ref
        .read(subcontractorControllerProvider.notifier)
        .createSubcontractor(payload);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contractor Profile Created!")));
    }
  }
}
