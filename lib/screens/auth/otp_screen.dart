import 'package:flutter/material.dart';
import 'dart:async'; // Required for Timer
import '../../widgets/auth_textfield.dart';
import '../../widgets/primary_button.dart';
import '../home_screen.dart'; // Ensure this import is correct

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final phoneCtrl = TextEditingController();
  final otpCtrl = TextEditingController();

  bool _isPhoneVisible = true;
  bool _isOtpVisible = false;
  bool _otpSent = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Animation controller for the popup slide effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5), // Start above the screen
      end: const Offset(0, 0.1), // End slightly down from the top
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut, // Bouncy effect
      reverseCurve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay(); // Ensure overlay is removed when leaving screen
    phoneCtrl.dispose();
    otpCtrl.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // --- CUSTOM POPUP LOGIC ---
  void _showTopSuccess(BuildContext context) {
    // If an overlay already exists, remove it first
    if (_overlayEntry != null) _removeOverlay();

    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60, // Position from top
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: Container(
                // 1. DECREASED WIDTH (0.70 of screen width)
                width: MediaQuery.of(context).size.width * 0.70,

                // 2. INCREASED HEIGHT via padding (vertical 35 makes it taller)
                padding:
                    const EdgeInsets.symmetric(vertical: 35, horizontal: 24),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "OTP Sent",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Green Check Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF26A69A), // Teal/Green color
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Insert the overlay
    overlayState.insert(_overlayEntry!);
    // Start animation
    _animationController.forward();

    // Remove automatically after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _animationController.reverse().then((value) => _removeOverlay());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const faintLightBlue = Color(0xFF90CAF9);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            _removeOverlay();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                const Center(
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E232C),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // --- PHONE FIELD ---
                const Text(
                  "Phone Number",
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Color(0xFF1E232C)),
                ),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  hint: _otpSent ? "XXXXX XXXXX" : "Enter phone number",
                  hintStyle: TextStyle(
                      color: _otpSent ? Colors.black87 : faintLightBlue),
                  obscureText: !_isPhoneVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPhoneVisible ? Icons.visibility : Icons.visibility_off,
                      color: faintLightBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPhoneVisible = !_isPhoneVisible;
                      });
                    },
                  ),
                ),

                // --- OTP FIELD (Visible after sent) ---
                if (_otpSent) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "OTP",
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Color(0xFF1E232C)),
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: otpCtrl,
                    keyboardType: TextInputType.number,
                    hint: "Enter OTP code",
                    hintStyle: const TextStyle(color: faintLightBlue),
                    obscureText: !_isOtpVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isOtpVisible ? Icons.visibility : Icons.visibility_off,
                        color: faintLightBlue,
                      ),
                      onPressed: () {
                        setState(() {
                          _isOtpVisible = !_isOtpVisible;
                        });
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // --- BUTTON ---
                PrimaryButton(
                  title: _otpSent ? "Continue" : "Send OTP",
                  onTap: () {
                    if (!_otpSent) {
                      setState(() {
                        _otpSent = true;
                        // Trigger the Top Popup
                        _showTopSuccess(context);
                      });
                    } else {
                      // Navigate to Dashboard
                      _removeOverlay(); // Clean up overlay before navigating
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const HomeScreen(isNewUser: true)));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
