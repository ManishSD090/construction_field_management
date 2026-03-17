import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/screens/payroll/payroll_settings.dart';
import 'package:construction_erp/controllers/payroll/payroll_controller.dart';

class PayrollDetailsScreen extends ConsumerStatefulWidget {
  const PayrollDetailsScreen({super.key});

  @override
  ConsumerState<PayrollDetailsScreen> createState() =>
      _PayrollDetailsScreenState();
}

class _PayrollDetailsScreenState extends ConsumerState<PayrollDetailsScreen> {
  String _selectedTab = 'Daily';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  Map<String, dynamic>? _rawPayrollData;
  List<Map<String, dynamic>> _groupedData = [];
  double _grandTotal = 0;

  final String _projectId = "ca0ee39d-f2e9-46d2-8cec-d3a8bb44b755";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPayroll();
    });
  }

  // 🚨 FETCH UPDATE: We now fetch a full 1 Year of history leading up to the selected date
  // so you can see all old records seamlessly.
  Future<void> _fetchPayroll() async {
    setState(() => _isLoading = true);
    try {
      // 🚨 FIX: Fetch the whole month instead of just 24 hours
      // This ensures the Weekly and Monthly tabs have data to display
      DateTime start = DateTime(_selectedDate.year, _selectedDate.month, 1);
      DateTime end =
          DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);

      final data = await ref.read(payrollControllerProvider).calculatePayroll(
            periodFrom: start,
            periodTo: end,
            projectId: _projectId,
          );

      setState(() {
        _rawPayrollData = data;
        _processData();
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _processBackendData(List<dynamic> workers) {
    // Grouping workers into the Daily/Weekly/Monthly list format
    // This fills your _groupedData list
  }

  void _processData() {
    if (_rawPayrollData == null || _rawPayrollData!['workers'] == null) return;

    final workers = _rawPayrollData!['workers'] as List<dynamic>;
    Map<DateTime, double> tempGroups = {};
    double totalAmount = 0;

    for (var worker in workers) {
      final attendances = worker['attendances'] as List<dynamic>? ?? [];

      for (var att in attendances) {
        // 🚨 FIX 1: Extract the ACTUAL date of the attendance, not today's date
        DateTime recordDate = DateTime.parse(att['date']).toLocal();

        // Normalize to midnight to group correctly
        DateTime dayOnly =
            DateTime(recordDate.year, recordDate.month, recordDate.day);

        // Use totalPayable from the DB record
        double amount = (att['totalPayable'] ?? 0).toDouble();

        if (_selectedTab == 'Daily') {
          tempGroups[dayOnly] = (tempGroups[dayOnly] ?? 0) + amount;
        } else if (_selectedTab == 'Weekly') {
          DateTime weekMonday =
              dayOnly.subtract(Duration(days: dayOnly.weekday - 1));
          tempGroups[weekMonday] = (tempGroups[weekMonday] ?? 0) + amount;
        } else {
          DateTime monthStart = DateTime(dayOnly.year, dayOnly.month, 1);
          tempGroups[monthStart] = (tempGroups[monthStart] ?? 0) + amount;
        }
        totalAmount += amount;
      }
    }

    var sortedDates = tempGroups.keys.toList()..sort((a, b) => b.compareTo(a));

    setState(() {
      _grandTotal = totalAmount;
      _groupedData = sortedDates.map((date) {
        String title;
        if (_selectedTab == 'Daily') {
          title = DateFormat('dd MMM yyyy').format(date).toUpperCase();
        } else if (_selectedTab == 'Weekly') {
          title = "WEEK OF ${DateFormat('dd MMM').format(date).toUpperCase()}";
        } else {
          title = DateFormat('MMM yyyy').format(date).toUpperCase();
        }
        return {'title': title, 'amount': tempGroups[date]};
      }).toList();
    });
  }

  String _formatCurrency(double amount) {
    final format =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return format.format(amount);
  }

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
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PayrollSettingsScreen()))
                  .then((_) => _fetchPayroll());
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
            _buildFilterRow(),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPayrollListView(),
            ),
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
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: ['Daily', 'Weekly', 'Monthly'].map((period) {
          bool isSelected = _selectedTab == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = period;
                });
                _processData(); // Recalculate groups immediately without refetching
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4)
                        ]
                      : [],
                ),
                child: Text(period,
                    style: TextStyle(
                        color: isSelected ? AppColors.primaryBlue : Colors.grey,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterRow() {
    String displayText = DateFormat('MMM yyyy').format(_selectedDate);

    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
          _fetchPayroll(); // Refetch a new 1-year block based on the new end-date
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade100),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(displayText,
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollListView() {
    if (_groupedData.isEmpty) {
      return Center(
        child: Text(
          "No payroll data found for this period.",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        ),
      );
    }

    return ListView.separated(
      itemCount: _groupedData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _groupedData[index];
        final title = item['title'];
        final amount = item['amount'];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87)),
              Text(_formatCurrency(amount),
                  style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
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
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          Text("₹1,21,600",
              style: TextStyle(
                  fontSize: 20,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
