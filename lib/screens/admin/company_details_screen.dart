import 'package:flutter/material.dart';
import '../../core/services/app_colors.dart';
import '../../models/user.dart';
import '../../models/company.dart';

class CompanyDetailsScreen extends StatelessWidget {
  final Company company;
  const CompanyDetailsScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final List<User>? admins = company.admins;
    final bool isActive = company.isActive ?? true;

    final int projectCount = company.counts?.projects ?? 0;
    final int userCount = company.counts?.users ?? 0;
    final int clientCount = company.counts?.clients ?? 0;

    final Color statusColor = isActive ? AppColors.tagGreen : AppColors.tagRed;
    final DateTime createdDate = company.createdAt ?? DateTime.now();
    final String formattedDate =
        "${createdDate.day} ${_getMonth(createdDate.month)} ${createdDate.year}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Company details",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header with Edit Button ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(company.name ?? "N/A",
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.2)),
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(Icons.edit, () {
                        // Action for Edit
                      }),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text("ID - ${company.id?.substring(0, 8) ?? '...'}",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 16),

                  // --- Date and Status Tag Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Created on: $formattedDate",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          isActive ? "Active" : "Suspended",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Stats Section ---
                  Row(
                    children: [
                      Expanded(child: _buildStatCard("Total clients", clientCount.toString())),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard("Total Projects", projectCount.toString())),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard("Total Users", userCount.toString())),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- Company Details Section ---
                  const Text("Company details", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),

                  _buildDetailRow("Registration Number", company.registrationNumber ?? "N/A"),
                  _buildDetailRow("GST Number", company.gstNumber ?? "N/A"),
                  _buildDetailRow("Email", company.email ?? "N/A", isLink: true),
                  _buildDetailRow("Phone", company.phone ?? "N/A"),
                  _buildDetailRow("Address", company.officeAddress ?? "N/A"),

                  const SizedBox(height: 24),

                  // --- Admin Details Section ---
                  const Text("Admin details", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  if (admins != null && admins.isNotEmpty) ...[
                    ...admins.map((admin) => _buildAdminBlock(admin, admins.length > 1)),
                  ] else ...[
                    const Text("No Admin Assigned", style: TextStyle(color: Colors.red)),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // --- Fixed Bottom Action Button ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? AppColors.alertRed : AppColors.successGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                onPressed: () {
                  // Action for Status Toggle
                },
                child: Text(
                  isActive ? "Suspend company" : "Activate company",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildAdminBlock(User admin, bool showLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text("Admin Account",
                style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        _buildDetailRow("Name", admin.name),
        _buildDetailRow("Email", admin.email ?? "N/A"),
        _buildDetailRow("Phone", admin.phone),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: isLink ? AppColors.primaryBlue : Colors.black87)),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }
}