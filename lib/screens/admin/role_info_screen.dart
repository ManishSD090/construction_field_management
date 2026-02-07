import 'package:flutter/material.dart';

class RoleInfoScreen extends StatefulWidget {
  final Map<String, dynamic> roleData;

  const RoleInfoScreen({super.key, required this.roleData});

  @override
  State<RoleInfoScreen> createState() => _RoleInfoScreenState();
}

class _RoleInfoScreenState extends State<RoleInfoScreen> {
  bool _isEditing = false;
  late TextEditingController _roleNameController;
  late TextEditingController _roleDescController;

  // Simulate Permissions Data (In a real app, pass this via constructor)
  // 1 = Checked, 0 = Unchecked
  late List<Map<String, dynamic>> _permissions;

  @override
  void initState() {
    super.initState();
    _roleNameController = TextEditingController(text: widget.roleData['name']);
    _roleDescController = TextEditingController(text: "Description for ${widget.roleData['name']}"); // Dummy desc

    // Initialize with dummy permission state matching the "Create Role" structure
    _permissions = [
      {'module': 'User Management', 'view': true, 'edit': false},
      {'module': 'Role Management', 'view': true, 'edit': true},
      {'module': 'Project Management', 'view': true, 'edit': false},
      {'module': 'Inventory', 'view': false, 'edit': false},
      {'module': 'Reports', 'view': true, 'edit': false},
    ];
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    _roleDescController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    setState(() {
      _isEditing = false;
      // Add API update logic here
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Role updated successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Primary Blue Color from your theme
    const primaryBlue = Color(0xFF0A6ED1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Role" : "Role Info"),
        backgroundColor: primaryBlue,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEdit,
              tooltip: "Edit Role",
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Role Header Card ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Role Name"),
                  const SizedBox(height: 8),
                  _isEditing
                      ? TextField(
                          controller: _roleNameController,
                          decoration: _inputDecoration("Enter role name"),
                        )
                      : Text(
                          _roleNameController.text,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                  const SizedBox(height: 20),
                  _buildLabel("Description"),
                  const SizedBox(height: 8),
                  _isEditing
                      ? TextField(
                          controller: _roleDescController,
                          decoration: _inputDecoration("Enter description"),
                          maxLines: 2,
                        )
                      : Text(
                          _roleDescController.text,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Permissions Table Section ---
            const Text(
              "Access Permissions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: const [
                        Expanded(flex: 3, child: Text("Module Name", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Center(child: Text("View", style: TextStyle(fontWeight: FontWeight.bold)))),
                        Expanded(flex: 1, child: Center(child: Text("Edit", style: TextStyle(fontWeight: FontWeight.bold)))),
                      ],
                    ),
                  ),
                  // Table Rows
                  ..._permissions.asMap().entries.map((entry) {
                    int idx = entry.key;
                    Map<String, dynamic> perm = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(perm['module'], style: const TextStyle(fontWeight: FontWeight.w500)),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: _buildCheckbox(
                                value: perm['view'],
                                onChanged: (val) {
                                  if (_isEditing) {
                                    setState(() => _permissions[idx]['view'] = val);
                                  }
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: _buildCheckbox(
                                value: perm['edit'],
                                onChanged: (val) {
                                  if (_isEditing) {
                                    setState(() => _permissions[idx]['edit'] = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Save / Cancel Buttons (Edit Mode Only) ---
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleEdit,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
    );
  }

  Widget _buildCheckbox({required bool value, required Function(bool?) onChanged}) {
    return SizedBox(
      height: 24,
      width: 24,
      child: Checkbox(
        value: value,
        onChanged: _isEditing ? onChanged : null, // Disable interactions in View Mode
        activeColor: const Color(0xFF0A6ED1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        // Visual styling for disabled state to make it look "read-only" but clear
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return value ? const Color(0xFF0A6ED1).withOpacity(0.6) : Colors.grey.shade200;
          }
          return const Color(0xFF0A6ED1);
        }),
      ),
    );
  }
}