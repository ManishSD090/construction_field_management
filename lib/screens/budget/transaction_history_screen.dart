import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart'; // 👈 IMPORT GLOBAL COLORS
import 'package:construction_erp/screens/budget/create_request_screen.dart';

// Data Model
class Transaction {
  final DateTime date;
  final String source; // "Admin", "Labour", "PO", "Petty Cash"
  final double amount;
  final String type; // "Fund", "Expense", "Request"
  final String? status; // "Approved", "Pending" (Only for Requests)

  Transaction({
    required this.date,
    required this.source,
    required this.amount,
    required this.type,
    this.status,
  });
}

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  // State
  int _selectedTabIndex = 0; // 0: Funds, 1: Expense, 2: Requests
  DateTime? _selectedDate;
  String _selectedStatusFilter = 'All'; // For Requests tab

  // Mock Data
  final List<Transaction> _allTransactions = [
    // Funds
    Transaction(date: DateTime(2026, 2, 20), source: "Admin", amount: 2000000, type: "Fund"),
    Transaction(date: DateTime(2026, 2, 20), source: "Admin", amount: 2000000, type: "Fund"),
    Transaction(date: DateTime(2026, 2, 21), source: "Admin", amount: 500000, type: "Fund"),
    
    // Expenses
    Transaction(date: DateTime(2026, 2, 20), source: "Labour", amount: 2000000, type: "Expense"),
    Transaction(date: DateTime(2026, 2, 20), source: "Admin", amount: 2000000, type: "Expense"),
    
    // Requests
    Transaction(date: DateTime(2026, 2, 20), source: "Labour", amount: 5000, type: "Request", status: "Approved"),
    Transaction(date: DateTime(2026, 2, 20), source: "PO", amount: 10000, type: "Request", status: "Pending"),
    Transaction(date: DateTime(2026, 2, 20), source: "Petty Cash", amount: 2000000, type: "Request", status: "Approved"),
    Transaction(date: DateTime(2026, 2, 20), source: "Labour", amount: 2000000, type: "Request", status: "Approved"),
  ];

  // Filtering Logic
  List<Transaction> get _filteredTransactions {
    String currentType = _selectedTabIndex == 0 ? "Fund" : (_selectedTabIndex == 1 ? "Expense" : "Request");
    
    return _allTransactions.where((tx) {
      // 1. Filter by Tab Type
      bool typeMatches = tx.type == currentType;

      // 2. Filter by Date (if selected)
      bool dateMatches = true;
      if (_selectedDate != null) {
        dateMatches = tx.date.year == _selectedDate!.year && 
                      tx.date.month == _selectedDate!.month && 
                      tx.date.day == _selectedDate!.day;
      }

      // 3. Filter by Status (Only for Requests)
      bool statusMatches = true;
      if (_selectedTabIndex == 2 && _selectedStatusFilter != 'All') {
        statusMatches = tx.status == _selectedStatusFilter;
      }

      return typeMatches && dateMatches && statusMatches;
    }).toList();
  }

  // Date Picker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 2, 20),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

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
          "Transaction History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 1. Custom Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _buildTabButton("Funds", 0),
                _buildTabButton("Expense", 1),
                _buildTabButton("Requests", 2),
              ],
            ),
          ),

          // 2. Date & Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Date Picker Button
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryBlue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedDate == null 
                              ? "MM/DD/YYYY" 
                              : DateFormat('MM/dd/yyyy').format(_selectedDate!),
                          style: TextStyle(
                            color: _selectedDate == null ? Colors.grey : Colors.black,
                            fontSize: 13
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today, color: AppColors.primaryBlue, size: 16),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Filter Button (Only visible on Requests Tab)
                if (_selectedTabIndex == 2)
                  PopupMenuButton<String>(
                    onSelected: (val) => setState(() => _selectedStatusFilter = val),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'All', child: Text("All")),
                      const PopupMenuItem(value: 'Approved', child: Text("Approved")),
                      const PopupMenuItem(value: 'Pending', child: Text("Pending")),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Text("Filter", style: TextStyle(fontSize: 13)),
                          SizedBox(width: 4),
                          Icon(Icons.tune, size: 16),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const Divider(height: 24, thickness: 1),

          // 3. Transaction List
          Expanded(
            child: _filteredTransactions.isEmpty 
              ? const Center(child: Text("No transactions found"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = _filteredTransactions[index];
                    return _buildTransactionCard(tx);
                  },
                ),
          ),

          // 4. Create Request Button (Always at bottom)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                 Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateRequestScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Create Request",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          
          // Bottom Navigation Placeholder
          _buildBottomNav(),
        ],
      ),
    );
  }

  // ================== WIDGET COMPONENTS ==================

  Widget _buildTabButton(String text, int index) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            _selectedDate = null; // Reset filters on tab switch
            _selectedStatusFilter = 'All';
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textGrey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction tx) {
    // Format amount
    final formatter = NumberFormat("#,##,000");
    String amountString = "₹${formatter.format(tx.amount)}";

    // Determine Colors based on Tab Type
    Color amountColor;
    if (_selectedTabIndex == 0 || _selectedTabIndex == 2) {
      amountColor = AppColors.successGreen; 
    } else {
      amountColor = AppColors.alertRed; 
    }
    
    if(_selectedTabIndex == 2 && tx.status == "Pending") {
       amountColor = AppColors.successGreen; 
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date
              Text(
                DateFormat('d MMM yyyy').format(tx.date),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              
              // Status Badge (Only for Requests)
              if (_selectedTabIndex == 2 && tx.status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tx.status == "Approved" ? AppColors.successGreen : AppColors.alertRed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tx.status!,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Source (Blue Text)
              Text(
                tx.source,
                style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w500),
              ),
              
              // Amount
              Text(
                amountString,
                style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1, // Project tab selected
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: "Project"),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Report"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }
}