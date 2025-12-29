import 'package:flutter/material.dart';
import '../home_screen.dart';

class SetPasswordScreen extends StatelessWidget {
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Set Password", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "New Password")),
            TextField(controller: confirmCtrl, decoration: const InputDecoration(labelText: "Confirm Password")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
              },
              child: const Text("Continue"),
            )
          ],
        ),
      ),
    );
  }
}
