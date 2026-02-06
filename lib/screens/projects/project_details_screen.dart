import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/models/enums.dart';

// Sub-screen imports
import 'package:construction_erp/screens/projects/tasks.dart';
import 'package:construction_erp/screens/projects/sub_contractors_list.dart';
import 'package:construction_erp/screens/projects/edit_project.dart';
import 'package:construction_erp/screens/projects/create_task.dart';
import 'package:construction_erp/screens/projects/add_sub_contractor.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  String _selectedTab = 'Overview';
  late Project project;
  bool _isProcessing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Project) {
      project = args;
    }
  }

  // ================== LOGIC HELPERS ==================

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  int _calculateDaysLeft() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(project.estimatedEndDate.year,
        project.estimatedEndDate.month, project.estimatedEndDate.day);
    final difference = end.difference(today).inDays;
    return difference < 0 ? 0 : difference;
  }

  // ================== DELETE LOGIC ==================

  void _showDeleteActionSheet() {
    bool isChecked = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                        color: AppColors.alertRed,
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
                          text: "${project.name}?",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: "\nThis action cannot be undone."),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      activeColor: AppColors.alertRed,
                      onChanged: (val) => setSheetState(() => isChecked = val!),
                    ),
                    const Text("I confirm this action",
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isChecked ? AppColors.alertRed : Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: isChecked ? () => _performDeleteProject() : null,
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
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _performDeleteProject() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      Navigator.pop(context); // Close sheet
      Navigator.pop(context); // Go back to list
    }
  }

  // ================== MAIN BUILD ==================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text("Project details",
            style:
                TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.pop(context)),
      ),
      floatingActionButton: (_selectedTab == 'Tasks' ||
              _selectedTab == 'Sub-contractor')
          ? FloatingActionButton(
              onPressed: () {
                // String projectId = project.id;
                if (_selectedTab == 'Tasks') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateTaskScreen()),
                  );
                }
                if (_selectedTab == 'Sub-contractor') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateSubContractorScreen(
                            projectId: project.id)),
                  );
                }
              },
              backgroundColor: AppColors.primaryBlue,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
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
            _buildDividerArrow(),
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                children: [
                  _buildTabBar(),
                  const SizedBox(height: 25),
                  _buildTabContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.name,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text("${project.location} | ${project.projectId}",
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 14)),
              const SizedBox(height: 16),
              _buildDateInfo("Start date:", _formatDate(project.startDate)),
              _buildDateInfo(
                  "Estimated end date:", _formatDate(project.estimatedEndDate)),
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
                  _buildActionIcon(Icons.edit, AppColors.lightGrey, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) =>
                                EditProjectScreen(project: project)));
                  }),
                  const SizedBox(width: 8),
                  _buildActionIcon(
                      Icons.delete, AppColors.alertRed, _showDeleteActionSheet),
                ],
              ),
              const SizedBox(height: 16),
              _buildRichTextLabel("Progress: ", "${project.progress}%"),
              _buildRichTextLabel(
                  "Priority: ", project.priority.name.toUpperCase(),
                  isPriority: true),
              const SizedBox(height: 8),
              _buildStatusChip(project.status.name.toUpperCase()),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        _buildMetricCard(
            Icons.payments_outlined,
            "₹${project.advanceReceived?.toInt() ?? 0}/₹${project.estimatedBudget.toInt()}",
            "Budget used"),
        const SizedBox(width: 12),
        _buildMetricCard(
            Icons.timer_outlined, "${_calculateDaysLeft()} Days", "Days Left"),
        const SizedBox(width: 12),
        _buildMetricCard(Icons.analytics_outlined,
            "${project.stats?.tasks ?? 0}", "Tasks Done"),
      ],
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == 'Tasks') {
      return const ProjectTasksTab();
    }
    if (_selectedTab == 'Sub-contractor') {
      return SubContractorsList(projectId: project.id);
    }
    if (_selectedTab != 'Overview') {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text("$_selectedTab content unavailable")));
    }

    return Column(
      children: [
        Row(
          children: [
            _buildProgressCircle(),
            const SizedBox(width: 25),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                      "Client:", project.client?.companyName ?? "N/A"),
                  _buildDetailRow("Location:", project.location),
                  _buildDetailRow("Project Manager:",
                      project.createdBy?.name ?? "Rahul Mehta"),
                  _buildDetailRow("Site Engineer:", "Ankit Verma"),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 40),
        _buildSectionTitle("Recent Activities"),
        _buildActivityItem(Icons.attachment, "DPR submitted by Site Engineer",
            "Today 6:30 PM"),
        _buildActivityItem(Icons.inventory_2_outlined,
            "Material request approved", "Yesterday 6:30 PM"),
        _buildActivityItem(
            Icons.check_circle_outline, "Task marked completed", "12 Dec 2025"),
      ],
    );
  }

  // ================== WIDGET COMPONENTS ==================

  Widget _buildTabBar() {
    final tabs = ['Overview', 'Tasks', 'Sub-contractor', 'Attendance', 'DPR'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: OutlinedButton(
              onPressed: () => setState(() => _selectedTab = tab),
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected ? AppColors.white : AppColors.white,
                side: BorderSide(
                    color:
                        isSelected ? AppColors.textDark : AppColors.lightGrey,
                    width: isSelected ? 1.5 : 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Text(tab,
                  style: TextStyle(
                      color: AppColors.textGrey,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgressCircle() {
    return SizedBox(
      height: 110,
      width: 110,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
              value: 1,
              strokeWidth: 10,
              color: AppColors.lightGrey.withOpacity(0.3)),
          CircularProgressIndicator(
              value: (project.progress ?? 0) / 100,
              strokeWidth: 10,
              color: AppColors.primaryBlue,
              strokeCap: StrokeCap.round),
          Center(
              child: Text("${project.progress}%",
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue))),
        ],
      ),
    );
  }

  Widget _buildRichTextLabel(String label, String value,
      {bool isPriority = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: AppColors.textDark),
          children: [
            TextSpan(text: label),
            TextSpan(
                text: value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isPriority ? AppColors.alertRed : AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text("$label ",
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
          Text(date,
              style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.statusYellow,
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(width: 6),
          const Icon(Icons.edit, color: Colors.white, size: 14),
        ],
      ),
    );
  }

  Widget _buildMetricCard(IconData icon, String val, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 24),
            const SizedBox(height: 8),
            Text(val,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(label,
                style:
                    const TextStyle(color: AppColors.textGrey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label ",
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
          Expanded(
              child: Text(val,
                  style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildDividerArrow() {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Divider(color: AppColors.lightGrey, thickness: 1.5),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.lightGrey),
                shape: BoxShape.circle),
            child: const Icon(Icons.keyboard_arrow_up,
                size: 20, color: AppColors.textGrey),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
        const Divider(color: AppColors.lightGrey),
      ],
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String time) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue, size: 22),
      title: Text(title,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
      trailing: Text(time,
          style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
