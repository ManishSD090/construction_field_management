import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/controllers/admin/user_controller.dart';

import '../../models/user.dart';
import 'package:construction_erp/routes.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  bool _isEditing = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();

    // Initial population
    WidgetsBinding.instance.addPostFrameCallback((_) => _populateControllers());
  }

  /// Automatically updates controllers if the state changes elsewhere
  void _populateControllers() {
    final user = ref.read(userControllerProvider).value?.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone;
      _addressController.text = user.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(User user) async {
    final updates = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
    };

    await ref
        .read(userControllerProvider.notifier)
        .updateUser(user.id, updates);

    setState(() {
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);

    // Listen to changes in the user object to keep controllers in sync
    ref.listen(userControllerProvider, (prev, next) {
      if (next.value?.currentUser != prev?.value?.currentUser) {
        _populateControllers();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Personal Info"),
        backgroundColor: const Color(0xFF0A6ED1),
        elevation: 0,
      ),
      body: userState.when(
        data: (state) {
          final user = state.currentUser;
          if (user == null) return const Center(child: Text("User not found"));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user),
                const SizedBox(height: 24),

                // --- Personal Info Card ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Edit Details",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: () {
                              if (_isEditing) {
                                _populateControllers(); // Reset on cancel
                              }
                              setState(() => _isEditing = !_isEditing);
                            },
                            icon: Icon(
                              _isEditing ? Icons.close : Icons.edit,
                              color: _isEditing ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, thickness: 1),
                      if (_isEditing) ...[
                        _buildTextField("Full Name", _nameController),
                        _buildTextField("Email", _emailController),
                        _buildTextField("Phone", _phoneController),
                        _buildTextField("Address", _addressController),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A6ED1),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: () => _saveChanges(user),
                            child: userState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text("Save Changes",
                                    style: TextStyle(color: Colors.white)),
                          ),
                        )
                      ] else ...[
                        _buildDataRow("Name:", user.name),
                        const SizedBox(height: 16),
                        _buildDataRow("Email:", user.email ?? 'N/A'),
                        const SizedBox(height: 16),
                        _buildDataRow("Phone:", user.phone),
                        const SizedBox(height: 16),
                        _buildDataRow("Address:", user.address ?? 'Not set'),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- Change Password Button ---
                Center(
                  child: TextButton.icon(
                    onPressed: () => {
                      Navigator.pushNamed(context, AppRoutes.changePassword)
                    },
                    icon: const Icon(Icons.lock_outline,
                        color: Color(0xFF0A6ED1)),
                    label: const Text(
                      "Change Password",
                      style: TextStyle(
                          color: Color(0xFF0A6ED1),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(user.company?.name ?? 'No Company',
                style: const TextStyle(fontSize: 14)),
            Text(
              user.role?.name ?? 'Employee',
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0A6ED1),
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Text("ID: ${user.employeeId ?? user.id.substring(0, 8)}",
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isObscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        children: [
          TextSpan(
              text: "$label ",
              style: const TextStyle(color: Color(0xFF666666))),
          TextSpan(
              text: value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
