import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:construction_erp/routes.dart'; 
import 'package:construction_erp/screens/inventory/inventory_screen.dart'; 
import 'package:construction_erp/screens/inventory/purchase_order_list_screen.dart';

class InventoryDashboardScreen extends StatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  State<InventoryDashboardScreen> createState() => _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends State<InventoryDashboardScreen> {
  // Brand Colors based on UI
  final Color primaryBlue = const Color(0xFF0D6EFD);
  final Color tealColor = const Color(0xFF00C4B4);
  final Color lightBlue = const Color(0xFFE8F1FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Inventory",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // History action
            },
            icon: const Icon(Icons.access_time, color: Colors.white),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Inventory Summary Card (Donut Chart)
              _buildInventorySummaryCard(),
              
              const SizedBox(height: 24),

              // 2. Budget Section
              _buildBudgetSection(),

              const SizedBox(height: 24),

              // 3. Recent Activity Section
              _buildRecentActivitySection(),

              const SizedBox(height: 30),

              // 4. Primary Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                   Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PurchaseOrderListScreen()),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Make a Purchase Order",
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  


                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, 
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
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

  // --- Widgets ---

  Widget _buildInventorySummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Donut Chart
          SizedBox(
            height: 120,
            width: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                startDegreeOffset: -90,
                sections: [
                  // Equipment Segment (Teal)
                  PieChartSectionData(
                    color: tealColor,
                    value: 38, // Approx percentage based on values
                    title: '',
                    radius: 12,
                    showTitle: false,
                  ),
                  // Material Segment (Blue)
                  PieChartSectionData(
                    color: primaryBlue,
                    value: 62,
                    title: '',
                    radius: 12,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right: Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem("Equipment", "₹30,35,000", tealColor),
                const SizedBox(height: 4),
                _buildLegendItem("Material", "₹18,40,000", primaryBlue),
                const SizedBox(height: 8),
                const Text(
                  "Inventory: ₹48,75,000",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to Inventory List Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InventoryScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("View Inventory", style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        children: [
          TextSpan(text: "$label: "),
          TextSpan(
            text: value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Budget",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(height: 24),
          
          // Custom Progress Bar
          Container(
            height: 35,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFCDE1FF), // Light blue background
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Used Portion
                Expanded(
                  flex: 60, // 60% Used
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                // Remaining Portion
                const Expanded(
                  flex: 40,
                  child: SizedBox(), // Transparent/Light blue background shows
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Total Contract: ₹20,00,000",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Used: ₹12,00,000", style: TextStyle(fontSize: 13, color: Colors.black87)),
              Text("Remaining: ₹8,00,000", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent activity",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton(
              onPressed: () {},
              child: Text("View all", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 8),
        _buildActivityItem(
          icon: Icons.assignment_outlined,
          title: "Materials Received",
          subtitle: "Material Cement Batch ID",
          time: "2h ago",
        ),
        _buildActivityItem(
          icon: Icons.assignment_late_outlined,
          title: "Low Stock Alert",
          subtitle: "Material Cement Batch ID",
          time: "2h ago",
        ),
        _buildActivityItem(
          icon: Icons.compare_arrows,
          title: "Material Transferred",
          subtitle: "24 Dec 2025",
          time: "5h ago",
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }
}