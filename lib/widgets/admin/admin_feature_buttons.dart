import 'package:flutter/material.dart';

// Replicating the Private Card style for consistency
class _AdminFeatureCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminFeatureCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 75, // Slightly larger for Admin emphasis
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(icon, size: 32, color: const Color(0xFF0A6ED1)), // Primary Blue
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ManagerTileButton extends StatelessWidget {
  final VoidCallback onTap;
  const ManagerTileButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return _AdminFeatureCard(
        label: "Managers",
        icon: Icons.supervisor_account_rounded,
        onTap: onTap);
  }
}

class SubContractorTileButton extends StatelessWidget {
  final VoidCallback onTap;
  const SubContractorTileButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return _AdminFeatureCard(
        label: "Sub-Contractors",
        icon: Icons.engineering_rounded,
        onTap: onTap);
  }
}

class CustomRoleTileButton extends StatelessWidget {
  final VoidCallback onTap;
  const CustomRoleTileButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return _AdminFeatureCard(
        label: "Custom Roles",
        icon: Icons.admin_panel_settings_rounded,
        onTap: onTap);
  }
}

class ApprovalHistoryButton extends StatelessWidget {
  final VoidCallback onTap;
  const ApprovalHistoryButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return _AdminFeatureCard(
        label: "Approvals",
        icon: Icons.history_edu_rounded,
        onTap: onTap);
  }
}