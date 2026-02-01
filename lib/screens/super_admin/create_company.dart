import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_colors.dart';
import 'package:construction_erp/controllers/super_admin/super_admin_controller.dart';

class CreateCompanyScreen extends ConsumerStatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  ConsumerState<CreateCompanyScreen> createState() =>
      _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends ConsumerState<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  // Company Controllers
  final TextEditingController companyNameCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController regNoCtrl = TextEditingController();
  final TextEditingController gstCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController websiteCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  // Admin Controllers
  final TextEditingController adminNameCtrl = TextEditingController();
  final TextEditingController adminEmailCtrl = TextEditingController();
  final TextEditingController adminPhoneCtrl = TextEditingController();

  bool giveAllPermissions = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    // Clean up controllers
    companyNameCtrl.dispose();
    addressCtrl.dispose();
    regNoCtrl.dispose();
    gstCtrl.dispose();
    emailCtrl.dispose();
    websiteCtrl.dispose();
    phoneCtrl.dispose();
    adminNameCtrl.dispose();
    adminEmailCtrl.dispose();
    adminPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // 1. Construct the Payload
      final Map<String, dynamic> payload = {
        'companyName': companyNameCtrl.text.trim(),
        'registrationNumber': regNoCtrl.text.trim(),
        'gstNumber': gstCtrl.text.trim(),
        'officeAddress': addressCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'website': websiteCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'adminName': adminNameCtrl.text.trim(),
        'adminEmail': adminEmailCtrl.text.trim(),
        'adminPhone': adminPhoneCtrl.text.trim(),
        'permissions': giveAllPermissions ? ['FULL_COMPANY_ACCESS'] : [],
      };

      // 2. Call Controller
      await ref
          .read(superAdminControllerProvider.notifier)
          .createCompany(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Company created successfully!")),
        );
        Navigator.pop(context); // Go back to list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error creating company: $e"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Create Company",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(
                  "Company name*", companyNameCtrl, "ABC Constructions Pvt Ltd",
                  required: true),
              _field(
                  "Address*", addressCtrl, "Site no. 24, Andheri East, Mumbai",
                  required: true),
              Row(children: [
                Expanded(
                    child: _field("Registration number*", regNoCtrl, "Reg No",
                        required: true)),
                const SizedBox(width: 12),
                Expanded(
                    child: _field("GST number*", gstCtrl, "GSTIN",
                        required: true)),
              ]),
              _field("Email*", emailCtrl, "admin@company.com",
                  isEmail: true, required: true),
              _field("Website", websiteCtrl, "www.company.com"),
              _field("Phone*", phoneCtrl, "+91 98765 43210", required: true),

              const SizedBox(height: 16),
              const Text("Admin details",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const Divider(),

              _field("Admin Name*", adminNameCtrl, "Rahul Sharma",
                  required: true),
              _field("Email*", adminEmailCtrl, "rahul@company.com",
                  isEmail: true, required: true),
              _field("Phone*", adminPhoneCtrl, "+91", required: true),

              Row(
                children: [
                  Checkbox(
                    value: giveAllPermissions,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (v) => setState(() => giveAllPermissions = v!),
                  ),
                  const Text("Give all permissions to admin")
                ],
              ),
              const SizedBox(height: 10),

              // --- SUBMIT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text("Create company",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c,
    String hint, {
    bool required = false,
    bool isEmail = false,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 6),
      TextFormField(
        controller: c,
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          if (isEmail && value != null && value.isNotEmpty) {
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) return 'Invalid email format';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0A6ED1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primaryBlue),
          ),
          errorBorder: OutlineInputBorder(
            // Add error border style
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
      const SizedBox(height: 14),
    ]);
  }
}
