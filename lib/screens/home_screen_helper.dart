import 'package:flutter/material.dart';
// Note: We are using relative imports for your widget folder structure
import '../widgets/common/home_screen_widgets/nav_bar_item.dart';
import '../core/services/app_colors.dart';

class HomeScreenHelper {
  // 1. Super Admin Bottom Bar
  static Widget buildSuperAdminBottomBar({
    required int currentIndex,
    required Function(int) onIndexChanged,
  }) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NavBarItem(
            label: "Dashboard",
            icon: Icons.grid_view_rounded,
            isSelected: currentIndex == 0,
            onTap: () => onIndexChanged(0),
          ),
          NavBarItem(
            label: "Companies",
            icon: Icons.apartment_rounded,
            isSelected: currentIndex == 1,
            onTap: () => onIndexChanged(1),
          ),
          NavBarItem(
            label: "Profile",
            icon: Icons.person_outline_rounded,
            isSelected: currentIndex == 2,
            onTap: () => onIndexChanged(2),
          ),
        ],
      ),
    );
  }

  // 2. Project Manager / Engineer Bottom Bar
  static Widget buildProjectBottomBar({
    required int currentIndex,
    required Function(int) onIndexChanged,
  }) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NavBarItem(
            label: "Dashboard",
            icon: Icons.grid_view_rounded,
            isSelected: currentIndex == 0,
            onTap: () => onIndexChanged(0),
          ),
          NavBarItem(
            label: "Project",
            icon: Icons.inventory_2_outlined,
            isSelected: currentIndex == 1,
            onTap: () => onIndexChanged(1),
          ),
          NavBarItem(
            label: "Task",
            icon: Icons.assignment_turned_in_outlined,
            isSelected: currentIndex == 2,
            onTap: () => onIndexChanged(2),
          ),
          NavBarItem(
            label: "Operation",
            icon: Icons.article_outlined,
            isSelected: currentIndex == 3,
            onTap: () => onIndexChanged(3),
          ),
          NavBarItem(
            label: "Profile",
            icon: Icons.person_outline_rounded,
            isSelected: currentIndex == 4,
            onTap: () => onIndexChanged(4),
          ),
        ],
      ),
    );
  }

  static PreferredSizeWidget buildAppBar({
    required String name,
    required String role,
    bool showNotification = true,
  }) {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
      toolbarHeight: 92,
      automaticallyImplyLeading: false, // removes back arrow

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
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            role,
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
              icon: const Icon(Icons.notifications_none_rounded,
                  color: Colors.white),
              onPressed: () {},
            ),
          ),
      ],
    );
  }
}
