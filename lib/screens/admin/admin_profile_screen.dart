import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/routes.dart';
import 'package:construction_erp/screens/admin/approvals_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Add intl for date formatting
import 'package:construction_erp/core/services/app_colors.dart';

// Controllers & Models
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/company.dart';

// Screens
import 'manage_users_menu.dart';
import 'personal_info_screen.dart';
import 'company_details_screen.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the Auth State
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            "Profile",
            style:
                TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),
      // 2. Handle Loading/Error/Data states
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("No session found"));
          }
          return _buildProfileBody(context, ref, user);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildProfileBody(BuildContext context, WidgetRef ref, User user) {
    // Helper for formatting dates
    String formatDate(DateTime? date) =>
        date != null ? DateFormat('dd MMM yyyy').format(date) : "N/A";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Header Section ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name, // Integrated
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.company?.name ?? "No Company Assigned", // Integrated
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.role?.name ??
                        user.userType.name.toUpperCase(), // Integrated
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0A6ED1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                "ID: ${user.employeeId == null ? user.id.substring(0, 8) : user.employeeId ?? 'N/A'}", // Integrated
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- 2. Account Info Card ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                const Text(
                  "Account Info",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 24, thickness: 1),
                _buildInfoRow("User type:", user.userType.toDisplayString()),
                const SizedBox(height: 12),
                _buildInfoRow("Account created:", formatDate(user.createdAt)),
                const SizedBox(height: 12),
                _buildInfoRow(
                    "Last Login:",
                    user.lastLogin != null
                        ? DateFormat('dd MMM yyyy · hh:mm a')
                            .format(user.lastLogin!)
                        : "First Session"),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- 3. Account Settings List ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    "Account Settings",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                _buildSettingsTile(
                  title: "Personal Info",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PersonalInfoScreen()),
                    );
                  },
                ),
                _buildSettingsTile(
                  title: "Company Details",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompanyDetailsScreen(
                          company: user.company ?? Company(name: "N/A"),
                        ),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  title: "Manage Users and Roles",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageUsersMenuScreen()),
                    );
                  },
                ),
                _buildSettingsTile(
                  title: "Manage Approvals",
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ApprovalsScreen()));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // --- 4. Log Out Button ---
          Center(
            child: SizedBox(
              width: 150,
              height: 45,
              child: ElevatedButton(
                onPressed: () => _handleLogout(context, ref), // Integrated
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Logout Logic with Confirmation
  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authControllerProvider.notifier).logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (ctx) => false);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        children: [
          TextSpan(
            text: "$label ",
            style: const TextStyle(color: Color(0xFF666666)),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
      {required String title, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }
}
