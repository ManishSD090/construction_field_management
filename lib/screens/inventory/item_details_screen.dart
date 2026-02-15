import 'package:flutter/material.dart';
import 'package:construction_erp/routes.dart'; // For your footer routing

class ItemDetailsScreen extends StatelessWidget {
  final bool isMaterial;
  final String itemName;

  const ItemDetailsScreen({
    super.key,
    required this.isMaterial,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Slightly off-white background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isMaterial ? "Material Details" : "Equipment Details",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itemName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Info Card
            _buildInfoCard(),
            const SizedBox(height: 16),
            
            // Vendor Card
            _buildVendorCard(),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showRequestModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B48A), // Greenish color
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Request", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showTransferModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD), // Blue color
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Transfer", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      
      // The shared footer you requested
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D6EFD),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            Navigator.pushNamedAndRemoveUntil(
              context, 
              AppRoutes.home, 
              (route) => false, 
              arguments: HomeArguments.project,
            );
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

  // --- Widget Builders ---

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Text(
                isMaterial ? "Material Info" : "Equipment Info",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 16, color: Colors.grey),
              )
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow("Name:", itemName),
          const SizedBox(height: 12),
          if (isMaterial) ...[
            _buildInfoRow("Unit:", "kg"),
            const SizedBox(height: 12),
            _buildInfoRow("Cost per unit:", "Rs/kg"),
            const SizedBox(height: 12),
            _buildInfoRow("Total cost:", "8,00,000/-"),
            const SizedBox(height: 12),
          ],
          _buildInfoRow("Total Quantity:", "12"),
          const SizedBox(height: 12),
          _buildInfoRow(isMaterial ? "Used:" : "In Use:", "6"),
          if (isMaterial) ...[
            const SizedBox(height: 12),
            _buildInfoRow("Remaining:", "6"),
            const SizedBox(height: 12),
            _buildInfoRow("Low Stock Threshold:", "6"),
          ],
        ],
      ),
    );
  }

  Widget _buildVendorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Text("Vendor Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 16, color: Colors.grey),
              )
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow("Name:", "Vendor Name"),
          const SizedBox(height: 12),
          _buildInfoRow("Email ID:", "abc@gmail.com"),
          const SizedBox(height: 12),
          _buildInfoRow("Phone Number:", "xxxxxxxxxx"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.black87)),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // --- Modals / Popups ---

  void _showRequestModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isMaterial ? "Request Material" : "Request Equipment",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField("Vendor Name"),
                const SizedBox(height: 12),
                _buildTextField("Vendor Phone/Email"),
                const SizedBox(height: 12),
                _buildTextField("Quantity to Request"),
                const SizedBox(height: 12),
                _buildTextField("Required Date"),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context), // Add save logic here
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B48A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      isMaterial ? "Request Material" : "Request Equipment",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTransferModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isMaterial ? "Transfer Material" : "Transfer Equipment",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Dropdown for Project Name
                const Text("Project Name", style: TextStyle(fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF0D6EFD)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0D6EFD)),
                      items: [], // Add items here
                      onChanged: (value) {},
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField("Quantity to Transfer"),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context), // Add transfer logic here
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      isMaterial ? "Transfer Material" : "Transfer Equipment",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper for text fields in the modals
  Widget _buildTextField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D6EFD), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}