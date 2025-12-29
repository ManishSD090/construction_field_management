import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscureText; // Controls visibility (dots vs text)
  final Widget? suffixIcon; // The eye icon widget
  final TextStyle? hintStyle; // Color of the placeholder text
  final bool isPassword; // Legacy param (optional)

  const AuthTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.hintStyle,
    this.isPassword = false, 
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText, 
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: hintStyle ?? const TextStyle(color: Colors.grey),
        suffixIcon: suffixIcon,
        
        // Basic styling
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255), // Light grey background
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        
        // Borders
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
          borderSide: const BorderSide(color: Color(0xFF0A6ED1)), // Highlight color
        ),
      ),
    );
  }
}