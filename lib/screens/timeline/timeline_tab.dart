import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/screens/timeline/edit_timeline.dart';
import 'package:construction_erp/controllers/admin/user_controller.dart';
import 'package:construction_erp/controllers/timeline/timeline_controller.dart';
import 'package:construction_erp/models/timeline.dart'; // Import TimelineVersion
import 'package:construction_erp/models/enums.dart';

class TimelineTab extends ConsumerStatefulWidget {
  final String timelineId;

  const TimelineTab({
    super.key,
    required this.timelineId,
  });

  @override
  ConsumerState<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends ConsumerState<TimelineTab> {
  late int _selectedMonth;
  late int _selectedYear;

  // Version Control
  String? _selectedVersionId;
  List<TimelineVersion> _versions = [];
  bool _isLoadingVersions = true;

  // Local state to hold the future for our calendar data
  Future<Map<String, dynamic>>? _calendarFuture;

  final List<int> _months = List.generate(12, (i) => i + 1);
  late List<int> _years;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _years = List.generate(5, (i) => now.year - 1 + i);

    _fetchVersions();
  }

  Future<void> _fetchVersions() async {
    try {
      final versions = await ref
          .read(timelineControllerProvider.notifier)
          .getTimelineVersions(widget.timelineId);

      if (mounted) {
        setState(() {
          _versions = versions;
          if (versions.isNotEmpty && _selectedVersionId == null) {
            _selectedVersionId = versions.first.id;
          }
          _isLoadingVersions = false;
        });
        _fetchCalendarData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingVersions = false);
        _fetchCalendarData();
      }
    }
  }

  void _fetchCalendarData() {
    // Add a guard to ensure we have a valid version if required by API
    if (_versions.isEmpty && _selectedVersionId == null) {
      debugPrint("No versions found yet, skipping calendar fetch");
      return;
    }
    setState(() {
      _calendarFuture = ref
          .read(timelineControllerProvider.notifier)
          .getTimelineCalendar(widget.timelineId, _selectedYear, _selectedMonth,
              versionId: _selectedVersionId // Ensure this isn't null
              );
    });
  }

  TimelineVersion? get _selectedVersion {
    if (_selectedVersionId == null || _versions.isEmpty) return null;
    try {
      return _versions.firstWhere((v) => v.id == _selectedVersionId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _submitForApproval() async {
    final version = _selectedVersion;
    if (version == null) return;

    // 1. Trigger User Fetch (To get potential approvers)
    await ref
        .read(userControllerProvider.notifier)
        .fetchUsers(status: 'ACTIVE');

    if (!mounted) return;

    final commentController = TextEditingController();
    String? selectedApproverId;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        // Use StatefulBuilder to manage dialog state
        builder: (context, setDialogState) =>
            Consumer(builder: (context, ref, _) {
          final userState = ref.watch(userControllerProvider);
          final users = userState.value?.userList ?? [];
          final bool isLoadingUsers = userState.isLoading;

          return AlertDialog(
            title: const Text("Submit for Approval"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Choose an approver and add any relevant notes."),
                const SizedBox(height: 20),

                // --- Approver Selection ---
                const Text("Approver",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoadingUsers
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: LinearProgressIndicator())
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedApproverId,
                            isExpanded: true,
                            hint: const Text("Select Admin/Manager"),
                            items: users
                                .map((u) => DropdownMenuItem(
                                      value: u.id,
                                      child: Text(u.name ?? u.email ?? u.id),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              // Correctly update state inside the dialog
                              setDialogState(() {
                                selectedApproverId = val;
                              });
                            },
                          ),
                        ),
                ),

                const SizedBox(height: 15),

                // --- Comments ---
                const Text("Submission Notes",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText:
                        "E.g., Adjusted foundation dates due to weather...",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue),
                child:
                    const Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }),
      ),
    );

    if (confirm == true) {
      if (selectedApproverId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Please select an approver."),
            backgroundColor: AppColors.alertRed));
        return;
      }

      try {
        await ref
            .read(timelineControllerProvider.notifier)
            .submitVersionForApproval(
                widget.timelineId, version.versionNumber, {
          "approverId": selectedApproverId,
          "comments": commentController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Submitted for review successfully"),
              backgroundColor: AppColors.successGreen));
          _fetchVersions();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Submission failed: $e"),
              backgroundColor: AppColors.alertRed));
        }
      }
    }
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC"
    ];
    return months[month - 1];
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'N/A';
    try {
      final date = DateTime.parse(isoDate);
      return "${date.day} ${_getMonthAbbreviation(date.month)} ${date.year}";
    } catch (e) {
      return isoDate.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isLoadingVersions && _versions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              children: [
                Expanded(child: _buildVersionSelector()),
                if (_selectedVersion?.status == TimelineVersionStatus.draft ||
                    _selectedVersion?.status == TimelineVersionStatus.rejected)
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: ElevatedButton(
                      onPressed: _submitForApproval,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("SUBMIT",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        FutureBuilder<Map<String, dynamic>>(
            future: _calendarFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator()));
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 40),
                      const Text(
                          "Unable to load timeline. Please check your connection or server status."),
                      ElevatedButton(
                          onPressed: _fetchVersions, child: const Text("Retry"))
                    ],
                  ),
                );
              }

              final data = snapshot.data;
              final timelineInfo = data?['timelineInfo'] ?? {};
              final summary = data?['summary'] ?? {};
              final tasksByWeek =
                  (data?['tasksByWeek'] as Map<String, dynamic>?) ?? {};

              final totalTasks = summary['totalTasks'] ?? 0;
              final totalWeeks = summary['totalWeeks'] ?? 0;
              final startDate = timelineInfo['startDate'];
              final endDate = timelineInfo['endDate'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(timelineInfo['name'] ?? "Timeline",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditTimelineScreen(
                                          timelineId: widget.timelineId)))
                              .then((_) {
                            _fetchVersions();
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.edit,
                                color: Colors.grey, size: 18)),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Tasks - $totalTasks",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      Text("Active Weeks - $totalWeeks",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      Text(
                          "Status: ${_selectedVersion?.status.toDisplayString() ?? 'N/A'}",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          _buildDropdown(
                              value: _selectedMonth,
                              items: _months,
                              labelBuilder: (val) => _getMonthAbbreviation(val),
                              onChanged: (val) {
                                if (val != null && val != _selectedMonth) {
                                  setState(() {
                                    _selectedMonth = val;
                                    _fetchCalendarData();
                                  });
                                }
                              }),
                          const SizedBox(width: 10),
                          _buildDropdown(
                              value: _selectedYear,
                              items: _years,
                              labelBuilder: (val) => val.toString(),
                              onChanged: (val) {
                                if (val != null && val != _selectedYear) {
                                  setState(() {
                                    _selectedYear = val;
                                    _fetchCalendarData();
                                  });
                                }
                              }),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Start date: ${_formatDate(startDate)}",
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade600)),
                          Text("Estimated end date: ${_formatDate(endDate)}",
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade600)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.blue, thickness: 1.5),
                  const SizedBox(height: 15),
                  Center(
                      child: Text(
                          "${_getMonthAbbreviation(_selectedMonth)} $_selectedYear",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 20),
                  const Text("Weekly Tasks",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 15),
                  if (tasksByWeek.isEmpty)
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                            child: Text("No tasks scheduled for this month.",
                                style: TextStyle(color: Colors.grey))))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasksByWeek.keys.length,
                      itemBuilder: (context, index) {
                        String weekKey = tasksByWeek.keys.elementAt(index);
                        List<dynamic> tasks = tasksByWeek[weekKey];
                        String weekNumStr =
                            weekKey.replaceAll(RegExp(r'[^0-9]'), '');
                        int weekNum = int.tryParse(weekNumStr) ?? (index + 1);
                        return _buildWeeklyTaskItem(weekNum, tasks);
                      },
                    ),
                  const SizedBox(height: 80),
                ],
              );
            }),
      ],
    );
  }

  Widget _buildVersionSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVersionId,
          isExpanded: true,
          hint: const Text("Select Version"),
          icon: const Icon(Icons.history, color: AppColors.primaryBlue),
          items: _versions.map((version) {
            bool isBaseline = version.isBaseline;
            String label = "V${version.versionNumber} - ${version.name}";
            return DropdownMenuItem<String>(
              value: version.id,
              child: Row(
                children: [
                  Expanded(
                      child: Text(label,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis)),
                  if (isBaseline)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green)),
                      child: const Text("BASELINE",
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    )
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null && val != _selectedVersionId) {
              setState(() {
                _selectedVersionId = val;
                _fetchCalendarData();
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(
      {required T value,
      required List<T> items,
      required String Function(T) labelBuilder,
      required ValueChanged<T?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue),
          borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<T>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(
                value: e,
                child: Text(labelBuilder(e),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue))))
            .toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
        icon:
            const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue),
        isDense: true,
      ),
    );
  }

  Widget _buildWeeklyTaskItem(int weekNum, List<dynamic> tasks) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40,
              decoration: const BoxDecoration(
                  color: Color(0xFF3B71CA),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8))),
              child: Center(
                  child: Text("$weekNum",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16))),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                    border: Border.all(color: Colors.grey.shade200)),
                child: Column(
                    children: tasks
                        .map((taskData) => _buildExpandableTask(taskData))
                        .toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableTask(dynamic timelineTaskInfo) {
    final taskData = timelineTaskInfo['task'] ?? {};
    final title = taskData['title'] ?? 'Unknown Task';
    final status = timelineTaskInfo['timelineStatus'] ?? 'SCHEDULED';
    final assignee = taskData['assignedTo']?['name'] ?? 'Unassigned';
    final isCritical = timelineTaskInfo['isCritical'] == true;
    final description = taskData['description'] ?? 'No description available.';
    final subtasks = taskData['subtasks'] as List<dynamic>? ?? [];

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        title: Row(
          children: [
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87))),
            if (isCritical)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4)),
                child: Text("CRITICAL",
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        childrenPadding: const EdgeInsets.only(left: 16, bottom: 10, right: 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("• Status: $status",
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 4),
                Text("• Assignee: $assignee",
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 4),
                Text("• Notes: $description",
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                if (subtasks.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text("Subtasks:",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  ...subtasks.map((sub) {
                    final subDesc = sub['description'] ?? 'Unnamed subtask';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0, left: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("• ",
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 14)),
                          Expanded(
                              child: Text(subDesc,
                                  style: const TextStyle(
                                      color: Colors.black87, fontSize: 14))),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}
