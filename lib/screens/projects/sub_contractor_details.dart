import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';
// ✅ Import the Edit Screen
import 'package:construction_erp/screens/projects/edit_sub_contractor.dart';

class SubContractorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> subContractor;

  const SubContractorDetailsScreen({super.key, required this.subContractor});

  @override
  Widget build(BuildContext context) {
    // Dummy Data for visual purposes
    const double totalContract = 200000;
    const double usedAmount = 120000;
    const double remainingAmount = 80000;
    const double progress = usedAmount / totalContract;

    return Scaffold(
      backgroundColor: const Color(0xFF0D6EFD), // Blue Background for top area
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Sub-contractor",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // White Content Container
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. Header Name & Edit Icon ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subContractor['name'] ?? "Sample Name",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        // ✅ Edit Button (Navigates to Edit Screen)
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditSubContractorScreen(
                                  subContractorData: subContractor,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit,
                                color: Colors.grey, size: 20),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- 2. Sub-contractor Info ---
                    _buildSectionHeader("Sub-contractor Info"),
                    const SizedBox(height: 15),
                    _buildInfoRow(
                        "Name:", subContractor['name'] ?? "Sample Name"),
                    _buildInfoRow(
                        "Work Type:", subContractor['workType'] ?? "Plumbing"),
                    _buildInfoRow("Phone:", "+91 91234 56789"),
                    _buildInfoRow("Email:", "xyz@abccinfrastructure.com"),
                    _buildInfoRow("Assigned Project:",
                        subContractor['project'] ?? "Project Name 1"),
                    _buildInfoRow("Start date:", "12 JAN 2026"),
                    _buildInfoRow("Estimated end date:", "13 Oct 2026"),

                    const SizedBox(height: 25),

                    // --- 3. Budget Card ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("Budget", isInsideCard: true),
                          const SizedBox(height: 15),
                          const Text("Total Contract: ₹2,00,000",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                          const SizedBox(height: 12),

                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              backgroundColor: const Color(0xFFD6E4FF),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF0D6EFD)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Used: ₹1,20,000",
                                  style: TextStyle(fontSize: 12)),
                              Text("Remaining: ₹80,000",
                                  style: TextStyle(fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // --- 4. Workforce Card ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("Workforce", isInsideCard: true),
                          const SizedBox(height: 15),
                          _buildWorkforceRow(
                              "Total Workers:", "6", const Color(0xFF0D6EFD)),
                          const SizedBox(height: 10),
                          _buildWorkforceRow(
                              "Active Today:", "5", const Color(0xFF0D6EFD)),
                          const SizedBox(height: 20),

                          // Mark Attendance Button
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle Attendance
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Attendance Marked!")));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D6EFD),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Mark Attendance",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionHeader(String title, {bool isInsideCard = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey.shade300, thickness: 1),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140, // Fixed width for labels alignment
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkforceRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }
}
