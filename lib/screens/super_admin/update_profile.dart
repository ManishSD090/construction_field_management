import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Routes & Resources
import 'package:construction_erp/routes.dart';
import 'package:construction_erp/core/services/app_colors.dart';

// State Management
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/controllers/super_admin/super_admin_controller.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() =>
      _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-fill data from Auth State on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(authControllerProvider);
      if (userState.hasValue && userState.value != null) {
        final user = userState.value!;
        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email ?? '';
          _phoneController.text =
              user.phone; // Assuming model uses phoneNumber or phone
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);

    try {
      final payload = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      await ref
          .read(superAdminControllerProvider.notifier)
          .updateSuperAdminProfile(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully"),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception:", "").trim()),
            backgroundColor: AppColors.alertRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // UI BUILDER
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Watch current user for the ID display
    final currentUser = ref.watch(authControllerProvider).value;
    final userId = currentUser?.id ?? 'Unknown';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User ID Label (Top Right)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'User ID: ${userId.substring(0, 8)}',
                style: TextStyle(
                  color: AppColors.textDark.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name Field
            _buildLabel("Name"),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: "Enter your name",
            ),
            const SizedBox(height: 20),

            // Email Field
            _buildLabel("Email"),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hint: "Enter email",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Phone Field
            _buildLabel("Phone"),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _phoneController,
              hint: "Enter phone number",
              keyboardType: TextInputType.phone,
              // Note: If backend expects pure numbers, you might remove this prefix visually
              // or handle the concatenation logic in _handleSave.
              prefix: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Text(
                  "+91", // Visual prefix only
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100), // Spacing before buttons

            // Change Password Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.changePassword,
                    arguments: AppRoutes
                        .superAdmin, // Redirect to Dashboard on success
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Change password",
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
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
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Save personal info",
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),

      // Visual Bottom Bar (Same as design)
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AppColors.secondaryBlue,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.white,
          selectedIndex: 2, // 'Profile' is selected
          onDestinationSelected: (index) {
            // Since this is a standalone screen pushed on top of the layout,
            // we typically pop back to the main layout to switch tabs.
            if (index != 2) {
              Navigator.of(context).pop();
              // Note: To switch tabs on the underlying screen, you might need
              // to pass a callback or use a global provider for navigation index.
            }
          },
          height: 70,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.business_outlined),
              label: 'Companies',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: AppColors.primaryBlue),
              selectedIcon: Icon(Icons.person, color: AppColors.primaryBlue),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET HELPERS
  // ---------------------------------------------------------------------------

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    Widget? prefix,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          prefixIcon: prefix != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 16, top: 14, bottom: 14),
                  child: prefix,
                )
              : null,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textGrey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primaryBlue, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
