import 'package:flutter/material.dart';
import '../../core/services/app_colors.dart';

class CreateRoleScreen extends StatefulWidget {
  const CreateRoleScreen({super.key});

  @override
  State<CreateRoleScreen> createState() => _CreateRoleScreenState();
}

class _CreateRoleScreenState extends State<CreateRoleScreen> {
  // Permission Model
  final List<Map<String, dynamic>> _modulePermissions = [
    {"module": "User Management", "view": false, "edit": false},
    {"module": "Project Management", "view": false, "edit": false},
    {"module": "Inventory Management", "view": false, "edit": false},
    {"module": "Financial Records", "view": false, "edit": false},
    {"module": "Attendance & Site", "view": false, "edit": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create Role",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Role Name"),
            _buildTextField("E.g. Site Manager"),
            
            const SizedBox(height: 20),
            _buildLabel("Role Description"),
            _buildTextField("Enter description here...", maxLines: 3),
            
            const SizedBox(height: 20),
            _buildLabel("Access Scope"),
            _buildTextField("Enter Scope (e.g. All Sites, Site A)"),
            
            const SizedBox(height: 30),
            
            // Permissions Header Row
            Row(
              children: [
                Expanded(flex: 3, child: _buildLabel("Module Name")),
                Expanded(child: Center(child: _buildLabel("View"))),
                Expanded(child: Center(child: _buildLabel("Edit"))),
              ],
            ),
            const Divider(),

            // Permissions List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _modulePermissions.length,
              itemBuilder: (context, index) {
                final module = _modulePermissions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(module['module'], style: const TextStyle(fontSize: 14)),
                      ),
                      // View Checkbox
                      Expanded(
                        child: Checkbox(
                          activeColor: AppColors.primaryBlue,
                          value: module['view'],
                          onChanged: (val) => setState(() => module['view'] = val),
                        ),
                      ),
                      // Edit/Create Checkbox
                      Expanded(
                        child: Checkbox(
                          activeColor: AppColors.primaryBlue,
                          value: module['edit'],
                          onChanged: (val) => setState(() => module['edit'] = val),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Create Role", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper UI Components ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}