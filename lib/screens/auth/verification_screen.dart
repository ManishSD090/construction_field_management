import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/routes.dart';
import 'package:construction_erp/widgets/auth/auth_textfield.dart';
import 'package:construction_erp/widgets/auth/primary_button.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch status to dynamically update UI
    final authStatus = ref.watch(authStatusProvider);
    final user = ref.read(authControllerProvider).value;

    if (authStatus == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Logic for button visibility and style
    final bool isFullyVerified =
        authStatus.emailVerified && authStatus.phoneVerified;
    final bool canContinue =
        authStatus.emailVerified || authStatus.phoneVerified;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title:
            const Text("Verification", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Verify your details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please verify your contact information to secure your account and access all features.",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 40),

              // --- EMAIL SECTION ---
              _buildVerificationItem(
                context,
                title: "Email Address",
                value: user?.email ?? "No Email",
                isVerified: authStatus.emailVerified,
                icon: Icons.email_outlined,
                onVerifyTap: () => _showOtpBottomSheet(context, 'email'),
              ),

              const SizedBox(height: 20),

              // --- PHONE SECTION ---
              _buildVerificationItem(
                context,
                title: "Phone Number",
                value: user?.phone ?? "No Phone",
                isVerified: authStatus.phoneVerified,
                icon: Icons.phone_android_outlined,
                onVerifyTap: () => _showOtpBottomSheet(context, 'phone'),
              ),

              const Spacer(),

              // --- CONTINUE BUTTON ---
              // Shows if at least one method is verified
              if (canContinue)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Logic: If password is needed, go there. Else, go back (to dashboard)
                      if (authStatus.needsPassword) {
                        Navigator.pushNamed(context, AppRoutes.setPassword);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      // Green if fully verified, Blue if partially verified
                      backgroundColor: isFullyVerified
                          ? Colors.green
                          : const Color(0xFF0D6EFD),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isFullyVerified) ...[
                          const Icon(Icons.check, color: Colors.white),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          isFullyVerified
                              ? "Everything Verified! Continue"
                              : "Continue",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET: Verification Item Row ---
  Widget _buildVerificationItem(
    BuildContext context, {
    required String title,
    required String value,
    required bool isVerified,
    required IconData icon,
    required VoidCallback onVerifyTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isVerified
                  ? Colors.green.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVerified ? Icons.check : icon,
              color: isVerified ? Colors.green : Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isVerified)
            TextButton(
              onPressed: onVerifyTap,
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text("VERIFY"),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Text(
                "Verified",
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  // --- LOGIC: OTP Bottom Sheet ---
  void _showOtpBottomSheet(BuildContext parentContext, String method) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true, // Allow full height for keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OtpVerificationSheet(method: method),
    );
  }
}

// ==============================================================================
// SUB-WIDGET: OTP Sheet (Handles Request & Submit Logic)
// ==============================================================================

class OtpVerificationSheet extends ConsumerStatefulWidget {
  final String method; // 'email' or 'phone'

  const OtpVerificationSheet({super.key, required this.method});

  @override
  ConsumerState<OtpVerificationSheet> createState() =>
      _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends ConsumerState<OtpVerificationSheet> {
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-request OTP when sheet opens
    _sendOtp();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .requestVerificationOtp(method: widget.method);

      if (mounted) {
        setState(() {
          _otpSent = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close sheet on fail
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to send OTP: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .submitVerificationOtp(otp: otp, method: widget.method);

      if (!mounted) return;
      Navigator.pop(context); // Close sheet

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("${widget.method.toUpperCase()} verified successfully!"),
            backgroundColor: Colors.green),
      );
      // The parent screen updates automatically because it watches authStatusProvider
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Invalid OTP"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle Keyboard Padding
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Verify ${widget.method == 'email' ? 'Email' : 'Phone'}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (!_otpSent && _isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Text("Enter the OTP sent to your ${widget.method}."),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _otpController,
              hint: "Enter OTP",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(title: "Confirm", onTap: _verifyOtp),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
