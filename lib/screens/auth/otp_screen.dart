import 'package:flutter/material.dart';
import 'set_password_screen.dart';

class OtpScreen extends StatelessWidget {
  final otpCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Enter OTP sent to your phone"),
            TextField(controller: otpCtrl, decoration: const InputDecoration(labelText: "OTP")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (otpCtrl.text == "1234") {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SetPasswordScreen()));
                }
              },
              child: const Text("Continue"),
            )
          ],
        ),
      ),
    );
  }
}
