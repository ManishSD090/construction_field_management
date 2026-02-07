import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/screens/projects/project_tab.dart';
import 'package:construction_erp/screens/projects/edit_project.dart';
import 'package:construction_erp/screens/projects/tasks.dart';
import 'package:construction_erp/screens/projects/sub_contractors_list.dart';
import 'package:construction_erp/screens/projects/add_sub_contractor.dart';
import 'package:construction_erp/screens/projects/timeline.dart';
import 'package:construction_erp/screens/projects/create_timeline.dart' as ct;
import 'package:construction_erp/screens/projects/gantt_chart_screen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  String _selectedTab = 'Overview';
  late ProjectModel project;
  bool _isProcessing = false; // Loading state for delete operation

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Project) {
      project = args;
    }
  }

  // ================== DELETE LOGIC START ==================

  // 1. Show Confirmation Bottom Sheet
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
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text("Delete Project? ⚠️",
                    style: TextStyle(
                        color: warningColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Warning Text
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

                // Checkbox
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
                    const Text("I confirm this action",
                        style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 24),

                // Delete Button
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
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),

                // Cancel Button
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

  // 2. Perform Delete Operation (Simulated)
  Future<void> _performDeleteProject() async {
    setState(() => _isProcessing = true);
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 1500));

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

  // 3. Show Success Dialog
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
                          Navigator.pop(
                              context); // Return to previous screen (Project List)
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
        title: const Text("Project details",
            style:
                TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.pop(context)),
      ),

      // Floating Action Button
      floatingActionButton: (_selectedTab == 'Tasks' ||
              _selectedTab == 'Sub-contractor' ||
              _selectedTab == 'Timeline')
          ? FloatingActionButton(
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
                              const CreateSubContractorScreen()));
                } else if (_selectedTab == 'Timeline') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ct.CreateTimelineScreen()));
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
            // Top Header & Metrics
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

            // Tab Bar & Content
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                children: [
                  _buildTabBar(),
                  const SizedBox(height: 25),
                  _buildTabContent(),

                  // Only show Recent Activities & Milestones if ON 'Overview' tab
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
    if (_selectedTab == 'Tasks') return const ProjectTasksTab();
    if (_selectedTab == 'Sub-contractor') return const SubContractorsList();
    if (_selectedTab == 'Timeline') return const TimelineTab();

    if (_selectedTab != 'Overview') {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("Content for $_selectedTab tab")));
    }

    // --- OVERVIEW CONTENT ---
    final int progressInt = (project.progress * 100).toInt();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side: Circular Progress & View Button
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
              const SizedBox(height: 10),

              // VIEW BUTTON
              SizedBox(
                height: 28,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GanttChartScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    elevation: 0,
                  ),
                  child: const Text("VIEW",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 10),
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

  // --- Header Section with Delete Icon Logic ---
  Widget _buildHeaderSection() {
    final int progressInt = (project.progress * 100).toInt();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(project.locationId,
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 14)),
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
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditProjectScreen(project: project)));
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: _buildIconButton(Icons.edit, AppColors.lightGrey),
                  ),
                  const SizedBox(width: 10),
                  // ✅ Delete Icon - Connects to _showDeleteActionSheet
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
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textDark),
                      children: [
                    const TextSpan(text: "Progress: "),
                    TextSpan(
                        text: "$progressInt %",
                        style: const TextStyle(fontWeight: FontWeight.bold))
                  ])),
              const SizedBox(height: 5),
              RichText(
                  text: TextSpan(
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textDark),
                      children: [
                    const TextSpan(text: "Priority: "),
                    TextSpan(
                        text: project.priority,
                        style: const TextStyle(
                            color: AppColors.alertRed,
                            fontWeight: FontWeight.bold))
                  ])),
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
              onPressed: () => setState(() => _selectedTab = tabName),
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
              child: Text(tabName,
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

  // Helper Wrappers
  Widget _buildDetailLinkRow(String l, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("$l ",
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
        Expanded(
            child: Text(v,
                style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis))
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
  Widget _buildIconButton(IconData i, Color c) => Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(i, color: c, size: 20));
  Widget _buildMetricCard(IconData i, String t, String s) => Expanded(
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Icon(i, color: AppColors.primaryBlue),
            const SizedBox(height: 10),
            Text(t,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(s,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
                textAlign: TextAlign.center)
          ])));

  Widget _buildRecentActivities() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Recent Activities",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark)),
      const SizedBox(height: 10),
      const Divider(color: AppColors.lightGrey),
      _buildActivityItem(
          Icons.attachment, "DPR submitted by Site Engineer", "Today 6:30 PM"),
      _buildActivityItem(Icons.inventory_2_outlined,
          "Material request approved: Cement (50 Bags)", "Yesterday 6:30 PM"),
      _buildActivityItem(Icons.check_circle_outline,
          "Task marked completed: Excavation work", "12 Dec 2025"),
      _buildActivityItem(Icons.person_outline,
          "Attendance updated for 42 workers", "11 Dec 2025")
    ]);
  }

  Widget _buildActivityItem(IconData i, String t, String time) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Icon(i, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 15),
        Expanded(
            child: Text(t,
                style: const TextStyle(color: AppColors.textDark, fontSize: 13),
                maxLines: 2)),
        const SizedBox(width: 10),
        Text(time,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 11))
      ]));

  Widget _buildMilestones() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Milestones",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
        TextButton(
            onPressed: () {},
            child: const Text("View all",
                style: TextStyle(
                    color: AppColors.primaryBlue, fontWeight: FontWeight.w600)))
      ]),
      const SizedBox(height: 5),
      _buildMilestoneItem("Foundation Work", "28 Dec 2025", true),
      _buildMilestoneItem("Foundation Work", "28 Dec 2025", true)
    ]);
  }

  Widget _buildMilestoneItem(String t, String d, bool c) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: AppColors.background, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(t,
            style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
                fontSize: 14)),
        Row(children: [
          Text(d,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
          const SizedBox(width: 10),
          Icon(c ? Icons.check_circle : Icons.radio_button_unchecked,
              color: c ? AppColors.successGreen : AppColors.textGrey, size: 18)
        ])
      ]));

  Widget _buildStatusChip(ProjectStatus s) {
    Color b = s == ProjectStatus.ongoing
        ? const Color(0xFFF9A825)
        : (s == ProjectStatus.completed
            ? AppColors.successGreen
            : AppColors.alertRed);
    return Container(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
        decoration:
            BoxDecoration(color: b, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
              s == ProjectStatus.ongoing
                  ? "Ongoing"
                  : (s == ProjectStatus.completed ? "Completed" : "On Hold"),
              style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
          const SizedBox(width: 8),
          Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.edit, color: AppColors.white, size: 12))
        ]));
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
