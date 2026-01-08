import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextStyle? hintStyle;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  // 1. Add new properties for keyboard actions
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const AuthTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.hintStyle,
    this.keyboardType,
    this.validator,
    this.textInputAction, // 2. Add to constructor
    this.onFieldSubmitted, // 2. Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,

      // 3. Connect properties to TextFormField
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: hintStyle ?? const TextStyle(color: Colors.grey),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0A6ED1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Color(0xFF0A6ED1)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
