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
    // Determine colors based on status
    final bool isActive = company.isActive!; // Removed default true to be safe
    const Color statusColor = Colors.white;
    final Color statusBg = isActive
        ? const Color(0xFF00A991) // Green
        : const Color(0xFFFF3B30); // Red
    final String statusText = isActive ? "Active" : "Suspended";

    // Safe access to Admin Name
    // final String adminName = company.admin?.fullname ?? company.email;
    final String adminName = company.admins?.first.name ?? "N/A";

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- LEFT SIDE: Company Info (Expanded) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Company Name
                  Text(
                    company.name ?? "Dummy Name",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // 2. Created Date
                  Text(
                    "Created On: ${_formatDate(company.createdAt ?? DateTime.now())}",
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 3. Admin Details (Wrapped safely)
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

            const SizedBox(width: 12), // Spacing between columns

            // --- RIGHT SIDE: Status & Action ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Status Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),

                // Spacing to push "View Company" down (adjust as needed)
                const SizedBox(height: 30),

                // 2. View Company Link
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

  // Helper to format date cleanly
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
