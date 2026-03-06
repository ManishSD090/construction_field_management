import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart'; // Adjust import if needed
import 'package:construction_erp/routes.dart'; // Adjust for your footer routing

class PayrollSettingsScreen extends StatefulWidget {
  const PayrollSettingsScreen({super.key});

  @override
  State<PayrollSettingsScreen> createState() => _PayrollSettingsScreenState();
}

class _PayrollSettingsScreenState extends State<PayrollSettingsScreen> {
  bool isWorkersSelected = true;
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _shiftController = TextEditingController();
  
  // State list to hold the dynamic shifts
  List<String> availableShifts = ['1.0', '0.75', '0.5'];

bool isStaffDeleteMode = false;
  List<Map<String, dynamic>> staffRoles = [
    {'role': 'Site Engineer', 'salary': '60,000', 'selected': false},
    {'role': 'Site Engineer', 'salary': '60,000', 'selected': false},
    {'role': 'Site Engineer', 'salary': '60,000', 'selected': false},
    {'role': 'Site Engineer', 'salary': '60,000', 'selected': false},
    {'role': 'Site Engineer', 'salary': '60,000', 'selected': false},
  ];

  String? _newRoleSelected; 
  final List<String> _roleOptions = ['Site Engineer', 'Supervisor', 'Project Manager', 'Safety Officer'];
  final TextEditingController _newSalaryController = TextEditingController();
  @override
  void dispose() {
    _rateController.dispose();
    _shiftController.dispose();
    super.dispose();
  }

  // --- Modal: Create Shift ---
  void _showCreateShiftDialog() {
    _shiftController.clear(); // Clear input before opening
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Create Shift",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "*1.0 is considered as Full Day",
                  style: TextStyle(color: AppColors.primaryBlue, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _shiftController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primaryBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_shiftController.text.isNotEmpty) {
                        // 1. Add to the list
                        setState(() {
                          availableShifts.add(_shiftController.text);
                        });
                        // 2. Close Create Dialog
                        Navigator.pop(context);
                        // 3. Show Success Dialog
                        _showSuccessDialog();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Create Shift", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Modal: Success ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // Auto-close success dialog after a short delay (optional, makes it feel premium)
        Future.delayed(const Duration(seconds: 1), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Shift Created",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00B48A), // Success Green
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
          "Payroll Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  _buildToggleButton("Workers", isWorkersSelected, () {
                    setState(() => isWorkersSelected = true);
                  }),
                  _buildToggleButton("Staff", !isWorkersSelected, () {
                    setState(() => isWorkersSelected = false);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 30),

            if (isWorkersSelected) 
              _buildWorkersView()
            else 
              Expanded(child: _buildStaffView()),

            // 4. Save Button (Hidden in Staff view unless in Edit mode)
            // 👇 Only show Save button for Workers, OR if Staff is in Edit Mode
            if (isWorkersSelected || (!isWorkersSelected && isStaffDeleteMode))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => isWorkersSelected ? Navigator.pop(context) : _showSaveStaffChangesSheet(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B48A), // Green
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }
// --- Modals for Staff Flow ---
  
  void _showDeleteRoleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Are you sure you want to\ndelete the Role?", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        staffRoles.removeWhere((r) => r['selected'] == true);
                        isStaffDeleteMode = false;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30), // Red
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Delete", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSaveStaffChangesSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Are you sure you want to\nsave the Changes?", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: () {setState(() {
                      // 1. Add new role if they typed one in
                      if (_newRoleSelected != null && _newSalaryController.text.isNotEmpty) {
                        staffRoles.add({
                          'role': _newRoleSelected,
                          'salary': _newSalaryController.text,
                          'selected': false
                        });
                        _newRoleSelected = null;
                        _newSalaryController.clear();
                      }

                      // 2. TURN OFF EDIT MODE (Hides save button & returns pencil icon)
                      isStaffDeleteMode = false;
                      
                      // 3. Uncheck all boxes
                      for (var role in staffRoles) {
                        role['selected'] = false;
                      }
                    });

                    Navigator.pop(context); // Close confirmation sheet
                    _showChangesSavedDialog(); // Show green checkmark
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Yes", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showChangesSavedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        Future.delayed(const Duration(seconds: 1), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Changes Saved", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Color(0xFF00B48A), shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShiftChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.primaryBlue)),
    );
  }

  Widget _buildAddShiftButton() {
    return GestureDetector(
      onTap: _showCreateShiftDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          // Note: Standard Flutter doesn't have dashed borders natively. 
          // Using a solid, slightly transparent border to mimic the look without requiring third-party packages.
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)), 
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 20),
      ),
    );
  }
  // --- UI: Workers View (Your existing code moved here) ---
  Widget _buildWorkersView() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Labour Rate", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryBlue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text("₹", style: TextStyle(color: AppColors.primaryBlue, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _rateController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.only(bottom: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text("per Day", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 30),
          const Text("Available shifts", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...availableShifts.map((shift) => _buildShiftChip(shift)),
              _buildAddShiftButton(),
            ],
          ),
        ],
      ),
    );
  }

  // --- UI: Staff View (New Code) ---
  Widget _buildStaffView() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Role and Salary/Month", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            InkWell(
              onTap: () {
                setState(() {
                  if (!isStaffDeleteMode) {
                    isStaffDeleteMode = true; // Enter edit mode
                  } else {
                    // If in edit mode and items are checked, show delete popup
                    if (staffRoles.any((r) => r['selected'])) {
                      _showDeleteRoleDialog();
                    } else {
                      isStaffDeleteMode = false; // Exit edit mode if nothing selected
                    }
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isStaffDeleteMode ? Colors.red.shade50 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isStaffDeleteMode ? Icons.delete_outline : Icons.edit, // Toggles Pencil/Trash
                  color: isStaffDeleteMode ? Colors.red : Colors.grey, 
                  size: 20
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 24),
        Expanded(
          child: ListView.builder(
           itemCount: isStaffDeleteMode ? staffRoles.length + 1 : staffRoles.length, // +1 for the "Add New" row
            itemBuilder: (context, index) {
              if (index == staffRoles.length) {
                if (index == staffRoles.length) {
                // The "Add New" Row
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 45,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue), borderRadius: BorderRadius.circular(8)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _newRoleSelected, // 👈 This makes the selection visible!
                              hint: const Text("Select", style: TextStyle(fontSize: 13, color: Colors.grey)),
                              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue),
                              items: _roleOptions.map((String val) {
                                return DropdownMenuItem<String>(value: val, child: Text(val, style: const TextStyle(fontSize: 13)));
                              }).toList(),
                              // 👈 This makes it ONLY clickable when the Edit Icon was pressed
                              onChanged: isStaffDeleteMode ? (value) {
                                setState(() {
                                  _newRoleSelected = value;
                                });
                              } : null, 
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue), borderRadius: BorderRadius.circular(8)),
                          child: TextField(
                            controller: _newSalaryController, // 👈 Grabs the typed salary
                            enabled: isStaffDeleteMode, // 👈 Only typable in Edit Mode
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: InputBorder.none, 
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)
                            ),
                          ),
                        ),
                      ),
                      if (isStaffDeleteMode) const SizedBox(width: 48), 
                    ],
                  ),
                );
              }
              }

              // Existing Roles Row
              final role = staffRoles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 45,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue), borderRadius: BorderRadius.circular(8)),
                        // 👇 SHOWS DROPDOWN IN EDIT MODE, NORMAL TEXT OTHERWISE 👇
                        child: isStaffDeleteMode 
                            ? DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  hint: Text(role['role'], style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue),
                                  items: ['Site Engineer', 'Supervisor', 'Project Manager', 'Safety Officer']
                                      .map((String val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 13))))
                                      .toList(),
                                  onChanged: (newVal) {
                                    setState(() => role['role'] = newVal!);
                                  },
                                ),
                              )
                            : Text(role['role'], style: const TextStyle(color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue), borderRadius: BorderRadius.circular(8)),
                        child: Text(role['salary'], style: const TextStyle(color: Colors.black87)),
                      ),
                    ),
                    if (isStaffDeleteMode)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: role['selected'],
                            activeColor: AppColors.primaryBlue,
                            side: const BorderSide(color: Colors.grey),
                            onChanged: (val) {
                              setState(() => role['selected'] = val);
                            },
                          ),
                        ),
                      )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1, 
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
          Navigator.pop(context); 
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: "Project"),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Report"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}