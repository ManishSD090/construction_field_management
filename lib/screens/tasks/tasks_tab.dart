import 'dart:async'; // ✅ Added for Timer (Debounce)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart'; // ✅ Added Dio import for error handling

import 'package:construction_erp/screens/tasks/task_details.dart'; // Adjust if needed
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/task.dart';
import 'package:construction_erp/models/enums.dart';

// IMPORTANT: Adjust this import to point to where your TaskController is defined!
import 'package:construction_erp/controllers/task/task_controller.dart';

class ProjectTasksTab extends ConsumerStatefulWidget {
  final bool showAppBar;
  final String?
      projectId; // Helpful if we want to fetch tasks for a specific project

  const ProjectTasksTab({
    super.key,
    this.showAppBar = false,
    this.projectId,
  });

  @override
  ConsumerState<ProjectTasksTab> createState() => _ProjectTasksTabState();
}

class _ProjectTasksTabState extends ConsumerState<ProjectTasksTab> {
  Timer? _debounce; // ✅ Added Timer for search debouncing

  // ✅ Separate local states to distinguish between search loading and button loading
  bool _isSearchLoading = false;
  bool _isButtonLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch the initial data when the tab is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _isSearchLoading = true);
      await ref.read(taskControllerProvider.notifier).refresh(
            projectId: widget.projectId,
          );
      if (mounted) {
        setState(() => _isSearchLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel(); // ✅ Cancel timer to prevent memory leaks
    super.dispose();
  }

  // Helper to format the task dates safely
  String _formatDuration(DateTime? start, DateTime? end) {
    if (start == null && end == null) return "Not set";
    if (start != null && end == null) {
      return "${DateFormat('dd MMM yyyy').format(start)} - TBD";
    }
    if (start == null && end != null) {
      return "Due ${DateFormat('dd MMM yyyy').format(end)}";
    }
    return "${DateFormat('dd MMM').format(start!)} - ${DateFormat('dd MMM yyyy').format(end!)}";
  }

  // Helper to get nice UI colors based on the backend TaskStatus enum
  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return AppColors.lightGrey; // Or a neutral blue
      case TaskStatus.inProgress:
        return AppColors.warningYellow;
      case TaskStatus.review:
        return AppColors.primaryBlue;
      case TaskStatus.completed:
        return AppColors.successGreen;
      case TaskStatus.blocked:
        return AppColors.alertRed;
      default:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the AsyncValue from Riverpod
    final taskStateAsync = ref.watch(taskControllerProvider);
    final taskState = taskStateAsync.value;
    final tasks = taskState?.tasks ?? [];

    // ✅ Logic to determine which loader to show
    final bool isRiverpodLoading =
        taskStateAsync.isLoading || taskStateAsync.isRefreshing;
    final bool showLinearLoader =
        _isSearchLoading || (isRiverpodLoading && !_isButtonLoading);

    final bool isAnyLoading =
        _isSearchLoading || _isButtonLoading || isRiverpodLoading;
    final bool isLoadingInitial =
        isAnyLoading && tasks.isEmpty && !taskStateAsync.hasError;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- SEARCH BAR ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: TextField(
            onChanged: (value) {
              // ✅ Debounce Logic: Wait 500ms after the user stops typing
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () async {
                setState(() => _isSearchLoading = true);
                await ref.read(taskControllerProvider.notifier).refresh(
                      projectId: widget.projectId,
                      search: value,
                    );
                if (mounted) {
                  setState(() => _isSearchLoading = false);
                }
              });
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.search, color: AppColors.textGrey, size: 26),
              hintText: "Search Tasks",
              hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 16),
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
              suffixIcon:
                  Icon(Icons.mic_none, color: AppColors.textGrey, size: 26),
            ),
          ),
        ),

        const SizedBox(height: 25),

        // --- HEADER ROW ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tasks list",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Row(
              children: [
                // Manual Refresh Button for embedded view
                if (!widget.showAppBar)
                  // ✅ Rotating refresh button strictly tied to button press
                  _isButtonLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primaryBlue),
                          ),
                        )
                      : IconButton(
                          onPressed: () async {
                            setState(() => _isButtonLoading = true);
                            await ref
                                .read(taskControllerProvider.notifier)
                                .refresh(projectId: widget.projectId);
                            if (mounted) {
                              setState(() => _isButtonLoading = false);
                            }
                          },
                          icon: const Icon(Icons.refresh,
                              color: AppColors.primaryBlue),
                          tooltip: "Refresh Tasks",
                        ),

                // Filter Button
                InkWell(
                  onTap: () {
                    // Open a filter bottom sheet to filter by Status, Priority, etc.
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.primaryBlue.withOpacity(0.6)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          "Filter",
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.tune,
                          size: 16,
                          color: AppColors.primaryBlue.withOpacity(0.8),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),

        // ✅ Top Loading Indicator strictly for Search or background loads
        if (showLinearLoader && tasks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
              color: AppColors.primaryBlue,
            ),
          )
        else
          const SizedBox(height: 15),

        // --- LIST VIEW (Riverpod State) ---
        if (isLoadingInitial)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue)),
          )
        else if (taskStateAsync.hasError && tasks.isEmpty)
          // ✅ Show Beautiful Error State
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child:
                _buildErrorState(taskStateAsync.error!, _isButtonLoading, ref),
          )
        else if (tasks.isEmpty)
          // ✅ Show Beautiful Empty State
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: _buildEmptyState(),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Important: Prevents scroll hijacking
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final Task task = tasks[index];

              // Map Backend Task fields to UI fields
              final isAssigned =
                  task.assignedToId != null && task.assignedToId!.isNotEmpty;
              final assignedStatusText = isAssigned
                  ? (task.assignedTo?.name ?? "Assigned")
                  : "Unassigned";

              // Calculate Subtasks correctly
              final totalSubtasks =
                  task.subtasks?.length ?? task.counts?['subtasks'] ?? 0;
              final completedSubtasks =
                  task.subtasks?.where((s) => s.isCompleted).length ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: InkWell(
                  onTap: () {
                    // Navigate to Task Details Screen and pass the specific task ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TaskDetailsScreen(taskId: task.id),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: TaskCard(
                    title: task.title,
                    assignedStatus: assignedStatusText,
                    duration: _formatDuration(task.startDate, task.dueDate),
                    subtasksCompleted: completedSubtasks,
                    subtasksTotal: totalSubtasks,
                    status: task.status.toDisplayString(),
                    statusColor: _getStatusColor(task.status),
                  ),
                ),
              );
            },
          ),

        // Load More Button
        if (taskState?.hasMore == true && !isLoadingInitial)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: TextButton(
                onPressed: () {
                  ref.read(taskControllerProvider.notifier).loadNextPage();
                },
                child: taskState!.isLoadingMore
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Load More Tasks",
                        style: TextStyle(color: AppColors.primaryBlue)),
              ),
            ),
          ),

        // Add padding ONLY if it's the standalone screen (not embedded in tabs)
        if (widget.showAppBar) const SizedBox(height: 80),
      ],
    );

    // If viewing as a standalone screen, apply the layout with App Bar & Pull-To-Refresh
    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "All Tasks",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
        ),
        body: RefreshIndicator(
          color: AppColors.primaryBlue,
          onRefresh: () async {
            setState(() => _isButtonLoading = true);
            await ref
                .read(taskControllerProvider.notifier)
                .refresh(projectId: widget.projectId);
            if (mounted) {
              setState(() => _isButtonLoading = false);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.all(20), // Standalone screen needs padding
            child: content,
          ),
        ),
      );
    } else {
      // EMBEDDED MODE (Inside ProjectDetailsScreen)
      return content;
    }
  }

  // --- Beautiful Error State ---
  Widget _buildErrorState(Object error, bool isButtonLoading, WidgetRef ref) {
    String errorMessage = _parseErrorMessage(error);

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getErrorIcon(error),
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Oops! Something went wrong",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isButtonLoading
                  ? null
                  : () async {
                      setState(() => _isButtonLoading = true);
                      await ref.read(taskControllerProvider.notifier).refresh(
                            projectId: widget.projectId,
                          );
                      if (mounted) {
                        setState(() => _isButtonLoading = false);
                      }
                    },
              icon: isButtonLoading
                  ? Container(
                      width: 16,
                      height: 16,
                      padding: const EdgeInsets.all(2),
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.refresh, size: 18),
              label: Text(isButtonLoading ? "Retrying..." : "Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.7),
                disabledForegroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Beautiful Empty State ---
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined,
              size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("No tasks found",
              style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text("Try adjusting your search or add a new task.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ],
      ),
    );
  }

  // --- Error Parsing Logic ---
  String _parseErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Connection timed out. Please check your internet connection.";
        case DioExceptionType.connectionError:
          return "Unable to connect to the server. Please verify your network.";
        case DioExceptionType.badResponse:
          final serverMessage = error.response?.data?['message'];
          return serverMessage ?? "Server error occurred. Please try again.";
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
}

class TaskCard extends StatelessWidget {
  final String title;
  final String assignedStatus;
  final String duration;
  final int subtasksCompleted;
  final int subtasksTotal;
  final String status;
  final Color statusColor;

  const TaskCard({
    super.key,
    required this.title,
    required this.assignedStatus,
    required this.duration,
    required this.subtasksCompleted,
    required this.subtasksTotal,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title and Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Row 2: Assigned Status
          Text(
            assignedStatus,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: assignedStatus.toLowerCase() == 'unassigned'
                  ? AppColors.alertRed
                  : AppColors.primaryBlue,
            ),
          ),

          const SizedBox(height: 10),

          // Row 3: Duration and Subtasks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  children: [
                    const TextSpan(text: "Duration: "),
                    TextSpan(
                      text: duration,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  children: [
                    const TextSpan(text: "Subtasks: "),
                    TextSpan(
                      text: "$subtasksCompleted/$subtasksTotal",
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
