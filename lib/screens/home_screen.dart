import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Welcome User'),
        backgroundColor:
            Theme.of(context).colorScheme.primary, // Construction orange
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Home Screen')),
    );
  }
}
