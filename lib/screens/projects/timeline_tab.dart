import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/screens/projects/edit_timeline.dart';
import 'package:construction_erp/controllers/timeline/timeline_controller.dart';
import 'package:construction_erp/models/timeline.dart'; // Import TimelineVersion

class TimelineTab extends ConsumerStatefulWidget {
  final String timelineId; // Need this to fetch specific timeline data

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

    // Generate years dynamically (e.g., previous year to 3 years in future)
    _years = List.generate(5, (i) => now.year - 1 + i);

    // First fetch available versions, then fetch calendar
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
          // Default to the latest version if available (versions are usually sorted desc)
          // If versions list is empty, _selectedVersionId remains null (fetching current state)
          if (versions.isNotEmpty) {
            // You can choose to default to the active/current one, or just the first in list
            _selectedVersionId = versions.first.id;
          }
          _isLoadingVersions = false;
        });
        _fetchCalendarData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingVersions = false);
        // Still try to fetch calendar without version
        _fetchCalendarData();
      }
    }
  }

  void _fetchCalendarData() {
    setState(() {
      _calendarFuture = ref
          .read(timelineControllerProvider.notifier)
          .getTimelineCalendar(widget.timelineId, _selectedYear, _selectedMonth,
              versionId: _selectedVersionId);
    });
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
        // Version Selector (Only show if loaded and multiple versions or just for clarity)
        if (!_isLoadingVersions && _versions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: _buildVersionSelector(),
          ),

        FutureBuilder<Map<String, dynamic>>(
            future: _calendarFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ));
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(
                      "Error loading timeline: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final data = snapshot.data;
              final timelineInfo = data?['timelineInfo'] ?? {};
              final summary = data?['summary'] ?? {};
              final tasksByWeek =
                  (data?['tasksByWeek'] as Map<String, dynamic>?) ?? {};

              // Calculate fallbacks if API data is missing
              final totalTasks = summary['totalTasks'] ?? 0;
              final totalWeeks = summary['totalWeeks'] ?? 0;
              final startDate = timelineInfo['startDate'];
              final endDate = timelineInfo['endDate'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. Header Section ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timelineInfo['name'] ?? "Timeline",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditTimelineScreen(
                                      timelineId: widget
                                          .timelineId, // Pass ID to edit screen
                                    )),
                          ).then((_) {
                            // Refresh versions and data when returning from edit screen
                            _fetchVersions();
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.grey, size: 18),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),

                  // --- 2. Stats Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Tasks - $totalTasks",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      Text("Active Weeks - $totalWeeks",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      Text("Status: ${timelineInfo['status'] ?? 'N/A'}",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // --- 3. Filters & Date Range ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Dropdowns
                      Row(
                        children: [
                          _buildDropdown(
                            value: _selectedMonth,
                            items: _months,
                            labelBuilder: (val) => _getMonthAbbreviation(val),
                            onChanged: (val) {
                              if (val != null && val != _selectedMonth) {
                                _selectedMonth = val;
                                _fetchCalendarData();
                              }
                            },
                          ),
                          const SizedBox(width: 10),
                          _buildDropdown(
                            value: _selectedYear,
                            items: _years,
                            labelBuilder: (val) => val.toString(),
                            onChanged: (val) {
                              if (val != null && val != _selectedYear) {
                                _selectedYear = val;
                                _fetchCalendarData();
                              }
                            },
                          ),
                        ],
                      ),
                      // Date Range Text
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

                  // --- 4. Month Title ---
                  Center(
                    child: Text(
                      "${_getMonthAbbreviation(_selectedMonth)} $_selectedYear",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- 5. Weekly Tasks List ---
                  const Text("Weekly Tasks",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 15),

                  if (tasksByWeek.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text("No tasks scheduled for this month.",
                            style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasksByWeek.keys.length,
                      itemBuilder: (context, index) {
                        String weekKey = tasksByWeek.keys.elementAt(index);
                        List<dynamic> tasks = tasksByWeek[weekKey];

                        // Extract just the number from "Week X" if possible
                        String weekNumStr =
                            weekKey.replaceAll(RegExp(r'[^0-9]'), '');
                        int weekNum = int.tryParse(weekNumStr) ?? (index + 1);

                        return _buildWeeklyTaskItem(weekNum, tasks);
                      },
                    ),

                  // Extra space at bottom
                  const SizedBox(height: 80),
                ],
              );
            }),
      ],
    );
  }

  // --- Version Selector Widget ---
  Widget _buildVersionSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
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

  // --- Helper Widgets ---

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(labelBuilder(e),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue)),
                ))
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
            // Blue Vertical Bar with Week Number
            Container(
              width: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF3B71CA), // Darker Blue
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  "$weekNum",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),

            // List of Tasks (Expandable)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: tasks.map((taskData) {
                    return _buildExpandableTask(taskData);
                  }).toList(),
                ),
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
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
            ),
            if (isCritical)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
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
                          const Text(
                            "• ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              subDesc,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}
