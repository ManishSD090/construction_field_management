import 'package:flutter/material.dart';
import '../../widgets/auth_input_field.dart';
import '../../widgets/auth_primary_button.dart';
import '../../services/auth_storage.dart';
import '../home_screen.dart';

class SetPasswordScreen extends StatefulWidget {
  final String phone;
  const SetPasswordScreen({super.key, required this.phone});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final password = passCtrl.text.trim();
    final confirm = confirmCtrl.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      _showError("Password cannot be empty");
      return;
    }

    if (password != confirm) {
      _showError("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    await AuthStorage.saveUser(widget.phone, password);

    if (!mounted) return;

    setState(() => isLoading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthInputField(
              label: "New Password",
              hint: "Enter new password",
              controller: passCtrl,
              obscure: true,
            ),
            const SizedBox(height: 16),
            AuthInputField(
              label: "Confirm Password",
              hint: "Re-enter password",
              controller: confirmCtrl,
              obscure: true,
            ),
            const SizedBox(height: 24),
            AuthPrimaryButton(
              text: "Continue",
              isLoading: isLoading,
              onTap: save,
            ),
          ],
        ),
      ),
    );
  }
}
