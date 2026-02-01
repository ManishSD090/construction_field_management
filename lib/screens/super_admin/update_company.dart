import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_colors.dart';
import 'package:construction_erp/controllers/super_admin/super_admin_controller.dart';

class UpdateCompanyScreen extends ConsumerStatefulWidget {
  // Pass the existing company data to pre-fill the form
  // You can replace Map<String, dynamic> with your specific CompanyModel if available
  final Map<String, dynamic> companyData;

  const UpdateCompanyScreen({super.key, required this.companyData});

  @override
  ConsumerState<UpdateCompanyScreen> createState() =>
      _UpdateCompanyScreenState();
}

class _UpdateCompanyScreenState extends ConsumerState<UpdateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  // Company Controllers
  late TextEditingController companyNameCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController regNoCtrl;
  late TextEditingController gstCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController websiteCtrl;
  late TextEditingController phoneCtrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize and Auto-fill data
    // Note: Adjust the keys (['companyName'], etc.) to match your actual API response model
    companyNameCtrl =
        TextEditingController(text: widget.companyData['companyName'] ?? '');
    addressCtrl =
        TextEditingController(text: widget.companyData['officeAddress'] ?? '');
    regNoCtrl = TextEditingController(
        text: widget.companyData['registrationNumber'] ?? '');
    gstCtrl =
        TextEditingController(text: widget.companyData['gstNumber'] ?? '');
    emailCtrl = TextEditingController(text: widget.companyData['email'] ?? '');
    websiteCtrl =
        TextEditingController(text: widget.companyData['website'] ?? '');
    phoneCtrl = TextEditingController(text: widget.companyData['phone'] ?? '');
  }

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
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // 1. Construct the Payload (Admin details removed)
      final Map<String, dynamic> updates = {
        'name': companyNameCtrl.text.trim(),
        'registrationNumber': regNoCtrl.text.trim(),
        'gstNumber': gstCtrl.text.trim(),
        'officeAddress': addressCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'website': websiteCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
      };

      // 2. Call Controller
      // Assuming your controller has an updateCompany(id, payload) method
      final id = widget.companyData['id'] ?? widget.companyData['_id'];

      await ref
          .read(superAdminControllerProvider.notifier)
          .updateCompany(id: id, updates: updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Company updated successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error updating company: $e"),
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
        title: const Text("Update Company",
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

              const SizedBox(height: 24),

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
                      : const Text("Save Changes",
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
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
      const SizedBox(height: 14),
    ]);
  }
}
