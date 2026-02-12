import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/timeline/timeline_controller.dart';
// import 'package:construction_erp/models/project_management.dart';

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
  final double _monthWidth = 140.0; // Slightly wider for better date spacing
  final double _rowHeight = 65.0;
  final double _headerHeight = 50.0;
  final double _labelWidth = 130.0;

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
      body: ganttAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (jsonResponse) {
          // Based on your provided API response structure
          final data = jsonResponse;
          final String? timelineName = data['timelineName'];
          final String? startStr = data['startDate'];
          final String? endStr = data['endDate'];
          final List<dynamic> ganttData = data['ganttData'] ?? [];
          final Map<String, dynamic> metrics = data['metrics'] ?? {};

          if (startStr == null || endStr == null) {
            return const Center(child: Text("Invalid timeline date range"));
          }

          final DateTime timelineStart = DateTime.parse(startStr);
          final DateTime timelineEnd = DateTime.parse(endStr);

          // Calculate total months range for the horizontal scroll width
          final int totalMonths =
              ((timelineEnd.year - timelineStart.year) * 12) +
                  timelineEnd.month -
                  timelineStart.month +
                  1;
          final double totalChartWidth = _monthWidth * totalMonths;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildProjectHeader(
                          timelineName, startStr, endStr, metrics),
                      const SizedBox(height: 25),
                      _buildLegend(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. FIXED LEFT COLUMN (Task Names)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: _headerHeight + 10,
                            width: _labelWidth,
                            alignment: Alignment.centerLeft,
                            child: const Text("TASK LIST",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue)),
                          ),
                          ...ganttData.map((t) =>
                              _buildFixedTaskLabel(t['text'] ?? "Unnamed")),
                        ],
                      ),
                      const SizedBox(width: 10),
                      // 2. SCROLLABLE GANTT AREA
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: totalChartWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTimelineHeader(
                                    timelineStart, totalMonths),
                                const SizedBox(height: 10),
                                ...ganttData.map((t) {
                                  return _buildTimelineRow(
                                    chartStart: timelineStart,
                                    totalMonths: totalMonths,
                                    task: t,
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
            _buildMetricItem("Total", "${metrics['totalTasks'] ?? 0}"),
            _buildMetricItem("Rate", "${metrics['completionRate'] ?? 0}%"),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    "Start: ${DateFormat('dd MMM yyyy').format(DateTime.parse(start))}",
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(
                    "End: ${DateFormat('dd MMM yyyy').format(DateTime.parse(end))}",
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
                fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue)),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
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
                  right: BorderSide(color: Colors.white.withOpacity(0.2))),
            ),
            child: Text(
              monthLabel,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFixedTaskLabel(String label) {
    return Container(
      height: _rowHeight,
      width: _labelWidth,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(right: 10),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTimelineRow({
    required DateTime chartStart,
    required int totalMonths,
    required dynamic task,
  }) {
    // Parse Dates from the API "yyyy-MM-dd"
    final DateTime taskStart = DateTime.parse(task['start_date']);
    final DateTime taskEnd = DateTime.parse(task['end_date']);
    final String status =
        (task['status'] ?? 'scheduled').toString().toLowerCase();
    final String priority =
        (task['priority'] ?? 'medium').toString().toLowerCase();

    // 1. Calculate Horizontal Offset (Left)
    // Find how many months difference from chart start
    int monthsDiff = (taskStart.year - chartStart.year) * 12 +
        taskStart.month -
        chartStart.month;
    // Calculate fractional day offset within that month
    double dayRatio =
        (taskStart.day - 1) / 30; // Approximation for visual placement
    double leftPosition = (monthsDiff * _monthWidth) + (dayRatio * _monthWidth);

    // 2. Calculate Width (Duration)
    // We use the duration from API or calculate from dates
    int durationDays = taskEnd.difference(taskStart).inDays;
    if (durationDays <= 0) durationDays = 1;
    double barWidth = (durationDays / 30) * _monthWidth;

    // 3. Determine Color
    Color barColor = AppColors.primaryBlue;
    if (priority == 'critical' || priority == 'high') barColor = Colors.red;
    if (status == 'completed' || status == 'done')
      barColor = AppColors.successGreen;

    return SizedBox(
      height: _rowHeight,
      child: Stack(
        children: [
          // Vertical Grid Lines (Months)
          Row(
            children: List.generate(
                totalMonths,
                (index) => Container(
                      width: _monthWidth,
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(color: Colors.grey.shade100))),
                    )),
          ),
          // Task Horizontal Bar
          Positioned(
            left: leftPosition,
            top: 15,
            child: Container(
              width:
                  barWidth < 10 ? 10 : barWidth, // Minimum width for visibility
              height: 28,
              decoration: BoxDecoration(
                  color: barColor.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                        color: barColor.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (priority == 'critical')
                      const Icon(Icons.bolt, color: Colors.white, size: 10),
                    if (barWidth > 40)
                      Expanded(
                        child: Text(
                          "${task['duration']}d",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
