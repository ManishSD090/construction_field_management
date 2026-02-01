import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/routes.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  // Show the confirmation dialog before logging out
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Are you sure you want to log out of your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      _performLogout(); // Perform actual logout
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30), // Red color
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "Log Out",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF3B30), // Red text
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Perform the actual logout logic
  void _performLogout() {
    ref.read(authControllerProvider.notifier).logout();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue, // Primary Blue
        elevation: 0,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            "Super Admin Profile",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // --- Scrollable Content (Header + Cards) ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // --- Header Section ---
                  if (user != null) _buildHeader(user),

                  const SizedBox(height: 20),

                  // --- Personal Info Card ---
                  if (user != null)
                    _buildInfoCard(
                      title: "Personal Info",
                      children: [
                        _buildInfoRow("Email", user.email ?? "N/A"),
                        _buildInfoRow("Password", "xxxxxxxx"),
                        _buildInfoRow("Phone", user.phone),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // --- Account Info Card ---
                  if (user != null)
                    _buildInfoCard(
                      title: "Account Info",
                      children: [
                        _buildInfoRow("User type", "SUPER_ADMIN",
                            isValueBold: true),
                        _buildInfoRow(
                            "Account created",
                            user.createdAt == null
                                ? "N/A"
                                : "${user.createdAt?.day} ${_getMonth(user.createdAt?.month ?? 1)} ${user.createdAt?.year}"),
                        _buildInfoRow(
                            "Last Login",
                            user.lastLogin == null
                                ? "N/A"
                                : "${user.lastLogin?.day} ${_getMonth(user.lastLogin?.month ?? 1)} ${user.lastLogin?.year}"),
                      ],
                    ),

                  // Add some bottom padding so content doesn't sit right on top of the button when scrolling
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // --- Sticky Bottom Button ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA), // Match background
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 10,
                )
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 160, // Fixed width for pill shape look
                height: 45,
                child: ElevatedButton(
                  onPressed: _handleLogout, // Call the dialog function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30), // Red color
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Log Out",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and Role
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.role?.name ?? "N/A",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0A6ED1), // Blue text
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // ID and Edit Icon
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "User ID: ${user.id.length > 8 ? user.id.substring(0, 8) : user.id}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.updateSuperAdminProfile);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isValueBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: isValueBold ? FontWeight.bold : FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonth(int month) {
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
    return months[month - 1];
  }
}
