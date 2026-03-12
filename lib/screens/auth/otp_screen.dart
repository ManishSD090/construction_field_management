import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:construction_erp/routes.dart';
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/widgets/auth/auth_textfield.dart';
import 'package:construction_erp/widgets/auth/primary_button.dart';

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

  // 1. ADD LOCAL LOADING STATE
  bool _isSendingOtp = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
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

  String _getErrorMessage(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError) {
        return "Unable to connect. Check your internet.";
      }
      if (error.response?.statusCode == 404) {
        return "Phone number not registered.";
      }
      if (error.response?.statusCode == 400 ||
          error.response?.statusCode == 401) {
        if (_otpSent) {
          return "Invalid OTP. Please try again.";
        }
        return "Invalid request.";
      }
      if (error.response?.data != null && error.response!.data is Map) {
        return error.response!.data['message'] ?? "An error occurred.";
      }
    }
    return error.toString();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- LOGIC: SEND OTP ---
  Future<void> _handleSendOtp() async {
    final identifier = identifierCtrl.text.trim();
    if (identifier.isEmpty) {
      _showErrorSnackBar("Please enter a phone number");
      return;
    }

    // 2. START LOADING
    setState(() {
      _isSendingOtp = true;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .requestLoginOtp(identifier: identifier);

      if (mounted) {
        setState(() {
          _otpSent = true;
        });
        _showTopSuccess(context);
      }
    } catch (e) {
      _showErrorSnackBar(_getErrorMessage(e));
    } finally {
      // 3. STOP LOADING (Always execute)
      if (mounted) {
        setState(() {
          _isSendingOtp = false;
        });
      }
    }
  }

  // --- LOGIC: VERIFY OTP ---
  Future<void> _handleVerifyOtp() async {
    final identifier = identifierCtrl.text.trim();
    final otp = otpCtrl.text.trim();

    if (otp.isEmpty) {
      _showErrorSnackBar("Please enter the OTP");
      return;
    }

    // No local loading state needed here; global Riverpod state handles it
    await ref
        .read(authControllerProvider.notifier)
        .verifyLoginOtp(identifier: identifier, otp: otp);
  }

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

    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError && !next.isLoading) {
_showErrorSnackBar(_getErrorMessage(next.error ?? Exception("Unknown error")));      } else if (!next.isLoading && next.value != null) {
        _removeOverlay(); // Clean up animation overlay

        final user = next.value!;

        // 1. Check if user is Super Admin/System Admin
        if (user.role?.isSystemAdmin == true) {
          Navigator.pushReplacementNamed(context, AppRoutes.superAdmin);
        } else {
          // 2. Default Dashboard
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    });

    final authState = ref.watch(authControllerProvider);

    // 4. COMBINE LOADING STATES
    // isLoading is TRUE if either the Controller is working OR we are sending OTP locally
    final isLoading = authState.isLoading || _isSendingOtp;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          // Disable back button if loading
          onPressed: isLoading
              ? null
              : () {
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
                  hint: _otpSent ? "XXXXX XXXXX" : "Enter Phone Number / Email",
                  hintStyle: TextStyle(
                      color: _otpSent ? Colors.black87 : faintLightBlue),
                  obscureText: !_isIdentifierVisible,

                  // CHANGE: Disable input if loading OR if OTP has been sent
                  enabled: !isLoading && !_otpSent,

                  textInputAction:
                      _otpSent ? TextInputAction.next : TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!isLoading) {
                      if (!_otpSent) {
                        _handleSendOtp();
                      }
                    }
                  },

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

                // --- OTP FIELD ---
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

                    // enabled: !isLoading,

                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!isLoading) _handleVerifyOtp();
                    },

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
                  // 5. PASS COMBINED LOADING STATE
                  isLoading: isLoading,

                  // Disable tap if loading
                  onTap: isLoading
                      ? null // Setting to null often visually disables buttons
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
