import 'package:flutter/material.dart';

class CreateGRNScreen extends StatelessWidget {
  const CreateGRNScreen({super.key});

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
          "Create GRN",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                 Text("Location", style: TextStyle(color: Colors.grey)),
                 Text("Sent: 13 Oct 2026", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                 Text("Supplier Name", style: TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold, fontSize: 16)),
                 Text("Received: 12 JAN 2026", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),
            
            // Table Header
            const Row(
              children: [
                Expanded(flex: 1, child: Text("Sr. No.", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text("Particulars", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("Ordered", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text("Received", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              ],
            ),
            const Divider(color: Colors.black),

            // Table Rows (Generate a few)
            ...List.generate(6, (index) => _buildGRNRow(index + 1)),

            const Divider(color: Colors.black),
            
            // Total Row
             const Row(
              children: [
                Expanded(flex: 1, child: SizedBox()),
                Expanded(flex: 3, child: Text("Total", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("Number", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              ],
            ),
             const SizedBox(height: 20),

             Row(
               children: [
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       _buildLabel("Quality Check"),
                       _buildDropdown(),
                     ],
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       _buildLabel("Rate Supplier"),
                       _buildDropdown(),
                     ],
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 16),

             _buildLabel("Remarks"),
             _buildTextField(""),

             const SizedBox(height: 16),
             _buildLabel("Upload Goods Photos"),
             // Dashed Box with Plus
              Container(
                 height: 100,
                 width: 100,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: const Color(0xFF0D6EFD), style: BorderStyle.solid), // Use DottedBorder package for dashed
                 ),
                 child: const Center(
                   child: Icon(Icons.add_circle_outline, color: Color(0xFF0D6EFD), size: 30),
                 ),
             ),
             const SizedBox(height: 16),

             _buildLabel("Receipt"),
             OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.description, size: 18),
                label: const Text("Select file"),
                style: OutlinedButton.styleFrom(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   side: const BorderSide(color: Color(0xFF0D6EFD)),
                ),
             ),
             const Text("Upload a jpeg, jpg, png, pdf no larger than 10 MB", style: TextStyle(fontSize: 11, color: Colors.grey)),

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
                child: const Text("Submit", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGRNRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(index.toString().padLeft(2, '0'))),
          const Expanded(flex: 3, child: Text("Particular 1")),
          const Expanded(flex: 2, child: Text("Number", textAlign: TextAlign.center)),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 30,
              child: TextField(
                 textAlign: TextAlign.center,
                 decoration: InputDecoration(
                   contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                   enabledBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(4),
                     borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
                   ),
                    focusedBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(4),
                     borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
                   ),
                 ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... Reuse _buildLabel, _buildTextField, _buildDropdown from previous screens ...
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
}