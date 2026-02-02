import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';

class EditTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task; // Receive task data

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  // Controllers
  late TextEditingController _taskNameController;
  late TextEditingController _descController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _contractorController;
  late TextEditingController _managerController;
  late TextEditingController _engineerController;

  String? _selectedAssignee;
  final List<String> _workers = ["Worker 1", "Worker 2", "Worker 3", "Team A"];

  @override
  void initState() {
    super.initState();
    // 1. Pre-fill data from the passed task map
    _taskNameController =
        TextEditingController(text: widget.task['title'] ?? "");
    _descController = TextEditingController(
        text: widget.task['description'] ??
            "Excavation work for the foundation block.");
    // Mapping 'dueDate' to End Date for this example
    _endDateController =
        TextEditingController(text: widget.task['dueDate'] ?? "");
    _startDateController = TextEditingController(text: "12 Jan 2026");

    _contractorController = TextEditingController(text: "ABC Contractors");
    _managerController = TextEditingController(text: "Rahul Sharma");
    _engineerController = TextEditingController(text: "Amit Verma");

    // Ensure the assignee exists in our list, otherwise default to first
    String assignee = widget.task['assignee'] ?? _workers.first;
    if (_workers.contains(assignee)) {
      _selectedAssignee = assignee;
    } else {
      _selectedAssignee = _workers.first;
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _contractorController.dispose();
    _managerController.dispose();
    _engineerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        title: const Text("Edit Task",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Task Name"),
            TextFormField(
              controller: _taskNameController,
              decoration: _inputDecor("Enter the task name"),
            ),

            _buildLabel("Description"),
            TextFormField(
              controller: _descController,
              decoration: _inputDecor("Enter description"),
            ),

            _buildLabel("Assigned to"),
            DropdownButtonFormField<String>(
              value: _selectedAssignee,
              decoration: _inputDecor("Select assignee"),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.primaryBlue),
              items: _workers
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedAssignee = val),
            ),

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
                        decoration: _inputDecor("",
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
                        decoration: _inputDecor("",
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

            const SizedBox(height: 25),

            // Side-by-Side Fields
            Row(children: [
              const SizedBox(
                  width: 120,
                  child: Text("Contractor",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14))),
              Expanded(
                  child: TextFormField(
                      controller: _contractorController,
                      decoration: _inputDecor("Enter the ..."))),
            ]),
            const SizedBox(height: 15),
            Row(children: [
              const SizedBox(
                  width: 120,
                  child: Text("Project manager",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14))),
              Expanded(
                  child: TextFormField(
                      controller: _managerController,
                      decoration: _inputDecor("Enter the ..."))),
            ]),
            const SizedBox(height: 15),
            Row(children: [
              const SizedBox(
                  width: 120,
                  child: Text("Site engineer",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14))),
              Expanded(
                  child: TextFormField(
                      controller: _engineerController,
                      decoration: _inputDecor("Enter the ..."))),
            ]),

            const SizedBox(height: 40),

            // Edit Button
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
                  onPressed: () {
                    // Handle Update Logic Here
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Task Updated Successfully!")),
                    );
                  },
                  child: const Text("Edit Task",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
