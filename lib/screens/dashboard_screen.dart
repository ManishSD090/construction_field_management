import 'package:construction_erp/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/models/user.dart';
// import 'package:construction_erp/screens/auth/login_screen.dart';

// Helper Enum to track which popup to show
enum DashboardPopupType { none, verification, setPassword }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // State to track which popup is currently visible
  DashboardPopupType _currentPopup = DashboardPopupType.none;

  @override
  void initState() {
    super.initState();
    // Check status after widget mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  void _checkAuthStatus() {
    // 1. Get the status from the provider (set during login)
    // If null, it means we are offline or status wasn't fetched -> Show nothing.
    final status = ref.read(authStatusProvider);

    if (status == null) return;

    setState(() {
      // 2. Priority Logic: Verification First, then Password
      if (status.needsVerification) {
        _currentPopup = DashboardPopupType.verification;
      } else if (status.needsPassword) {
        _currentPopup = DashboardPopupType.setPassword;
      } else {
        _currentPopup = DashboardPopupType.none;
      }
    });
  }

  void _closePopup() {
    setState(() {
      _currentPopup = DashboardPopupType.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch Auth State for UI updates (Name/Role)
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    return Stack(
      children: [
        // --- LAYER 1: Main Dashboard Content ---
        Scaffold(
          backgroundColor: Colors.grey[50],
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, user),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Quick actions",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      _buildQuickActionsGrid(),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Recent activity",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text("View all",
                                style: TextStyle(color: Colors.blue)),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildRecentActivityList(),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavBar(),
          // Optional: FAB to toggle popups manually for testing
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _checkAuthStatus(); // Re-trigger check
            },
            backgroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.refresh, color: Colors.blue),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),

        // --- LAYER 2: Dimmed Background ---
        if (_currentPopup != DashboardPopupType.none)
          GestureDetector(
            onTap: _closePopup, // Optional: Close on outside tap
            child: Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
            ),
          ),

        // --- LAYER 3: The Dynamic Popup ---
        if (_currentPopup != DashboardPopupType.none)
          Positioned(
            bottom: 30,
            left: 20, // Added padding
            right: 20, // Added padding
            child: Center(
              child: _buildDynamicPopupContent(),
            ),
          ),
      ],
    );
  }

  // --- POPUP BUILDER ---
  Widget _buildDynamicPopupContent() {
    final status = ref.read(authStatusProvider);
    String title = "";
    String message = "";
    String btnText = "";
    VoidCallback onAction = () {};

    if (_currentPopup == DashboardPopupType.verification) {
      title = "Verification Required";
      // Determine if email, phone, or both need verification
      String method = "account";
      if (status?.emailVerified == false) method = "email";
      if (status?.phoneVerified == false) method = "phone number";

      message = "Please verify your $method to unlock full features.";
      btnText = "VERIFY NOW";
      onAction = () {
        _closePopup();

        Navigator.pushNamed(context, AppRoutes.verification);
      };
    } else if (_currentPopup == DashboardPopupType.setPassword) {
      title = "Set Your Password";
      message =
          "You are currently logged in via OTP. Set a password for easier access.";
      btnText = "SET PASSWORD";
      onAction = () {
        _closePopup();

        Navigator.pushNamed(context, AppRoutes.setPassword);
      };
    }

    return Container(
      width: double.infinity, // Takes available width within padding
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon based on type
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D6EFD).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _currentPopup == DashboardPopupType.verification
                  ? Icons.mark_email_unread_outlined
                  : Icons.lock_outline,
              color: const Color(0xFF0D6EFD),
              size: 28,
            ),
          ),
          const SizedBox(height: 15),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // --- ACTION BUTTON ---
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                btnText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // --- DISMISS BUTTON ---
          TextButton(
            onPressed: _closePopup,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              "Remind me later",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- EXISTING COMPONENT WIDGETS ---
  // (These remain exactly the same as your code)

  Widget _buildHeader(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF0D6EFD),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "WELCOME BACK,",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              Text(
                user?.name ?? "Loading...",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                user?.role?.name ?? "Contractor",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
              const SizedBox(width: 5),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications,
                        color: Colors.white, size: 28),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(Icons.person_outline, Colors.blue[50]!, Colors.blue,
            "Attendance", "45/50"),
        _buildActionCard(Icons.assignment_outlined, Colors.teal[50]!,
            Colors.teal, "Tasks", "12/18 done"),
        _buildActionCard(Icons.description_outlined, Colors.orange[50]!,
            Colors.orange, "DPR", "20 submitted"),
        _buildActionCard(Icons.inventory_2_outlined, Colors.red[50]!,
            Colors.redAccent, "Projects", "3 active"),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, Color bgColor, Color iconColor,
      String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const Spacer(),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Column(
      children: [
        _buildActivityItem(Icons.assignment_turned_in, Colors.blue,
            "Task completed", "Foundation work - Block A", "2 h ago"),
        const SizedBox(height: 12),
        _buildActivityItem(
            Icons.book, Colors.blue, "DPR submitted", "24 Dec 2025", "5 h ago"),
        const SizedBox(height: 12),
        _buildActivityItem(Icons.check_circle_outline, Colors.blue,
            "Check in recorded", "Arrived at site", "7 h ago"),
      ],
    );
  }

  Widget _buildActivityItem(
      IconData icon, Color color, String title, String subtitle, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              spreadRadius: 1,
              blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.grid_view_rounded, color: Colors.blue),
                ),
                const Text("Dashboard",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold))
              ],
            ),
            const SizedBox(width: 40),
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, color: Colors.grey),
                Text("Profile",
                    style: TextStyle(color: Colors.grey, fontSize: 10))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
