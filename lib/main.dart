import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes.dart';
import 'package:construction_erp/controllers/auth/auth_controller.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/widgets/common/error/no_internet_widget.dart';
import 'package:construction_erp/core/services/app_colors.dart';

void main() async {
  // 1. Ensure bindings are initialized first
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2. PRESERVE the Native Splash Screen
  // This tells the native OS: "Don't remove the splash image yet, I'm busy."
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 3. Create a temporary Riverpod Container
  // We need this to read providers before the widget tree (ProviderScope) exists.
  final container = ProviderContainer();

  try {
    // 4. Await the Auth Check
    // We read the .future of the provider to wait for the build() method to finish.
    // This will check SecureStorage and SQLite.
    final user = await container.read(authControllerProvider.future);

    // 5. Determine the start screen based on the result
    String initialRoute = AppRoutes.login;

    if (user != null) {
      // User is logged in, now check role
      if (user.userType == UserType.superAdmin) {
        initialRoute = AppRoutes.superAdmin;
      } else {
        initialRoute = AppRoutes.home;
      }
    }

    // 6. Run App with the pre-calculated state
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: MyApp(initialRoute: initialRoute),
      ),
    );
  } catch (e) {
    // Fallback in case of DB error: Go to Login
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(initialRoute: AppRoutes.login),
      ),
    );
  }

  // 7. REMOVE the Native Splash Screen
  // Now that the app is ready and the correct route is set, we lift the curtain.
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Construction ERP',
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.lexendTextTheme(Theme.of(context).textTheme),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primaryBlue, // The spinner color
    refreshBackgroundColor: Colors.white, // The background circle color
  ),
      ),
      routes: AppRoutes.routes,
      // --- ADD THIS BUILDER ---
      builder: (context, child) {
        return StreamBuilder<List<ConnectivityResult>>(
          stream: Connectivity().onConnectivityChanged,
          builder: (context, snapshot) {
            final connectivityResult = snapshot.data;

            // If we have data and it contains 'none', show the prompt
            if (connectivityResult != null &&
                connectivityResult.contains(ConnectivityResult.none)) {
              return NoInternetWidget(child: child!);
            }

            // Otherwise, show the app normally (child is the current route)
            return child!;
          },
        );
      },
    );
  }
}
