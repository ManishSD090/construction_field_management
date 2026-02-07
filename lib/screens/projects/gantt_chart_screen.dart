import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';

class GanttChartScreen extends StatelessWidget {
  const GanttChartScreen({super.key});

  final double _monthWidth = 60.0; // Width for one month column
  final double _rowHeight = 60.0; // Fixed height for each task row
  final double _headerHeight = 50.0; // Fixed height for timeline header

  @override
  Widget build(BuildContext context) {
    // Total width of the chart (12 months)
    final double totalChartWidth = _monthWidth * 12;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Info (Project Title & Status) ---
            _buildProjectHeader(),
            const SizedBox(height: 20),

            // --- Overall Progress Bar ---
            const Text("Progress : 50 %",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.5,
                minHeight: 10,
                backgroundColor: Colors.blue.withOpacity(0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
            ),
            const SizedBox(height: 20),

            // --- Legend ---
            Row(
              children: [
                _buildLegendItem(Colors.red, "Backlog"),
                const SizedBox(width: 15),
                _buildLegendItem(const Color(0xFFF9A825), "Ongoing"),
                const SizedBox(width: 15),
                _buildLegendItem(const Color(0xFF009688), "Completed"),
              ],
            ),
            const SizedBox(height: 20),

            // --- SCROLLABLE GANTT CHART AREA ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. FIXED LEFT COLUMN (Task Names)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Empty Corner Header
                    Container(
                      height: _headerHeight,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Task Name List
                    _buildFixedTaskLabel("Task Name"),
                    _buildFixedTaskLabel("Task Name"),
                    _buildFixedTaskLabel("Task Name"),
                    _buildFixedTaskLabel("Task Name"),
                    _buildFixedTaskLabel("Task Name"),
                    _buildFixedTaskLabel("Task Name"),
                  ],
                ),
                const SizedBox(width: 5),

                // 2. SCROLLABLE RIGHT AREA (Timeline)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: totalChartWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline Header (Year & Months)
                          _buildTimelineHeader(totalChartWidth),
                          const SizedBox(height: 10),

                          // Timeline Rows (Bars)
                          // Jan-Feb (Ongoing)
                          _buildTimelineRow(totalChartWidth, 0, 90,
                              const Color(0xFFF9A825), "12 Jan - 28 Feb"),
                          // Apr-Jun (Completed)
                          _buildTimelineRow(totalChartWidth, 210, 150,
                              const Color(0xFF009688), ""),
                          // May-Jun (Backlog)
                          _buildTimelineRow(
                              totalChartWidth, 280, 80, Colors.red, ""),
                          // Aug-Oct (Future/Blue)
                          _buildTimelineRow(totalChartWidth, 450, 100,
                              Colors.blue.withOpacity(0.3), ""),
                          // Placeholder Empty Rows
                          _buildTimelineRow(
                              totalChartWidth, 0, 0, Colors.transparent, ""),
                          _buildTimelineRow(
                              totalChartWidth, 0, 0, Colors.transparent, ""),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTimelineHeader(double totalWidth) {
    return Column(
      children: [
        // Year Header
        Container(
          width: totalWidth,
          height: 25,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: const Text("2026",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
        // Months Header
        Container(
          width: totalWidth,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: Row(
            children: List.generate(12, (index) {
              // Month Names
              final months = [
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
              return Container(
                width: _monthWidth,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(
                          color: Colors.white.withOpacity(0.5), width: 1)),
                ),
                child: Text(
                  months[index],
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildFixedTaskLabel(String label) {
    return Container(
      height: _rowHeight, // Fixed Height to match timeline rows
      alignment: Alignment.topCenter, // Align with the bar top
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 15), // Spacing between chips
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildTimelineRow(double totalWidth, double startOffset,
      double durationWidth, Color color, String text) {
    return Container(
      height: _rowHeight, // Fixed Height
      alignment: Alignment.topCenter,
      child: Container(
        height: 35, // Bar Height (smaller than row height for padding)
        width: totalWidth,
        margin: const EdgeInsets.only(bottom: 15),
        child: Stack(
          children: [
            // Vertical Grid Lines
            Row(
              children: List.generate(12, (index) {
                return Container(
                  width: _monthWidth,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                );
              }),
            ),
            // Colored Bar
            if (durationWidth > 0)
              Positioned(
                left: startOffset,
                child: Container(
                  width: durationWidth,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: text.isNotEmpty
                      ? Text(text,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Site A - Residential Block",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 4),
                  Text("Mumbai | ID-2341",
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 11, color: Colors.black87),
                    children: [
                      TextSpan(text: "Progress: "),
                      TextSpan(
                          text: "75 %",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 11, color: Colors.black87),
                    children: [
                      TextSpan(text: "Priority: "),
                      TextSpan(
                          text: "High",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9A825),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text("Ongoing",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.edit, color: Colors.white, size: 10)
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Start date: 12 JAN 2026",
                style: TextStyle(fontSize: 11, color: Colors.blue)),
            Text("Estimated end date: 13 Oct 2026",
                style: TextStyle(fontSize: 11, color: Colors.blue)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
