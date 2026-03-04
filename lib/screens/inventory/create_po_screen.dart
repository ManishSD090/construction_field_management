import 'package:flutter/material.dart';

class CreatePOScreen extends StatelessWidget {
  const CreatePOScreen({super.key});

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
          "Create PO",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Supplier"),
            _buildDropdown(),
            const SizedBox(height: 16),

            _buildLabel("Location"),
            _buildTextField(""), // Empty hint or specific hint
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildColumnField("Expected Date")),
                const SizedBox(width: 16),
                Expanded(child: _buildColumnField("GST% (optional)")),
              ],
            ),
            const SizedBox(height: 16),

            // Material & Quantity Row
             Row(
              crossAxisAlignment: CrossAxisAlignment.end, // Align bottom
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       _buildLabel("Material"),
                       _buildDropdown(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       _buildLabel("Quantity"),
                       _buildTextField(""),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Dashed Box (Placeholder for added items or add button)
            Container(
              height: 50,
              width: double.infinity, // Or fixed width based on design
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF0D6EFD), style: BorderStyle.none), // Can't do dashed natively easily without package, use light solid for now or custom painter
              ),
              // Use a dotted border package if strict adherence needed, otherwise solid light blue border
               child: Container(
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: const Color(0xFF0D6EFD), width: 1), // Using solid for simplicity
                 ),
                 // If you need dashed specifically, use DottedBorder package
               ),
            ),
             const SizedBox(height: 16),

            _buildLabel("Total Amount"),
            _buildTextField(""),

            const SizedBox(height: 30),

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
                child: const Text("Send for Approval", style: TextStyle(fontSize: 16, color: Colors.white)),
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
}