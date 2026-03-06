import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:intl/intl.dart';

class PayrollDetailsScreen extends StatefulWidget {
  const PayrollDetailsScreen({super.key});

  @override
  State<PayrollDetailsScreen> createState() => _PayrollDetailsScreenState();
}

class _PayrollDetailsScreenState extends State<PayrollDetailsScreen> {
  // ✅ State variables for selection logic
  DateTime _selectedDate = DateTime.now();
  String _selectedWeek = "Week 1";

  // ✅ Expanded Year Picker Logic
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      // Fixed: Showing a wider range of years
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode:
          DatePickerMode.year, // Opens directly to year selection
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
              onPressed: () {},
            )
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  indicatorPadding: const EdgeInsets.all(4),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 3,
                          offset: const Offset(0, 1))
                    ],
                  ),
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: Colors.grey.shade500,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(text: "Daily"),
                    Tab(text: "Weekly"),
                    Tab(text: "Monthly"),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTabContent('Daily'),
                  _buildTabContent('Weekly'),
                  _buildTabContent('Monthly'),
                ],
              ),
            ),
            _buildBottomTotalBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String type) {
    return Column(
      children: [
        _buildFilters(type),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 7,
            itemBuilder: (context, index) {
              String label = "";
              if (type == 'Daily') {
                label = DateFormat('dd MMM yyyy')
                    .format(_selectedDate.subtract(Duration(days: index)));
              } else if (type == 'Weekly') {
                // ✅ Reflecting the selected week and month in the list
                label =
                    "${DateFormat('MMM yyyy').format(_selectedDate)} - $_selectedWeek";
              } else {
                label = DateFormat('MMM yyyy').format(_selectedDate);
              }
              return _buildPayrollCard(label, "₹21,600");
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(String type) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
      child: Row(
        children: [
          // ✅ Functional Month/Year Selector
          GestureDetector(
            onTap: () => _selectDate(context),
            child: _buildFilterChip(
                type == 'Daily'
                    ? DateFormat('MM/dd/yyyy').format(_selectedDate)
                    : DateFormat('MM/yyyy').format(_selectedDate),
                icon: type == 'Daily'
                    ? Icons.calendar_today_outlined
                    : Icons.keyboard_arrow_down),
          ),

          // ✅ Functional Week Selector Dropdown
          if (type == 'Weekly') ...[
            const SizedBox(width: 12),
            PopupMenuButton<String>(
              onSelected: (String value) {
                setState(() => _selectedWeek = value);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                    value: 'Week 1', child: Text('Week 1')),
                const PopupMenuItem<String>(
                    value: 'Week 2', child: Text('Week 2')),
                const PopupMenuItem<String>(
                    value: 'Week 3', child: Text('Week 3')),
                const PopupMenuItem<String>(
                    value: 'Week 4', child: Text('Week 4')),
              ],
              child: _buildFilterChip(_selectedWeek,
                  icon: Icons.keyboard_arrow_down),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String text, {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(width: 8),
          Icon(icon, size: 14, color: AppColors.primaryBlue),
        ],
      ),
    );
  }

  Widget _buildPayrollCard(String date, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
          Text(amount,
              style: const TextStyle(
                  fontSize: 16,
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
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total Payroll:",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text("₹1,21,600",
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue)),
          ],
        ),
      ),
    );
  }
}
