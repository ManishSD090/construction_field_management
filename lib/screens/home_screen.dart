import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import 'auth/set_pass_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isNewUser;
  const HomeScreen({super.key, this.isNewUser = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showPasswordPopup = false;

  @override
  void initState() {
    super.initState();
    if (widget.isNewUser) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _showPasswordPopup = true);
      });
    }
  }

  void _closePopup() => setState(() => _showPasswordPopup = false);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[50],
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 25),
                _buildRecentActivityList(),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavBar(),
        ),

        if (_showPasswordPopup) GestureDetector(
          onTap: _closePopup,
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),

        if (_showPasswordPopup)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(child: _passwordPopup(context)),
          ),
      ],
    );
  }

  Widget _passwordPopup(BuildContext context) => Container(
    width: 230,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 8)],
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text("Continue with password?",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: () {
          _closePopup();
          Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SetPasswordScreen()));
        },
        child: const Text("SET PASSWORD"),
      ),
      TextButton(onPressed: _closePopup, child: const Text("No Thanks"))
    ]),
  );

  Widget _buildHeader(BuildContext context) => Container(
    height: 120,
    alignment: Alignment.center,
    decoration: const BoxDecoration(color: Color(0xFF0D6EFD)),
    child: const Text("WELCOME", style: TextStyle(color: Colors.white,fontSize:22)),
  );

  Widget _buildRecentActivityList() => const Padding(
    padding: EdgeInsets.all(20),
    child: Text("Dashboard content here"),
  );

  Widget _buildBottomNavBar() => const BottomAppBar(
    child: SizedBox(height: 60, child: Center(child: Text("Bottom Bar"))),
  );
}
