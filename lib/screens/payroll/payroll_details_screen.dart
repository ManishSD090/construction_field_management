import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/screens/payroll/payroll_settings.dart';
import 'package:construction_erp/controllers/payroll/payroll_controller.dart';

class PayrollDetailsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const PayrollDetailsScreen({super.key, required this.projectId});

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
  int _fetchId = 0;

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
      final int currentFetchId = ++_fetchId;
      // Always fetch from Jan 1 to get full history for the year
      DateTime start = DateTime(_selectedDate.year, 1, 1);
      DateTime end;

      if (_selectedTab == 'Daily') {
        end = DateTime(_selectedDate.year, _selectedDate.month,
            _selectedDate.day, 23, 59, 59);
      } else if (_selectedTab == 'Monthly') {
        end = DateTime(
            _selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
      } else {
        // Weekly
        end = DateTime(
            _selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
      }

      final data = await ref.read(payrollControllerProvider).calculatePayroll(
            periodFrom: start,
            periodTo: end,
            projectId: widget.projectId,
          );

      if (currentFetchId != _fetchId) return;

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
    Map<String, double> tempGroups = {}; // Use String key for robust comparison
    double totalAmount = 0;

    // Pre-populate missing gaps
    if (_selectedTab == 'Daily') {
      DateTime current = DateTime(_selectedDate.year, 1, 1);
      DateTime endDate =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
        tempGroups[DateFormat('yyyy-MM-dd').format(current)] = 0.0;
        current = current.add(const Duration(days: 1));
      }
    } else if (_selectedTab == 'Weekly') {
      DateTime current = DateTime(_selectedDate.year, 1, 1);
      DateTime endDate =
          DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
        int weekNum = ((current.day - 1) / 7).floor() + 1;
        String key = "${DateFormat('yyyy-MM').format(current)}-$weekNum";
        tempGroups[key] = 0.0;
        current = current.add(const Duration(days: 1));
      }
    } else {
      DateTime current = DateTime(_selectedDate.year, 1, 1);
      DateTime endDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
        tempGroups[DateFormat('yyyy-MM-01').format(current)] = 0.0;
        current = DateTime(current.year, current.month + 1, 1);
      }
    }

    for (var worker in workers) {
      final attendances = worker['dailyBreakdown'] as List<dynamic>? ?? [];
      final wName = worker['workerName'] ?? worker['name'] ?? 'Unknown';
      debugPrint("Worker: $wName, records: ${attendances.length}");

      for (var att in attendances) {
        // Parse date-only string to avoid timezone shifts
        String dateStr = att['date'].toString().split('T')[0];
        DateTime recordDate = DateFormat('yyyy-MM-dd').parse(dateStr);
        
        double amount = (att['amount'] ?? 0).toDouble();
        String key;

        if (_selectedTab == 'Daily') {
          key = dateStr; // Already yyyy-MM-dd
        } else if (_selectedTab == 'Weekly') {
          int weekNum = ((recordDate.day - 1) / 7).floor() + 1;
          key = "${DateFormat('yyyy-MM').format(recordDate)}-$weekNum";
        } else {
          key = DateFormat('yyyy-MM-01').format(recordDate);
        }

        debugPrint("Match found: $key, amount: $amount");
        tempGroups[key] = (tempGroups[key] ?? 0) + amount;
        totalAmount += amount;
      }
    }

    var sortedKeys = tempGroups.keys.toList()..sort((a, b) => b.compareTo(a));

    // Calculate grand total from the grouped data to ensure perfection
    double finalTotal = 0;
    tempGroups.forEach((k, v) => finalTotal += v);

    setState(() {
      _grandTotal = finalTotal;
      _groupedData = sortedKeys.map((key) {
        String title;
        if (_selectedTab == 'Daily') {
          DateTime date = DateFormat('yyyy-MM-dd').parse(key);
          title = DateFormat('dd MMM yyyy').format(date).toUpperCase();
        } else if (_selectedTab == 'Weekly') {
          // Key format: YYYY-MM-WeekNum
          List<String> parts = key.split('-');
          DateTime date = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
          String monthName = DateFormat('MMM yyyy').format(date).toUpperCase();
          title = "$monthName, WEEK ${parts[2]}";
        } else {
          DateTime date = DateFormat('yyyy-MM-dd').parse(key);
          title = DateFormat('MMM yyyy').format(date).toUpperCase();
        }
        return {'title': title, 'amount': tempGroups[key]};
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
        title: Column(
          children: [
            const Text("Payroll Details",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text("Project ID: ${widget.projectId}", 
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
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
                      builder: (context) => PayrollSettingsScreen(
                            projectId: widget.projectId,
                          ))).then((_) => _fetchPayroll());
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
                if (_selectedTab != period) {
                  setState(() {
                    _selectedTab = period;
                  });
                  _fetchPayroll(); // Refetch boundaries
                }
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
    String displayText;
    if (_selectedTab == 'Daily') {
      displayText = DateFormat('dd-MM-yyyy').format(_selectedDate);
    } else {
      displayText = DateFormat('MMM yyyy').format(_selectedDate);
    }

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total Payroll:",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          Text(_formatCurrency(_grandTotal),
              style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
