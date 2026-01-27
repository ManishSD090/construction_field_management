import 'package:dio/dio.dart'; // <--- IMPORT THIS
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:construction_erp/routes.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/widgets/auth/auth_textfield.dart';
import 'package:construction_erp/widgets/auth/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;

  static const _faintLightBlue = Color(0xFF90CAF9);
  static const _textColor = Color(0xFF1E232C);

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).loginWithPassword(
            identifier: _identifierCtrl.text.trim(),
            password: _passCtrl.text,
          );
    }
  }

  /// Helper to generate user-friendly error messages
  String _getErrorMessage(Object error) {
    if (error is DioException) {
      // 1. Handle 401 (Invalid Credentials)
      if (error.response?.statusCode == 401) {
        return "Invalid Credentials. Please try again or login with OTP.";
      }

      // 2. Handle Server Connection Issues
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError) {
        return "Unable to connect to server. Check your internet.";
      }

      // 3. Try to extract backend error message (e.g., {"message": "User blocked"})
      if (error.response?.data != null && error.response!.data is Map) {
        return error.response!.data['message'] ?? "Server error occurred.";
      }
    }

    // 4. Fallback
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // --- UPDATED LISTENER ---
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        // Get the friendly message
        final message = _getErrorMessage(next.error!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next.value != null && !next.isLoading) {
        // Login Successful
        final user = next.value!;

        // 1. Check if user is Super Admin/System Admin
        // (Adjust 'isSystemAdmin' to 'isSuperAdmin' if that is your exact field name)
        if (user.userType == UserType.superAdmin) {
          Navigator.pushReplacementNamed(context, AppRoutes.superAdmin);
        } else {
          // 2. Default Dashboard
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    });
    // -----------------------

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
                      validator: (value) => value!.isEmpty ? "Required" : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),
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
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
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
                    authState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButton(
                            title: "Continue",
                            onTap: _handleLogin,
                          ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
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
