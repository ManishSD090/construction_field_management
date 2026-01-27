import 'package:flutter/material.dart';

// Import your models
import 'package:construction_erp/models/company.dart';

// --- IMPORTS: Import all your screens here ---
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/set_pass_screen.dart';
import 'screens/main_layout.dart';
import 'screens/super_admin/super_admin_layout.dart';
import 'package:construction_erp/screens/auth/verification_screen.dart';
import 'package:construction_erp/screens/super_admin/create_company.dart';
import 'package:construction_erp/screens/super_admin/update_company.dart';
import 'package:construction_erp/screens/super_admin/company_details.dart';
import 'package:construction_erp/screens/projects/create_project_screen.dart';
import 'package:construction_erp/screens/projects/project_details_screen.dart';

class AppRoutes {
  // --- CONSTANTS: Define your route names ---
  static const String login = '/';
  static const String otp = '/otp';
  static const String setPassword = '/setPassword';
  static const String verification = '/verification';
  static const String home = '/home';

  // Super Admin Routes
  static const String superAdmin = '/superAdmin';
  static const String createCompany = '/createCompany';
  static const String updateCompany = '/updateCompany';
  static const String companyDetails = '/companyDetails';

  // Projects Routes
  static const String createProject = '/createProject';
  static const String projectDetails = '/projectDetails';

  // --- ROUTE MAP: Define the map ---
  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    otp: (context) => const OtpScreen(),
    setPassword: (context) => const SetPasswordScreen(),
    verification: (context) => const VerificationScreen(),
    home: (context) => const MainLayoutScreen(),
    superAdmin: (context) => const SuperAdminLayout(),
    createCompany: (context) => const CreateCompanyScreen(),
    updateCompany: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return UpdateCompanyScreen(companyData: args);
    },
    companyDetails: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Company;
      return CompanyDetailsScreen(company: args);
    },
    createProject: (context) => const CreateProjectScreen(),
    projectDetails: (context) => const ProjectDetailsScreen(),
  };
}

class HomeArguments {
  final String tab;
  HomeArguments({required this.tab});

  static const dashboard = 'dashboard';
  static const project = 'project';
  static const task = 'task';
  static const operation = 'operation';
  static const profile = 'profile';
}
