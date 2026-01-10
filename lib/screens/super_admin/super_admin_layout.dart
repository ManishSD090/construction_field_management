import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// FIX: Go up one level (..) to find home_screen_helper.dart
import '../home_screen_helper.dart';
import 'dashboard_tab.dart';
import 'companies_list_tab.dart';

// Import Auth Controller
import 'package:construction_erp/controllers/auth/auth_controller.dart';

class SuperAdminLayout extends ConsumerStatefulWidget {
  const SuperAdminLayout({super.key});

  @override
  ConsumerState<SuperAdminLayout> createState() => _SuperAdminLayoutState();
}

class _SuperAdminLayoutState extends ConsumerState<SuperAdminLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardTab(),
    const CompaniesListTab(),
    const Center(child: Text("Profile Page Placeholder")),
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Watch the Auth Controller for changes
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    // 2. Extract Data (Safely handle nulls)
    // Adjust 'fullname' or 'name' based on your exact User model property
    final displayName = user?.name ?? 'Super Admin';
    final displayRole = user?.role?.name ?? 'Super Admin';

    return Scaffold(
      backgroundColor: Colors.white,

      // 3. Header with Dynamic Data
      appBar: HomeScreenHelper.buildAppBar(
        name: displayName,
        role: displayRole.toUpperCase(), // Optional formatting
      ),

      // 4. Body
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // 5. Bottom Bar
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
