import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/screens/projects/project_tab.dart'; // Ensure ProjectModel is imported
import 'package:construction_erp/screens/projects/edit_project.dart'; // Edit Screen
import 'package:construction_erp/screens/projects/tasks.dart'; // Tasks Tab & Create Task Screen

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  String _selectedTab = 'Overview';
  late ProjectModel project;
  bool _isProcessing = false; // For delete loading state

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve arguments passed from the previous screen
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ProjectModel) {
      project = args;
    }
  }

  // ================== DELETE LOGIC START ==================
  void _showDeleteActionSheet() {
    bool isChecked = false;
    const Color color = AppColors.alertRed;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Delete Project? ⚠️",
                    style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: Colors.black87, fontSize: 15, height: 1.5),
                    children: [
                      const TextSpan(
                          text: "Are you sure you want to permanently delete "),
                      TextSpan(
                          text: "${project.title}?",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: "\nThis action cannot be undone."),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                          value: isChecked,
                          activeColor: color,
                          onChanged: (val) =>
                              setSheetState(() => isChecked = val!)),
                    ),
                    const SizedBox(width: 10),
                    const Text("I confirm this action",
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isChecked ? color : Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    onPressed: isChecked
                        ? () {
                            Navigator.pop(context); // Close sheet
                            _performDeleteProject();
                          }
                        : null,
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text("Delete Project",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Text("Cancel",
                        style: TextStyle(
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w600)),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _performDeleteProject() async {
    setState(() => _isProcessing = true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.successGreen, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      "Project Deleted!",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(c); // Close dialog
                          Navigator.pop(context); // Return to list screen
                        },
                        child: const Text("OK",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primaryBlue)),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }
  // ================== DELETE LOGIC END ==================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Project details",
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
      ),

      // ✅ FAB Logic: Only show when "Tasks" tab is selected
      floatingActionButton: _selectedTab == 'Tasks'
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to Create Task Screen (imported from tasks.dart)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateTaskScreen()),
                );
              },
              backgroundColor: AppColors.primaryBlue,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- TOP SECTION (Header & Metrics) ---
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 25),
                  _buildMetricsRow(),
                ],
              ),
            ),

            // --- DIVIDER ARROW ---
            SizedBox(
              height: 30,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Divider(color: AppColors.lightGrey, thickness: 1),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.lightGrey),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.keyboard_arrow_up,
                        color: AppColors.textGrey),
                  )
                ],
              ),
            ),

            // --- BOTTOM SECTION (Tabs & Content) ---
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabBar(),
                  const SizedBox(height: 25),

                  // Content Switcher
                  _buildTabContent(),

                  // ✅ Only show Recent Activities & Milestones if NOT on Tasks tab
                  if (_selectedTab == 'Overview') ...[
                    const SizedBox(height: 30),
                    _buildRecentActivities(),
                    const SizedBox(height: 0),
                    const Divider(color: AppColors.lightGrey, thickness: 1),
                    const SizedBox(height: 5),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text("View more",
                            style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    _buildMilestones(),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== HELPER WIDGETS ==================

  Widget _buildTabContent() {
    // 1. Show Tasks Content
    if (_selectedTab == 'Tasks') {
      return const ProjectTasksTab();
    }

    // 2. Placeholder for unimplemented tabs
    if (_selectedTab != 'Overview') {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("Content for $_selectedTab tab")));
    }

    // 3. Overview Content
    final int progressInt = (project.progress * 100).toInt();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side: Circular Progress
        Expanded(
          flex: 2,
          child: Column(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.lightGrey.withOpacity(0.5))),
                    CircularProgressIndicator(
                        value: project.progress,
                        strokeWidth: 12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryBlue),
                        strokeCap: StrokeCap.round),
                    Center(
                        child: Text("$progressInt%",
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue))),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text("Due date: ${project.endDate}",
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Right Side: Project Details
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailLinkRow("Client:", project.clientName),
              _buildDetailLinkRow(
                  "Location:", project.locationId.split('|')[0].trim()),
              _buildDetailLinkRow("Project Manager:", project.projectManager),
              _buildDetailLinkRow("Site Engineer:", project.siteEngineer),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    final int progressInt = (project.progress * 100).toInt();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                project.locationId,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 15),
              _buildDateRow("Start date:", project.startDate),
              _buildDateRow("Estimated end date:", project.endDate),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Edit Button
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProjectScreen(project: project),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: _buildIconButton(Icons.edit, AppColors.lightGrey),
                  ),
                  const SizedBox(width: 10),
                  // Delete Button
                  InkWell(
                    onTap: _showDeleteActionSheet,
                    borderRadius: BorderRadius.circular(8),
                    child: _buildIconButton(Icons.delete, AppColors.alertRed),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textDark),
                  children: [
                    const TextSpan(text: "Progress: "),
                    TextSpan(
                        text: "$progressInt %",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textDark),
                  children: [
                    const TextSpan(text: "Priority: "),
                    TextSpan(
                        text: project.priority,
                        style: const TextStyle(
                            color: AppColors.alertRed,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildStatusChip(project.status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ProjectStatus status) {
    Color bgColor;
    String label;
    switch (status) {
      case ProjectStatus.ongoing:
        bgColor = const Color(0xFFF9A825);
        label = "Ongoing";
        break;
      case ProjectStatus.completed:
        bgColor = AppColors.successGreen;
        label = "Completed";
        break;
      case ProjectStatus.onHold:
        bgColor = AppColors.alertRed;
        label = "On Hold";
        break;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.edit, color: AppColors.white, size: 12),
          )
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        _buildMetricCard(Icons.currency_rupee,
            "₹ ${project.budgetUsed}/₹ ${project.totalBudget}", "Budget used"),
        const SizedBox(width: 15),
        _buildMetricCard(
            Icons.timelapse, "${project.daysLeft} Days", "Days Left"),
        const SizedBox(width: 15),
        _buildMetricCard(Icons.assignment_turned_in,
            "${project.tasksDone}/${project.totalTasks}", "Tasks Done"),
      ],
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Overview', 'Tasks', 'DPR', 'Attendance'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tabName) {
          final isSelected = _selectedTab == tabName;
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedTab = tabName;
                });
              },
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    isSelected ? AppColors.secondaryBlue : AppColors.white,
                side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textGrey.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                tabName,
                style: TextStyle(
                  color:
                      isSelected ? AppColors.primaryBlue : AppColors.textGrey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailLinkRow(String label, String linkText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label ",
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
          Expanded(
              child: Text(linkText,
                  style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text("$label ",
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
          Text(date,
              style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildMetricCard(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue),
            const SizedBox(height: 10),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Activities",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
        const SizedBox(height: 10),
        const Divider(color: AppColors.lightGrey),
        _buildActivityItem(Icons.attachment, "DPR submitted by Site Engineer",
            "Today 6:30 PM"),
        _buildActivityItem(Icons.inventory_2_outlined,
            "Material request approved: Cement (50 Bags)", "Yesterday 6:30 PM"),
        _buildActivityItem(Icons.check_circle_outline,
            "Task marked completed: Excavation work", "12 Dec 2025"),
        _buildActivityItem(Icons.person_outline,
            "Attendance updated for 42 workers", "11 Dec 2025"),
      ],
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 15),
          Expanded(
              child: Text(title,
                  style:
                      const TextStyle(color: AppColors.textDark, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 10),
          Text(time,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMilestones() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Milestones",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            TextButton(
                onPressed: () {},
                child: const Text("View all",
                    style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600)))
          ],
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 1),
        const Divider(color: AppColors.lightGrey, thickness: 1),
        const SizedBox(height: 5),
        _buildMilestoneItem("Foundation Work", "28 Dec 2025", true),
        _buildMilestoneItem("Foundation Work", "28 Dec 2025", true),
        _buildMilestoneItem("Foundation Work", "28 Dec 2025", true),
        _buildMilestoneItem("Foundation Work", "28 Dec 2025", true),
      ],
    );
  }

  Widget _buildMilestoneItem(String title, String date, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: AppColors.background, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
          Row(
            children: [
              Text(date,
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              const SizedBox(width: 10),
              Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color:
                      isCompleted ? AppColors.successGreen : AppColors.textGrey,
                  size: 18),
            ],
          )
        ],
      ),
    );
  }
}
