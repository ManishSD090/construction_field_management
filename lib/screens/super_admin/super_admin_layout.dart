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
  bool _isInit = false;

  // 1. Define the Map linking String keys to Index integers
  final Map<String, int> _tabRouteMap = {
    SuperAdminArguments.dashboard: 0,
    SuperAdminArguments.companies: 1,
    SuperAdminArguments.profile: 2,
  };

  final List<Widget> _pages = [
    const DashboardTab(),
    const CompaniesListTab(),
    const ProfileTab(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 2. Logic matches MainLayoutScreen: Check _isInit, then process args
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;

      // Handle the Arguments Class
      if (args is SuperAdminArguments) {
        final tabName = args.tab.toLowerCase().trim();
        if (_tabRouteMap.containsKey(tabName)) {
          setState(() {
            _currentIndex = _tabRouteMap[tabName]!;
          });
        }
      }
      // Fallback: Handle raw String if passed directly (optional, but robust)
      else if (args is String) {
        final tabName = args.toLowerCase().trim();
        if (_tabRouteMap.containsKey(tabName)) {
          setState(() {
            _currentIndex = _tabRouteMap[tabName]!;
          });
        }
      }

      _isInit = true;
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
