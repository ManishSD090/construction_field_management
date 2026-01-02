import 'package:flutter/material.dart';
import '../../utilities/app_colors.dart'; // Adjust path as needed

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
        const Text(
          "System alerts ⚠️",
          style: TextStyle(
            color: AppColors.alertRed, // Ensure this is defined in AppColors
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.alertRed.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFFFEBEE), // Light red background
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...alerts.map((alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      "• $alert",
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                  )),
              const SizedBox(height: 8),
              InkWell(
                onTap: onViewAll,
                child: const Text(
                  "View all",
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
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