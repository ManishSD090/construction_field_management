import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  DateTime? _selectedDate;
  String _activeFilter = 'All'; // Options: All, Approved, Pending, Rejected

  // 1. Data Source for Filtering
  final List<Map<String, String>> _allTransactions = [
    {
      "date": "20 Feb 2026",
      "project": "Project Alpha",
      "type": "Material",
      "amount": "20,00,000",
      "status": "Approved"
    },
    {
      "date": "20 Feb 2026",
      "project": "Project Beta",
      "type": "Labor",
      "amount": "10,000",
      "status": "Pending"
    },
    {
      "date": "22 Feb 2026",
      "project": "Project Gamma",
      "type": "Equipment",
      "amount": "20,00,000",
      "status": "Rejected"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 2. Filter Logic: Happens on every setState()
    final filteredTransactions = _allTransactions.where((t) {
      if (_activeFilter == 'All') return true;
      return t['status'] == _activeFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Transaction",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: const Icon(Icons.mic, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- Funds Released Card ---
          _buildFundsCard(),

          const SizedBox(height: 16),

          // --- Date Picker and Filter Row ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // FIXED WIDTH CALENDAR BOX
                SizedBox(
                  width: 150,
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null)
                        setState(() => _selectedDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryBlue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? "MM/DD/YYYY"
                                : DateFormat('dd/MM/yyyy')
                                    .format(_selectedDate!),
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 13),
                          ),
                          Icon(Icons.calendar_month_outlined,
                              color: AppColors.primaryBlue, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(), // Pushes filter button to the right

                _buildStatusFilterToggle(),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(color: AppColors.primaryBlue, thickness: 1),

          // --- Dynamic Transaction List ---
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(child: Text("No transactions found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final t = filteredTransactions[index];
                      return _buildTransactionCard(
                        t['date']!,
                        t['project']!,
                        t['type']!,
                        t['amount']!,
                        t['status']!,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundsCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
          children: [
            const TextSpan(text: "Funds Released: "),
            TextSpan(
              text: "₹20,00,000",
              style: TextStyle(
                  color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterToggle() {
    return PopupMenuButton<String>(
      onSelected: (String value) => setState(() => _activeFilter = value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'All', child: Text('Show All')),
        const PopupMenuItem(value: 'Approved', child: Text('Approved')),
        const PopupMenuItem(value: 'Pending', child: Text('Pending')),
        const PopupMenuItem(value: 'Rejected', child: Text('Rejected')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text("Filter ($_activeFilter) ",
                style: const TextStyle(color: Colors.black87, fontSize: 13)),
            const Icon(Icons.tune, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
      String date, String project, String type, String amount, String status) {
    Color statusColor;
    if (status == "Approved")
      statusColor = const Color(0xFF4CAF50);
    else if (status == "Pending")
      statusColor = const Color(0xFF3F51B5);
    else
      statusColor = const Color(0xFFF44336);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text("₹$amount",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project,
                      style: const TextStyle(
                          color: Color(0xFF2196F3), fontSize: 14)),
                  Text(type,
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
