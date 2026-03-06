import 'package:flutter/material.dart';
import 'package:construction_erp/screens/inventory/create_po_screen.dart'; 
import 'package:construction_erp/screens/inventory/create_grn_screen.dart';
import 'package:intl/intl.dart'; // Needed for DateFormat

// 1. Simple Data Model
class PurchaseOrder {
  final String date;
  final String poNumber;
  final String supplierName;
  final String status; // "Pending", "Received", "Completed"

  PurchaseOrder({
    required this.date,
    required this.poNumber,
    required this.supplierName,
    required this.status,
  });
}

class PurchaseOrderListScreen extends StatefulWidget {
  const PurchaseOrderListScreen({super.key});

  @override
  State<PurchaseOrderListScreen> createState() => _PurchaseOrderListScreenState();
}

class _PurchaseOrderListScreenState extends State<PurchaseOrderListScreen> {
  // State Variables
  String _selectedFilter = 'All'; 
  DateTime? _selectedDate; // 👈 New Variable for Date

  // Sample Data List (Using "d MMM" format like "20 Feb")
  final List<PurchaseOrder> _allOrders = [
    PurchaseOrder(date: "20 Feb", poNumber: "PO-2026-041", supplierName: "Supplier Name", status: "Pending"),
    PurchaseOrder(date: "20 Feb", poNumber: "PO-2026-042", supplierName: "Supplier Name", status: "Received"),
    PurchaseOrder(date: "21 Feb", poNumber: "PO-2026-043", supplierName: "Supplier Name", status: "Completed"),
    PurchaseOrder(date: "22 Feb", poNumber: "PO-2026-044", supplierName: "Supplier Name", status: "Pending"),
    PurchaseOrder(date: "23 Feb", poNumber: "PO-2026-045", supplierName: "Supplier Name", status: "Received"),
  ];

  // Updated Filter Logic
  List<PurchaseOrder> get _filteredOrders {
    return _allOrders.where((order) {
      // 1. Status Filter
      bool statusMatches = _selectedFilter == 'All' || order.status == _selectedFilter;

      // 2. Date Filter
      bool dateMatches = true;
      if (_selectedDate != null) {
        // Convert selected date to "d MMM" (e.g., "20 Feb") to match sample data
        String formattedSelected = DateFormat('d MMM').format(_selectedDate!);
        dateMatches = order.date == formattedSelected;
      }

      return statusMatches && dateMatches;
    }).toList();
  }

  // 3. Date Picker Function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 2, 20), // Default to Feb 2026 for demo
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D6EFD), // Blue Header
              onPrimary: Colors.white, // White text
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Purchase Order",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Filter & Date Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 👇 UPDATED: Date Picker Button
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context), // Opens the calendar
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF0D6EFD)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null 
                                ? "MM/DD/YYYY" 
                                : DateFormat('MM/dd/yyyy').format(_selectedDate!), // Shows selected date
                            style: TextStyle(
                              color: _selectedDate == null ? Colors.grey : Colors.black
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: Color(0xFF0D6EFD), size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Popup Menu Filter (From previous step)
                PopupMenuButton<String>(
                  initialValue: _selectedFilter,
                  onSelected: (String newValue) {
                    setState(() {
                      _selectedFilter = newValue;
                    });
                  },
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    _buildPopupMenuItem('All'),
                    _buildPopupMenuItem('Pending'),
                    _buildPopupMenuItem('Received'),
                    _buildPopupMenuItem('Completed'),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF0D6EFD)),
                      color: _selectedFilter != 'All' ? const Color(0xFFE8F1FF) : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tune, size: 18, color: Color(0xFF0D6EFD)),
                        const SizedBox(width: 8),
                        Text(
                          _selectedFilter == 'All' ? "Filter" : _selectedFilter,
                          style: const TextStyle(
                            color: Color(0xFF0D6EFD),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // List Items
          Expanded(
            child: _filteredOrders.isEmpty 
              ? const Center(child: Text("No orders found")) 
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = _filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePOScreen()),
          );
        },
        backgroundColor: const Color(0xFF0D6EFD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ... (Keep your existing _buildPopupMenuItem, _buildOrderCard, and _buildBottomNavBar methods exactly as they are) ...
  
  PopupMenuItem<String> _buildPopupMenuItem(String value) {
    bool isSelected = _selectedFilter == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0D6EFD) : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected)
            const Icon(Icons.check, size: 18, color: Color(0xFF0D6EFD)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(PurchaseOrder order) {
    Color statusColor;
    bool showCreateGRN = false;

    switch (order.status) {
      case "Pending":
        statusColor = Colors.red;
        break;
      case "Received":
        statusColor = const Color(0xFF0D6EFD);
        showCreateGRN = true;
        break;
      case "Completed":
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.black;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                order.poNumber,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                order.status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(order.supplierName, style: const TextStyle(color: Colors.black87)),
          
          if (showCreateGRN) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 28,
                child: ElevatedButton(
                  onPressed: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateGRNScreen()),
                     );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text("Create GRN", style: TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
        currentIndex: 0, 
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D6EFD),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Project"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
    );
  }
}