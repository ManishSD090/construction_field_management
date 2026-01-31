import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_colors.dart'; // Ensure this path is correct
// import 'package:construction_erp/controllers/auth/auth_controller.dart'; // Uncomment when ready

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock Data (Replace with Riverpod data later)
    final String displayName = "Person Name";
    final String displayRole = "Site Engineer";
    final bool showNotification = true;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------------
          // 1. HEADER (Reusing the style from Super Admin)
          // ---------------------------------------------------------
          AppBar(
            backgroundColor: AppColors.primaryBlue,
            elevation: 0,
            toolbarHeight: 92,
            automaticallyImplyLeading: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "WELCOME BACK,",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  displayRole,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
            actions: [
              if (showNotification)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
            ],
          ),

          // ---------------------------------------------------------
          // 2. BODY CONTENT
          // ---------------------------------------------------------
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Quick Actions ---
                  const Text(
                    "Quick actions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Grid Layout
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5, // Widescreen card ratio
                    children: [
                      _buildActionCard(
                        label: "Attendance",
                        subLabel: "45/50",
                        icon: Icons.people_alt,
                        color: Colors.blue,
                        onTap: () {},
                      ),
                      _buildActionCard(
                        label: "Tasks",
                        subLabel: "12/18 done",
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                        onTap: () {},
                      ),
                      _buildActionCard(
                        label: "DPR",
                        subLabel: "20 submitted",
                        icon: Icons.assignment_outlined,
                        color: Colors.orange,
                        onTap: () {},
                      ),
                      _buildActionCard(
                        label: "Projects",
                        subLabel: "3 active",
                        icon: Icons.apartment_rounded,
                        color: Colors.purple,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Recent Activity ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent activity",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("View all", style: TextStyle(color: AppColors.primaryBlue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Activity List
                  _buildActivityItem(
                    title: "Task completed",
                    subtitle: "Foundation work - Block A",
                    time: "2h ago",
                    icon: Icons.check_box_rounded,
                    color: Colors.blue,
                  ),
                  _buildActivityItem(
                    title: "DPR submitted",
                    subtitle: "Daily progress report",
                    time: "5h ago",
                    icon: Icons.description_rounded,
                    color: Colors.orange,
                  ),
                  _buildActivityItem(
                    title: "Check in recorded",
                    subtitle: "Arrived at site",
                    time: "7h ago",
                    icon: Icons.timer_outlined,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget: Action Card (Quick Actions) ---
  Widget _buildActionCard({
    required String label,
    required String subLabel,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subLabel,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Activity Item ---
  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}