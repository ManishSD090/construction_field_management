import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/screens/payroll/payroll_settings.dart';

class PayrollListScreen extends StatefulWidget {
  const PayrollListScreen({super.key});

  @override
  State<PayrollListScreen> createState() => _PayrollListScreenState();
}

class _PayrollListScreenState extends State<PayrollListScreen> {
  String _selectedTab = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text("Payroll Details", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PayrollSettingsScreen(projectId: '',)));
            },
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodToggle(),
            const SizedBox(height: 20),
            _buildDatePicker(),
            const SizedBox(height: 20),
            Expanded(child: _buildPayrollListView()),
            const Divider(height: 30, color: Colors.grey),
            _buildTotalFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade100, 
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: ['Daily', 'Weekly', 'Monthly'].map((period) {
          bool isSelected = _selectedTab == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = period),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected 
                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] 
                      : [],
                ),
                child: Text(
                  period, 
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryBlue : Colors.grey, 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
                  )
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade100), 
        borderRadius: BorderRadius.circular(8)
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("03/11/2026", style: TextStyle(color: Colors.grey, fontSize: 13)),
          SizedBox(width: 8),
          Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primaryBlue),
        ],
      ),
    );
  }

  Widget _buildPayrollListView() {
    return ListView.separated(
      itemCount: 7, 
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        int day = 11 - index;
        String dayString = day < 10 ? "0$day" : "$day";
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$dayString Mar 2026", 
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
              const Text("₹21,600", 
                  style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalFooter() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Total Payroll:", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text("₹1,21,600", 
              style: TextStyle(fontSize: 20, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}