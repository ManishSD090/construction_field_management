import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/screens/attendance/payroll_settings_screen.dart';

class PayrollDetailsScreen extends StatefulWidget {
  const PayrollDetailsScreen({super.key});

  @override
  State<PayrollDetailsScreen> createState() => _PayrollDetailsScreenState();
}

class _PayrollDetailsScreenState extends State<PayrollDetailsScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedWeek = "Week 1";

  // Date Picker Logic
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          centerTitle: true,
          title: const Text("Payroll Details",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined,
                  color: Colors.white, size: 22),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PayrollSettingsScreen()),
                );
              },
            )
          ],
        ),
        body: Column(
          children: [
            // --- CUSTOM TAB BAR (Segmented Control Style) ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Container(
                height: 45,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F8), // Light grey track background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Colors.white, // White floating indicator
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  labelColor: AppColors.primaryBlue,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelColor: Colors.grey.shade600,
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "Daily"),
                    Tab(text: "Weekly"),
                    Tab(text: "Monthly"),
                  ],
                ),
              ),
            ),

            // --- TAB CONTENT ---
            Expanded(
              child: TabBarView(
                children: [
                  _buildTabContent('Daily'),
                  _buildTabContent('Weekly'),
                  _buildTabContent('Monthly'),
                ],
              ),
            ),

            // --- BOTTOM TOTAL BAR ---
            _buildBottomTotalBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- FILTER ROW ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              _buildDateFilterButton(type),
              if (type == 'Weekly') ...[
                const SizedBox(width: 12),
                _buildWeekFilterButton(),
              ]
            ],
          ),
        ),

        // --- LIST ---
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: 7,
            itemBuilder: (context, index) {
              // Logic to simulate list dates based on tab type
              String label = "";
              if (type == 'Daily') {
                label = DateFormat('dd MMM yyyy').format(_selectedDate.subtract(Duration(days: index)));
              } else if (type == 'Weekly') {
                label = "${DateFormat('MMM yyyy').format(_selectedDate)} - Week ${4 - (index % 4)}";
              } else {
                // Monthly view usually shows months
                DateTime monthDate = DateTime(_selectedDate.year, _selectedDate.month - index);
                label = DateFormat('MMM yyyy').format(monthDate);
              }
              
              return _buildPayrollCard(label, "₹21,600");
            },
          ),
        ),
      ],
    );
  }

  // Styled Date Filter Button (03/2026 v)
  Widget _buildDateFilterButton(String type) {
    String text;
    if (type == 'Daily') {
      text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    } else {
      text = DateFormat('MM/yyyy').format(_selectedDate);
    }

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text, 
              style: TextStyle(
                color: Colors.grey.shade700, 
                fontWeight: FontWeight.w600,
                fontSize: 14
              )
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.primaryBlue)
          ],
        ),
      ),
    );
  }

  // Styled Week Filter Button
  Widget _buildWeekFilterButton() {
    return PopupMenuButton<String>(
      onSelected: (val) => setState(() => _selectedWeek = val),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Week 1', child: Text('Week 1')),
        const PopupMenuItem(value: 'Week 2', child: Text('Week 2')),
        const PopupMenuItem(value: 'Week 3', child: Text('Week 3')),
        const PopupMenuItem(value: 'Week 4', child: Text('Week 4')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedWeek, 
              style: TextStyle(
                color: Colors.grey.shade700, 
                fontWeight: FontWeight.w600,
                fontSize: 14
              )
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.primaryBlue)
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollCard(String date, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
          Text(amount,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildBottomTotalBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ]
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total Payroll:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text("₹1,21,600",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue)),
          ],
        ),
      ),
    );
  }
}