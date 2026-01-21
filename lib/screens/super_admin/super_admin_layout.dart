import 'package:construction_erp/screens/super_admin/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// FIX: Go up one level (..) to find home_screen_helper.dart
import '../home_screen_helper.dart';
import 'dashboard_tab.dart';
import 'companies_list_tab.dart';

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
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Watch the Auth Controller for changes

    return Scaffold(
      backgroundColor: Colors.white,

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
