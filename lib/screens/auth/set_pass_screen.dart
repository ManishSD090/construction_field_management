// import 'package:flutter/material.dart';
// import 'package:construction_erp/widgets/auth_textfield.dart';
// import 'package:construction_erp/widgets/primary_button.dart';

// class SetPasswordScreen extends StatefulWidget {
//   const SetPasswordScreen({super.key});

//   @override
//   State<SetPasswordScreen> createState() => _SetPasswordScreenState();
// }

// class _SetPasswordScreenState extends State<SetPasswordScreen> {
//   final newPassCtrl = TextEditingController();
//   final confirmPassCtrl = TextEditingController();

//   // State to toggle visibility for both fields independently
//   bool _isNewPassVisible = false;
//   bool _isConfirmPassVisible = false;

//   @override
//   Widget build(BuildContext context) {
//     const faintLightBlue = Color(0xFF90CAF9);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 22),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // --- HEADER ---
//                 const Center(
//                   child: Text(
//                     "Set Password",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1E232C),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 // --- NEW PASSWORD SECTION ---
//                 const Text(
//                   "New Password",
//                   style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF1E232C),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 AuthTextField(
//                   controller: newPassCtrl,
//                   hint: "New password",
//                   hintStyle: const TextStyle(color: faintLightBlue),
//                   obscureText: !_isNewPassVisible, // Hides text by default
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isNewPassVisible
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                       color: faintLightBlue,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _isNewPassVisible = !_isNewPassVisible;
//                       });
//                     },
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // --- CONFIRM PASSWORD SECTION ---
//                 const Text(
//                   "Confirm Password",
//                   style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF1E232C),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 AuthTextField(
//                   controller: confirmPassCtrl,
//                   hint: "Confirm password",
//                   hintStyle: const TextStyle(color: faintLightBlue),
//                   obscureText: !_isConfirmPassVisible, // Hides text by default
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isConfirmPassVisible
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                       color: faintLightBlue,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _isConfirmPassVisible = !_isConfirmPassVisible;
//                       });
//                     },
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // --- ACTION BUTTON ---
//                 PrimaryButton(
//                   title: "Continue",
//                   onTap: () {
//                     // Logic to save password goes here
//                     if (newPassCtrl.text == confirmPassCtrl.text) {
//                       print("Passwords match. Saving...");
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                             content: Text("Passwords do not match!")),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../home_screen.dart'; // Import to navigate back to Home after success

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

    // 1. Check for empty fields
    if (newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields")),
      );
      return;
    }

    // 2. Check if passwords match
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 3. Success Logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password set successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to Dashboard (as a logged-in user)
    // We pass isNewUser: false so the popup doesn't show again
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const HomeScreen(isNewUser: false)),
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // SafeArea ensures it doesn't overlap with the notch/status bar
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
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

                // New Password Label
                const Text(
                  "New Password",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E232C),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // New Password Field
                _buildPasswordField(
                  controller: _newPassController,
                  hint: "New password",
                  isVisible: _isNewPassVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isNewPassVisible = !_isNewPassVisible;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Confirm Password Label
                const Text(
                  "Confirm Password",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E232C),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Confirm Password Field
                _buildPasswordField(
                  controller: _confirmPassController,
                  hint: "Confirm password",
                  isVisible: _isConfirmPassVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isConfirmPassVisible = !_isConfirmPassVisible;
                    });
                  },
                ),

                const SizedBox(height: 40),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _validateAndSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E64D0), // Match Blue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget for Password Fields to keep code clean
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF90CAF9)), // Light blue hint
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E64D0)), // Blue border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E64D0), width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF90CAF9),
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}
