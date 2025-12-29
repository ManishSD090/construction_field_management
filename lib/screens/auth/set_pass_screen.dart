import 'package:flutter/material.dart';
import '../../widgets/auth_textfield.dart';
import '../../widgets/primary_button.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  // State to toggle visibility for both fields independently
  bool _isNewPassVisible = false;
  bool _isConfirmPassVisible = false;

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
          onPressed: () => Navigator.pop(context),
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
                    "Set Password",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E232C),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // --- NEW PASSWORD SECTION ---
                const Text(
                  "New Password",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E232C),
                  ),
                ),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: newPassCtrl,
                  hint: "New password",
                  hintStyle: const TextStyle(color: faintLightBlue),
                  obscureText: !_isNewPassVisible, // Hides text by default
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPassVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: faintLightBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPassVisible = !_isNewPassVisible;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // --- CONFIRM PASSWORD SECTION ---
                const Text(
                  "Confirm Password",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E232C),
                  ),
                ),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: confirmPassCtrl,
                  hint: "Confirm password",
                  hintStyle: const TextStyle(color: faintLightBlue),
                  obscureText: !_isConfirmPassVisible, // Hides text by default
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPassVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: faintLightBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPassVisible = !_isConfirmPassVisible;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // --- ACTION BUTTON ---
                PrimaryButton(
                  title: "Continue",
                  onTap: () {
                    // Logic to save password goes here
                    if (newPassCtrl.text == confirmPassCtrl.text) {
                      print("Passwords match. Saving...");
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Passwords do not match!")),
                      );
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
