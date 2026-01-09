import 'package:flutter/material.dart';
import '../../utilities/app_colors.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController company = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController regNo = TextEditingController();
  final TextEditingController gst = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController website = TextEditingController();
  final TextEditingController phone = TextEditingController();

  final TextEditingController adminName = TextEditingController();
  final TextEditingController adminEmail = TextEditingController();
  final TextEditingController adminPhone = TextEditingController();

  bool giveAllPermissions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Company details",
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            _field("Company name*", company, "ABC Constructions Pvt Ltd"),
            _field("Address*", address, "Site no. 24, Andheri East, Mumbai"),

            Row(children: [
              Expanded(child: _field("Registration number*", regNo, "")),
              const SizedBox(width: 12),
              Expanded(child: _field("GST number*", gst, "15-character GSTIN")),
            ]),

            _field("Email*", email, "admin@company.com"),
            _field("Website", website, "www.company.com"),
            _field("Phone*", phone, "+91 98765 43210"),

            const SizedBox(height: 16),
            const SizedBox(height: 16),

            const Text("Admin details",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                
            const Divider(),

            _field("Admin Name*", adminName, "Rahul Sharma"),
            _field("Email*", adminEmail, "rahul@company.com"),
            _field("Phone*", adminPhone, "+91"),

            Row(
              children: [
                Checkbox(
                  value: giveAllPermissions,
                  onChanged: (v) => setState(() => giveAllPermissions = v!),
                ),
                const Text("Give all permissions to admin")
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {},
                child: const Text("Create company",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 6),
      TextFormField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0A6ED1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primaryBlue),
          ),
        ),
      ),
      const SizedBox(height: 14),
    ]);
  }
}
