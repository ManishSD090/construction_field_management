import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports from your project structure
import 'package:construction_erp/routes.dart'; // Your named routes file
import 'package:construction_erp/controllers/auth_controller.dart'; // Your Auth Controller
import 'package:construction_erp/widgets/auth_textfield.dart';
import 'package:construction_erp/widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Added for validation

  bool _isPasswordVisible = false;

  // Constants for colors to keep build method clean
  static const _faintLightBlue = Color(0xFF90CAF9);
  static const _textColor = Color(0xFF1E232C);

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // 1. Validate inputs
    if (_formKey.currentState!.validate()) {
      // 2. Trigger Controller
      ref.read(authControllerProvider.notifier).login(
            identifier: _identifierCtrl.text.trim(),
            password: _passCtrl.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Watch Auth State (for loading indicator)
    final authState = ref.watch(authControllerProvider);

    // 4. Listen for Side Effects (Navigation or Error)
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        // Show Error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else if (next.value != null && !next.isLoading) {
        // Success: Navigate to Dashboard using Named Route
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            "Welcome back !",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: _textColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- EMAIL/PHONE FIELD ---
                    const Text(
                      "Phone Number/ Email",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AuthTextField(
                      controller: _identifierCtrl,
                      hint: "Enter phone number/Email",
                      hintStyle: const TextStyle(color: _faintLightBlue),
                      // Add basic validation
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),

                    const SizedBox(height: 20),

                    // --- PASSWORD FIELD ---
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AuthTextField(
                      controller: _passCtrl,
                      hint: "Enter password",
                      hintStyle: const TextStyle(color: _faintLightBlue),
                      obscureText: !_isPasswordVisible,
                      validator: (value) => value!.isEmpty ? "Required" : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: _faintLightBlue,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- LOGIN BUTTON ---
                    // If loading, show spinner. Else show button.
                    authState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButton(
                            title: "Continue",
                            onTap: _handleLogin,
                          ),

                    const SizedBox(height: 20),

                    // --- OTP LOGIN LINK ---
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // Standard Push for OTP screen (Back button enabled)
                          Navigator.pushNamed(
                            context,
                            AppRoutes.otp,
                          );
                        },
                        child: const Text(
                          "Log in with OTP",
                          style: TextStyle(
                            color: Color(0xFF1E88E5),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF1E88E5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
