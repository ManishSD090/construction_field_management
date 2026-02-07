import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/controllers/admin/user_controller.dart';
import 'package:construction_erp/models/user.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserInfoScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _aadharController; // New controller for text input

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _aadharController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _syncControllers());
  }

  void _syncControllers() {
    final user = _getSpecificUser();
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone;
      _aadharController.text = user.aadharNumber ?? ''; // Sync Aadhar number
    }
  }

  User? _getSpecificUser() {
    final state = ref.read(userControllerProvider).value;
    return state?.userList.firstWhere((u) => u.id == widget.userId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);

    final user = userState.value?.userList.firstWhere(
      (u) => u.id == widget.userId,
      orElse: () => _getSpecificUser()!,
    );

    if (user == null)
      return const Scaffold(body: Center(child: Text("User not found")));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Manage Users and Roles",
            style: TextStyle(fontSize: 18, color: Colors.white)),
        backgroundColor: const Color(0xFF0A6ED1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(user.role?.name ?? "Manager",
                        style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0A6ED1),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                Text(
                  "User ID: ${user.employeeId ?? user.id.substring(0, 8)}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- User Info Card ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("User Info",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade300,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              setState(() => _isEditing = !_isEditing),
                          icon: Icon(_isEditing ? Icons.close : Icons.edit,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, thickness: 1),
                  if (_isEditing) ...[
                    _buildTextField("Name", _nameController),
                    _buildTextField("Email", _emailController),
                    _buildTextField("Phone", _phoneController),
                    _buildTextField("Aadhar Number",
                        _aadharController), // Aadhar as text field
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A6ED1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          await ref
                              .read(userControllerProvider.notifier)
                              .updateUser(user.id, {
                            'name': _nameController.text,
                            'email': _emailController.text,
                            'phone': _phoneController.text,
                            'aadharNumber':
                                _aadharController.text, // Save as text
                          });
                          setState(() => _isEditing = false);
                        },
                        child: const Text("Save Changes",
                            style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ] else ...[
                    _buildDataRow("Name:", user.name),
                    const SizedBox(height: 16),
                    _buildDataRow("Email:",
                        user.email ?? "rakesh.sharma@abccinfrastructure.com"),
                    const SizedBox(height: 16),
                    _buildDataRow("Phone:", user.phone),
                    const SizedBox(height: 16),

                    _buildDataRow("Assigned Projects",
                        user.stats?.projects.toString() ?? "0"),

                    const SizedBox(height: 20),

                    // --- Aadhar Card Section (Display Mode) ---
                    Row(
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text("Aadhar card:",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 14)),
                        ),
                        // Displaying the text value instead of a file upload UI
                        Text(user.aadharNumber ?? "Not Provided",
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 14)),
        ),
        Expanded(
          child: Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
