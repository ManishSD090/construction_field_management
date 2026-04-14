import 'dart:async'; // ✅ Added for Timer (Debounce)
import 'package:construction_erp/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:construction_erp/routes.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/controllers/project/project_controller.dart';

class ProjectTab extends ConsumerStatefulWidget {
  const ProjectTab({super.key});

  @override
  ConsumerState<ProjectTab> createState() => _ProjectTabState();
}

class _ProjectTabState extends ConsumerState<ProjectTab> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

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
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectControllerProvider);

    // ✅ Determine if Riverpod is actively fetching data in the background (search or retry)
    final bool isReloading =
        projectState.isLoading || projectState.isRefreshing;

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: _buildSearchBar(ref),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildListHeader(),
          ),

          // ✅ TOP LOADING INDICATOR (Shows seamlessly during search or error retry)
          if (isReloading && (projectState.hasValue || projectState.hasError))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
                color: AppColors.primaryBlue,
              ),
            )
          else
            const SizedBox(
                height: 13), // 10 top padding + 3 height to prevent layout jump

          Expanded(
            child: projectState.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildErrorState(err, isReloading, ref),
              data: (state) {
                // Empty state handling
                if (state.projects.isEmpty && !state.isLoadingMore) {
                  return RefreshIndicator(
                    color: AppColors.primaryBlue,
                    onRefresh: () =>
                        ref.read(projectControllerProvider.notifier).refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: _buildEmptyState(),
                        ),
                      ],
                    ),
                  );
                }

                // Proper ListView for Data
                return RefreshIndicator(
                  color: AppColors.primaryBlue,
                  onRefresh: () =>
                      ref.read(projectControllerProvider.notifier).refresh(),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 80),
                    physics: const AlwaysScrollableScrollPhysics(),
                    // +1 to show the loading indicator at the bottom if isLoadingMore is true
                    itemCount:
                        state.projects.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      if (index == state.projects.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _ProjectCard(project: state.projects[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            ref.read(projectControllerProvider.notifier).refresh(search: value);
          });
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

  // ✅ Updated Error State to accept `isReloading` to show a spinning button
  Widget _buildErrorState(Object error, bool isReloading, WidgetRef ref) {
    String errorMessage = _parseErrorMessage(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getErrorIcon(error),
                size: 60,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Oops! Something went wrong",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              // Disable button if already reloading to prevent spam-clicks
              onPressed: isReloading
                  ? null
                  : () {
                      ref.read(projectControllerProvider.notifier).refresh();
                    },
              // Swap Icon with a tiny spinner when reloading
              icon: isReloading
                  ? Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(2),
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.refresh, size: 20),
              label: Text(isReloading ? "Retrying..." : "Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                // Keep the button blue even when disabled, just slightly faded
                disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.7),
                disabledForegroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _parseErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Connection timed out. Please check your internet connection or make sure the server is running.";
        case DioExceptionType.connectionError:
          return "Unable to connect to the server. Please verify your network and server IP address.";
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final serverMessage = error.response?.data?['message'];
          return serverMessage ??
              "Server responded with an error ($statusCode). Please try again later.";
        default:
          return "A network error occurred. Please try again.";
      }
    }
    return error.toString().replaceAll('Exception: ', '');
  }

  IconData _getErrorIcon(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError) {
        return Icons.wifi_off_rounded;
      }
    }
    return Icons.error_outline_rounded;
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("No projects found",
              style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text("Try adjusting your search or create a new project.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final double progressValue = (project.progress ?? 0) / 100.0;
    final String progressPercent = (project.progress ?? 0).toString();

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.projectDetails,
            arguments: project);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
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
                          fontSize: 16,
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
                          fontSize: 11,
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
                          fontSize: 10, color: AppColors.textGrey),
                    ),
                    Text(
                      "Start: ${project.startDate.day} ${_getMonth(project.startDate.month)} ${project.startDate.year}",
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textGrey),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: AppColors.textDark),
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
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
                      color: AppColors.primaryBlue,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.textDark,
                  size: 22,
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
        style: const TextStyle(fontSize: 11, color: AppColors.textDark),
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
      return AppColors.primaryBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: getStatusColor(status),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toDisplayString(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
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
