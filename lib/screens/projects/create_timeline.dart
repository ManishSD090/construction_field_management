import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';

// Helper class to manage state for each Task Card
class TimelineTaskData {
  String? selectedMonthYear;
  String? selectedWeek;
  TextEditingController taskNameController = TextEditingController();
  // Start with one empty controller for "Subtask 1"
  List<TextEditingController> subtaskControllers = [TextEditingController()];
}

class CreateTimelineScreen extends StatefulWidget {
  const CreateTimelineScreen({super.key});

  @override
  State<CreateTimelineScreen> createState() => _CreateTimelineScreenState();
}

class _CreateTimelineScreenState extends State<CreateTimelineScreen> {
  // Global Controllers
  final _timelineNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String? _selectedProject;
  final List<String> _projects = ["Project A", "Project B", "Project C"];

  // Dynamic List of Tasks
  final List<TimelineTaskData> _tasks = [
    TimelineTaskData()
  ]; // Start with 1 Task Card

  // Dropdown Data
  final List<String> _monthYears = ["Jan 2026", "Feb 2026", "Mar 2026"];
  final List<String> _weeks = ["Week 1", "Week 2", "Week 3", "Week 4"];

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

  // Logic to add a new Subtask Field
  void _addSubtask(TimelineTaskData task) {
    setState(() {
      task.subtaskControllers.add(TextEditingController());
    });
  }

  // Logic to add a new Task Card
  void _addTask() {
    setState(() {
      _tasks.add(TimelineTaskData());
    });
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
          "Create Timeline",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Timeline Name"),
            _buildTextField(_timelineNameController, "Enter the timeline name"),

            _buildLabel("Assigned Project"),
            _buildDropdown(_projects, _selectedProject, (val) {
              setState(() => _selectedProject = val);
            }),

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

            const SizedBox(height: 25),
            const Text("Add tasks",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // --- Dynamic Task List ---
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tasks.length,
              separatorBuilder: (c, i) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                return _buildTaskCard(_tasks[index], index);
              },
            ),

            const SizedBox(height: 20),

            // --- Add New Task Button ---
            Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2))
                    ]),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Task Name"),
                      InkWell(
                        onTap: _addTask,
                        child: _buildDashedButton(""),
                      ),
                    ])),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Timeline Created Successfully!")),
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
                  "Create Timeline",
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

  // --- Widget Builders ---

  Widget _buildTaskCard(TimelineTaskData task, int taskIndex) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Month/Year"),
                    _buildDropdown(_monthYears, task.selectedMonthYear, (val) {
                      setState(() => task.selectedMonthYear = val);
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Week"),
                    _buildDropdown(_weeks, task.selectedWeek, (val) {
                      setState(() => task.selectedWeek = val);
                    }),
                  ],
                ),
              ),
            ],
          ),

          _buildLabel("Task Name"),
          _buildTextField(task.taskNameController, "Enter Task Name"),

          const SizedBox(height: 15),

          // Dynamic Subtasks List (Side-by-Side Layout)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: task.subtaskControllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Label: "Subtask X"
                    SizedBox(
                      width: 80, // Fixed width for alignment
                      child: Text(
                        "Subtask ${index + 1}",
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Right Input: Text Field
                    Expanded(
                      child:
                          _buildTextField(task.subtaskControllers[index], ""),
                    ),
                  ],
                ),
              );
            },
          ),

          // Add Next Subtask Button (Side-by-Side Layout)
          Row(
            children: [
              SizedBox(
                width: 80, // Matches label width above
                child: Text(
                  "Subtask ${task.subtaskControllers.length + 1}",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => _addSubtask(task),
                  child: _buildDashedButton(""),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
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
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12), // Reduced vertical padding
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0D6EFD).withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text("", style: TextStyle(color: Colors.blue.withOpacity(0.3))),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0D6EFD)),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
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
              hintText: "",
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

  Widget _buildDashedButton(String text) {
    return Container(
        width: double.infinity,
        height: 45, // Matches text field height approx
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color(0xFF0D6EFD), style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (text.isNotEmpty) ...[
              Text(text, style: const TextStyle(color: Colors.black54)),
              const SizedBox(width: 10),
            ],
            const Icon(Icons.add_circle_outline, color: Color(0xFF0D6EFD)),
          ],
        ));
  }
}
