import 'package:flutter/material.dart';
import '../../core/services/app_colors.dart'; // Ensure this import exists

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Light grey background
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF0A6ED1), // Primary Blue
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Header Section (Same as Profile) ---
            //
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Person Name", 
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "ABC Infrastructure Pvt Ltd", 
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Admin", 
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0A6ED1), 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Text(
                  "User ID: SYS-ADM-001",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- 2. Personal Info Card ---
            //
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
                  // Card Header with Edit Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Personal Info",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Edit Button (Visual only for now)
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2), // Light grey circle
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, thickness: 1),
                  
                  // Data Rows
                  _buildDataRow("Name:", "Sample Name"),
                  const SizedBox(height: 16),
                  _buildDataRow("Email:", "rakesh.sharma@abccinfrastructure.com"),
                  const SizedBox(height: 16),
                  _buildDataRow("Password:", "xxxxxxxx"),
                  const SizedBox(height: 16),
                  _buildDataRow("Phone:", "+91 91234 56789"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for "Label: Value" rows
  Widget _buildDataRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        children: [
          TextSpan(
            text: "$label ",
            style: const TextStyle(color: Color(0xFF666666)), // Grey label
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w500), // Bold value
          ),
        ],
      ),
    );
  }
}