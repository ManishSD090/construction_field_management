import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/routes.dart';

// Import your tab views
import 'package:construction_erp/screens/admin/dashboard_tab.dart';
import 'package:construction_erp/screens/projects/project_tab.dart';
import 'package:construction_erp/screens/admin/admin_profile_screen.dart';

enum DashboardPopupType { none, verification, setPassword }

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  int _selectedIndex = 0;
  DashboardPopupType _currentPopup = DashboardPopupType.none;
  bool _isInit = false;

  final Map<String, int> _tabRouteMap = {
    'dashboard': 0,
    'project': 1,
    'operation': 2,
    'profile': 3,
  };

  final List<Widget> _pages = [
    const DashboardTab(),
    const ProjectTab(),
    const Center(child: Text("Operations Screen")),
    const AdminProfileScreen()
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        final tabName = args.toLowerCase().trim();
        if (_tabRouteMap.containsKey(tabName)) {
          setState(() {
            _selectedIndex = _tabRouteMap[tabName]!;
          });
        }
      }
      _isInit = true;
    }
  }

  void _checkAuthStatus() {
    final status = ref.read(authStatusProvider);
    if (status == null) return;
    setState(() {
      if (status.needsVerification) {
        _currentPopup = DashboardPopupType.verification;
      } else if (status.needsPassword) {
        _currentPopup = DashboardPopupType.setPassword;
      } else {
        _currentPopup = DashboardPopupType.none;
      }
    });
  }

  void _closePopup() {
    setState(() {
      _currentPopup = DashboardPopupType.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[50],
          // Display the widget corresponding to the selected index
          body: _pages[_selectedIndex],

          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            child: NavigationBar(
              height: 70,
              elevation: 0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              indicatorColor: Colors.blue.shade100,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home, color: Color(0xFF0D6EFD)),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon:
                      Icon(Icons.inventory_2, color: Color(0xFF0D6EFD)),
                  label: 'Project',
                ),
                NavigationDestination(
                  icon: Icon(Icons.note_alt_outlined),
                  selectedIcon: Icon(Icons.note_alt, color: Color(0xFF0D6EFD)),
                  label: 'Operation',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: Color(0xFF0D6EFD)),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),

        // --- POPUP LAYERS ---
        if (_currentPopup != DashboardPopupType.none)
          GestureDetector(
            onTap: _closePopup,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
            ),
          ),

        if (_currentPopup != DashboardPopupType.none)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Center(child: _buildDynamicPopupContent()),
          ),
      ],
    );
  }

  Widget _buildDynamicPopupContent() {
    final status = ref.read(authStatusProvider);
    String title = "";
    String message = "";
    String btnText = "";
    VoidCallback onAction = () {};
    Widget? secondaryAction;

    if (_currentPopup == DashboardPopupType.verification) {
      title = "Verification Required";
      String method = "account";
      if (status?.emailVerified == false) method = "email";
      if (status?.phoneVerified == false) method = "phone number";

      message = "Please verify your $method to unlock full features.";
      btnText = "VERIFY NOW";
      onAction = () {
        _closePopup();
        Navigator.pushNamed(context, AppRoutes.verification);
      };

      // Check if partially verified (at least one method is verified)
      if (status?.emailVerified == true || status?.phoneVerified == true) {
        secondaryAction = SizedBox(
          width: double.infinity,
          height: 45,
          child: OutlinedButton(
            onPressed: () {
              _closePopup();
              // If they still need a password, go there. Otherwise just close popup (continue to dashboard).
              if (status?.needsPassword == true) {
                Navigator.pushNamed(context, AppRoutes.setPassword);
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF0D6EFD)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Continue",
                style: TextStyle(
                    color: Color(0xFF0D6EFD),
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        );
      }
    } else if (_currentPopup == DashboardPopupType.setPassword) {
      title = "Set Your Password";
      message =
          "You are currently logged in via OTP. Set a password for easier access.";
      btnText = "SET PASSWORD";
      onAction = () {
        _closePopup();
        Navigator.pushNamed(context, AppRoutes.setPassword);
      };
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D6EFD).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _currentPopup == DashboardPopupType.verification
                  ? Icons.mark_email_unread_outlined
                  : Icons.lock_outline,
              color: const Color(0xFF0D6EFD),
              size: 28,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(btnText,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ),
          ),
          if (secondaryAction != null) ...[
            const SizedBox(height: 10),
            secondaryAction,
          ],
          const SizedBox(height: 10),
          TextButton(
            onPressed: _closePopup,
            style: TextButton.styleFrom(
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: const Text("Remind me later",
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
