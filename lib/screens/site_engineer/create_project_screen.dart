import 'package:flutter/material.dart';

class CreateProjectScreen extends StatelessWidget {
  const CreateProjectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Project", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Project Name"),
            _buildTextField("Enter project name"),
            
            _buildLabel("Description"),
            _buildTextField("Enter description", maxLines: 3),
            
            _buildLabel("Location"),
            _buildTextField("Enter project location"), // Could be Google Maps picker later
            
            _buildLabel("Client Name"),
            DropdownButtonFormField(
              decoration: _inputDecoration("Select client"),
              items: const [], // TODO: Load clients from DB
              onChanged: (val) {},
            ),
            
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Start Date"),
                    _buildTextField("Select", icon: Icons.calendar_today),
                  ],
                )),
                const SizedBox(width: 16),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("End Date"),
                    _buildTextField("Select", icon: Icons.calendar_today),
                  ],
                )),
              ],
            ),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Create project", style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1, IconData? icon}) {
    return TextFormField(
      maxLines: maxLines,
      decoration: _inputDecoration(hint, icon: icon),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}