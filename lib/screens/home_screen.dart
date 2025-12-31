import 'package:flutter/material.dart';
import 'package:construction_erp/screens/auth/login_screen.dart'; // Ensure this matches your folder structure

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background matching the design
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Custom Header (Blue Curve with Logout)
            _buildHeader(context),

            const SizedBox(height: 20),

            // 2. Quick Actions Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick actions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildQuickActionsGrid(),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 3. Recent Activity List
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

            // Extra space at bottom so content isn't hidden by the BottomNavBar
            const SizedBox(height: 80),
          ],
        ),
      ),

      // 4. Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavBar(),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // You can trigger the "Set Password" modal here if needed
        },
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.blue),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF0D6EFD), // The blue color from your design
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "WELCOME BACK,",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 5),
              Text(
                "Person Name",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "Site Engg",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              // --- LOGOUT BUTTON ---
              IconButton(
                onPressed: () {
                  // Navigate back to LoginScreen and remove history
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: "Logout",
              ),

              const SizedBox(width: 5),

              // Notification Icon
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
                        color: Colors.red, // Notification dot
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
      childAspectRatio: 1.5, // Makes the cards rectangular
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
            const SizedBox(width: 40), // Space for FAB
            Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
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
