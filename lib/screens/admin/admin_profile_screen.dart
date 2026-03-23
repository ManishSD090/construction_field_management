import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/routes.dart';
import 'package:construction_erp/screens/admin/approvals_screen.dart';
import 'package:construction_erp/screens/sub_contractor/sub_contractor_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
    String formatDate(DateTime? date) =>
        date != null ? DateFormat('dd MMM yyyy').format(date) : "N/A";

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header Section ---
                _buildHeader(user),
                const SizedBox(height: 24),

                // --- Account Info Card ---
                _buildAccountInfoCard(user, formatDate),
                const SizedBox(height: 24),

                // --- Account Settings List ---
                _buildSettingsList(context, user),
                const SizedBox(height: 24),


                // --- Log Out Button ---
                Center(
                  child: TextButton(
                    onPressed: () => _handleLogout(context, ref),
                    child: const Text(
                      "Log Out",
                      style: TextStyle(
                        color: Color(0xFFFF3B30),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- UI Components ---

  Widget _buildHeader(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(user.company?.name ?? "ABC Infrastructure Pvt Ltd",
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
              Text(
                user.role?.name ?? "Site Engineer",
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Text(
          "User ID: ${user.employeeId ?? 'SYS-ADM-001'}",
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard(User user, Function formatDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Account Info",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          _buildInfoRow("User type:", user.userType.toDisplayString()),
          const SizedBox(height: 12),
          _buildInfoRow("Account created:", formatDate(user.createdAt)),
          const SizedBox(height: 12),
          _buildInfoRow(
              "Last Login:",
              user.lastLogin != null
                  ? DateFormat('dd MMM yyyy · hh:mm a')
                      .format(user.lastLogin!.toLocal())
                  : "14 Aug 2025 · 09:12 AM"),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, User user) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text("Account Settings",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: "Personal Info",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PersonalInfoScreen())),
          ),
          _buildSettingsTile(
            icon: Icons.business_outlined,
            title: "Company Details",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CompanyDetailsScreen(
                        company: user.company ?? Company(name: "N/A")))),
          ),
          _buildSettingsTile(
            icon: Icons.group_outlined,
            title: "Manage Users and Roles",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManageUsersMenuScreen())),
          ),
          _buildSettingsTile(
            icon: Icons.history_outlined,
            title: "Approval History",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ApprovalsScreen())),
          ),
          _buildSettingsTile(
            icon: Icons.engineering_outlined,
            title: "Manage Sub-Contractors",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>  const SubcontractorListScreen())),
          ),
        ],
      ),
    );
  }


  // --- Helpers ---

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4))
      ],
    );
  }

  Widget _buildSettingsTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(title,
          style: const TextStyle(fontSize: 14, color: Colors.black87)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text("$label ",
            style: const TextStyle(color: Color(0xFF666666), fontSize: 14)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
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
}
