import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/timeline/timeline_controller.dart';

// Helper class to manage state for each Task Card
class TimelineTaskData {
  int? selectedMonth;
  int? selectedYear;
  int? selectedWeek;

  TextEditingController taskNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController estimatedHoursController = TextEditingController();

  String priority = 'MEDIUM';
  bool isCritical = false;

  DateTime? plannedStartDate;
  DateTime? plannedEndDate;
  TextEditingController plannedStartController = TextEditingController();
  TextEditingController plannedEndController = TextEditingController();

  // Start with one empty controller for "Subtask 1"
  List<TextEditingController> subtaskControllers = [TextEditingController()];

  void dispose() {
    taskNameController.dispose();
    descriptionController.dispose();
    estimatedHoursController.dispose();
    plannedStartController.dispose();
    plannedEndController.dispose();
    for (var sub in subtaskControllers) {
      sub.dispose();
    }
  }
}

class CreateTimelineScreen extends ConsumerStatefulWidget {
  final String projectId; // Pass the project ID from the Project Details screen

  const CreateTimelineScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<CreateTimelineScreen> createState() =>
      _CreateTimelineScreenState();
}

class _CreateTimelineScreenState extends ConsumerState<CreateTimelineScreen> {
  // Global Controllers & State
  final _timelineNameController = TextEditingController();
  final _timelineDescController = TextEditingController();
  final _versionCommentController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  // Dynamic List of Tasks
  final List<TimelineTaskData> _tasks = [
    TimelineTaskData()
  ]; // Start with 1 Task Card

  // Dropdown Data
  final List<int> _weeks = [1, 2, 3, 4, 5]; // Max 5 weeks in a month
  final List<String> _priorities = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];

  @override
  void dispose() {
    _timelineNameController.dispose();
    _timelineDescController.dispose();
    _versionCommentController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    for (var task in _tasks) {
      task.dispose();
    }
    super.dispose();
  }

  // --- Date Math Helpers ---

  List<int> _getAvailableYears() {
    if (_startDate == null || _endDate == null) return [];
    int startY = _startDate!.year;
    int endY = _endDate!.year;
    return List.generate(endY - startY + 1, (i) => startY + i);
  }

  List<int> _getAvailableMonths(int? selectedYear) {
    if (_startDate == null || _endDate == null || selectedYear == null) {
      return [];
    }
    int startY = _startDate!.year;
    int endY = _endDate!.year;
    int startM = _startDate!.month;
    int endM = _endDate!.month;

    if (startY == endY) {
      // Same year: range is start month to end month
      return List.generate(endM - startM + 1, (i) => startM + i);
    } else if (selectedYear == startY) {
      // First year of multi-year range
      return List.generate(12 - startM + 1, (i) => startM + i);
    } else if (selectedYear == endY) {
      // Last year of multi-year range
      return List.generate(endM, (i) => i + 1);
    } else {
      // Full year in the middle of a multi-year range
      return List.generate(12, (i) => i + 1);
    }
  }

  void _validateTaskDates() {
    // If the main timeline dates change, ensure task dropdowns are still valid
    final validYears = _getAvailableYears();
    for (var task in _tasks) {
      if (task.selectedYear != null &&
          !validYears.contains(task.selectedYear)) {
        task.selectedYear = null;
        task.selectedMonth = null;
      } else if (task.selectedYear != null) {
        final validMonths = _getAvailableMonths(task.selectedYear);
        if (task.selectedMonth != null &&
            !validMonths.contains(task.selectedMonth)) {
          task.selectedMonth = null;
        }
      }
    }
  }

  // Date Picker Function for Timeline
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
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
        if (isStart) {
          _startDate = picked;
          _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
          // If end date is before new start date, reset it
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
            _endDateController.text = '';
          }
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
        _validateTaskDates(); // Re-check task dates
      });
    }
  }

  // Date Picker Function for Specific Task
  Future<void> _selectTaskDate(
      BuildContext context, TimelineTaskData task, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (task.plannedStartDate ?? _startDate ?? DateTime.now())
          : (task.plannedEndDate ??
              task.plannedStartDate ??
              _startDate ??
              DateTime.now()),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: _endDate ?? DateTime(2100),
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
        if (isStart) {
          task.plannedStartDate = picked;
          task.plannedStartController.text =
              DateFormat('yyyy-MM-dd').format(picked);
          if (task.plannedEndDate != null &&
              task.plannedEndDate!.isBefore(task.plannedStartDate!)) {
            task.plannedEndDate = null;
            task.plannedEndController.text = '';
          }
        } else {
          task.plannedEndDate = picked;
          task.plannedEndController.text =
              DateFormat('yyyy-MM-dd').format(picked);
        }
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

  // Submit Timeline Logic
  Future<void> _submitTimeline() async {
    // 1. Basic Validation
    if (_timelineNameController.text.trim().isEmpty) {
      _showError("Please enter a timeline name.");
      return;
    }
    if (_startDate == null || _endDate == null) {
      _showError("Please select both start and end dates.");
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      _showError("End date must be after start date.");
      return;
    }

    // 2. Format Tasks Payload
    List<Map<String, dynamic>> tasksPayload = [];
    for (int i = 0; i < _tasks.length; i++) {
      var t = _tasks[i];
      if (t.taskNameController.text.trim().isEmpty) {
        _showError("Task ${i + 1} must have a name.");
        return;
      }
      if (t.selectedYear == null ||
          t.selectedMonth == null ||
          t.selectedWeek == null) {
        _showError(
            "Please select Year, Month, and Week for '${t.taskNameController.text}'.");
        return;
      }

      // Filter empty subtasks
      List<Map<String, String>> validSubtasks = t.subtaskControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .map((text) => {"description": text})
          .toList();

      tasksPayload.add({
        "title": t.taskNameController.text.trim(),
        if (t.descriptionController.text.trim().isNotEmpty)
          "description": t.descriptionController.text.trim(),
        "year": t.selectedYear,
        "month": t.selectedMonth,
        "week": t.selectedWeek,
        "isCritical": t.isCritical,
        "priority": t.priority,
        "estimatedHours":
            int.tryParse(t.estimatedHoursController.text.trim()) ?? 0,
        if (t.plannedStartDate != null)
          "plannedStartDate":
              DateFormat('yyyy-MM-dd').format(t.plannedStartDate!),
        if (t.plannedEndDate != null)
          "plannedEndDate": DateFormat('yyyy-MM-dd').format(t.plannedEndDate!),
        "subtasks": validSubtasks,
      });
    }

    // 3. Create Payload
    final payload = {
      "projectId": widget.projectId,
      "name": _timelineNameController.text.trim(),
      if (_timelineDescController.text.trim().isNotEmpty)
        "description": _timelineDescController.text.trim(),
      "startDate": DateFormat('yyyy-MM-dd').format(_startDate!),
      "endDate": DateFormat('yyyy-MM-dd').format(_endDate!),
      if (_versionCommentController.text.trim().isNotEmpty)
        "versionComment": _versionCommentController.text.trim(),
      "tasks": tasksPayload,
    };

    // 4. Send Request via Controller
    try {
      await ref
          .read(timelineControllerProvider.notifier)
          .createTimeline(payload);

      final state = ref.read(timelineControllerProvider);
      if (state.hasError) {
        _showError(state.error.toString());
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Timeline Created Successfully!"),
                backgroundColor: AppColors.successGreen),
          );
          Navigator.pop(context); // Go back to Project Details
        }
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.alertRed),
    );
  }

  String _getMonthName(int monthIndex) {
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
    return months[monthIndex - 1];
  }

  @override
  Widget build(BuildContext context) {
    // Watch loading state
    final timelineState = ref.watch(timelineControllerProvider);
    final isLoading = timelineState.isLoading;

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
            _buildTextField(_timelineNameController, "E.g., Feb 2026 Plan11"),

            _buildLabel("Description"),
            _buildTextField(_timelineDescController,
                "E.g., Construction timeline for February 2026",
                maxLines: 2),

            const SizedBox(height: 15),

            // Dates Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Start date"),
                      _buildDatePicker(_startDateController, true),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("End date"),
                      _buildDatePicker(_endDateController, false),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            _buildLabel("Version Comment"),
            _buildTextField(_versionCommentController,
                "E.g., Initial setup with foundation work"),

            const SizedBox(height: 25),
            const Divider(thickness: 1.5, color: AppColors.lightGrey),
            const SizedBox(height: 10),

            const Text("Add tasks",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue)),
            if (_startDate == null || _endDate == null)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                    "Please select Timeline Start & End Dates first to enable scheduling.",
                    style: TextStyle(fontSize: 13, color: AppColors.alertRed)),
              ),
            const SizedBox(height: 15),

            // --- Dynamic Task List ---
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tasks.length,
              separatorBuilder: (c, i) => const SizedBox(height: 25),
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
                        child: _buildDashedButton("Add another task"),
                      ),
                    ])),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitTimeline,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text(
                        "Create Timeline",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildTaskCard(TimelineTaskData task, int taskIndex) {
    final availableYears = _getAvailableYears();
    final availableMonths = _getAvailableMonths(task.selectedYear);
    final isDateLocked = _startDate == null || _endDate == null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 3,
                offset: const Offset(0, 1))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Task ${taskIndex + 1}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primaryBlue)),
              if (taskIndex > 0)
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.alertRed, size: 20),
                  onPressed: () => setState(() => _tasks.removeAt(taskIndex)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
            ],
          ),
          const SizedBox(height: 10),

          _buildLabel("Task Title"),
          _buildTextField(task.taskNameController, "E.g., Excavation Work"),

          _buildLabel("Description"),
          _buildTextField(task.descriptionController,
              "E.g., Site excavation and preparation",
              maxLines: 2),

          const SizedBox(height: 15),

          // Scheduling Row (Year, Month, Week)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Year"),
                    _buildDropdown<int>(
                      items: availableYears,
                      selectedValue: task.selectedYear,
                      labelBuilder: (y) => y.toString(),
                      onChanged: isDateLocked
                          ? null
                          : (val) {
                              setState(() {
                                task.selectedYear = val;
                                task.selectedMonth =
                                    null; // reset month when year changes
                              });
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Month"),
                    _buildDropdown<int>(
                      items: availableMonths,
                      selectedValue: task.selectedMonth,
                      labelBuilder: (m) => _getMonthName(m),
                      onChanged: (isDateLocked || task.selectedYear == null)
                          ? null
                          : (val) {
                              setState(() => task.selectedMonth = val);
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Week"),
                    _buildDropdown<int>(
                      items: _weeks,
                      selectedValue: task.selectedWeek,
                      labelBuilder: (w) => "Wk $w",
                      onChanged: (val) =>
                          setState(() => task.selectedWeek = val),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Priority, Estimated Hours, and Critical flag
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Priority"),
                    _buildDropdown<String>(
                      items: _priorities,
                      selectedValue: task.priority,
                      labelBuilder: (p) => p,
                      onChanged: (val) => setState(() => task.priority = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Estimated Hours"),
                    _buildTextField(task.estimatedHoursController, "E.g., 40",
                        inputType: TextInputType.number),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          CheckboxListTile(
            title: const Text("Is this a Critical Task?",
                style: TextStyle(fontSize: 14)),
            value: task.isCritical,
            onChanged: (val) => setState(() => task.isCritical = val ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.alertRed,
            dense: true,
          ),

          const SizedBox(height: 10),

          // Planned Start & End Dates (Optional but explicitly handled in payload)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Planned Start (Optional)"),
                    _buildTaskDatePicker(
                        task, task.plannedStartController, true),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Planned End (Optional)"),
                    _buildTaskDatePicker(
                        task, task.plannedEndController, false),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: AppColors.lightGrey),
          const Text("Subtasks",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

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
                    SizedBox(
                      width: 80,
                      child: Text(
                        "Subtask ${index + 1}",
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(task.subtaskControllers[index],
                          "Subtask description"),
                    ),
                    if (index > 0)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: AppColors.alertRed, size: 20),
                        onPressed: () {
                          setState(() {
                            task.subtaskControllers[index].dispose();
                            task.subtaskControllers.removeAt(index);
                          });
                        },
                      )
                  ],
                ),
              );
            },
          ),

          // Add Next Subtask Button
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  "Subtask ${task.subtaskControllers.length + 1}",
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54),
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
            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0D6EFD).withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.blue.withOpacity(0.3), fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required List<T> items,
    required T? selectedValue,
    required String Function(T) labelBuilder,
    required ValueChanged<T?>? onChanged,
  }) {
    bool isDisabled = onChanged == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDisabled
                ? Colors.grey.shade300
                : const Color(0xFF0D6EFD).withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selectedValue,
          hint: Text("Select",
              style:
                  TextStyle(color: Colors.blue.withOpacity(0.3), fontSize: 13)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              color: isDisabled ? Colors.grey : const Color(0xFF0D6EFD),
              size: 20),
          items: items.map((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Text(labelBuilder(value),
                  style: TextStyle(
                      fontSize: 13,
                      color: isDisabled ? Colors.grey : Colors.black)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker(TextEditingController controller, bool isStart) {
    return GestureDetector(
      onTap: () => _selectDate(context, isStart),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF0D6EFD).withOpacity(0.3)),
        ),
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              hintText: "YYYY-MM-DD",
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: Icon(Icons.calendar_month_outlined,
                  color: Color(0xFF0D6EFD), size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskDatePicker(
      TimelineTaskData task, TextEditingController controller, bool isStart) {
    return GestureDetector(
      onTap: () => _selectTaskDate(context, task, isStart),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF0D6EFD).withOpacity(0.3)),
        ),
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              hintText: "YYYY-MM-DD",
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: Icon(Icons.calendar_month_outlined,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color(0xFF0D6EFD), style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (text.isNotEmpty) ...[
              Text(text,
                  style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 10),
            ],
            const Icon(Icons.add_circle_outline, color: Color(0xFF0D6EFD)),
          ],
        ));
  }
}
