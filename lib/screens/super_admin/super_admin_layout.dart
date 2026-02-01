import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/routes.dart'; // Import AppRoutes & SuperAdminArguments

import '../home_screen_helper.dart';
import 'dashboard_tab.dart';
import 'companies_list_tab.dart';
import 'profile_tab.dart';

class SuperAdminLayout extends ConsumerStatefulWidget {
  const SuperAdminLayout({super.key});

  @override
  ConsumerState<SuperAdminLayout> createState() => _SuperAdminLayoutState();
}

class _SuperAdminLayoutState extends ConsumerState<SuperAdminLayout> {
  int _currentIndex = 0;
  bool _isInit = true;

  final List<Widget> _pages = [
    const DashboardTab(),
    const CompaniesListTab(),
    const ProfileTab(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check arguments only once when the screen loads
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;

      // Handle SuperAdminArguments
      if (args is SuperAdminArguments) {
        // Validate index to prevent range errors
        if (args.tab >= 0 && args.tab < _pages.length) {
          _currentIndex = args.tab;
        }
      }
      // Fallback: Legacy support if you accidentally pass a raw int somewhere else
      else if (args is int) {
        if (args >= 0 && args < _pages.length) {
          _currentIndex = args;
        }
      }

      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Body
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // Bottom Bar
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
