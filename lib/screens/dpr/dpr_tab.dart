import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/screens/dpr/create_dpr_screen.dart';

class ProjectDPRTab extends StatelessWidget {
  const ProjectDPRTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data matching your screenshot
    final List<Map<String, dynamic>> dprList = [
      {
        "date": "25 Sep 2025",
        "preparedBy": "Ajay Singh",
        "status": "Approved",
        "color": const Color(0xFF4CAF50) // Green
      },
      {
        "date": "26 Sep 2025",
        "preparedBy": "Ajay Singh",
        "status": "Submitted",
        "color": const Color(0xFF1976D2) // Blue
      },
      {
        "date": "27 Sep 2025",
        "preparedBy": "Ajay Singh",
        "status": "Submitted",
        "color": const Color(0xFF1976D2) // Blue
      },
    ];

    return Column(
      children: [
        // --- Header Row (Title, Icons, Filter) ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              const Text(
                "DPR list",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              // Edit Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.grey, size: 20),
              ),
              const SizedBox(width: 8),
              // Delete Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.alertRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete,
                    color: AppColors.alertRed, size: 20),
              ),
              const SizedBox(width: 12),
              // Filter Button
              OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon:
                    const Icon(Icons.tune, size: 16, color: AppColors.textDark),
                label: const Text(
                  "Filter",
                  style: TextStyle(color: AppColors.textDark, fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // --- DPR List ---
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dprList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = dprList[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['date'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          children: [
                            const TextSpan(text: "Prepared by: "),
                            TextSpan(
                              text: item['preparedBy'],
                              style:
                                  const TextStyle(color: AppColors.primaryBlue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: item['color'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item['status'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}