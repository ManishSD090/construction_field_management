import 'package:flutter/material.dart';
import '../../services/auth_storage.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/auth_input_field.dart';
import '../../widgets/otp_sent_card.dart';
import '../../widgets/auth_primary_button.dart';
import '../home_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool isOtpMode = false;
  bool otpSent = false;
  bool isLoading = false;

  @override
  void dispose() {
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  Future<void> onContinue() async {
    final phone = phoneCtrl.text.trim();

    if (!_isValidPhone(phone)) {
      _showError("Enter valid 10-digit phone number");
      return;
    }

    if (isOtpMode) {
      setState(() => otpSent = true);
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(phone: phone),
        ),
      );
    } else {
      final password = passwordCtrl.text.trim();

      if (password.isEmpty) {
        _showError("Password required");
        return;
      }

      setState(() => isLoading = true);
      final ok = await AuthStorage.verifyPassword(phone, password);

      if (!mounted) return;
      setState(() => isLoading = false);

      if (ok) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        _showError("Invalid credentials");
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              if (otpSent) const OtpSentCard(),

              const SizedBox(height: 40),

              const AuthHeader(),

              const SizedBox(height: 40),

              AuthInputField(
                label: "Phone Number",
                hint: "Enter phone number",
                controller: phoneCtrl,
              ),

              const SizedBox(height: 20),

              if (!isOtpMode)
                AuthInputField(
                  label: "Password",
                  hint: "Enter password",
                  controller: passwordCtrl,
                  obscure: true,
                ),

              const SizedBox(height: 30),

              AuthPrimaryButton(
                isLoading: isLoading,
                text: "Continue",
                onTap: onContinue,
              ),

              const SizedBox(height: 18),

              TextButton(
                onPressed: () {
                  setState(() {
                    isOtpMode = !isOtpMode;
                    otpSent = false;
                  });
                },
                child: Text(
                  isOtpMode
                      ? "Login with Password"
                      : "Log in with OTP",
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
