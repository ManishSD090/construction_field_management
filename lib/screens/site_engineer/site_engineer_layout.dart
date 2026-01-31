import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/home_screen_helper.dart';
import 'dashboard_tab.dart';
import 'Project/project_list_screen.dart';

class SiteEngineerLayout extends ConsumerStatefulWidget {
  static const String routeName = '/site-engineer';

  const SiteEngineerLayout({super.key});

  @override
  ConsumerState<SiteEngineerLayout> createState() => _SiteEngineerLayoutState();
}

class _SiteEngineerLayoutState extends ConsumerState<SiteEngineerLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Index 0: Dashboard
          const DashboardTab(),
          // Index 1: Project
          const ProjectListScreen(),
          // Index 2: Report
          _buildPlaceholderTab("Report"),
          // Index 3: Profile
          _buildPlaceholderTab("Profile"),
        ],
      ),
      bottomNavigationBar: HomeScreenHelper.buildProjectBottomBar(
        currentIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  /// Placeholder tab for future implementation
  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Text(
        '$title Tab',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}