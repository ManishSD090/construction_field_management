import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';
// ✅ Import the Edit Screen
import 'package:construction_erp/screens/projects/edit_timeline.dart';

class TimelineTab extends StatefulWidget {
  const TimelineTab({super.key});

  @override
  State<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends State<TimelineTab> {
  // Dummy Data for Dropdowns
  String _selectedMonth = "FEB";
  String _selectedYear = "2026";
  final List<String> _months = [
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
  final List<String> _years = ["2025", "2026", "2027"];

  // Dummy Tasks Data (Grouped by Week Number)
  final Map<int, List<String>> _weeklyTasks = {
    1: ["1. Task Name", "2. Task Name", "3. Task Name", "4. Task Name"],
    2: ["1. Task Name", "2. Task Name", "3. Task Name"],
    3: ["1. Task Name", "2. Task Name", "3. Task Name"],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. Header Section ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Timeline",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // ✅ Wrapped Edit Icon with InkWell for Navigation
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditTimelineScreen()),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.grey, size: 18),
              ),
            )
          ],
        ),
        const SizedBox(height: 15),

        // --- 2. Stats Row ---
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total Months - 12",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text("Total Weeks - 48",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text("Total Days - 365",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
                _buildDropdown(_selectedMonth, _months, (val) {
                  setState(() => _selectedMonth = val!);
                }),
                const SizedBox(width: 10),
                _buildDropdown(_selectedYear, _years, (val) {
                  setState(() => _selectedYear = val!);
                }),
              ],
            ),
            // Date Range Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Start date: 12 JAN 2026",
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                Text("Estimated end date: 13 Oct 2026",
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade600)),
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
            "$_selectedMonth $_selectedYear",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),

        // --- 5. Weekly Tasks List ---
        const Text("Weekly Tasks",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _weeklyTasks.length,
          itemBuilder: (context, index) {
            int weekNum = _weeklyTasks.keys.elementAt(index);
            List<String> tasks = _weeklyTasks[weekNum]!;
            return _buildWeeklyTaskItem(weekNum, tasks);
          },
        ),

        // Extra space at bottom
        const SizedBox(height: 80),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildDropdown(
      String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
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

  Widget _buildWeeklyTaskItem(int weekNum, List<String> tasks) {
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
                  children: tasks.map((taskName) {
                    return _buildExpandableTask(taskName);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableTask(String taskName) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        title: Text(
          taskName,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        childrenPadding: const EdgeInsets.only(left: 16, bottom: 10, right: 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("•  Subtask 1: Description here",
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                SizedBox(height: 4),
                Text("•  Subtask 2: Description here",
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                SizedBox(height: 4),
                Text("•  Subtask 3: Description here",
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
