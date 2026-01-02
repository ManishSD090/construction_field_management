import 'package:construction_erp/routes.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import Widgets
import 'package:construction_erp/widgets/auth_textfield.dart';
import 'package:construction_erp/widgets/primary_button.dart';

// Import Controller
import 'package:construction_erp/controllers/auth_controller.dart'; // Adjust path if needed

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  final identifierCtrl = TextEditingController();
  final otpCtrl = TextEditingController();

  bool _isIdentifierVisible = true;
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
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0.1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    identifierCtrl.dispose();
    otpCtrl.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // --- LOGIC: SEND OTP ---
  Future<void> _handleSendOtp() async {
    final identifier = identifierCtrl.text.trim();
    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a phone number")));
      return;
    }

    try {
      // 1. Call Controller
      await ref
          .read(authControllerProvider.notifier)
          .requestLoginOtp(identifier: identifier);

      // 2. On Success: Update UI
      if (mounted) {
        setState(() {
          _otpSent = true;
        });
        _showTopSuccess(context);
      }
    } catch (e) {
      // 3. Handle Error (e.g., API failure)
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to send OTP: $e")));
      }
    }
  }

  // --- LOGIC: VERIFY OTP ---
  Future<void> _handleVerifyOtp() async {
    final identifier = identifierCtrl.text.trim();
    final otp = otpCtrl.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please enter the OTP")));
      return;
    }

    // 1. Call Controller (This updates the global state)
    await ref
        .read(authControllerProvider.notifier)
        .verifyLoginOtp(identifier: identifier, otp: otp);

    // Note: Navigation is handled by the ref.listen below
  }

  // --- CUSTOM POPUP LOGIC ---
  void _showTopSuccess(BuildContext context) {
    if (_overlayEntry != null) _removeOverlay();

    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.70,
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
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF26A69A),
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

    overlayState.insert(_overlayEntry!);
    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _animationController.reverse().then((value) => _removeOverlay());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const faintLightBlue = Color(0xFF90CAF9);

    // 1. Listen for Auth State Changes (Navigation & Errors)
    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Failed: ${next.error}")),
        );
      } else if (next is AsyncData && next.value != null) {
        // Login Successful -> Navigate
        _removeOverlay();
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    });

    // 2. Watch for Loading State
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

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
                  "Phone Number/ Email",
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Color(0xFF1E232C)),
                ),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: identifierCtrl,
                  keyboardType: TextInputType.text,
                  hint: _otpSent ? "XXXXX XXXXX" : "Enter phone number",
                  hintStyle: TextStyle(
                      color: _otpSent ? Colors.black87 : faintLightBlue),
                  obscureText: !_isIdentifierVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isIdentifierVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: faintLightBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        _isIdentifierVisible = !_isIdentifierVisible;
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
                  isLoading: isLoading, // Show loading spinner
                  onTap: isLoading
                      ? () {} // Disable tap while loading
                      : () {
                          if (!_otpSent) {
                            _handleSendOtp();
                          } else {
                            _handleVerifyOtp();
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
