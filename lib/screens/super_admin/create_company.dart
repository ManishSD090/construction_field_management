import 'dart:math';
import 'package:flutter/material.dart';
import '../../utilities/app_colors.dart';
// import '../../models/company.dart'; // Import if you need to create the object here

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllers ---
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- Logic: Generate Random Password ---
  void _generateRandomKey() {
    const length = 10;
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890@#%&';
    Random rnd = Random();
    String newPassword = String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

    setState(() {
      _passwordController.text = newPassword;
    });
  }

  // --- Logic: Handle Submit ---
  void _handleCreate() {
    if (_formKey.currentState!.validate()) {
      // TODO: Connect to your API/Bloc here

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company Created Successfully'),
          backgroundColor: AppColors.successGreen,
        ),
      );

      // Go back to the list
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _locationController.dispose();
    _adminNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- AppBar ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Create company",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Company Details Section ---
              const Text("Company details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _buildLabel("Company name"),
              _buildTextField(
                  controller: _companyNameController,
                  hint: "Enter the company name"),

              const SizedBox(height: 16),
              _buildLabel("Location"),
              _buildTextField(
                  controller: _locationController,
                  hint: "Enter the office address"),

              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade200, thickness: 1),
              const SizedBox(height: 16),

              // --- 2. Admin Details Section ---
              const Text("Admin details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _buildLabel("Admin name"),
              _buildTextField(
                  controller: _adminNameController,
                  hint: "Enter the admin name"),

              const SizedBox(height: 16),
              _buildLabel("Email"),
              _buildTextField(
                  controller: _emailController,
                  hint: "XYZ@gmail.com",
                  inputType: TextInputType.emailAddress),

              const SizedBox(height: 16),
              _buildLabel("Phone"),
              _buildTextField(
                  controller: _phoneController,
                  hint: "+91",
                  inputType: TextInputType.phone),

              const SizedBox(height: 24),

              // --- 3. Password Section ---
              const Text("Login password",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _buildLabel("Set password"),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _passwordController,
                      hint: "",
                      isPassword:
                          false, // Set to true if you want to hide characters
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48, // Match height of text field
                    child: ElevatedButton(
                      onPressed: _generateRandomKey,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF00BFA5), // Teal color from design
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text("Generate random key",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "*Share this password with the company admin. They can change it later.",
                style: TextStyle(color: AppColors.primaryBlue, fontSize: 11),
              ),

              const SizedBox(height: 40),

              // --- 4. Submit Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 4,
                    shadowColor: AppColors.primaryBlue.withOpacity(0.3),
                  ),
                  child: const Text("Create company",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper: Label ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 14),
      ),
    );
  }

  // --- Helper: Input Field ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isPassword,
      validator: (value) => value!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
