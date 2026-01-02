import 'package:flutter/material.dart';
import 'package:construction_erp/widgets/auth/auth_textfield.dart';
import 'package:construction_erp/widgets/auth/primary_button.dart';
import 'package:construction_erp/screens/home_screen.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isNewPassVisible = false;
  bool _isConfirmPassVisible = false;

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    String newPass = _newPassController.text.trim();
    String confirmPass = _confirmPassController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields")),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password set successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const HomeScreen(isNewUser: false)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                const SizedBox(height: 50),

                const Text("New Password",
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _newPassController,
                  hint: "New password",
                  obscureText: !_isNewPassVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isNewPassVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF90CAF9)),
                    onPressed: () =>
                        setState(() => _isNewPassVisible = !_isNewPassVisible),
                  ),
                ),

                const SizedBox(height: 20),

                const Text("Confirm Password",
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _confirmPassController,
                  hint: "Confirm password",
                  obscureText: !_isConfirmPassVisible,
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

                PrimaryButton(title: "Continue", onTap: _validateAndSubmit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
