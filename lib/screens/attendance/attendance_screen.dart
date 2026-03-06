import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/controllers/project/project_controller.dart';
import 'package:construction_erp/controllers/timeline/timeline_controller.dart';

// Tab and Screen Imports
import 'package:construction_erp/screens/projects/edit_project.dart';
import 'package:construction_erp/screens/tasks/tasks_tab.dart';
import 'package:construction_erp/screens/tasks/create_task.dart';
import 'package:construction_erp/screens/projects/project_sub_contractors_list.dart';
import 'package:construction_erp/screens/projects/add_sub_contractor.dart';
import 'package:construction_erp/screens/timeline/timeline_tab.dart';
import 'package:construction_erp/screens/timeline/create_timeline.dart' as ct;
import 'package:construction_erp/screens/timeline/create_timeline_version.dart';
import 'package:construction_erp/screens/projects/gantt_chart_screen.dart';
import 'package:construction_erp/screens/dpr/dpr_tab.dart';
import 'package:construction_erp/screens/dpr/create_dpr_screen.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  ConsumerState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen>
    with TickerProviderStateMixin {
  String _selectedTab = 'Overview';
  late Project project;
  bool _isHeaderVisible = true;
  bool _isDeleting = false;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Project) {
        project = args;
        _isInit = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(timelineControllerProvider.notifier)
              .refresh(projectId: project.id);
        });
      }
    }
  }

  // ================== DELETE LOGIC ==================

  void _showDeleteActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Delete Project",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.alertRed)),
                const SizedBox(height: 15),
                Text(
                    "Are you sure you want to delete '${project.name}'? This action cannot be undone.",
                    textAlign: TextAlign.center),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel")),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _performDeleteProject();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.alertRed),
                        child: const Text("Delete",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performDeleteProject() async {
    setState(() => _isDeleting = true);
    try {
      await ref
          .read(projectControllerProvider.notifier)
          .deleteProject(project.id);
      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle,
            color: AppColors.successGreen, size: 50),
        content: const Text("Project deleted successfully.",
            textAlign: TextAlign.center),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isHeaderVisible
                      ? Container(
                          color: AppColors.white,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildHeaderSection(),
                              const SizedBox(height: 25),
                              _buildMetricsRow(),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
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
          if (_isDeleting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildDividerArrow() {
    return Container(
      height: 30,
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Divider(color: AppColors.lightGrey, thickness: 1),
          GestureDetector(
            onTap: () => setState(() => _isHeaderVisible = !_isHeaderVisible),
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.lightGrey),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isHeaderVisible
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppColors.textGrey,
                size: 18,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget? _buildFab() {
    if (!['Tasks', 'Sub-contractor', 'Timeline', 'DPR', 'Attendance']
        .contains(_selectedTab)) {
      return null;
    }

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
          final timelineState =
              ref.read(timelineControllerProvider).valueOrNull;
          final existingTimelineId =
              (timelineState != null && timelineState.timelines.isNotEmpty)
                  ? timelineState.timelines.first.id
                  : null;

          if (existingTimelineId != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateTimelineVersionScreen(
                        timelineId: existingTimelineId)));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ct.CreateTimelineScreen(projectId: project.id)));
          }
        } else if (_selectedTab == 'DPR') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CreateDPRScreen()));
        }
      },
      backgroundColor: AppColors.primaryBlue,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == 'Tasks') return const ProjectTasksTab();
    if (_selectedTab == 'Sub-contractor')
      return ProjectSubContractorsList(projectId: project.id);
    if (_selectedTab == 'DPR') return const ProjectDPRTab();

    // ✅ REFINED COMPACT ATTENDANCE TAB
    if (_selectedTab == 'Attendance') {
      return _buildAttendanceTabContent();
    }

    if (_selectedTab == 'Timeline') {
      return Consumer(
        builder: (context, ref, child) {
          final timelineAsyncValue = ref.watch(timelineControllerProvider);
          return timelineAsyncValue.when(
            data: (state) => state.timelines.isNotEmpty
                ? TimelineTab(timelineId: state.timelines.first.id)
                : const Center(child: Text("No Timeline found.")),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text("Error: $e")),
          );
        },
      );
    }

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

    return Center(child: Text("$_selectedTab Module Coming Soon!"));
  }

  // ================== REFINED ATTENDANCE COMPONENTS ==================

  Widget _buildAttendanceTabContent() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3, // Reduced flex to match target UI
              child: Column(
                children: [
                  _buildCompactStatTile("Labors", 50, Colors.blue),
                  const SizedBox(height: 12),
                  _buildCompactStatTile("Staff", 26, const Color(0xFF4CAF50)),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 2, // Reduced flex to match target UI
              child: _buildCompactWorkforceGauge(76),
            ),
          ],
        ),
        const SizedBox(height: 25),
        _buildPayrollSummaryCard(),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D6EFD),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Mark Attendance",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Adjusted size
                    fontWeight: FontWeight.w600)), // Thinner weight
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStatTile(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12), // Compact padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500)), // Normal weight
          Text("$value",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600, // Reduced from bold
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildCompactWorkforceGauge(int total) {
    return Column(
      children: [
        SizedBox(
          height: 110, // Reduced height to match design
          width: 110,
          // Remove 'alignment: Alignment.center' from here
          child: Center(
            // Use Center widget to align the Stack
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 100, // Reduced gauge size
                  width: 100,
                  child: CircularProgressIndicator(
                    value: 0.76,
                    strokeWidth: 10,
                    backgroundColor: Colors.blue.shade100.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF0D6EFD)),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$total",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold, // Kept bold for readability
                      ),
                    ),
                    const Text(
                      "Total\nWorkforce",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayrollSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500),
                  children: [
                    TextSpan(text: "Overall Payroll: "),
                    TextSpan(
                        text: "₹21,600",
                        style: TextStyle(
                            color: Color(0xFF0D6EFD),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Material(
                color: const Color(0xFF0D6EFD),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text("View",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          _payrollSubRow("Labours:", "₹10,600"),
          const SizedBox(height: 6),
          _payrollSubRow("Staff:", "₹11,000"),
        ],
      ),
    );
  }

  Widget _payrollSubRow(String label, String amount) => Row(
        children: [
          Text("$label ",
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(amount,
              style: const TextStyle(
                  color: Color(0xFF0D6EFD),
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      );

  // ================== HELPER WIDGETS ==================

  Widget _buildTabBar() {
    final tabs = [
      'Overview',
      'Attendance',
      'DPR',
      'Tasks',
      'Sub-contractor',
      'Timeline',
      'WPR'
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

  Widget _buildHeaderSection() {
    final int progressInt = project.progress ?? 0;
    Color statusColor = project.status == ProjectStatus.ongoing
        ? const Color(0xFFF9A825)
        : (project.status == ProjectStatus.completed
            ? AppColors.successGreen
            : AppColors.alertRed);

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
                      fontSize: 20, fontWeight: FontWeight.bold)),
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
                  IconButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditProjectScreen(project: project))),
                      icon: const Icon(Icons.edit, color: AppColors.lightGrey)),
                  IconButton(
                      onPressed: _showDeleteActionSheet,
                      icon:
                          const Icon(Icons.delete, color: AppColors.alertRed)),
                ],
              ),
              const SizedBox(height: 10),
              _buildRichMetric("Progress: ", "$progressInt %", true),
              _buildRichMetric(
                  "Priority: ", project.priority.name.toUpperCase(), true,
                  color: AppColors.alertRed),
              const SizedBox(height: 10),
              _buildStatusChip(project.status, statusColor),
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
  Widget _buildRichMetric(String l, String v, bool b,
          {Color color = AppColors.textDark}) =>
      RichText(
          text: TextSpan(
              style: const TextStyle(fontSize: 12, color: AppColors.textDark),
              children: [
            TextSpan(text: l),
            TextSpan(
                text: v,
                style: TextStyle(
                    fontWeight: b ? FontWeight.bold : FontWeight.normal,
                    color: color))
          ]));
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
  Widget _buildDateRow(String l, String v) => Row(children: [
        Text("$l ",
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
        Text(v,
            style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w500))
      ]);
  Widget _buildStatusChip(ProjectStatus s, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(s.name.toUpperCase(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)));
  Widget _buildRecentActivities() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Recent Activities",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        _buildActivityItem(
            Icons.attachment, "DPR submitted by Site Engineer", "Today 6:30 PM")
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
        _buildMilestoneItem("Foundation Work", "28 Dec 2025", true)
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
