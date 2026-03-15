import 'package:construction_erp/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/routes.dart';
import 'package:construction_erp/core/services/app_colors.dart';
// Updated Imports
import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/controllers/project/project_controller.dart';

class ProjectTab extends ConsumerStatefulWidget {
  const ProjectTab({super.key});

  @override
  ConsumerState<ProjectTab> createState() => _ProjectTabState();
}

class _ProjectTabState extends ConsumerState<ProjectTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Setup pagination listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(projectControllerProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectControllerProvider);

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
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),
      body: projectState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (state) {
          if (state.projects.isEmpty) {
            return const Center(child: Text("No projects found."));
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(projectControllerProvider.notifier).refresh(),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildSearchBar(ref),
                    const SizedBox(height: 25),
                    _buildListHeader(),
                    const SizedBox(height: 15),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.projects.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        return _ProjectCard(project: state.projects[index]);
                      },
                    ),
                    if (state.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createProject),
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColors.white, size: 32),
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
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
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        onChanged: (value) {
          // You might want to debounce this in a production app
          ref.read(projectControllerProvider.notifier).refresh(search: value);
        },
        decoration: const InputDecoration(
          hintText: "Search Projects",
          hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 16),
          icon: Icon(Icons.search, color: AppColors.textGrey, size: 20),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "All Projects",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark),
        ),
        OutlinedButton.icon(
          onPressed: () {
            // Open filter dialog here
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textDark,
            side: const BorderSide(color: AppColors.lightGrey),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          icon: const Icon(Icons.filter_list, size: 18),
          label: const Text("Filter"),
        ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    // Ensuring progress is handled as a double (0.0 to 1.0)
    final double progressValue = (project.progress ?? 0) / 100.0;
    final String progressPercent = (project.progress ?? 0).toString();

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.projectDetails,
            arguments: project);
      },
      child: Container(
        padding: const EdgeInsets.all(12), // Reduced padding
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upper Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 16, // Reduced from 20
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${project.location} | ${project.projectId}",
                        style: const TextStyle(
                          fontSize: 11, // Reduced from 14
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildPriorityTag(project.priority.name),
                    const SizedBox(height: 4),
                    _buildStatusChip(project.status),
                    const SizedBox(height: 8),
                    Text(
                      "End: ${project.estimatedEndDate.day} ${_getMonth(project.estimatedEndDate.month)} ${project.estimatedEndDate.year}",
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textGrey), // Reduced from 12
                    ),
                    Text(
                      "Start: ${project.startDate.day} ${_getMonth(project.startDate.month)} ${project.startDate.year}",
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textGrey), // Reduced from 12
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16), // Reduced gap

            // Progress Label
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textDark), // Reduced from 22
                children: [
                  const TextSpan(text: "Progress : "),
                  TextSpan(
                    text: "$progressPercent %",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Bottom Section: Progress Bar and Navigation Arrow
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
                      color: AppColors.primaryBlue,
                      minHeight: 8, // Reduced from 12
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.textDark,
                  size: 22, // Reduced from 28
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityTag(String priority) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontSize: 11, color: AppColors.textDark), // Reduced from 14
        children: [
          const TextSpan(text: "Priority: "),
          TextSpan(
            text: priority.toUpperCase(),
            style: const TextStyle(
              color: AppColors.alertRed,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ProjectStatus status) {
    // Helper to get the dynamic color based on status
    Color getStatusColor(ProjectStatus status) {
      final statusName = status.name.toLowerCase();
      if (statusName == 'ongoing') return const Color(0xFFF9A825);
      if (statusName == 'completed') return AppColors.successGreen;
      if (statusName == 'cancelled' || statusName == 'delayed') {
        return AppColors.alertRed;
      }
      if (statusName == 'on_hold' || statusName == 'onhold') {
        return Colors.purple;
      }
      return AppColors.primaryBlue; // Default for Planning
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 4), // Slimmer chip
      decoration: BoxDecoration(
        color: getStatusColor(status), // Applies the dynamic color here
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toDisplayString(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11, // Reduced from 14
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return months[month - 1];
  }
}
