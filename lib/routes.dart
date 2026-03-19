import 'package:flutter/material.dart';

// Models
import 'package:construction_erp/models/company.dart';
import 'package:construction_erp/models/dpr.dart';

// Auth Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/set_pass_screen.dart';
import 'package:construction_erp/screens/auth/change_pass_screen.dart';
import 'package:construction_erp/screens/auth/verification_screen.dart';

// Layout
import 'screens/main_layout.dart';

// Super Admin Screens
import 'screens/super_admin/super_admin_layout.dart';
import 'package:construction_erp/screens/super_admin/create_company.dart';
import 'package:construction_erp/screens/super_admin/update_company.dart';
import 'package:construction_erp/screens/super_admin/company_details.dart';
import 'package:construction_erp/screens/super_admin/update_profile.dart';

// Project Screens
import 'package:construction_erp/screens/projects/create_project_screen.dart';
import 'package:construction_erp/screens/projects/project_details_screen.dart';

// DPR Screens
import 'package:construction_erp/screens/dpr/create_dpr_screen.dart';
import 'package:construction_erp/screens/dpr/dpr_details.dart';

class AppRoutes {
  // --- AUTH ---
  static const String login = '/';
  static const String otp = '/otp';
  static const String setPassword = '/setPassword';
  static const String changePassword = '/changePassword';
  static const String verification = '/verification';

  // --- HOME ---
  static const String home = '/home';

  // --- SUPER ADMIN ---
  static const String superAdmin = '/superAdmin';
  static const String createCompany = '/createCompany';
  static const String updateCompany = '/updateCompany';
  static const String companyDetails = '/companyDetails';
  static const String updateSuperAdminProfile = '/updateSuperAdminProfile';

  // --- PROJECT ---
  static const String createProject = '/createProject';
  static const String projectDetails = '/projectDetails';

  // --- DPR ---
  static const String createDPR = '/createDPR';
  static const String dprDetails = '/dprDetails';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),

    otp: (context) => const OtpScreen(),

    setPassword: (context) => const SetPasswordScreen(),

    changePassword: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final String? route = args is String ? args : null;
      return ChangePasswordScreen(onSuccessRoute: route);
    },

    verification: (context) => const VerificationScreen(),

    home: (context) => const MainLayoutScreen(),

    // Super Admin
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

    updateSuperAdminProfile: (context) => const UpdateProfileScreen(),

    // Projects
    createProject: (context) => const CreateProjectScreen(),

    projectDetails: (context) => const ProjectDetailsScreen(),

    // DPR
    createDPR: (context) =>
    CreateDPRScreen(scrollController: ScrollController(), projectId: ''),
    dprDetails: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as DailyProgressReport;
      return DPRDetailsScreen(dpr: args);
    },
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

class SuperAdminArguments {
  final String tab;
  SuperAdminArguments({required this.tab});

  static const dashboard = 'dashboard';
  static const companies = 'companies';
  static const profile = 'profile';
}