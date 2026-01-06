import 'package:flutter/material.dart';
import '../../utilities/app_colors.dart';
import '../../models/company.dart';

class CompanyDetailsScreen extends StatefulWidget {
  final Company company;
  const CompanyDetailsScreen({super.key, required this.company});

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  // --- 1. The Suspend Warning Bottom Sheet ---
  void _showSuspendSheet() {
    bool isChecked = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text("Suspend Company? ⚠️",
                    style: TextStyle(
                        color: AppColors.alertRed,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Warning Text
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: Colors.black87, fontSize: 15, height: 1.5),
                    children: [
                      const TextSpan(text: "Are you sure you want to suspend "),
                      TextSpan(
                          text: "${widget.company.name}?",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Consequences List
                const Text("Suspending this company will:",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text(
                  "• Immediately block all users from logging in\n• Pause all ongoing projects\n• Restrict access to data",
                  style: TextStyle(
                      color: AppColors.textGrey, height: 1.5, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Checkbox
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                          value: isChecked,
                          activeColor: AppColors.alertRed,
                          onChanged: (val) =>
                              setSheetState(() => isChecked = val!)),
                    ),
                    const SizedBox(width: 10),
                    const Text("I understand the impact of this action",
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isChecked ? AppColors.alertRed : Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    onPressed: isChecked
                        ? () {
                            Navigator.pop(context); // Close sheet
                            _showSuccessDialog(); // Show success popup
                          }
                        : null,
                    child: const Text("Suspend company",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Text("Cancel",
                        style: TextStyle(
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w600)),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  // --- 2. The Success Dialog ---
  void _showSuccessDialog() {
    showDialog(
        context: context,
        builder: (c) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.successGreen, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      "${widget.company.name} has been\nsuccessfully suspended!",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Users will no longer be able to access the system.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(c); // Close dialog
                          Navigator.pop(context); // Go back to list
                        },
                        child: const Text("OK",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primaryBlue)),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    // Formatting Helpers
    final bool isActive = widget.company.isActive;
    final Color statusColor =
        isActive ? AppColors.successGreen : AppColors.alertRed;
    final Color statusBg =
        isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    String formattedDate =
        "${widget.company.createdAt.day} ${_getMonth(widget.company.createdAt.month)} ${widget.company.createdAt.year}";

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Section ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(widget.company.name,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.2)),
                      ),
                      const SizedBox(width: 8),
                      // Edit Icon (Visual only)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.edit,
                            size: 16, color: Colors.grey),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location & Status
                  Row(
                    children: [
                      Text("Mumbai | ID-2341 ",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(isActive ? "Active" : "Suspended",
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Created on: $formattedDate",
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 12)),

                  const SizedBox(height: 24),

                  // --- Stats Section (Row of Cards) ---
                  Row(
                    children: [
                      // Card 1: Projects (with Donut)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Mini Donut
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator(
                                    value: 0.7,
                                    color: AppColors.primaryBlue,
                                    backgroundColor: Colors.grey.shade100,
                                    strokeWidth: 5),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Total Projects: 11",
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                  Text("Active Projects: 7",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.successGreen)),
                                  Text("Inactive Projects: 4",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.alertRed)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Card 2: Users
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: const [
                            Text("48",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Total users",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- Company Details List ---
                  const Text("Company details",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),

                  _buildDetailRow(
                      "Registration Number", "U45201MH2016PTC287654"),
                  _buildDetailRow("GST Number", "27AABCA1234F1Z9"),
                  _buildDetailRow("Email", "info@abc.com", isLink: true),
                  _buildDetailRow("Website", "www.abc.com", isLink: true),
                  _buildDetailRow("Phone", "+91 98765 43210"),

                  const SizedBox(height: 24),

                  // --- Location Section ---
                  const Text("Company Location",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  const Text(
                    "3rd Floor, Shree Ganesh Plaza,\nNear Andheri Metro Station,\nAndheri East, Mumbai - 400069",
                    style: TextStyle(
                        color: Colors.black87, height: 1.5, fontSize: 13),
                  ),

                  const SizedBox(height: 24),

                  // --- Admin Details ---
                  const Text("Admin details",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  _buildDetailRow("Name", "Rakesh Sharma"),
                  _buildDetailRow("Role", "Company Admin"),
                  _buildDetailRow("Phone", "+91 91234 56789"),
                  _buildDetailRow(
                      "Email", widget.company.email ?? "admin@abc.com"),

                  const SizedBox(height: 40), // Spacing for scroll
                ],
              ),
            ),
          ),

          // --- Suspend Button (Footer) ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.alertRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                onPressed: _showSuspendSheet,
                child: const Text("Suspend company",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- Helper: Detail Row ---
  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
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
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }
}
