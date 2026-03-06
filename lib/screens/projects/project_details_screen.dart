import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/controllers/project/project_controller.dart';
import 'package:construction_erp/controllers/timeline/timeline_controller.dart';

// Screen Imports
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
import 'package:construction_erp/screens/budget/transaction_history_screen.dart';
import 'package:construction_erp/screens/budget/create_request_screen.dart';
import 'package:construction_erp/screens/projects/project_inventory_dashboard.dart';

// ✅ Attendance Imports from your working version
import 'package:construction_erp/screens/attendance/payroll_details_screen.dart';
import 'package:construction_erp/screens/attendance/mark_attendance_screen.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  ConsumerState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen>
    with TickerProviderStateMixin {
  String _selectedTab = 'Overview';
  int _selectedReportType = 0;
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
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
                          child: const Text("Cancel"))),
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
                              style: TextStyle(color: Colors.white)))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performDeleteProject() async {
    setState(() => _isDeleting = true);
    try {
      await ref
          .read(projectControllerProvider.notifier)
          .deleteProject(project.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text("Project details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
      ),
      floatingActionButton: _buildFab(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isHeaderVisible
                        ? Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(20),
                            child: Column(children: [
                              _buildHeaderSection(),
                              const SizedBox(height: 25),
                              _buildMetricsRow()
                            ]),
                          )
                        : const SizedBox.shrink(),
                  ),
                  _buildDividerArrow(),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: Column(children: [
                      _buildTabBar(),
                      const SizedBox(height: 25),
                      _buildTabContent()
                    ]),
                  ),
                ],
              ),
            ),
          ),
          // ✅ Working Fixed Attendance Button logic
          if (_selectedTab == 'Attendance') _buildFixedMarkAttendanceButton(),
        ],
      ),
    );
  }

  Widget _buildFixedMarkAttendanceButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12))),
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MarkAttendanceScreen())),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D6EFD),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 0),
          child: const Text("Mark Attendance",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // ================== TAB CONTENT ==================
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'Attendance':
        return _buildAttendanceTabUI();
      case 'Transactions':
        return _buildTransactionsTab();
      case 'Inventory':
        return ProjectInventoryDashboardScreen(projectId: project.id);
      case 'Tasks':
        return const ProjectTasksTab();
      case 'Sub-contractor':
        return ProjectSubContractorsList(projectId: project.id);
      case 'DPR':
        return const ProjectDPRTab();
      case 'Timeline':
        return _buildTimelineTab();
      case 'Overview':
        return _buildOverviewTab();
      default:
        return const Center(child: Text("Module Coming Soon!"));
    }
  }

  // ✅ Your WORKING Attendance UI integrated here
  Widget _buildAttendanceTabUI() {
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
            flex: 5,
            child: Column(children: [
              _buildStatCard("Labors", 50, const Color(0xFF3B71CA)),
              const SizedBox(height: 12),
              _buildStatCard("Staff", 26, const Color(0xFF4CAF50))
            ])),
        const SizedBox(width: 15),
        Expanded(flex: 4, child: _buildAttendanceGauge(76)),
      ]),
      const SizedBox(height: 25),
      _buildPayrollSummaryCard(),
    ]);
  }

  // ✅ GitHub Transactions Tab integrated here
  Widget _buildTransactionsTab() {
    return Column(children: [
      Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8)),
          child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Approved Budget: ₹1,80,00,000",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("View Version",
                    style: TextStyle(
                        color: AppColors.primaryBlue,
                        decoration: TextDecoration.underline,
                        fontSize: 12))
              ])),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(
            flex: 5,
            child: Column(children: [
              _buildBudgetCard(
                  "Total Expenses", "₹28,40,000", AppColors.alertRed),
              const SizedBox(height: 12),
              _buildBudgetCard(
                  "Available Balance", "₹46,60,000", AppColors.primaryBlue)
            ])),
        Expanded(
            flex: 6,
            child: SizedBox(
                height: 160,
                child: PieChart(PieChartData(sections: [
                  PieChartSectionData(
                      color: AppColors.primaryBlue,
                      value: 65,
                      radius: 10,
                      showTitle: false),
                  PieChartSectionData(
                      color: AppColors.alertRed,
                      value: 15,
                      radius: 10,
                      showTitle: false),
                  PieChartSectionData(
                      color: const Color(0xFF00C4B4),
                      value: 20,
                      radius: 10,
                      showTitle: false)
                ]))))
      ]),
      const SizedBox(height: 16),
      InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TransactionHistoryScreen())),
          child: const Text("View Transactions",
              style: TextStyle(
                  color: AppColors.primaryBlue,
                  decoration: TextDecoration.underline))),
      if (!_isHeaderVisible)
        Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateRequestScreen())),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text("Create Request",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)))))
    ]);
  }

  Widget _buildTimelineTab() {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(timelineControllerProvider).valueOrNull;
      if (state != null && state.timelines.isNotEmpty)
        return TimelineTab(timelineId: state.timelines.first.id);
      return const Center(
          child: Text("No Timeline found. Click + to create one."));
    });
  }

  Widget _buildOverviewTab() {
    return Column(children: [
      Row(children: [
        _buildProgressCircle(),
        const SizedBox(width: 25),
        Expanded(
            child: Column(children: [
          _rowInfo("Location:", project.location),
          _rowInfo("Manager:", project.createdBy?.name ?? "Not Assigned"),
          _rowInfo("Engineer:", "Assigned")
        ]))
      ]),
      const SizedBox(height: 30),
      _buildRecentActivities(),
      const Divider(),
      _buildMilestones(),
    ]);
  }

  // ================== HELPER WIDGETS (Unified) ==================
  Widget _buildHeaderSection() {
    Color statusColor = project.status == ProjectStatus.ongoing
        ? const Color(0xFFF9A825)
        : (project.status == ProjectStatus.completed
            ? AppColors.successGreen
            : AppColors.alertRed);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          flex: 3,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(project.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(project.location, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),
            _rowText(
                "Start:", DateFormat('dd MMM yyyy').format(project.startDate)),
            _rowText("End:",
                DateFormat('dd MMM yyyy').format(project.estimatedEndDate))
          ])),
      Expanded(
          flex: 2,
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EditProjectScreen(project: project))),
                  icon: const Icon(Icons.edit, color: Colors.grey)),
              IconButton(
                  onPressed: _showDeleteActionSheet,
                  icon: const Icon(Icons.delete, color: AppColors.alertRed))
            ]),
            _richText("Progress: ", "${project.progress ?? 0}%", true),
            _richText("Priority: ", project.priority.name.toUpperCase(), true,
                color: AppColors.alertRed),
            const SizedBox(height: 10),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(project.status.name.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)))
          ])),
    ]);
  }

  Widget _buildMetricsRow() => Row(children: [
        _metricCard(Icons.payments_outlined,
            "₹${project.estimatedBudget.toInt()}", "Budget"),
        const SizedBox(width: 12),
        _metricCard(Icons.timer_outlined, "1395 Days", "Left"),
        const SizedBox(width: 12),
        _metricCard(Icons.analytics_outlined, "6", "Tasks")
      ]);

  Widget _buildTabBar() {
    final tabs = [
      'Overview',
      'Attendance',
      'Inventory',
      'Transactions',
      'DPR',
      'Tasks',
      'Sub-contractor',
      'Timeline'
    ];
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            children: tabs
                .map((tab) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: OutlinedButton(
                        onPressed: () => setState(() => _selectedTab = tab),
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: _selectedTab == tab
                                    ? AppColors.primaryBlue
                                    : Colors.grey.shade300)),
                        child: Text(tab,
                            style: TextStyle(
                                color: _selectedTab == tab
                                    ? AppColors.primaryBlue
                                    : Colors.grey)))))
                .toList()));
  }

  Widget _buildProgressCircle() => Column(children: [
        SizedBox(
            height: 100,
            width: 100,
            child: Stack(fit: StackFit.expand, children: [
              CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation(
                      AppColors.lightGrey.withOpacity(0.3))),
              CircularProgressIndicator(
                  value: (project.progress ?? 0) / 100,
                  strokeWidth: 10,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primaryBlue),
                  strokeCap: StrokeCap.round),
              Center(
                  child: Text("${project.progress ?? 0}%",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)))
            ]))
      ]);

  Widget _buildAttendanceGauge(int total) => Container(
      height: 140,
      alignment: Alignment.center,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
            height: 130,
            width: 130,
            child: CircularProgressIndicator(
                value: 0.76,
                strokeWidth: 14,
                backgroundColor: Colors.blue.shade50,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF0D6EFD)),
                strokeCap: StrokeCap.round)),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text("$total",
              style:
                  const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const Text("Total\nWorkforce",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600))
        ])
      ]));

  // Common UI components
  Widget _buildStatCard(String t, int v, Color c) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(t,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        Text("$v",
            style:
                TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: c))
      ]));
  Widget _buildPayrollSummaryCard() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Overall Payroll: ₹21,600",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PayrollDetailsScreen())),
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xFF0D6EFD),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text("View",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))))
        ]),
        const SizedBox(height: 15),
        _rowText("Labours:", "₹10,600"),
        const SizedBox(height: 8),
        _rowText("Staff:", "₹11,000")
      ]));
  Widget _buildBudgetCard(String t, String a, Color c) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(children: [
        Text(t,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(a,
            style:
                TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: c))
      ]));
  Widget _metricCard(IconData i, String t, String s) => Expanded(
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
            Text(s, style: const TextStyle(color: Colors.grey, fontSize: 10))
          ])));
  Widget _rowText(String l, String v) => Row(children: [
        Text("$l ", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(v,
            style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600))
      ]);
  Widget _rowInfo(String l, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text("$l ", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(
            child: Text(v,
                style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 13),
                overflow: TextOverflow.ellipsis))
      ]));
  Widget _richText(String l, String v, bool b, {Color color = Colors.black}) =>
      RichText(
          text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.black),
              children: [
            TextSpan(text: l),
            TextSpan(
                text: v,
                style: TextStyle(
                    fontWeight: b ? FontWeight.bold : FontWeight.normal,
                    color: color))
          ]));
  Widget _buildDividerArrow() => Container(
      height: 30,
      color: Colors.white,
      child: Stack(alignment: Alignment.center, children: [
        const Divider(),
        GestureDetector(
            onTap: () => setState(() => _isHeaderVisible = !_isHeaderVisible),
            child: Container(
                height: 24,
                width: 24,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Icon(
                    _isHeaderVisible
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                    size: 18)))
      ]));
  Widget _buildRecentActivities() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Recent Activities",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        _activityItem(Icons.attachment, "DPR submitted", "Today 6:30 PM")
      ]);
  Widget _activityItem(IconData i, String t, String time) => ListTile(
      leading: Icon(i, color: AppColors.primaryBlue, size: 20),
      title: Text(t, style: const TextStyle(fontSize: 13)),
      trailing:
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      contentPadding: EdgeInsets.zero,
      dense: true);
  Widget _buildMilestones() => Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Milestones",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          TextButton(onPressed: () {}, child: const Text("View all"))
        ]),
        _milestoneItem("Foundation Work", "28 Dec 2025", true)
      ]);
  Widget _milestoneItem(String t, String d, bool c) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.background, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(t, style: const TextStyle(fontWeight: FontWeight.w500)),
        Icon(c ? Icons.check_circle : Icons.radio_button_unchecked,
            color: c ? Colors.green : Colors.grey, size: 20)
      ]));

  Widget? _buildFab() {
    if (!['Sub-contractor', 'Timeline', 'DPR'].contains(_selectedTab)) {
      return null;
    }
    return FloatingActionButton(
        onPressed: () {
          if (_selectedTab == 'Sub-contractor') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddSubContractorScreen(projectId: project.id)));
          } else if (_selectedTab == 'Timeline') {
            final tId = ref
                .read(timelineControllerProvider)
                .valueOrNull
                ?.timelines
                .firstOrNull
                ?.id;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => tId != null
                        ? CreateTimelineVersionScreen(timelineId: tId)
                        : ct.CreateTimelineScreen(projectId: project.id)));
          } else if (_selectedTab == 'DPR')
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateDPRScreen(
                  scrollController: ScrollController(),
                ),
              ),
            );
        },
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white));
  }
}
