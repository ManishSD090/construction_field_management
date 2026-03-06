import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});
  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _contractorController = TextEditingController();
  final TextEditingController _managerController = TextEditingController();
  final TextEditingController _engineerController = TextEditingController();
  String? _selectedAssignee;
  final List<String> _workers = ["Worker 1", "Worker 2", "Worker 3", "Team A"];

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
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() => controller.text =
          "${picked.day} ${_getMonth(picked.month)} ${picked.year}");
    }
  }

  String _getMonth(int month) => [
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
      ][month - 1];
  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87)));
  InputDecoration _inputDecor(String hint, {Widget? suffixIcon}) =>
      InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder:
              OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF0A6ED1))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primaryBlue, width: 2)),
          suffixIcon: suffixIcon,
          fillColor: Colors.white,
          filled: true);

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
              onPressed: () => Navigator.pop(context)),
          title: const Text("Create Task",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildLabel("Task Name"),
            TextFormField(
                controller: _taskNameController,
                decoration: _inputDecor("Enter the task name")),
            _buildLabel("Description"),
            TextFormField(
                controller: _descController,
                decoration: _inputDecor("Enter description")),
            _buildLabel("Assigned to"),
            DropdownButtonFormField<String>(
                initialValue: _selectedAssignee,
                decoration: _inputDecor("Select assignee"),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.primaryBlue),
                items: _workers
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedAssignee = val)),
            Row(children: [
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
                        onTap: () => _selectDate(context, _startDateController))
                  ])),
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
                        onTap: () => _selectDate(context, _endDateController))
                  ]))
            ]),
            const SizedBox(height: 25),
            Row(children: [
              const SizedBox(
                  width: 120,
                  child: Text("Contractor",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14))),
              Expanded(
                  child: TextFormField(
                      controller: _contractorController,
                      decoration: _inputDecor("Enter the ...")))
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
                      decoration: _inputDecor("Enter the ...")))
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
                      decoration: _inputDecor("Enter the ...")))
            ]),
            const SizedBox(height: 40),
            Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                    width: 140,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D6EFD),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25))),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Task Created Successfully!")));
                        },
                        child: const Text("Create Task",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14))))),
            const SizedBox(height: 20),
          ])),
    );
  }
}