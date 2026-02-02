import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';

class EditSubContractorScreen extends StatefulWidget {
  final Map<String, dynamic> subContractorData;

  const EditSubContractorScreen({super.key, required this.subContractorData});

  @override
  State<EditSubContractorScreen> createState() =>
      _EditSubContractorScreenState();
}

class _EditSubContractorScreenState extends State<EditSubContractorScreen> {
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _workTypeController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _contractAmountController;
  late TextEditingController _budgetController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  String? _selectedProject;
  final List<String> _projects = [
    "Project Name 1",
    "Project Name 2",
    "Project C"
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with passed data
    _nameController =
        TextEditingController(text: widget.subContractorData['name']);
    _workTypeController =
        TextEditingController(text: widget.subContractorData['workType']);
    _phoneController =
        TextEditingController(text: "9123456789"); // Dummy/Passed data
    _emailController =
        TextEditingController(text: "xyz@abccinfrastructure.com");
    _contractAmountController = TextEditingController(text: "200000");
    _budgetController = TextEditingController(text: "150000");
    _startDateController = TextEditingController(text: "12/01/2026");
    _endDateController = TextEditingController(text: "13/10/2026");

    // Set selected project (Handle null safely)
    if (_projects.contains(widget.subContractorData['project'])) {
      _selectedProject = widget.subContractorData['project'];
    } else {
      _selectedProject = _projects.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _workTypeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _contractAmountController.dispose();
    _budgetController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

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
          "Edit Sub-contractor",
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
            _buildTextField(_nameController, "Enter name"),

            _buildLabel("Work Type"),
            _buildTextField(_workTypeController, "Enter type of work"),

            _buildLabel("Phone number"),
            _buildTextField(_phoneController, "Enter Phone Number",
                inputType: TextInputType.phone),

            _buildLabel("Email ID"),
            _buildTextField(_emailController, "Enter Email ID",
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
            _buildTextField(_contractAmountController, "Enter amount",
                inputType: TextInputType.number),

            _buildLabel("Estimated budget"),
            _buildTextField(_budgetController, "Enter budget",
                inputType: TextInputType.number),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Handle Update Logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Sub-contractor Updated Successfully!")),
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
                  "Update Sub-contractor",
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
