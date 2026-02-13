import 'package:flutter/material.dart';
import 'package:construction_erp/routes.dart'; // Make sure this is imported for routing
import 'package:construction_erp/screens/admin/inventory/inventory_history_screen.dart'; // Adjust path if needed
import 'package:construction_erp/screens/admin/inventory/item_details_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool isMaterialSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD), // Matched to your dashboard blue
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Inventory", style: TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.access_time, color: Colors.white),
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onSelected: (value) {
              if (value == 'transfer' || value == 'request') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InventoryHistoryScreen(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'transfer',
                child: Text('Transfer History'),
              ),
              const PopupMenuItem<String>(
                value: 'request',
                child: Text('Request History'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Name",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.mic),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. Custom Toggle
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildToggleButton("Materials", isMaterialSelected, () {
                  setState(() => isMaterialSelected = true);
                }),
                _buildToggleButton("Equipments", !isMaterialSelected, () {
                  setState(() => isMaterialSelected = false);
                }),
              ],
            ),
          ),

          // 3. Stats Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${isMaterialSelected ? '20' : '5'} Total ${isMaterialSelected ? 'Materials' : 'Equipments'}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD)),
                  ),
                  Text(
                    "₹${isMaterialSelected ? '42,300' : '1,00,000'} Total Usage",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD)),
                  ),
                ],
              ),
            ),
          ),

          // 4. List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  isMaterialSelected ? "Materials List" : "Equipments List",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text("Filter"),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // 5. Grid List
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return isMaterialSelected 
                    ? _buildMaterialCard(index == 2 || index == 5)
                    : _buildEquipmentCard();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0D6EFD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      
      // 👇 HERE IS THE FOOTER WITH YOUR ROUTING 👇
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // 0 because user opened this from Dashboard
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D6EFD), // Blue for active
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            // Drop back to the main Dashboard screen
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            // Navigate to Projects 
            Navigator.pushNamedAndRemoveUntil(
              context, 
              AppRoutes.home, 
              (route) => false, 
              arguments: HomeArguments.project,
            );
          } else if (index == 2) {
            // Navigate to Report (Add routing logic when ready)
          } else if (index == 3) {
            // Navigate to Profile (Add routing logic when ready)
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Project"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D6EFD) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCard(bool showAlert) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ItemDetailsScreen(
              isMaterial: true,
              itemName: "Cement",
            ),
          ),
        );
      },
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Cement", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (showAlert) const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
            ],
          ),
          const Text("Quantity", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const Spacer(),
          const Text("Total: 120", style: TextStyle(fontSize: 12, color: Color(0xFF0D6EFD))),
          const Text("Used: 40", style: TextStyle(fontSize: 12, color: Color(0xFF0D6EFD))),
          const Text("Remaining: 80", style: TextStyle(fontSize: 12, color: Color(0xFF0D6EFD))),
        ],
      ),
    ),
    );
  }

  Widget _buildEquipmentCard() {
    return InkWell( // <--- Added InkWell
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ItemDetailsScreen(
              isMaterial: false, // Set to false for Equipment
              itemName: "Equipment Name",
            ),
          ),
        );
      },
      child: Container(
    
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Equipment Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text("Quantity", style: TextStyle(color: Colors.grey, fontSize: 12)),
          Spacer(),
          Text("Available: 120", style: TextStyle(fontSize: 11, color: Color(0xFF0D6EFD))),
          Text("In use: 40", style: TextStyle(fontSize: 11, color: Color(0xFF0D6EFD))),
          Text("Damaged: 80", style: TextStyle(fontSize: 11, color: Color(0xFF0D6EFD))),
        ],
      ),
      ),
    );
  }
}