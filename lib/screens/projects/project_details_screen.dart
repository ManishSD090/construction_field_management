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

// ==========================================================================
// SCREEN
// ==========================================================================

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

        // Trigger the fetch for this project's timeline using the global controller
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(timelineControllerProvider.notifier)
              .refresh(projectId: project.id);
        });
      }
    }
  }

  // ================== DELETE & SUCCESS LOGIC ==================

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
                const Text(
                  "Delete Project",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.alertRed,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Are you sure you want to delete '${project.name}'? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textDark),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close bottom sheet
                          _performDeleteProject();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.alertRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.white),
                        ),
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

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete project: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Icon(Icons.check_circle,
              color: AppColors.successGreen, size: 50),
          content: const Text(
            "Project deleted successfully.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Pop back to project list screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
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

          // Show overlay loader if deleting
          if (_isDeleting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              ),
            ),
        ],
      ),
    );
  }

  // ================== COMPONENTS ==================

  Widget _buildDividerArrow() {
    return Container(
      height: 30,
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Divider(color: AppColors.lightGrey, thickness: 1),
          GestureDetector(
            onTap: () {
              setState(() {
                _isHeaderVisible = !_isHeaderVisible;
              });
            },
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.lightGrey),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ],
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
    if (!['Tasks', 'Sub-contractor', 'Timeline', 'DPR']
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
          // ✅ Use ref.read to grab the latest timeline state
          final timelineState =
              ref.read(timelineControllerProvider).valueOrNull;

          // Check if a timeline already exists
          final existingTimelineId =
              (timelineState != null && timelineState.timelines.isNotEmpty)
                  ? timelineState.timelines.first.id
                  : null;

          if (existingTimelineId != null) {
            // Timeline exists -> Open the version creation form
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateTimelineVersionScreen(
                          timelineId: existingTimelineId,
                        )));
          } else {
            // No timeline exists -> Open the master timeline creation form
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ct.CreateTimelineScreen(
                          projectId: project.id,
                        )));
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

  Widget _buildHeaderSection() {
    final int progressInt = project.progress ?? 0;

    // Status color selection block
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

  Widget _buildTabBar() {
    final tabs = [
      'Overview',
      'Tasks',
      'Sub-contractor',
      'Timeline',
      'Attendance',
      'DPR',
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

  Widget _buildTabContent() {
    if (_selectedTab == 'Tasks') return const ProjectTasksTab();
    if (_selectedTab == 'Sub-contractor') {
      return ProjectSubContractorsList(projectId: project.id);
    }

    // ✅ Handle Timeline Tab directly via the TimelineController's State
    if (_selectedTab == 'Timeline') {
      return Consumer(
        builder: (context, ref, child) {
          final timelineAsyncValue = ref.watch(timelineControllerProvider);

          return timelineAsyncValue.when(
            data: (state) {
              if (state.timelines.isNotEmpty) {
                return TimelineTab(timelineId: state.timelines.first.id);
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Text(
                      "No Timeline found.\nClick '+' to create one.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                    ),
                  ),
                );
              }
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(child: Text("Error fetching timeline: $error")),
            ),
          );
        },
      );
    }

    if (_selectedTab == 'DPR') return const ProjectDPRTab();

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

    // Fallback for unattended tabs
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Text("$_selectedTab Module Coming Soon!"),
      ),
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
        const SizedBox(height: 10),

        // Disable VIEW Gantt chart if no timeline is available by pulling state
        Consumer(builder: (context, ref, child) {
          final timelineAsync = ref.watch(timelineControllerProvider);
          final state = timelineAsync.valueOrNull;

          // Extract timelineId if available
          final tId = (state != null && state.timelines.isNotEmpty)
              ? state.timelines.first.id
              : null;

          return ElevatedButton(
            onPressed: () {
              if (tId != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GanttChartScreen(timelineId: tId)));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Please create a timeline first to view the Gantt chart.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    tId != null ? AppColors.primaryBlue : AppColors.lightGrey,
                minimumSize: const Size(80, 28),
                shape: const StadiumBorder()),
            child: const Text("VIEW",
                style: TextStyle(color: Colors.white, fontSize: 10)),
          );
        })
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
              style: const TextStyle(fontSize: 12, color: AppColors.textDark),
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

  Widget _buildStatusChip(ProjectStatus s, Color color) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(20)),
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
