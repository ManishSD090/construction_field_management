import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/timeline/timeline_controller.dart';

class GanttChartScreen extends ConsumerStatefulWidget {
  final String timelineId;

  const GanttChartScreen({
    super.key,
    required this.timelineId,
  });

  @override
  ConsumerState<GanttChartScreen> createState() => _GanttChartScreenState();
}

class _GanttChartScreenState extends ConsumerState<GanttChartScreen> {
  // Increased width significantly for maximum task text readability
  final double _monthWidth = 600.0;
  final double _baseRowHeight = 40.0;
  final double _headerHeight = 50.0;
  final double _labelWidth = 85.0;

  // Local state to manage the non-modal popup
  dynamic _activePopupTask;
  Offset? _popupPosition;

  void _handleBarTap(dynamic task, Offset globalPosition) {
    setState(() {
      _activePopupTask = task;
      _popupPosition = globalPosition;
    });
  }

  void _dismissPopup() {
    if (_activePopupTask != null) {
      setState(() {
        _activePopupTask = null;
        _popupPosition = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ganttAsync = ref.watch(timelineGanttProvider(widget.timelineId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Timeline Chart",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _dismissPopup,
        child: Stack(
          children: [
            ganttAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
              data: (data) {
                final String? startStr = data['startDate'];
                final String? endStr = data['endDate'];
                final List<dynamic> ganttData = data['ganttData'] ?? [];
                final Map<String, dynamic> metrics = data['metrics'] ?? {};

                if (startStr == null || endStr == null) {
                  return const Center(child: Text("Invalid timeline dates"));
                }

                final DateTime timelineStart = DateTime.parse(startStr);
                final DateTime timelineEnd = DateTime.parse(endStr);

                // Calculate total range in months
                final int totalMonths =
                    ((timelineEnd.year - timelineStart.year) * 12) +
                        timelineEnd.month -
                        timelineStart.month +
                        1;

                final double totalChartWidth = _monthWidth * totalMonths;

                // REFACTOR: Use discrete year/month/week from backend for grouping
                Map<int, Map<int, List<dynamic>>> tasksByMonthAndWeek = {};

                for (var task in ganttData) {
                  final int taskYear = task['year'] ?? timelineStart.year;
                  final int taskMonth = task['month'] ?? timelineStart.month;
                  final int taskWeek = task['week'] ?? 1; // 1-5

                  // Calculate month offset relative to project start
                  int mIdx = (taskYear - timelineStart.year) * 12 +
                      (taskMonth - timelineStart.month);

                  // Week index (0-4)
                  int wIdx = taskWeek - 1;

                  if (!tasksByMonthAndWeek.containsKey(mIdx)) {
                    tasksByMonthAndWeek[mIdx] = {};
                  }
                  if (!tasksByMonthAndWeek[mIdx]!.containsKey(wIdx)) {
                    tasksByMonthAndWeek[mIdx]![wIdx] = [];
                  }
                  tasksByMonthAndWeek[mIdx]![wIdx]!.add(task);
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildProjectHeader(
                            data['timelineName'], startStr, endStr, metrics),
                      ),
                      _buildLegendPadding(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. FIXED LEFT COLUMN (Repeating Weeks 1-5)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: _headerHeight + 2,
                                  width: _labelWidth,
                                  alignment: Alignment.centerLeft,
                                  child: const Text("WEEK",
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryBlue)),
                                ),
                                ...List.generate(totalMonths, (mIdx) {
                                  return Column(
                                    children: List.generate(5, (wIdx) {
                                      final weekTasks =
                                          tasksByMonthAndWeek[mIdx]?[wIdx] ??
                                              [];
                                      double h = _baseRowHeight;
                                      // Stack height for multiple tasks starting same week
                                      if (weekTasks.length > 1) {
                                        h = _baseRowHeight +
                                            ((weekTasks.length - 1) * 40);
                                      }

                                      return _buildFixedWeekLabel(
                                          wIdx + 1, h, mIdx, wIdx);
                                    }),
                                  );
                                }),
                              ],
                            ),
                            // 2. SCROLLABLE CHART AREA
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: totalChartWidth,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildTimelineHeader(
                                          timelineStart, totalMonths),
                                      const SizedBox(height: 2),
                                      ...List.generate(totalMonths, (mIdx) {
                                        return Column(
                                          children: List.generate(5, (wIdx) {
                                            final weekTasks =
                                                tasksByMonthAndWeek[mIdx]
                                                        ?[wIdx] ??
                                                    [];
                                            return _buildTimelineRow(
                                              chartStart: timelineStart,
                                              totalMonths: totalMonths,
                                              monthIndex: mIdx,
                                              weekIndex: wIdx,
                                              tasks: weekTasks,
                                            );
                                          }),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                );
              },
            ),
            if (_activePopupTask != null && _popupPosition != null)
              _buildPopupOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendPadding() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      child: _buildLegend(),
    );
  }

  Widget _buildPopupOverlay() {
    final List<dynamic> subtasks = _activePopupTask['subtasks'] ?? [];
    final double screenWidth = MediaQuery.of(context).size.width;

    double left = _popupPosition!.dx;
    if (left > screenWidth - 220) {
      left -= 210;
    } else {
      left += 10;
    }

    return Positioned(
      left: left,
      top: _popupPosition!.dy - 100,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _activePopupTask['text'] ?? "Subtasks",
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue),
            ),
            const Divider(height: 12),
            if (subtasks.isEmpty)
              const Text("No subtasks",
                  style: TextStyle(fontSize: 10, color: Colors.grey))
            else
              Column(
                children: subtasks.map((sub) {
                  final bool isDone = sub['isCompleted'] == true;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("• ",
                            style: TextStyle(
                                color: isDone
                                    ? AppColors.successGreen
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        Expanded(
                          child: Text(
                            sub['description'] ?? "",
                            style: TextStyle(
                              fontSize: 10,
                              color: isDone ? Colors.grey : Colors.black87,
                              decoration:
                                  isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectHeader(
      String? name, String start, String end, Map<String, dynamic> metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name ?? "Timeline Overview",
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMetricItem("Tasks", "${metrics['totalTasks'] ?? 0}"),
            _buildMetricItem("Subtasks", "${metrics['totalSubtasks'] ?? 0}"),
            _buildMetricItem("Progress",
                "${(metrics['completionRate'] as num?)?.toInt() ?? 0}%"),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    "S: ${DateFormat('dd MMM yy').format(DateTime.parse(start))}",
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
                Text(
                    "E: ${DateFormat('dd MMM yy').format(DateTime.parse(end))}",
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue)),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLegendItem(Colors.red, "Critical"),
          _buildLegendItem(AppColors.primaryBlue, "Scheduled"),
          _buildLegendItem(AppColors.successGreen, "Completed"),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTimelineHeader(DateTime start, int totalMonths) {
    return Container(
      height: _headerHeight,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: List.generate(totalMonths, (index) {
          final monthDate = DateTime(start.year, start.month + index);
          final monthLabel = DateFormat('MMM yyyy').format(monthDate);
          return Container(
            width: _monthWidth,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(
                      color: Colors.white.withOpacity(0.3), width: 2.0)),
            ),
            child: Text(
              monthLabel,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFixedWeekLabel(
      int repeatingWeekNum, double height, int mIdx, int wIdx) {
    bool isMonthStart = wIdx == 0;
    return Container(
      height: height,
      width: _labelWidth,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
          top: isMonthStart
              ? BorderSide(
                  color: AppColors.primaryBlue.withOpacity(0.3), width: 1.5)
              : BorderSide.none,
        ),
      ),
      child: Text(
        "Week $repeatingWeekNum",
        style: TextStyle(
            fontSize: 10,
            fontWeight: isMonthStart ? FontWeight.bold : FontWeight.w500,
            color: Colors.black54),
      ),
    );
  }

  Widget _buildTimelineRow({
    required DateTime chartStart,
    required int totalMonths,
    required int monthIndex,
    required int weekIndex,
    required List<dynamic> tasks,
  }) {
    // REFACTOR: 5 Weeks grid logic
    double weekWidth = _monthWidth / 5;

    // Dynamic height based on stacked tasks
    double rowHeight = _baseRowHeight;
    if (tasks.length > 1) {
      rowHeight = _baseRowHeight + ((tasks.length - 1) * 40);
    }

    bool isMonthStart = weekIndex == 0;

    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        border: Border(
          top: isMonthStart
              ? BorderSide(
                  color: AppColors.primaryBlue.withOpacity(0.3), width: 1.5)
              : BorderSide.none,
        ),
      ),
      child: Stack(
        children: [
          // Background Weekly Grid Lines
          Row(
            children: List.generate(totalMonths * 5, (index) {
              bool isMonthEnd = (index + 1) % 5 == 0;
              return Container(
                width: weekWidth,
                decoration: BoxDecoration(
                    border: Border(
                  right: BorderSide(
                    color: isMonthEnd
                        ? Colors.grey.shade400
                        : Colors.grey.shade100,
                    width: isMonthEnd ? 1.5 : 0.5,
                  ),
                  bottom: BorderSide(color: Colors.grey.shade100, width: 0.5),
                )),
              );
            }),
          ),

          // REFACTOR: Tasks positioning using passed monthIndex and weekIndex
          ...tasks.asMap().entries.map((entry) {
            int taskIdx = entry.key;
            var task = entry.value;

            final String priority =
                (task['priority'] ?? 'medium').toString().toLowerCase();
            final String status =
                (task['status'] ?? 'scheduled').toString().toLowerCase();

            // POSITION FIX: Calculate absolute horizontal offset based on indices to prevent shifts
            double leftPosition =
                (monthIndex * _monthWidth) + (weekIndex * weekWidth);

            // WIDTH FIX: Consistent scaling based on duration (days -> week slots)
            int durationDays = task['duration'] ?? 1;
            double barWidth = (durationDays / 7) * weekWidth;
            if (barWidth < weekWidth) barWidth = weekWidth;

            Color barColor = AppColors.primaryBlue;
            if (priority == 'critical' || priority == 'high') {
              barColor = Colors.red;
            }
            if (status == 'completed' || status == 'done') {
              barColor = AppColors.successGreen;
            }

            return Positioned(
              left: leftPosition,
              top: 5.0 + (taskIdx * 38.0),
              child: GestureDetector(
                onTapDown: (details) =>
                    _handleBarTap(task, details.globalPosition),
                child: Container(
                  width: barWidth - 1,
                  height: 35, // Taller bars for readability
                  decoration: BoxDecoration(
                      color: barColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                            color: barColor.withOpacity(0.15),
                            blurRadius: 2,
                            offset: const Offset(0, 1))
                      ]),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fixed: Text & Icon overflow guards
                      if (priority == 'critical' && barWidth > 40)
                        const Padding(
                          padding: EdgeInsets.only(right: 6.0),
                          child:
                              Icon(Icons.bolt, color: Colors.white, size: 14),
                        ),
                      if (barWidth > 25)
                        Expanded(
                          child: Text(
                            task['text'] ?? "",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
