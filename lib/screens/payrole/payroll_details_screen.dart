import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart'; // Ensure this import matches your project
import 'package:construction_erp/screens/payrole/payroll_settings_screen.dart';

class PayrollDetailsScreen extends StatefulWidget {
  const PayrollDetailsScreen({super.key});

  @override
  State<PayrollDetailsScreen> createState() => _PayrollDetailsScreenState();
}

class _PayrollDetailsScreenState extends State<PayrollDetailsScreen> {
  bool isWorkersSelected = true; // Toggle state for Workers/Staff
  String selectedFilter = 'Daily'; // Filter state: Daily, Weekly, Monthly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Payroll Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PayrollSettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          
          // 1. Workers / Staff Toggle
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF), // Light blue background
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _buildToggleButton("Workers", isWorkersSelected, () {
                  setState(() => isWorkersSelected = true);
                }),
                _buildToggleButton("Staff", !isWorkersSelected, () {
                  setState(() => isWorkersSelected = false);
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Filters (Daily, Weekly, Monthly)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFilterOption("Daily"),
              _buildFilterOption("Weekly"),
              _buildFilterOption("Monthly"),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Date Picker Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 150, // Fixed width as per screenshot
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryBlue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("MM/DD/YYYY", style: TextStyle(color: Colors.black54, fontSize: 13)),
                    Icon(Icons.calendar_today, color: AppColors.primaryBlue, size: 16),
                  ],
                ),
              ),
            ),
          ),
          
          const Spacer(),
          // Add list content here later
        ],
      ),
      // Shared Footer
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Highlight Project tab
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Project"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // Toggle Button Helper
  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Filter Option Helper (Daily/Weekly/Monthly)
  Widget _buildFilterOption(String text) {
    bool isSelected = selectedFilter == text;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppColors.primaryBlue : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}