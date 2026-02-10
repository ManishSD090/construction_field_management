import 'package:flutter/material.dart';
import '../../core/services/app_colors.dart';
import '../../models/company.dart';

class CompanyTile extends StatelessWidget {
  final Company company;
  final VoidCallback onTap;

  const CompanyTile({
    super.key,
    required this.company,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Safe Status Handling
    final bool isActive = company.isActive ?? true;
    final Color statusBg =
        isActive ? const Color(0xFF00A991) : const Color(0xFFFF3B30);
    final String statusText = isActive ? "Active" : "Suspended";

    // 2. FIXED: Safe access to Admin Name
    // Using 'firstOrNull' (if using Dart 3) or checking isEmpty
    final String adminName =
        (company.admins != null && company.admins!.isNotEmpty)
            ? company.admins!.first.name ?? "Unnamed Admin"
            : "No Admin Assigned";

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Ensures the whole area is tappable
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- LEFT SIDE: Company Info ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name ?? "Unnamed Company",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Created On: ${_formatDate(company.createdAt ?? DateTime.now())}",
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGrey),
                      children: [
                        const TextSpan(text: "Admin: "),
                        TextSpan(
                          text: adminName,
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // --- RIGHT SIDE: Status & Action ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusPill(statusText, statusBg),
                const SizedBox(height: 32), // Adjusted spacing
                const Text(
                  "View company",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Extracted UI Components for cleaner build method
  Widget _buildStatusPill(String text, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
