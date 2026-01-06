import 'package:flutter/material.dart';
import '../../utilities/app_colors.dart';
import '../../models/company.dart'; // Ensure this matches your model file path

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
    // Determine colors based on status (Active vs Suspended)
    final bool isActive = company.isActive;
    final Color statusColor =
        isActive ? AppColors.successGreen : AppColors.alertRed;
    final Color statusBg = isActive
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFEBEE); // Light Green vs Light Red
    final String statusText = isActive ? "Active" : "Suspended";

    return GestureDetector(
      onTap: onTap,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Row 1: Name and Status Pill ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    company.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --- Row 2: Date Created ---
            Text(
              "Created On: ${_formatDate(company.createdAt)}",
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 6),

            // --- Row 3: Admin Details (Blue Link style) ---
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                children: [
                  const TextSpan(text: "Company Admin: "),
                  TextSpan(
                    text: company.email ??
                        "N/A", // Or use company.adminName if available
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Optional: "View company" text at bottom right if needed matches design perfectly
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "View company →",
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper to format date cleanly (e.g., "12 Aug 2025")
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
