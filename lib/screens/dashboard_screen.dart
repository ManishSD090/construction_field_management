import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/screens/auth/login_screen.dart';
import 'package:construction_erp/screens/auth/set_pass_screen.dart'; // Ensure this exists

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Local state for popup visibility
  bool _showPasswordPopup = false;

  @override
  void initState() {
    super.initState();
    // Check if we need to show the popup after the widget mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNewUserStatus();
    });
  }

  void _checkNewUserStatus() {
    // 1. Get current user from Riverpod state
    final user = ref.read(authControllerProvider).value;

    // 2. Check logic (Assuming your User model has an 'isNewUser' or similar flag)
    // You can adjust this condition based on your actual User model
    // For now, I'm simulating it as always true for demonstration if needed,
    // or you can check: if (user?.isNewUser == true)

    bool isNewUser = user != null && user.lastLogin == null;

    if (isNewUser) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _showPasswordPopup = true;
          });
        }
      });
    }
  }

  void _closePopup() {
    setState(() {
      _showPasswordPopup = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch Auth State for UI updates (Name/Role)
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    // Use Stack to overlay the popup
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
          // Optional: FAB to trigger popup manually for testing
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                _showPasswordPopup = true;
              });
            },
            backgroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.blue),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),

        // --- LAYER 2: Dimmed Background (Visible only when popup is shown) ---
        if (_showPasswordPopup)
          GestureDetector(
            onTap: _closePopup,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              width: double.infinity,
              height: double.infinity,
            ),
          ),

        // --- LAYER 3: The Floating Popup ---
        if (_showPasswordPopup)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 220,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Continue to login\nwith password ?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // --- SET PASSWORD BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () {
                          _closePopup();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SetPasswordScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6EFD),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "SET PASSWORD",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    // --- NO THANKS BUTTON ---
                    TextButton(
                      onPressed: _closePopup,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "No Thanks",
                        style: TextStyle(
                          color: Color(0xFF0D6EFD),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --- COMPONENT WIDGETS ---

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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
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
