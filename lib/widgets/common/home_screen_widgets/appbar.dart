import 'package:construction_erp/core/services/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

AppBar buildHomeScreenAppBar() {
  return AppBar(
    backgroundColor: AppColors.primaryBlue,
    elevation: 0,
    centerTitle: true,
    title: const Text(
      "All Tasks",
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    automaticallyImplyLeading: false,
    // ✅ Fixed: placed inside the AppBar constructor
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );
}
