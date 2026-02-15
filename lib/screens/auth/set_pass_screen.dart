import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:construction_erp/controllers/auth/auth_controller.dart'; // Import Controller
import 'package:construction_erp/widgets/auth/auth_textfield.dart';
import 'package:construction_erp/widgets/auth/primary_button.dart';
import 'package:construction_erp/routes.dart';

class SetPasswordScreen extends ConsumerStatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isNewPassVisible = false;
  bool _isConfirmPassVisible = false;

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleSetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    // 1. Local Validation: Check Match
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2. Call AuthController
    try {
      await ref.read(authControllerProvider.notifier).completeSetup(
            password: newPass,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password set successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // 3. Close the screen (and the popup in Dashboard will close automatically due to status update)
      Navigator.popUntil(context, ModalRoute.withName(AppRoutes.home));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Set Password",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E232C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "Secure your account for easier login next time.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // --- NEW PASSWORD ---
                  const Text("New Password",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _newPassController,
                    hint: "New password",
                    obscureText: !_isNewPassVisible,
                    validator: (val) => val != null && val.length < 6
                        ? "Minimum 6 characters"
                        : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isNewPassVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF90CAF9)),
                      onPressed: () => setState(
                          () => _isNewPassVisible = !_isNewPassVisible),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- CONFIRM PASSWORD ---
                  const Text("Confirm Password",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _confirmPassController,
                    hint: "Confirm password",
                    obscureText: !_isConfirmPassVisible,
                    validator: (val) => val!.isEmpty ? "Required" : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isConfirmPassVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF90CAF9)),
                      onPressed: () => setState(
                          () => _isConfirmPassVisible = !_isConfirmPassVisible),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- SUBMIT BUTTON ---
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : PrimaryButton(
                          title: "Continue", onTap: _handleSetPassword),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
