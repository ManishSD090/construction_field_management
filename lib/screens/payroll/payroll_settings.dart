import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';

class PayrollSettingsScreen extends StatefulWidget {
  const PayrollSettingsScreen({super.key});

  @override
  State<PayrollSettingsScreen> createState() => _PayrollSettingsScreenState();
}

class _PayrollSettingsScreenState extends State<PayrollSettingsScreen> {
  String _selectedRole = 'Workers';
  
  // --- NEW: Editing State ---
  bool _isEditingStaff = false;

  // List for Workers
  final List<String> _shifts = ['1.0', '0.75', '0.5'];

  // Mock List for Staff
  final List<Map<String, String>> _staffRoles = [
    {"role": "Site Engineer", "salary": "60,000"},
    {"role": "Site Engineer", "salary": "60,000"},
    {"role": "Site Engineer", "salary": "60,000"},
    {"role": "Site Engineer", "salary": "60,000"},
    {"role": "Site Engineer", "salary": "60,000"},
    {"role": "Site Engineer", "salary": "60,000"},
  ];

  // ===================== DIALOGS =====================

  // --- Create Shift Dialog (Unchanged) ---
  void _showCreateShiftDialog() {
    final TextEditingController shiftController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      "Create Shift!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                "*1.0 is considered as Full Day",
                style: TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 45,
                child: TextField(
                  controller: shiftController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (shiftController.text.isNotEmpty) {
                    setState(() {
                      _shifts.add(shiftController.text);
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  minimumSize: const Size(140, 40),
                  elevation: 0,
                ),
                child: const Text(
                  "Create Shift",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- NEW: Delete Role Confirmation Dialog ---
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Delete Role"),
          content: Text(
              "Are you sure you want to delete the role of '${_staffRoles[index]['role']}' and its salary setting?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _staffRoles.removeAt(index);
                });
                Navigator.pop(context); // Close dialog
              },
              child: const Text("Delete",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ===================== BUILDER =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text("Payroll Settings",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRoleToggle(),
          Expanded(
            child: _selectedRole == 'Workers' 
                ? _buildWorkersContent() 
                : _buildStaffContent(),
          ),
          // Conditionally hide the Save button when editing staff list
          if (_selectedRole == 'Workers' || (_selectedRole == 'Staff' && !_isEditingStaff)) 
            _buildSaveButton(),
        ],
      ),
    );
  }

  // --- Toggle Buttons ---
  Widget _buildRoleToggle() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: ['Workers', 'Staff'].map((role) {
          bool isSelected = _selectedRole == role;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRole = role;
                  // Reset edit state when switching tabs
                  if (role == 'Workers') _isEditingStaff = false;
                });
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(role,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===================== WORKERS CONTENT (Unchanged) =====================
  Widget _buildWorkersContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabourRateInput(),
          const SizedBox(height: 30),
          const Text("Available shifts",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          _buildShiftList(),
        ],
      ),
    );
  }

  Widget _buildLabourRateInput() {
    return Row(
      children: [
        const Text("Labour Rate  ",
            style: TextStyle(fontWeight: FontWeight.w500)),
        Container(
          width: 120,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryBlue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("₹",
                    style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Text("  per Day", style: TextStyle(color: AppColors.primaryBlue)),
      ],
    );
  }

  Widget _buildShiftList() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ..._shifts.map((shift) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryBlue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(shift,
                  style: const TextStyle(
                      color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            )),
        GestureDetector(
          onTap: _showCreateShiftDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryBlue, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue.withOpacity(0.05),
            ),
            child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 20),
          ),
        ),
      ],
    );
  }

  // ===================== STAFF CONTENT (Updated for Editing Flow) =====================
  Widget _buildStaffContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Switches between Edit Icon and Done Button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Role and Salary/Month", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              
              _isEditingStaff 
                // While Editing: Show Done Button
                ? ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditingStaff = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD), // Blue
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(60, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      elevation: 0,
                    ),
                    child: const Text("Done", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                // Default State: Show Edit Icon
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditingStaff = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6)
                      ),
                      child: const Icon(Icons.edit, size: 16, color: Colors.grey),
                    ),
                  )
            ],
          ),
          const SizedBox(height: 15),
          
          // Staff List
          Expanded(
            child: ListView.separated(
              itemCount: _staffRoles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                // If editing, use a controller to manage the editable text
                final salaryController = TextEditingController(text: "₹ ${_staffRoles[index]['salary']}/-");

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Adjusted vertical padding
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // --- NEW: Conditionally show the delete icon ---
                      if (_isEditingStaff)
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: GestureDetector(
                            onTap: () => _showDeleteConfirmationDialog(index),
                            child: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                          ),
                        ),
                      
                      Expanded(
                        child: Text(
                          _staffRoles[index]['role']!, 
                          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)
                        ),
                      ),

                      // --- NEW: Conditionally swap Text with an editable TextField ---
                      _isEditingStaff
                        ? SizedBox(
                            width: 120, // Constrain the input width
                            child: TextField(
                              controller: salaryController,
                              textAlign: TextAlign.right,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0D6EFD))),
                              ),
                              onSubmitted: (newValue) {
                                // Simple update logic: remove symbols to just store the number
                                String cleanedValue = newValue.replaceAll('₹', '').replaceAll('/', '').replaceAll('-', '').trim();
                                _staffRoles[index]['salary'] = cleanedValue;
                              },
                            ),
                          )
                        : Text(
                            "₹ ${_staffRoles[index]['salary']}/-", 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)
                          ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Save Button ---
  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00B69B), // Success Green
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text("Save Changes",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}