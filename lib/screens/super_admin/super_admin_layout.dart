import 'package:flutter/material.dart';

// FIX: Go up one level (..) to find home_screen.dart
import '../home_screen.dart';
import 'dashboard_tab.dart';
import 'companies_list_tab.dart';

class SuperAdminLayout extends StatefulWidget {
  const SuperAdminLayout({super.key});

  @override
  State<SuperAdminLayout> createState() => _SuperAdminLayoutState();
}

class _SuperAdminLayoutState extends State<SuperAdminLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardTab(),
    const CompaniesListTab(),
    const Center(child: Text("Profile Page Placeholder")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 1. Header
      appBar: HomeScreenHelper.buildAppBar(
        name: "Person Name",
        role: "Super Admin",
      ),

      // 2. Body
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // 3. Bottom Bar
      bottomNavigationBar: HomeScreenHelper.buildSuperAdminBottomBar(
        currentIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
