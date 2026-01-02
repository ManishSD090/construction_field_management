import 'package:flutter/material.dart';

// --- IMPORTS: Import all your screens here ---
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/set_pass_screen.dart';
import 'screens/dashboard_screen.dart';

class AppRoutes {
  // --- CONSTANTS: Define your route names ---
  static const String login = '/';
  static const String otp = '/otp';
  static const String setPassword = '/setPassword';
  static const String dashboard = '/dashboard';

  // --- ROUTE MAP: Define the map ---
  // Note: This must be 'static final', NOT 'static const'
  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    otp: (context) => const OtpScreen(),
    setPassword: (context) => const SetPasswordScreen(),
    dashboard: (context) => const DashboardScreen(),
  };
}
