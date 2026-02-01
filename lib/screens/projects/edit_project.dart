import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/screens/projects/project_tab.dart'; // Ensure ProjectModel is imported

class EditProjectScreen extends StatefulWidget {
  final ProjectModel project;
  const EditProjectScreen({super.key, required this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _locationController;
  late TextEditingController _clientNameController;
  late TextEditingController _budgetController;
  late TextEditingController _advanceController;
  late TextEditingController _contractValueController;
  late TextEditingController _managerController;
  late TextEditingController _siteEngineerController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    // 1. Initialize ALL controllers
    _nameController = TextEditingController(text: widget.project.title);
    _descController = TextEditingController(text: "Project Description");
    _locationController = TextEditingController(
        text: widget.project.locationId.split('|')[0].trim());

    // Client Name Controller
    _clientNameController =
        TextEditingController(text: widget.project.clientName);

    _budgetController = TextEditingController(text: widget.project.totalBudget);
    _advanceController = TextEditingController(text: "10,00,000");
    _contractValueController = TextEditingController(text: "50,00,000");
    _managerController =
        TextEditingController(text: widget.project.projectManager);
    _siteEngineerController =
        TextEditingController(text: widget.project.siteEngineer);
    _startDateController =
        TextEditingController(text: widget.project.startDate);
    _endDateController = TextEditingController(text: widget.project.endDate);
  }

  @override
  void dispose() {
    // 2. Dispose ALL controllers
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _clientNameController.dispose();
    _budgetController.dispose();
    _advanceController.dispose();
    _contractValueController.dispose();
    _managerController.dispose();
    _siteEngineerController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  // --- SIMPLE CALENDAR LOGIC (Standard Flutter Picker) ---
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
              primary: AppColors.primaryBlue, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Format: DD MMM YYYY (e.g., 12 Jan 2026)
        controller.text =
            "${picked.day} ${_getMonth(picked.month)} ${picked.year}";
      });
    }
  }

  String _getMonth(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }

  // --- CONFIRMATION DIALOG ---
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure you want to edit the Project?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close Dialog
                    Navigator.pop(context); // Go back
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Project Updated Successfully!")),
                    );
                  },
                  child: const Text("Yes",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                      color: AppColors.alertRed,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI HELPERS ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87)),
    );
  }

  InputDecoration _inputDecor(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0A6ED1))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
      suffixIcon: suffixIcon,
      fillColor: Colors.white,
      filled: true,
    );
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
        title: const Text("Edit Project",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Project Name"),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecor("Project Name"),
            ),

            _buildLabel("Description"),
            TextFormField(
              controller: _descController,
              decoration: _inputDecor("Project Description"),
            ),

            _buildLabel("Location"),
            TextFormField(
              controller: _locationController,
              decoration: _inputDecor("Project Location"),
            ),

            _buildLabel("Client name"),
            TextFormField(
              controller: _clientNameController,
              decoration: _inputDecor("Enter Client Name"),
            ),

            // Date Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Start date"),
                      TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        decoration: _inputDecor("Select Date",
                            suffixIcon: const Icon(
                                Icons.calendar_month_outlined,
                                color: AppColors.primaryBlue,
                                size: 20)),
                        onTap: () => _selectDate(context, _startDateController),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("End date"),
                      TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        decoration: _inputDecor("Select Date",
                            suffixIcon: const Icon(
                                Icons.calendar_month_outlined,
                                color: AppColors.primaryBlue,
                                size: 20)),
                        onTap: () => _selectDate(context, _endDateController),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Budget Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Estimated budget"),
                      TextFormField(
                        controller: _budgetController,
                        decoration: _inputDecor("Enter the ..."),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Advanced received"),
                      TextFormField(
                        controller: _advanceController,
                        decoration: _inputDecor("Enter the ..."),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            _buildLabel("Contract Value"),
            TextFormField(
              controller: _contractValueController,
              decoration: _inputDecor("Enter the ..."),
            ),

            const SizedBox(height: 20),

            // --- Project Manager Section (Side-by-Side) ---
            Row(
              children: [
                const SizedBox(
                  width: 130,
                  child: Text("Project manager",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87)),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _managerController,
                    decoration: _inputDecor("Enter the ..."),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // --- Site Engineer Section (Side-by-Side) ---
            Row(
              children: [
                const SizedBox(
                  width: 130,
                  child: Text("Site engineer",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87)),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _siteEngineerController,
                    decoration: _inputDecor("Enter the ..."),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Edit Project Button
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: _showConfirmationDialog,
                  child: const Text("Edit Project",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
