import 'package:flutter/material.dart';
import 'site_engineer/site_engineer_layout.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SiteEngineerLayout();
  }
}
