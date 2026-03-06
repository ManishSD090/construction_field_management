import 'package:flutter/material.dart';
import '../../core/services/app_colors.dart';

class SystemAlertCard extends StatelessWidget {
  final List<String> alerts;
  final VoidCallback onViewAll;

  const SystemAlertCard({
    super.key,
    required this.alerts,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. Header with Warning Icon ---
        const Row(
          children: [
            Text(
              "System alerts",
              style: TextStyle(
                color: AppColors.alertRed, // Red color for title
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.warning_amber_rounded,
                color: AppColors.alertRed, size: 20),
          ],
        ),
        const SizedBox(height: 10),

        // --- 2. The Alert Content Card ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: Colors.grey.shade200), // Subtle grey border
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
              // Map the list of alert strings to Text widgets
              ...alerts.map((alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      alert,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  )),

              // "View all" Link
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: onViewAll,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "View all",
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
