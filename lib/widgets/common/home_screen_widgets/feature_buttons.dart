import 'package:flutter/material.dart';

// --- Base Widget for the Card (Private) ---
// We keep this private (_FeatureCard) so only the specific buttons below can be used.
class _FeatureCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
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
            width: 65, // Slightly larger to match screenshots
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18), // Soft rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            // Grey icon color to match your screenshots
            child: Icon(icon, size: 30, color: const Color(0xFF666666)),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Specific Widgets (Based on your Screenshots) ---

class ProfileButton extends StatelessWidget {
  final VoidCallback onTap;
  const ProfileButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Matches the "User" outline icon
    return _FeatureCard(
        label: "Profile", icon: Icons.person_outline_rounded, onTap: onTap);
  }
}

class DashboardButton extends StatelessWidget {
  final VoidCallback onTap;
  const DashboardButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Matches the "Home" shape
    return _FeatureCard(
        label: "Dashboard", icon: Icons.grid_view_rounded, onTap: onTap);
  }
}

class CompaniesButton extends StatelessWidget {
  final VoidCallback onTap;
  const CompaniesButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Matches the "House with Gear" concept
    return _FeatureCard(
        label: "Companies",
        icon: Icons.domain_disabled_outlined, // or Icons.business
        onTap: onTap);
  }
}

class ProjectButton extends StatelessWidget {
  final VoidCallback onTap;
  const ProjectButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Matches the "Box" icon
    return _FeatureCard(
        label: "Project", icon: Icons.inventory_2_outlined, onTap: onTap);
  }
}

class OperationButton extends StatelessWidget {
  final VoidCallback onTap;
  const OperationButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Matches the "Notepad with Pen" icon
    return _FeatureCard(
        label: "Operation", icon: Icons.edit_note_rounded, onTap: onTap);
  }
}

class TaskButton extends StatelessWidget {
  final VoidCallback onTap;
  const TaskButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Matches the "Document with Check" icon
    return _FeatureCard(
        label: "Task", icon: Icons.assignment_turned_in_outlined, onTap: onTap);
  }
}
