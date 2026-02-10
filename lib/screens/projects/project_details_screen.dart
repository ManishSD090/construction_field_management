import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/controllers/project/project_controller.dart';

// Tab and Screen Imports
import 'package:construction_erp/screens/projects/edit_project.dart';
import 'package:construction_erp/screens/projects/tasks.dart';
import 'package:construction_erp/screens/projects/create_task.dart';
import 'package:construction_erp/screens/projects/sub_contractors_list.dart';
import 'package:construction_erp/screens/projects/add_sub_contractor.dart';
import 'package:construction_erp/screens/projects/timeline.dart';
import 'package:construction_erp/screens/projects/create_timeline.dart' as ct;
import 'package:construction_erp/screens/projects/gantt_chart_screen.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  ConsumerState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  String _selectedTab = 'Overview';
  late Project project;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Project) {
      project = args;
    }
  }

  // ================== DELETE LOGIC ==================

  void _showDeleteActionSheet() {
    bool isChecked = false;
    const Color warningColor = AppColors.alertRed;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          // Monitor the controller's state for loading status
          final controllerState = ref.watch(projectControllerProvider);
          final bool isProcessing = controllerState.isLoading;

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Delete Project? ⚠️",
                    style: TextStyle(
                        color: warningColor,
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
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                          value: isChecked,
                          activeColor: warningColor,
                          onChanged: (val) =>
                              setSheetState(() => isChecked = val!)),
                    ),
                    const SizedBox(width: 8),
                    const Text("I confirm this action",
                        style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isChecked ? warningColor : Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: (isChecked && !isProcessing)
                        ? () => _performDeleteProject()
                        : null,
                    child: isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text("Delete Project",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
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
    // Call the delete method from your ProjectController
    await ref
        .read(projectControllerProvider.notifier)
        .deleteProject(project.id);

    if (mounted) {
      final state = ref.read(projectControllerProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${state.error}"),
              backgroundColor: Colors.red),
        );
      } else {
        Navigator.pop(context); // Close BottomSheet
        _showSuccessDialog();
      }
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
                    const SizedBox(height: 8),
                    const Text(
                      "The project has been successfully removed.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(c); // Close dialog
                          Navigator.pop(context); // Return to List
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

  // ================== BUILDER ==================

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
      floatingActionButton: _buildFab(),
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

  // ================== COMPONENTS ==================

  Widget? _buildFab() {
    if (!['Tasks', 'Sub-contractor', 'Timeline'].contains(_selectedTab))
      return null;

    return FloatingActionButton(
      onPressed: () {
        if (_selectedTab == 'Tasks') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateTaskScreen()));
        } else if (_selectedTab == 'Sub-contractor') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AddSubContractorScreen(projectId: project.id)));
        } else if (_selectedTab == 'Timeline') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ct.CreateTimelineScreen()));
        }
      },
      backgroundColor: AppColors.primaryBlue,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildHeaderSection() {
    final int progressInt = project.progress ?? 0;
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text(project.location,
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 14)),
              const SizedBox(height: 15),
              _buildDateRow("Start date:",
                  DateFormat('dd MMM yyyy').format(project.startDate)),
              _buildDateRow("Estimated end date:",
                  DateFormat('dd MMM yyyy').format(project.estimatedEndDate)),
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
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditProjectScreen(project: project))),
                    child: _buildIconButton(Icons.edit, AppColors.lightGrey),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _showDeleteActionSheet,
                    child: _buildIconButton(Icons.delete, AppColors.alertRed),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildRichMetric("Progress: ", "$progressInt %", true),
              const SizedBox(height: 5),
              _buildRichMetric(
                  "Priority: ", project.priority.name.toUpperCase(), true,
                  color: AppColors.alertRed),
              const SizedBox(height: 10),
              _buildStatusChip(project.status),
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
            Icons.timer_outlined,
            "${project.estimatedEndDate.difference(DateTime.now()).inDays} Days",
            "Days Left"),
        const SizedBox(width: 12),
        _buildMetricCard(Icons.analytics_outlined,
            "${project.stats?.tasks ?? 0}", "Tasks Done"),
      ],
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      'Overview',
      'Tasks',
      'Sub-contractor',
      "Timeline",
      'Attendance',
      'DPR'
    ];
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
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.textGrey,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == 'Tasks') return const ProjectTasksTab();
    if (_selectedTab == 'Sub-contractor') {
      return SubContractorsList(projectId: project.id);
    }
    if (_selectedTab == 'Timeline') return const TimelineTab();

    if (_selectedTab == 'Overview') {
      return Column(
        children: [
          Row(
            children: [
              _buildProgressCircle(),
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  children: [
                    // _buildDetailLinkRow(
                    //     "Client:", project.client?.companyName ?? "N/A"),
                    _buildDetailLinkRow("Location:", project.location),
                    _buildDetailLinkRow("Project Manager:",
                        project.createdBy?.name ?? "Not Assigned"),
                    _buildDetailLinkRow("Site Engineer:", "Assigned"),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 30),
          _buildRecentActivities(),
          const Divider(color: AppColors.lightGrey, thickness: 1),
          _buildMilestones(),
        ],
      );
    }
    return Center(child: Text("$_selectedTab Content"));
  }

  // ================== HELPERS ==================

  Widget _buildProgressCircle() {
    final progressVal = (project.progress ?? 0) / 100.0;
    return Column(
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation(
                      AppColors.lightGrey.withOpacity(0.3))),
              CircularProgressIndicator(
                  value: progressVal,
                  strokeWidth: 10,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primaryBlue),
                  strokeCap: StrokeCap.round),
              Center(
                  child: Text("${project.progress}%",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const GanttChartScreen())),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              minimumSize: const Size(80, 28),
              shape: StadiumBorder()),
          child: const Text("VIEW",
              style: TextStyle(color: Colors.white, fontSize: 10)),
        )
      ],
    );
  }

  Widget _buildDetailLinkRow(String l, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text("$l ",
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
        Expanded(
            child: Text(v,
                style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 13),
                overflow: TextOverflow.ellipsis))
      ]));

  Widget _buildRichMetric(String label, String value, bool bold,
          {Color color = AppColors.textDark}) =>
      RichText(
          text: TextSpan(
              style: TextStyle(fontSize: 12, color: AppColors.textDark),
              children: [
            TextSpan(text: label),
            TextSpan(
                text: value,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    color: color))
          ]));

  Widget _buildIconButton(IconData i, Color c) => Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(i, color: c, size: 20));

  Widget _buildMetricCard(IconData i, String t, String s) => Expanded(
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Icon(i, color: AppColors.primaryBlue),
            const SizedBox(height: 8),
            Text(t,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(s,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 10))
          ])));

  Widget _buildDividerArrow() => SizedBox(
      height: 30,
      child: Stack(alignment: Alignment.center, children: [
        const Divider(color: AppColors.lightGrey),
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.lightGrey),
                shape: BoxShape.circle),
            child: const Icon(Icons.keyboard_arrow_up,
                color: AppColors.textGrey, size: 20))
      ]));

  Widget _buildDateRow(String l, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Text("$l ",
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
        Text(v,
            style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w500))
      ]));

  Widget _buildStatusChip(ProjectStatus s) {
    Color b = s == ProjectStatus.ongoing
        ? const Color(0xFFF9A825)
        : (s == ProjectStatus.completed
            ? AppColors.successGreen
            : AppColors.alertRed);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: b, borderRadius: BorderRadius.circular(20)),
        child: Text(s.name.toUpperCase(),
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10)));
  }

  Widget _buildRecentActivities() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Recent Activities",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        _buildActivityItem(Icons.attachment, "DPR submitted by Site Engineer",
            "Today 6:30 PM"),
        _buildActivityItem(Icons.inventory_2_outlined,
            "Material request approved", "Yesterday"),
      ]);

  Widget _buildActivityItem(IconData i, String t, String time) => ListTile(
      leading: Icon(i, color: AppColors.primaryBlue, size: 20),
      title: Text(t, style: const TextStyle(fontSize: 13)),
      trailing: Text(time,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
      contentPadding: EdgeInsets.zero,
      dense: true);

  Widget _buildMilestones() => Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Milestones",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          TextButton(onPressed: () {}, child: const Text("View all"))
        ]),
        _buildMilestoneItem("Foundation Work", "28 Dec 2025", true),
      ]);

  Widget _buildMilestoneItem(String t, String d, bool c) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.background, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(t, style: const TextStyle(fontWeight: FontWeight.w500)),
        Icon(c ? Icons.check_circle : Icons.radio_button_unchecked,
            color: c ? AppColors.successGreen : AppColors.textGrey, size: 20)
      ]));
}
