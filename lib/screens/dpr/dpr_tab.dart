import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/dpr.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/screens/dpr/create_wpr_screen.dart';
import 'package:construction_erp/screens/dpr/create_dpr_screen.dart';

import 'dpr_details.dart';

class ProjectDPRTab extends StatefulWidget {
  final ValueChanged<int>? onTypeChanged;

  const ProjectDPRTab({super.key, this.onTypeChanged});

  @override
  State<ProjectDPRTab> createState() => _ProjectDPRTabState();
}

class _ProjectDPRTabState extends State<ProjectDPRTab> {

  void _openCreateReport(BuildContext context) {
  if (_selectedType == 0) {
    // Daily -> DPR
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateDPRScreen(
          scrollController: ScrollController(),
        ),
      ),
    );
  } else {
    // Weekly -> WPR
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateWPRScreen(
          scrollController: ScrollController(),
        ),
      ),
    );
  }
}

  int _selectedType = 0; // 0 = Daily, 1 = Weekly
  DailyProgressReport _mapToDummyDpr(Map<String, dynamic> item) {
  final now = DateTime.now();

  DateTime date = now;
  final rawDate = (item['date'] ?? '').toString();

  // daily date format: "25 Sep 2025"
  try {
    date = DateFormat("dd MMM yyyy").parse(rawDate);
  } catch (_) {
    // weekly item fallback: keep now
  }

  // status string -> TaskStatus
  final statusStr = (item['status'] ?? '').toString().toLowerCase();
  TaskStatus status = TaskStatus.values.first;

  // If your enum contains these names, it'll match.
  // Otherwise it will fallback safely.
  TaskStatus? byNameSafe(String name) {
    try {
      return TaskStatus.values.byName(name);
    } catch (_) {
      return null;
    }
  }

  if (statusStr.contains("approved")) {
    status = byNameSafe("APPROVED") ?? byNameSafe("Approved") ?? TaskStatus.values.first;
  } else if (statusStr.contains("submitted")) {
    status = byNameSafe("SUBMITTED") ?? byNameSafe("Submitted") ?? TaskStatus.values.first;
  }

  return DailyProgressReport(
    id: "temp_${now.millisecondsSinceEpoch}",
    reportNo: "DPR-${now.millisecondsSinceEpoch}",
    projectId: "Project A",
    projectName: "Project A",
    preparedById: item['preparedBy']?.toString() ?? "temp_user",
    preparedBy: null,
    date: date,
    weather: "Sunny",
    workDescription: "-",
    completedWork: "-",
    totalWorkers: 0,
    supervisorPresent: false,
    status: status,
    createdAt: now,
    updatedAt: now,
    photos: const [],
    documents: const [],
  );
}

  final List<Map<String, dynamic>> dailyDprList = [
    {
      "date": "25 Sep 2025",
      "preparedBy": "Ajay Singh",
      "status": "Approved",
      "color": const Color(0xFF4CAF50),
    },
    {
      "date": "26 Sep 2025",
      "preparedBy": "Ajay Singh",
      "status": "Submitted",
      "color": const Color(0xFF1976D2),
    },
    {
      "date": "27 Sep 2025",
      "preparedBy": "Ajay Singh",
      "status": "Submitted",
      "color": const Color(0xFF1976D2),
    },
  ];

  final List<Map<String, dynamic>> weeklyDprList = [
    {
      "date": "Week 1 (Sep 2025)",
      "preparedBy": "Ajay Singh",
      "status": "Approved",
      "color": const Color(0xFF4CAF50),
    },
    {
      "date": "Week 2 (Sep 2025)",
      "preparedBy": "Ajay Singh",
      "status": "Submitted",
      "color": const Color(0xFF1976D2),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentList = _selectedType == 0 ? dailyDprList : weeklyDprList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Daily / Weekly Toggle (Segmented) ---
        Container(
          height: 42,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.12),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedType = 0);
                    widget.onTypeChanged?.call(_selectedType);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedType == 0
                          ? AppColors.primaryBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      "Daily",
                      style: TextStyle(
                        color: _selectedType == 0
                            ? Colors.white
                            : AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedType = 1);
                    widget.onTypeChanged?.call(_selectedType);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedType == 1
                          ? AppColors.primaryBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      "Weekly",
                      style: TextStyle(
                        color: _selectedType == 1
                            ? Colors.white
                            : AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // --- Header Row (Title, Icons, Filter) ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              const Text(
                "DPR list",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.grey, size: 20),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.alertRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete,
                    color: AppColors.alertRed, size: 20),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _openCreateReport(context),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.tune,
                    size: 16, color: AppColors.textDark),
                label: const Text(
                  "Filter",
                  style: TextStyle(color: AppColors.textDark, fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // --- DPR List ---
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: currentList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = currentList[index];

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                final dpr = _mapToDummyDpr(item);

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DPRDetailsScreen(dpr: dpr),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['date'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            children: [
                              const TextSpan(text: "Prepared by: "),
                              TextSpan(
                                text: item['preparedBy'],
                                style: const TextStyle(color: AppColors.primaryBlue),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: item['color'],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['status'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}