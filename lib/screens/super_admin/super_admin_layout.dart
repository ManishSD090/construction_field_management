import 'package:flutter/material.dart';
import '../home_screen.dart'; // Imports the helper functions (Header & BottomBar)
import 'dashboard_tab.dart'; // Imports the DashboardTab you created
import 'companies_list_tab.dart'; // Imports the Companies List

class SuperAdminLayout extends StatefulWidget {
  const SuperAdminLayout({super.key});

  @override
  State<SuperAdminLayout> createState() => _SuperAdminLayoutState();
}

class _SuperAdminLayoutState extends State<SuperAdminLayout> {
  int _currentIndex = 0;

  // --- 1. Define the Pages for the Bottom Nav ---
  final List<Widget> _pages = [
    const DashboardTab(),      // Index 0: Your DashboardTab
    const CompaniesListTab(),  // Index 1: Your CompaniesListTab
    const Center(child: Text("Profile Screen")), // Index 2: Profile Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // --- 2. Call the Header Function (from HomeScreenHelper) ---
      // We change the title dynamically based on the current index
      appBar: HomeScreenHelper.buildAppBar(
        title: _currentIndex == 0 
            ? "Dashboard" 
            : _currentIndex == 1 
                ? "Companies" 
                : "Profile",
        showNotification: true, 
      ),
      
      // --- 3. The Body (Switches based on index) ---
      // IndexedStack preserves the state of the Dashboard so it doesn't reload when switching tabs
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      // --- 4. Call the Bottom Bar Function (from HomeScreenHelper) ---
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