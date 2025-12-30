// import 'package:flutter/material.dart';
// import '../../widgets/auth_textfield.dart'; // Ensure this widget is updated
// import '../../widgets/primary_button.dart';
// import 'otp_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final phoneCtrl = TextEditingController();
//   final passCtrl = TextEditingController();

//   // State to manage visibility of text fields
//   bool _isPhoneVisible = false;
//   bool _isPasswordVisible = false;

//   @override
//   void dispose() {
//     phoneCtrl.dispose();
//     passCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Define the faint light blue color from the UI design
//     const faintLightBlue = Color(0xFF90CAF9);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         // 4. Center the entire UI component
//         child: Center(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 22),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center, // Vertically center
//                 crossAxisAlignment: CrossAxisAlignment.start, // Keep labels left-aligned
//                 children: [
//                   // Header Section (Centered)
//                   const Center(
//                     child: const Column(
//                       children: const [
//                         Text(
//                           "Welcome back !",
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF1E232C),
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           "Sign In",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w500,
//                             color: Color(0xFF1E232C),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 40),

//                   // Phone/Email Section
//                   const Text(
//                     "Phone Number/ Email",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF1E232C),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   AuthTextField(
//                     controller: phoneCtrl,
//                     hint: "Enter phone number/Email",
//                     // 2. Change placeholder color
//                     hintStyle: const TextStyle(color: faintLightBlue),
//                     // 1. Add eye button and toggle visibility
//                     obscureText: !_isPhoneVisible,
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _isPhoneVisible
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                         color: faintLightBlue,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isPhoneVisible = !_isPhoneVisible;
//                         });
//                       },
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Password Section
//                   const Text(
//                     "Password",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF1E232C),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   AuthTextField(
//                     controller: passCtrl,
//                     hint: "Enter password",
//                     // 2. Change placeholder color
//                     hintStyle: const TextStyle(color: faintLightBlue),
//                     // 1. Add eye button and toggle visibility
//                     obscureText: !_isPasswordVisible,
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _isPasswordVisible
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                         color: faintLightBlue,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isPasswordVisible = !_isPasswordVisible;
//                         });
//                       },
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   // Main Action Button
//                   PrimaryButton(
//                     title: "Continue",
//                     onTap: () {
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (_) => OtpScreen()));
//                     },
//                   ),

//                   const SizedBox(height: 20),

//                   // OTP Login Link (Centered)
//                   Center(
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.push(context,
//                             MaterialPageRoute(builder: (_) => OtpScreen()));
//                       },
//                       child: const Text(
//                         "Log in with OTP",
//                         style: TextStyle(
//                           color: Color(0xFF1E88E5),
//                           fontWeight: FontWeight.bold,
//                           decoration: TextDecoration.underline,
//                           decorationColor: Color(0xFF1E88E5),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../widgets/auth_textfield.dart';
import '../../widgets/primary_button.dart';
import 'otp_screen.dart';
import '../home_screen.dart'; // <--- 1. Import your HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool _isPhoneVisible = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    phoneCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const faintLightBlue = Color(0xFF90CAF9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
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
                            color: Color(0xFF1E232C),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E232C),
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
                      color: Color(0xFF1E232C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: phoneCtrl,
                    hint: "Enter phone number/Email",
                    hintStyle: const TextStyle(color: faintLightBlue),
                    obscureText:
                        !_isPhoneVisible, // Usually false for email/phone, but kept as per your code
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPhoneVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: faintLightBlue,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPhoneVisible = !_isPhoneVisible;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Password",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E232C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: passCtrl,
                    hint: "Enter password",
                    hintStyle: const TextStyle(color: faintLightBlue),
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: faintLightBlue,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Main Action Button
                  PrimaryButton(
                    title: "Continue",
                    onTap: () {
                      // <--- 2. UPDATED NAVIGATION LOGIC
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const OtpScreen()));
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
    );
  }
}
