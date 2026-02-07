import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  // Form Key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();

  // Dropdown Values
  String? _selectedProject;
  String? _selectedRole;

  // Dummy Data for Dropdowns
  final List<String> _projects = ['Metro Line 5', 'Highway Expansion', 'City Bridge'];
  final List<String> _roles = ['Manager', 'Site Engineer', 'Supervisor', 'Staff'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid - Proceed with creation logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Created Successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create User",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. User Name ---
              _buildLabel("User Name"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: "Enter the user name",
                validator: (val) => val == null || val.isEmpty ? "Name is required" : null,
              ),

              const SizedBox(height: 20),

              // --- 2. User Email ---
              _buildLabel("User Email"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: "Enter user email",
                inputType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Email is required";
                  if (!val.contains('@')) return "Enter a valid email";
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // --- 3. Phone Number ---
              _buildLabel("Phone Number"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _phoneController,
                hint: "Enter the user phone number",
                inputType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Phone number is required";
                  if (val.length < 10) return "Enter a valid phone number";
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // --- 4. Project Name (Dropdown) ---
              _buildLabel("Project Name"),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedProject,
                items: _projects,
                hint: "Select Project",
                onChanged: (val) => setState(() => _selectedProject = val),
              ),

              const SizedBox(height: 20),

              // --- 5. Role Name (Dropdown) ---
              _buildLabel("Role Name"),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedRole,
                items: _roles,
                hint: "Select Role",
                onChanged: (val) => setState(() => _selectedRole = val),
              ),

              const SizedBox(height: 20),

              // --- 6. Aadhar Number (Replaced Field) ---
              _buildLabel("Aadhar Number"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _aadharController,
                keyboardType: TextInputType.number,
                maxLength: 12,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: "Enter 12-digit Aadhar number",
                  hintStyle: const TextStyle(color: Color(0xFFB0C4DE)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4A90E2)), // Light Blue Border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF0A6ED1), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  counterText: "", // Hides the tiny character counter
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Aadhar number is required";
                  if (val.length != 12) return "Aadhar number must be exactly 12 digits";
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // --- 7. Create User Button ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A6ED1), // Primary Blue from image
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Create User",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0C4DE)), // Light blue-grey hint
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A90E2)), // Matching blue border from image
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A6ED1), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0A6ED1)), // Blue chevron
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A90E2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A6ED1), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      hint: Text(
        hint,
        style: const TextStyle(color: Color(0xFFB0C4DE)),
      ),
      validator: (val) => val == null ? "Please select an option" : null,
    );
  }
}