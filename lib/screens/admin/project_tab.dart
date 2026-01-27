import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';

// --- Local Model & Data ---

enum ProjectStatus { ongoing, completed, onHold }

class ProjectModel {
  final String title;
  final String locationId;
  final String priority;
  final ProjectStatus status;
  final String startDate;
  final String endDate;
  final double progress; // 0.0 to 1.0

  ProjectModel({
    required this.title,
    required this.locationId,
    required this.priority,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.progress,
  });
}

final List<ProjectModel> _dummyProjects = [
  ProjectModel(
    title: "Site A - Residential Block",
    locationId: "Mumbai | ID-2341",
    priority: "High",
    status: ProjectStatus.ongoing,
    startDate: "12 JAN 2026",
    endDate: "13 Oct 2026",
    progress: 0.5,
  ),
  ProjectModel(
    title: "Site B - Commercial Complex",
    locationId: "Delhi | ID-9928",
    priority: "High",
    status: ProjectStatus.completed,
    startDate: "10 JAN 2025",
    endDate: "15 Dec 2025",
    progress: 1.0,
  ),
  ProjectModel(
    title: "Site C - Industrial Park",
    locationId: "Pune | ID-1123",
    priority: "High",
    status: ProjectStatus.onHold,
    startDate: "01 FEB 2026",
    endDate: "01 Nov 2026",
    progress: 0.25,
  ),
];

// --- Main Tab Widget ---

class ProjectTab extends StatelessWidget {
  const ProjectTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            "Project list",
            style:
                TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 25),
              _buildListHeader(),
              const SizedBox(height: 15),

              // Project List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _dummyProjects.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  return _ProjectCard(project: _dummyProjects[index]);
                },
              ),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const TextField(
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: "Search Projects",
          hintStyle: TextStyle(
            color: AppColors.textGrey,
            fontSize: 16,
          ),
          icon: Icon(
            Icons.search,
            color: AppColors.textGrey,
            size: 20,
          ),
          suffixIcon: Icon(Icons.mic, color: AppColors.textGrey, size: 20),
          border: InputBorder.none,
          isCollapsed: true, // Removes default padding
          contentPadding: EdgeInsets.symmetric(vertical: 14), // Centers text
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Project List",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textDark,
            side: const BorderSide(color: AppColors.lightGrey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          icon: const Icon(Icons.filter_list, size: 18),
          label: const Text("Filter"),
        ),
      ],
    );
  }
}

// --- Project Card Widget ---
// TODO: Refactor this into a separate file (widgets/project_card.dart) once the ProjectModel is centralized.
class _ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final String progressPercent = (project.progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title/ID vs Priority/Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.locationId,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusChip(project.status),
                  const SizedBox(height: 8),
                  Text("End: ${project.endDate}",
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textGrey)),
                  Text("Start: ${project.startDate}",
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textGrey)),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),

          // Progress Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style:
                      const TextStyle(fontSize: 14, color: AppColors.textDark),
                  children: [
                    const TextSpan(text: "Progress : "),
                    TextSpan(
                      text: "$progressPercent %",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar (Fixed Clipping with Row + Expanded)
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: project.progress,
                    backgroundColor: AppColors.lightGrey,
                    color: AppColors.primaryBlue,
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward,
                  color: AppColors.textDark, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ProjectStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case ProjectStatus.ongoing:
        bgColor = AppColors.statusYellow;
        textColor = AppColors.white;
        label = "Ongoing";
        break;
      case ProjectStatus.completed:
        bgColor = AppColors.tagGreen;
        textColor = AppColors.white;
        label = "Completed";
        break;
      case ProjectStatus.onHold:
        bgColor = AppColors.tagRed;
        textColor = AppColors.white;
        label = "On Hold";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
