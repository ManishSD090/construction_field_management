import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/controllers/admin/user_controller.dart';
import 'package:construction_erp/controllers/admin/role_controller.dart';
import 'package:construction_erp/models/role.dart';

class CreateUserScreen extends ConsumerStatefulWidget {
  const CreateUserScreen({super.key});

  @override
  ConsumerState<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends ConsumerState<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. Primary Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // 2. Employment Controllers
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  // 3. Financial & Compliance Controllers
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();

  String? _selectedRoleId;
  String? _selectedSalaryType = 'MONTHLY';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _salaryController.dispose();
    _aadharController.dispose();

    _bankAccountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRoleId == null) {
        _showError('Please select a role for the employee');
        return;
      }

      // Mapping all controllers to the backend request body
      final Map<String, dynamic> employeeData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'employeeId': _employeeIdController.text.trim(), // Required
        'department': _departmentController.text.trim(), // Required
        'designation': _designationController.text.trim(),
        'salary':
            double.tryParse(_salaryController.text.trim()), // Numeric Required
        'salaryType': _selectedSalaryType,
        'roleId': _selectedRoleId,
        'aadharNumber': _aadharController.text.trim(),
        'bankAccount': _bankAccountController.text.trim(),
        'ifscCode': _ifscController.text.trim(),
      };

      try {
        // Triggering the UserController action
        await ref
            .read(userControllerProvider.notifier)
            .createEmployee(employeeData);
        if (mounted) {
          Navigator.pop(context); // Return to directory
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee successfully invited!')),
          );
        }
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Reactive role fetching from RoleController
    final rolesAsync = ref.watch(roleControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Create Employee",
            style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("PRIMARY DETAILS"),
              _buildLabel("Full Name *"),
              _buildTextField(
                  controller: _nameController,
                  hint: "Enter full name",
                  validator: (val) => val!.isEmpty ? "Name is required" : null),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFieldGroup(
                        "Email *", _emailController, "email@company.com",
                        inputType: TextInputType.emailAddress),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFieldGroup(
                        "Phone *", _phoneController, "Phone number",
                        inputType: TextInputType.phone),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionHeader("EMPLOYMENT DETAILS"),
              Row(
                children: [
                  Expanded(
                    child: _buildFieldGroup(
                        "Employee ID *", _employeeIdController, "EMP-001",
                        validator: (val) => val!.isEmpty ? "Required" : null),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFieldGroup(
                        "Department *", _departmentController, "Engineering",
                        validator: (val) => val!.isEmpty ? "Required" : null),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel("Designation"),
              _buildTextField(
                  controller: _designationController,
                  hint: "e.g. Project Manager"),
              const SizedBox(height: 16),
              _buildLabel("Access Role *"),
              rolesAsync.when(
                data: (roleState) => _buildRoleDropdown(roleState.roles),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => const Text("Error loading roles",
                    style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader("FINANCIAL & COMPLIANCE"),
              Row(
                children: [
                  Expanded(
                    child: _buildFieldGroup(
                        "Salary Amount *", _salaryController, "0.00",
                        inputType: TextInputType.number, validator: (val) {
                      if (val == null || val.isEmpty) return "Required";
                      if (double.tryParse(val) == null) return "Invalid number";
                      return null;
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Salary Type"),
                        _buildSalaryTypeDropdown(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel("Aadhar Number"),
              _buildTextField(
                  controller: _aadharController,
                  hint: "12-digit number",
                  inputType: TextInputType.number),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildFieldGroup(
                          "Bank Account", _bankAccountController, "Account No",
                          inputType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildFieldGroup(
                          "IFSC Code", _ifscController, "IFSC0001234")),
                ],
              ),
              const SizedBox(height: 48),
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Build Methods ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A6ED1),
              letterSpacing: 1.1)),
    );
  }

  Widget _buildFieldGroup(
      String label, TextEditingController controller, String hint,
      {TextInputType inputType = TextInputType.text,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        _buildTextField(
            controller: controller,
            hint: hint,
            inputType: inputType,
            validator: validator),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54)),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hint,
      TextInputType inputType = TextInputType.text,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0C4DE), fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE1EEFA))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0A6ED1), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }

  Widget _buildRoleDropdown(List<Role> roles) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedRoleId,
      items: roles
          .map((role) =>
              DropdownMenuItem(value: role.id, child: Text(role.name)))
          .toList(),
      onChanged: (val) => setState(() => _selectedRoleId = val),
      decoration: _dropdownDecoration("Select access role"),
      validator: (val) => val == null ? "Required" : null,
    );
  }

  Widget _buildSalaryTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedSalaryType,
      items: ['MONTHLY', 'WEEKLY', 'DAILY', 'HOURLY']
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: (val) => setState(() => _selectedSalaryType = val),
      decoration: _dropdownDecoration("Type"),
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE1EEFA))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0A6ED1))),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A6ED1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: const Text("Create User",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
