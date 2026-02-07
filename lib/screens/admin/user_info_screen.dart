import 'package:flutter/material.dart';

class UserInfoScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String role;
  final String userId;
  final String aadharNumber;

  const UserInfoScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.userId,
    required this.aadharNumber,
  });

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _roleController;
  late TextEditingController _aadharController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _roleController = TextEditingController(text: widget.role);
    _aadharController = TextEditingController(text: widget.aadharNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("User Info"),
        backgroundColor: const Color(0xFF0A6ED1),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔹 Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "User Account",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      _roleController.text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0A6ED1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  "User ID: ${widget.userId}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// 🔹 User Info Card
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

                  /// Card Header + Edit Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "User Details",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                        icon: Icon(
                          _isEditing ? Icons.close : Icons.edit,
                          color: _isEditing ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24, thickness: 1),

                  /// 🔹 Edit Mode
                  if (_isEditing) ...[
                    _buildTextField("Name", _nameController),
                    _buildTextField("Email", _emailController),
                    _buildTextField("Phone", _phoneController),
                    _buildTextField("Role", _roleController),
                    _buildTextField("Aadhar Number", _aadharController),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A6ED1),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            // TODO: save/update API call here
                          });
                        },
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )

                  /// 🔹 View Mode
                  ] else ...[
                    _buildDataRow("Name:", _nameController.text),
                    const SizedBox(height: 16),
                    _buildDataRow("Email:", _emailController.text),
                    const SizedBox(height: 16),
                    _buildDataRow("Phone:", _phoneController.text),
                    const SizedBox(height: 16),
                    _buildDataRow("Role:", _roleController.text),
                    const SizedBox(height: 16),
                    _buildDataRow("Aadhar No:", _aadharController.text),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Editable Field
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  /// 🔹 Display Row
  Widget _buildDataRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        children: [
          TextSpan(
              text: "$label ",
              style: const TextStyle(color: Color(0xFF666666))),
          TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
