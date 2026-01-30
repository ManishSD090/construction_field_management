import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'project_list_screen.dart';

class SiteEngineerLayout extends StatefulWidget {
  const SiteEngineerLayout({Key? key}) : super(key: key);

  @override
  State<SiteEngineerLayout> createState() => _SiteEngineerLayoutState();
}

class _SiteEngineerLayoutState extends State<SiteEngineerLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProjectListScreen(),
    const Center(child: Text("Report Screen")), // Placeholder
    const Center(child: Text("Profile Screen")), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.business_center_outlined), label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Reports"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}