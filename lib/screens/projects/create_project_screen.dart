import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _advancedController = TextEditingController();
  final _contractValueController = TextEditingController();
  final _projectManagerController = TextEditingController();
  final _siteEngineerController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  // Dropdown value
  String? _selectedClient;

  // Function to pick date
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Format: YYYY-MM-DD
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Create Project",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      // --- BODY ---
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Project Name"),
              _buildTextField(
                controller: _nameController,
                hint: "Enter the project name",
              ),

              const SizedBox(height: 15),
              _buildLabel("Description"),
              _buildTextField(
                controller: _descriptionController,
                hint: "Enter description",
              ),

              const SizedBox(height: 15),
              _buildLabel("Location"),
              _buildTextField(
                controller: _locationController,
                hint:
                    "Enter the project location", // Adjusted hint based on image context
              ),

              const SizedBox(height: 15),
              _buildLabel("Client name"),
              _buildDropdown(),

              const SizedBox(height: 15),
              // --- Row: Start Date & End Date ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Start date"),
                        _buildDatePicker(_startDateController, "Select date"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("End date"),
                        _buildDatePicker(_endDateController, "Select date"),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              // --- Row: Budget & Advanced ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Estimated budget"),
                        _buildTextField(
                          controller: _budgetController,
                          hint: "Enter the ...",
                          keyboardType: TextInputType.number,
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
                        _buildTextField(
                          controller: _advancedController,
                          hint: "Enter the ...",
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              _buildLabel("Contract Value"),
              _buildTextField(
                controller: _contractValueController,
                hint: "Enter the ...",
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 15),
              // --- Inline Label Layout for Manager ---
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: _buildLabel("Project manager", marginBottom: 0)),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: _projectManagerController,
                      hint: "Enter the ...",
                      height: 45,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              // --- Inline Label Layout for Engineer ---
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: _buildLabel("Site engineer", marginBottom: 0)),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: _siteEngineerController,
                      hint: "Enter the ...",
                      height: 45,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- SUBMIT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle Form Submission
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Create project",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildLabel(String text, {double marginBottom = 8}) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    double height = 50,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.primaryBlue.withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedClient,
          hint: Text(
            "Select Client",
            style: TextStyle(
                color: AppColors.primaryBlue.withOpacity(0.3), fontSize: 14),
          ),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.primaryBlue),
          isExpanded: true,
          items: ["Client A", "Client B", "Client C"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedClient = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker(TextEditingController controller, String hint) {
    return GestureDetector(
      onTap: () => _selectDate(context, controller),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
        ),
        child: AbsorbPointer(
          // Prevents keyboard from opening
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(color: AppColors.primaryBlue.withOpacity(0.3)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: const Icon(Icons.calendar_month_outlined,
                  color: AppColors.primaryBlue, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
