import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Added Riverpod
import 'package:construction_erp/controllers/subcontractor/subcontractor_controller.dart'; // ✅ Import your controller
import 'package:construction_erp/screens/sub_contractor/edit_sub_contractor.dart';
import 'package:intl/intl.dart'; // ✅ For date formatting

class SubContractorDetailsScreen extends ConsumerWidget {
  // ✅ Changed to ConsumerWidget
  final String contractorProjectId;

  const SubContractorDetailsScreen(
      {super.key, required this.contractorProjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Watch the specific project details using the family provider
    final detailsAsync =
        ref.watch(contractorProjectDetailsProvider(contractorProjectId));

    return Scaffold(
      backgroundColor: const Color(0xFF0D6EFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Sub-contractor Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: detailsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(
            child: Text("Error: $err",
                style: const TextStyle(color: Colors.white))),
        data: (data) {
          // ✅ Map backend data to variables
          final summary = data['summary'];
          final financial = summary['financial'];
          final workers = summary['assignments'];
          final contractor = data['contractor'];

          final double totalContract =
              (financial['totalContractAmount'] as num).toDouble();
          final double remainingAmount =
              (financial['balanceAmount'] as num).toDouble();
          // final double usedAmount = (financial['totalPaid'] as num).toDouble();
          final double usedAmount = totalContract - remainingAmount;
          final double progress =
              totalContract > 0 ? usedAmount / totalContract : 0.0;

          // Date Formatting
          String formatDate(String? dateStr) {
            if (dateStr == null) return "N/A";
            final date = DateTime.tryParse(dateStr);
            return date != null
                ? DateFormat('dd MMM yyyy').format(date)
                : "N/A";
          }

          return Column(
            children: [
              const SizedBox(height: 10),
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
                              contractor['name'] ?? "Sample Name",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) =>
                                //         EditSubContractorScreen(
                                //       subContractorData: data, // Pass full data
                                //     ),
                                //   ),
                                // );
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
                        _buildInfoRow("Name:", contractor['name'] ?? "N/A"),
                        _buildInfoRow("Work Type:", data['workType'] ?? "N/A"),
                        _buildInfoRow("Phone:", contractor['phone'] ?? "N/A"),
                        _buildInfoRow("Email:", contractor['email'] ?? "N/A"),
                        _buildInfoRow("Assigned Project:",
                            data['project']['name'] ?? "N/A"),
                        _buildInfoRow(
                            "Start date:", formatDate(data['startDate'])),
                        _buildInfoRow(
                            "Estimated end date:", formatDate(data['endDate'])),

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
                              Text(
                                  "Total Contract: ₹${NumberFormat('#,##,###').format(totalContract)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87)),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 12,
                                  backgroundColor: const Color(0xFFD6E4FF),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF0D6EFD)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "Used: ₹${NumberFormat('#,##,###').format(usedAmount)}",
                                      style: const TextStyle(fontSize: 12)),
                                  Text(
                                      "Remaining: ₹${NumberFormat('#,##,###').format(remainingAmount)}",
                                      style: const TextStyle(fontSize: 12)),
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
                              _buildSectionHeader("Workforce",
                                  isInsideCard: true),
                              const SizedBox(height: 15),
                              _buildWorkforceRow(
                                  "Total Workers:",
                                  "${workers['total']}",
                                  const Color(0xFF0D6EFD)),
                              const SizedBox(height: 10),
                              _buildWorkforceRow(
                                  "Active Today:",
                                  "${workers['active']}",
                                  const Color(0xFF0D6EFD)),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text("Attendance Marked!")));
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
          );
        },
      ),
    );
  }

  // --- HELPER WIDGETS (Keep exactly as your previous UI) ---
  Widget _buildSectionHeader(String title, {bool isInsideCard = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
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
              width: 140,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildWorkforceRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
        const SizedBox(width: 5),
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}
