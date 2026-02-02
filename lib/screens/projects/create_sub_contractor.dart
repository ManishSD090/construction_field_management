import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';

class CreateSubContractorScreen extends StatefulWidget {
  const CreateSubContractorScreen({super.key});

  @override
  State<CreateSubContractorScreen> createState() =>
      _CreateSubContractorScreenState();
}

class _CreateSubContractorScreenState extends State<CreateSubContractorScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _workTypeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _contractAmountController = TextEditingController();
  final _budgetController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String? _selectedProject;
  final List<String> _projects = ["Project A", "Project B", "Project C"];

  // Date Picker Function
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create Sub-contractor",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Sub-contractor Name"),
            _buildTextField(_nameController, "Enter the sub-contractor name"),

            _buildLabel("Work Type"),
            _buildTextField(_workTypeController, "Enter type of work"),

            _buildLabel("Phone number"),
            _buildTextField(_phoneController, "Enter the Phone Number",
                inputType: TextInputType.phone),

            _buildLabel("Email ID"),
            _buildTextField(_emailController, "Enter the Email ID",
                inputType: TextInputType.emailAddress),

            _buildLabel("Assigned Project"),
            _buildDropdown(),

            const SizedBox(height: 15),

            // Dates Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Start date"),
                      _buildDatePicker(_startDateController),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("End date"),
                      _buildDatePicker(_endDateController),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            _buildLabel("Total Contract Amount"),
            _buildTextField(_contractAmountController, "Enter the ...",
                inputType: TextInputType.number),

            _buildLabel("Estimated budget"),
            _buildTextField(_budgetController, "Enter the ...",
                inputType: TextInputType.number),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Handle Creation Logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Sub-contractor Created Successfully!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD), // Blue
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Create Sub-contractor",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType inputType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0D6EFD).withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.blue.withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0D6EFD).withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedProject,
          hint: Text("", style: TextStyle(color: Colors.blue.withOpacity(0.3))),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0D6EFD)),
          items: _projects.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedProject = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker(TextEditingController controller) {
    return GestureDetector(
      onTap: () => _selectDate(context, controller),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF0D6EFD).withOpacity(0.5)),
        ),
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Select date",
              hintStyle: TextStyle(color: Colors.blue.withOpacity(0.3)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: const Icon(Icons.calendar_month_outlined,
                  color: Color(0xFF0D6EFD), size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
