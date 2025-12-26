import 'package:construction_erp/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Construction ERP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 10, 110, 209),
          primary: const Color.fromARGB(255, 10, 110, 209),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.lexendTextTheme(
          Theme.of(context)
              .textTheme, // Pass existing theme to inherit defaults
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // 1. The Color (Approximated from your image)
            backgroundColor: const Color.fromARGB(255, 10, 110, 209),
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 10, 110, 209),
          primary: const Color.fromARGB(255, 10, 110, 209),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
