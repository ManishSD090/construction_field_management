import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/screens/projects/edit_task.dart';

class ProjectTasksTab extends StatefulWidget {
  final bool showAppBar;

  const ProjectTasksTab({
    super.key,
    this.showAppBar = false,
  });

  @override
  State<ProjectTasksTab> createState() => _ProjectTasksTabState();
}

class _ProjectTasksTabState extends State<ProjectTasksTab> {
  // State variables
  bool _isDeleteMode = false;
  bool _isEditMode = false; // ✅ Added Edit Mode State
  final Set<int> _selectedTaskIndices = {};

  final List<Map<String, dynamic>> _tasks = [
    {
      "title": "Excavation for Block A",
      "assignee": "Worker 1",
      "dueDate": "28 Sep 2025",
      "priority": "High",
      "status": "In progress",
      "statusColor": const Color(0xFFF9A825),
    },
    {
      "title": "Column Reinforcement - Phase 1",
      "assignee": "Worker 1",
      "dueDate": "28 Sep 2025",
      "priority": "High",
      "status": "Completed",
      "statusColor": AppColors.successGreen,
    },
    {
      "title": "Excavation for Block B",
      "assignee": "Worker 1",
      "dueDate": "28 Sep 2025",
      "priority": "High",
      "status": "Pending",
      "statusColor": AppColors.alertRed,
    },
  ];

  // Toggle Delete Mode (Turns off Edit mode if active)
  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
      _isEditMode = false; // Disable edit mode
      _selectedTaskIndices.clear();
    });
  }

  // ✅ Toggle Edit Mode (Turns off Delete mode if active)
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      _isDeleteMode = false; // Disable delete mode
      _selectedTaskIndices.clear();
    });
  }

  void _onTaskSelected(bool? selected, int index) {
    setState(() {
      if (selected == true) {
        _selectedTaskIndices.add(index);
      } else {
        _selectedTaskIndices.remove(index);
      }
    });
  }

  void _deleteSelectedTasks() {
    setState(() {
      final List<int> indicesToRemove = _selectedTaskIndices.toList()
        ..sort((a, b) => b.compareTo(a));

      for (int index in indicesToRemove) {
        _tasks.removeAt(index);
      }
      _isDeleteMode = false;
      _selectedTaskIndices.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Selected tasks deleted")),
    );
  }

  // ✅ Helper to Navigate to Edit Screen
  void _navigateToEdit(Map<String, dynamic> task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        // Hide Search Bar if in Delete OR Edit Mode
        if (!_isDeleteMode && !_isEditMode) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: AppColors.textGrey),
                hintText: "Search Tasks",
                hintStyle: TextStyle(color: AppColors.textGrey),
                border: InputBorder.none,
                suffixIcon: Icon(Icons.mic, color: AppColors.textGrey),
              ),
            ),
          ),
          const SizedBox(height: 25),
        ],

        // --- HEADER ROW ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tasks list",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark),
            ),

            // Logic for Buttons
            if (_isDeleteMode)
              Row(
                children: [
                  TextButton(
                    onPressed: _toggleDeleteMode,
                    child: const Text("Cancel",
                        style: TextStyle(
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _selectedTaskIndices.isNotEmpty
                        ? _deleteSelectedTasks
                        : null,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.alertRed),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: const Text("Delete selected",
                        style:
                            TextStyle(color: AppColors.alertRed, fontSize: 12)),
                  ),
                ],
              )
            else if (_isEditMode)
              // ✅ Show Cancel button for Edit Mode
              Row(
                children: [
                  const Text("Select to Edit",
                      style:
                          TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: _toggleEditMode,
                    child: const Text("Done",
                        style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            else
              // Normal Mode Icons
              Row(
                children: [
                  // ✅ EDIT BUTTON NOW WORKS
                  _buildSmallIcon(
                      Icons.edit, AppColors.lightGrey, _toggleEditMode),
                  const SizedBox(width: 8),
                  _buildSmallIcon(
                      Icons.delete, AppColors.alertRed, _toggleDeleteMode),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryBlue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Text("Filter",
                            style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        SizedBox(width: 4),
                        Icon(Icons.tune, size: 14, color: AppColors.primaryBlue)
                      ],
                    ),
                  )
                ],
              )
          ],
        ),
        const SizedBox(height: 15),

        // --- LIST VIEW ---
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            final task = _tasks[index];
            final isChecked = _selectedTaskIndices.contains(index);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  // 1. DELETE MODE: Checkbox
                  if (_isDeleteMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: isChecked,
                          activeColor: AppColors.alertRed,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          side: const BorderSide(
                              color: AppColors.textGrey, width: 1.5),
                          onChanged: (val) => _onTaskSelected(val, index),
                        ),
                      ),
                    ),

                  // 2. EDIT MODE: Pencil Icon
                  if (_isEditMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: InkWell(
                        onTap: () => _navigateToEdit(task),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: AppColors.lightGrey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.edit,
                              size: 18, color: AppColors.textDark),
                        ),
                      ),
                    ),

                  // 3. TASK CARD
                  Expanded(
                    child: InkWell(
                      // Allow tapping the card to edit in Edit Mode
                      onTap: () {
                        if (_isEditMode) {
                          _navigateToEdit(task);
                        }
                      },
                      child: TaskCard(
                        title: task['title'],
                        assignee: task['assignee'],
                        dueDate: task['dueDate'],
                        priority: task['priority'],
                        status: task['status'],
                        statusColor: task['statusColor'],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 80),
      ],
    );

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "All Tasks",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: content,
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
        //     );
        //   },
        //   backgroundColor: AppColors.primaryBlue,
        //   shape: const CircleBorder(),
        //   child: const Icon(Icons.add, color: Colors.white),
        // ),
      );
    } else {
      return content;
    }
  }

  Widget _buildSmallIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

// ... (TaskCard and CreateTaskScreen remain unchanged below) ...
// Ensure you include the TaskCard and CreateTaskScreen classes in your file
// exactly as they were in the previous version.
// I have omitted them here to save space but they are required.

class TaskCard extends StatelessWidget {
  final String title;
  final String assignee;
  final String dueDate;
  final String priority;
  final String status;
  final Color statusColor;

  const TaskCard(
      {super.key,
      required this.title,
      required this.assignee,
      required this.dueDate,
      required this.priority,
      required this.status,
      required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: statusColor == AppColors.alertRed
                        ? AppColors.alertRed
                        : statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(status,
                    style: TextStyle(
                        color: statusColor == AppColors.alertRed
                            ? Colors.white
                            : statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
              text: TextSpan(
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  children: [
                const TextSpan(text: "Assigned to: "),
                TextSpan(
                    text: assignee,
                    style: const TextStyle(color: AppColors.primaryBlue))
              ])),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Due Date: $dueDate",
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textGrey)),
            RichText(
                text: TextSpan(
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGrey),
                    children: [
                  const TextSpan(text: "Priority: "),
                  TextSpan(
                      text: priority,
                      style: const TextStyle(
                          color: AppColors.alertRed,
                          fontWeight: FontWeight.bold))
                ])),
          ])
        ],
      ),
    );
  }
}
