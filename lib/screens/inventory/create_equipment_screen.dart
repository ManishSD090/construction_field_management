import 'package:flutter/material.dart';

class CreateEquipmentScreen extends StatefulWidget {
  const CreateEquipmentScreen({super.key});

  @override
  State<CreateEquipmentScreen> createState() => _CreateEquipmentScreenState();
}

class _CreateEquipmentScreenState extends State<CreateEquipmentScreen> {
  bool isOwned = true; // State for radio buttons

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create Equipment",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Material Name"), // Assuming typo in your UI, label says Material Name
            _buildTextField("Enter the material name"),
            const SizedBox(height: 16),

            _buildLabel("Category"),
            _buildDropdown(),
            const SizedBox(height: 16),

            // Radio Buttons
            Row(
              children: [
                _buildRadioButton("Owned", true),
                const SizedBox(width: 20),
                _buildRadioButton("Rented", false),
              ],
            ),
            const SizedBox(height: 16),

            // Conditionally show content based on radio selection
            if (isOwned) ...[
              Row(
                children: [
                  Expanded(child: _buildColumnField("Purchase Cost")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildColumnField("Purchase Date")), // You can add DatePicker logic here
                ],
              ),
            ] else ...[
              _buildLabel("Vendor"),
              _buildDropdown(),
              const SizedBox(height: 16),
              _buildLabel("Rent Per Day"),
              _buildTextField(""),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildColumnField("Start date")), // Add DatePicker logic
                  const SizedBox(width: 16),
                  Expanded(child: _buildColumnField("End date")),   // Add DatePicker logic
                ],
              ),
            ],
            
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildColumnField("Fuel Type")),
                const SizedBox(width: 16),
                Expanded(child: _buildColumnField("Fuel Cost per Litre")),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildLabel("Avg Consumption Per Day"),
            _buildTextField(""),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Create Equipment", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
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
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0D6EFD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0D6EFD)),
          items: const [],
          onChanged: (value) {},
        ),
      ),
    );
  }

  Widget _buildColumnField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        _buildTextField(""),
      ],
    );
  }

  Widget _buildRadioButton(String label, bool value) {
    return Row(
      children: [
        Radio<bool>(
          value: value,
          groupValue: isOwned,
          activeColor: const Color(0xFF0D6EFD),
          onChanged: (val) {
            setState(() {
              isOwned = val!;
            });
          },
        ),
        Text(label),
      ],
    );
  }
}