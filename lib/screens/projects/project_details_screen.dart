import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
import 'package:construction_erp/screens/dpr/dpr_tab.dart';
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
  String _selectedTab =
      'Attendance'; // Set default to Attendance to check the box
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
      // ✅ Using Column ensures the button stays fixed at the bottom while the top area is Expanded/scrollable
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
                    color: Colors.white,
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
          ),
          // ✅ THIS BOX REMAINS FIXED AT THE BOTTOM WHEN HEADER GOES UP
          if (_selectedTab == 'Attendance') _buildFixedBottomMarkAttendance(),
        ],
      ),
    );
  }

  Widget _buildFixedBottomMarkAttendance() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
        ],
      ),
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MarkAttendanceScreen())),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D6EFD),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: const Text("Mark Attendance",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // ================== TAB CONTENT LOGIC ==================

  Widget _buildTabContent() {
    if (_selectedTab == 'Attendance') return _buildAttendanceTabUI();
    if (_selectedTab == 'Tasks') return const ProjectTasksTab();
    if (_selectedTab == 'Sub-contractor')
      return ProjectSubContractorsList(projectId: project.id);
    if (_selectedTab == 'DPR') return const ProjectDPRTab();

    return const Center(child: Text("Module Coming Soon!"));
  }

  Widget _buildAttendanceTabUI() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildStatCard("Labors", 50, const Color(0xFF3B71CA)),
                  const SizedBox(height: 12),
                  _buildStatCard("Staff", 26, const Color(0xFF4CAF50)),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(flex: 4, child: _buildAttendanceGauge(76)),
          ],
        ),
        const SizedBox(height: 25),
        _buildPayrollSummaryCard(),
        const SizedBox(height: 20),
      ],
    );
  }

  // ================== HELPER UI METHODS (DEFINED ONLY ONCE) ==================

  Widget _buildHeaderSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text(project.location,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 15),
              _rowText("Start date:",
                  DateFormat('dd MMM yyyy').format(project.startDate)),
              _rowText("Estimated end date:",
                  DateFormat('dd MMM yyyy').format(project.estimatedEndDate)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        _metricTile(Icons.payments_outlined,
            "₹${project.estimatedBudget.toInt()}", "Budget"),
        const SizedBox(width: 12),
        _metricTile(Icons.timer_outlined, "1395 Days", "Left"),
        const SizedBox(width: 12),
        _metricTile(Icons.analytics_outlined, "6", "Tasks"),
      ],
    );
  }

  Widget _buildStatCard(String title, int val, Color color) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        Text("$val",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ]));

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
          ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PayrollDetailsScreen())),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  shape: const StadiumBorder()),
              child: const Text("View",
                  style: TextStyle(color: Colors.white, fontSize: 12)))
        ]),
        const SizedBox(height: 10),
        const Text("Labours: ₹10,600", style: TextStyle(color: Colors.grey)),
        const Text("Staff: ₹11,000", style: TextStyle(color: Colors.grey)),
      ]));

  Widget _buildTabBar() {
    final tabs = ['Overview', 'Attendance', 'DPR', 'Tasks', 'Sub-contractor'];
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

  Widget _rowText(String l, String v) => Row(children: [
        Text("$l ", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(v,
            style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600))
      ]);
  Widget _metricTile(IconData i, String t, String s) => Expanded(
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

  Widget? _buildFab() => null; // FAB logic can be added here if needed
}
