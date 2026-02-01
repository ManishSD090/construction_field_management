import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/auth/auth_controller.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  // NEW: Add the route parameter here
  final String? onSuccessRoute;

  const ChangePasswordScreen({
    super.key,
    this.onSuccessRoute, // NEW: Include in constructor
  });

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  // Logic State
  int _currentStep = 0; // 0 = Old Password, 1 = New Password
  bool _isLoading = false;

  // Controllers
  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // Visibility Toggles
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Form Keys (One for each step to validate independently)
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // LOGIC
  // -------------------------------------------------------------------------

  void _handleBack() {
    if (_currentStep == 1) {
      // If on step 2, go back to step 1
      setState(() => _currentStep = 0);
    } else {
      // If on step 1, close the screen
      Navigator.pop(context);
    }
  }

  void _handleContinue() async {
    if (_currentStep == 0) {
      // Validate Step 1
      if (_step1Key.currentState!.validate()) {
        setState(() => _currentStep = 1);
      }
    } else {
      // Validate Step 2 & Submit
      if (_step2Key.currentState!.validate()) {
        await _submitChangePassword();
      }
    }
  }

  Future<void> _submitChangePassword() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).changePassword(
            currentPassword: _oldPassController.text.trim(),
            newPassword: _newPassController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password changed successfully"),
            backgroundColor: Colors.green,
          ),
        );

        // NEW: Check if a route was provided
        if (widget.onSuccessRoute != null &&
            widget.onSuccessRoute!.isNotEmpty) {
          // Navigate to the success route (replacing the current screen)
          Navigator.of(context).pushReplacementNamed(widget.onSuccessRoute!);
        } else {
          // Default behavior: close screen
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception:", "").trim()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // -------------------------------------------------------------------------
  // UI BUILDER
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Intercept hardware back button to handle step navigation
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: _handleBack,
          ),
          title: const Text(
            'Edit Profile',
            style:
                TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                "Change Password",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 40),

              // ANIMATED CONTENT AREA
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  // Custom transition to make it slide like a new page
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(1.0, 0.0), // Slide in from right
                      end: Offset.zero,
                    ).animate(animation);

                    // Combine Slide with Fade for smoothness
                    return SlideTransition(
                      position: offsetAnimation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: _currentStep == 0 ? _buildStepOne() : _buildStepTwo(),
                ),
              ),

              // BOTTOM BUTTON (Shared position)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Continue",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // STEP 1 VIEW
  // -------------------------------------------------------------------------
  Widget _buildStepOne() {
    return Form(
      key: _step1Key,
      child: Column(
        key: const ValueKey(0), // Key is vital for AnimatedSwitcher
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Enter your old Password",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          _buildPasswordField(
            controller: _oldPassController,
            obscureText: _obscureOld,
            hint: "Enter password",
            onToggle: () => setState(() => _obscureOld = !_obscureOld),
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Enter current password' : null,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // STEP 2 VIEW
  // -------------------------------------------------------------------------
  Widget _buildStepTwo() {
    return Form(
      key: _step2Key,
      child: Column(
        key: const ValueKey(1), // Key is vital for AnimatedSwitcher
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("New Password"),
          const SizedBox(height: 8),
          _buildPasswordField(
            controller: _newPassController,
            obscureText: _obscureNew,
            hint: "New password",
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
            validator: (val) => (val == null || val.length < 6)
                ? "Password must be at least 6 characters"
                : null,
          ),
          const SizedBox(height: 20),
          _buildLabel("Confirm Password"),
          const SizedBox(height: 8),
          _buildPasswordField(
            controller: _confirmPassController,
            obscureText: _obscureConfirm,
            hint: "Confirm password",
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            validator: (val) => (val != _newPassController.text)
                ? "Passwords do not match"
                : null,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // HELPERS
  // -------------------------------------------------------------------------

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required String hint,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.iconBlueLight),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.primaryBlue.withOpacity(0.5),
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
