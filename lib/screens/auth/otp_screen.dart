// import 'package:flutter/material.dart';
// import '../../widgets/auth_textfield.dart';
// import '../../widgets/primary_button.dart';

// class OtpScreen extends StatefulWidget {
//   const OtpScreen({super.key});

//   @override
//   State<OtpScreen> createState() => _OtpScreenState();
// }

// class _OtpScreenState extends State<OtpScreen> {
//   final phoneCtrl = TextEditingController();
//   final otpCtrl = TextEditingController();

//   bool _isPhoneVisible = true;
//   bool _isOtpVisible = false;
//   bool _otpSent = false;

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
//         // CENTER FIX: extendBody + Center + SingleChildScrollView with physics
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 22),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // --- SUCCESS BANNER ---
//                 if (_otpSent) ...[
//                   Center(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 16, horizontal: 24),
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 15,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           const Text(
//                             "OTP Sent",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Color(0xFF00BFA5),
//                             ),
//                             child: const Icon(Icons.check,
//                                 color: Colors.white, size: 20),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//                 ] else ...[
//                   const SizedBox(height: 20),
//                 ],

//                 // --- HEADER ---
//                 const Center(
//                   child: Text(
//                     "Sign In",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1E232C),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 // --- PHONE FIELD ---
//                 const Text(
//                   "Phone Number",
//                   style: TextStyle(
//                       fontWeight: FontWeight.w500, color: Color(0xFF1E232C)),
//                 ),
//                 const SizedBox(height: 8),
//                 AuthTextField(
//                   controller: phoneCtrl,
//                   keyboardType: TextInputType.phone, // KEYBOARD FIX
//                   hint: _otpSent ? "XXXXX XXXXX" : "Enter phone number",
//                   hintStyle: TextStyle(
//                       color: _otpSent ? Colors.black87 : faintLightBlue),
//                   obscureText: !_isPhoneVisible,
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isPhoneVisible ? Icons.visibility : Icons.visibility_off,
//                       color: faintLightBlue,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _isPhoneVisible = !_isPhoneVisible;
//                       });
//                     },
//                   ),
//                 ),

//                 // --- OTP FIELD ---
//                 if (_otpSent) ...[
//                   const SizedBox(height: 20),
//                   const Text(
//                     "OTP",
//                     style: TextStyle(
//                         fontWeight: FontWeight.w500, color: Color(0xFF1E232C)),
//                   ),
//                   const SizedBox(height: 8),
//                   AuthTextField(
//                     controller: otpCtrl,
//                     keyboardType: TextInputType.number, // KEYBOARD FIX
//                     hint: "Enter OTP code",
//                     hintStyle: const TextStyle(color: faintLightBlue),
//                     obscureText: !_isOtpVisible,
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _isOtpVisible ? Icons.visibility : Icons.visibility_off,
//                         color: faintLightBlue,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isOtpVisible = !_isOtpVisible;
//                         });
//                       },
//                     ),
//                   ),
//                 ],

//                 const SizedBox(height: 30),

//                 // --- BUTTON ---
//                 PrimaryButton(
//                   title: _otpSent ? "Continue" : "Send OTP",
//                   onTap: () {
//                     if (!_otpSent) {
//                       setState(() {
//                         _otpSent = true;
//                         // Don't clear controller if you want to keep the number for logic
//                         // phoneCtrl.text = "XXXXX XXXXX";
//                       });
//                     } else {
//                       print("Verifying OTP: ${otpCtrl.text}");
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
import 'package:construction_erp/widgets/auth_textfield.dart';
import 'package:construction_erp/widgets/primary_button.dart';
import '../../widgets/auth_textfield.dart';
import '../../widgets/primary_button.dart';
import '../home_screen.dart'; // <--- 1. Import HomeScreen

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final phoneCtrl = TextEditingController();
  final otpCtrl = TextEditingController();

  bool _isPhoneVisible = true;
  bool _isOtpVisible = false;
  bool _otpSent = false;

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
                // --- SUCCESS BANNER ---
                if (_otpSent) ...[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "OTP Sent",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF00BFA5),
                            ),
                            child: const Icon(Icons.check,
                                color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ] else ...[
                  const SizedBox(height: 20),
                ],

                // --- HEADER ---
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
                  "Phone Number",
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Color(0xFF1E232C)),
                ),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  hint: _otpSent ? "XXXXX XXXXX" : "Enter phone number",
                  hintStyle: TextStyle(
                      color: _otpSent ? Colors.black87 : faintLightBlue),
                  obscureText: !_isPhoneVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPhoneVisible ? Icons.visibility : Icons.visibility_off,
                      color: faintLightBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPhoneVisible = !_isPhoneVisible;
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
                  onTap: () {
                    if (!_otpSent) {
                      setState(() {
                        _otpSent = true;
                      });
                    } else {
                      // <--- 2. Navigate to Dashboard (HomeScreen)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
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
