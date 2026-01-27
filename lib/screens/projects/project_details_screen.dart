import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';
// Import where your ProjectModel is defined.
// If it's still in project_tab.dart, import that.
// Ideally, move ProjectModel to lib/models/project_model.dart
import 'package:construction_erp/screens/projects/project_tab.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  String _selectedTab = 'Overview';
  late ProjectModel project; // Variable to hold the data

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the project passed from the list screen
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ProjectModel) {
      project = args;
    } else {
      // Fallback or Error handling if no data passed
      // For now, we assume data is always passed correctly
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safety check in case project wasn't initialized
    // (though didChangeDependencies runs before build)

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top white section
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

            // Divider Arrow
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

            // Bottom section
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabBar(),
                  const SizedBox(height: 25),
                  _buildTabContent(),
                  const SizedBox(height: 30),
                  _buildRecentActivities(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== DYNAMIC WIDGETS ==================

  Widget _buildHeaderSection() {
    final int progressInt = (project.progress * 100).toInt();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Side
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
        // Right Side
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildIconButton(Icons.edit, AppColors.lightGrey),
                  const SizedBox(width: 10),
                  _buildIconButton(Icons.delete, AppColors.alertRed),
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
              // Dynamic Status Chip
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
        bgColor = AppColors.statusYellow;
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
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(0.1), // Slight dark overlay for icon bg
                shape: BoxShape.circle),
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

  Widget _buildTabContent() {
    if (_selectedTab != 'Overview') {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text("Content for $_selectedTab tab"),
      ));
    }

    final int progressInt = (project.progress * 100).toInt();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Circular Progress
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
                          AppColors.lightGrey.withOpacity(0.5)),
                    ),
                    CircularProgressIndicator(
                      value: project.progress,
                      strokeWidth: 12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBlue),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        "$progressInt%",
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue),
                      ),
                    ),
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
        // Right side: Project Details Links
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailLinkRow("Client:", project.clientName),
              // Split locationID to get just location if format is "Location | ID"
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

  // ... (The rest of the helper methods _buildDateRow, _buildIconButton, _buildTabBar, _buildRecentActivities stay exactly the same as the previous response) ...

  // Re-pasting helper methods for completeness:

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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildMetricCard(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
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
            child: Text(
              linkText,
              style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                  fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Activities",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark),
        ),
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
            child: Text(
              title,
              style: const TextStyle(color: AppColors.textDark, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Text(time,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
        ],
      ),
    );
  }
}
