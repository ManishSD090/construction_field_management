import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/screens/tasks/edit_task.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/task.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/controllers/task/task_controller.dart';

class TaskDetailsScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  // Track which subtasks are currently updating to show a loading state
  final Set<String> _updatingSubtasks = {};

  // Helper to format dates for UI
  String _formatDate(DateTime? date) {
    if (date == null) return "Not set";
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Helper to get UI status name
  String _formatStatusName(TaskStatus status) {
    return status.name
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  // Helper to get UI colors based on TaskStatus enum
  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return AppColors.warningYellow;
      case TaskStatus.completed:
        return AppColors.successGreen;
      case TaskStatus.blocked:
        return AppColors.alertRed;
      default:
        return AppColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the specific task details using the family provider
    final taskAsync = ref.watch(taskDetailsProvider(widget.taskId));

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Task Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: taskAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (task) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(taskDetailsProvider(widget.taskId).future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Title & Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            task.project?.name ?? "Unknown Project",
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(task.status),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatStatusName(task.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditTaskScreen(
                                  taskId: task.id,
                                  projectId: task.projectId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit,
                                size: 16, color: AppColors.textGrey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Progress Bar
                Row(
                  children: [
                    const Text(
                      "Progress : ",
                      style: TextStyle(fontSize: 13, color: AppColors.textDark),
                    ),
                    Text(
                      "${task.progress ?? 0} %",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (task.progress ?? 0) / 100,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                    color: AppColors.primaryBlue,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 25),

                // Task Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Task Info",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: Colors.grey.shade200, thickness: 1),
                      const SizedBox(height: 10),
                      _infoRow("Assigned To: ",
                          task.assignedTo?.name ?? "Unassigned"),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _infoRow(
                              "Priority: ",
                              task.priority.name.toUpperCase(),
                            ),
                          ),
                          Expanded(
                            child: _infoRow(
                              "Est. Hours: ",
                              "${task.estimatedHours ?? 0}",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _infoRow("Start Date: ", _formatDate(task.startDate)),
                      const SizedBox(height: 12),
                      _infoRow("Due Date: ", _formatDate(task.dueDate)),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Subtasks Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Subtasks",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.info_outline,
                        size: 14, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    const Text(
                      "Long-press to mark complete",
                      style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (task.subtasks == null || task.subtasks!.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                        child: Text("No subtasks available",
                            style: TextStyle(color: AppColors.textGrey))),
                  )
                else
                  ...task.subtasks!
                      .map((subtask) => _buildSubtaskCard(task, subtask))
                      .toList(),

                const SizedBox(height: 15),

                // Show completion badge if task is actually completed
                if (task.status == TaskStatus.completed)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.completionMint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Completed",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                const SizedBox(height: 25),

                // Photos Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Photos",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: Colors.grey.shade200, thickness: 1),
                      const SizedBox(height: 10),
                      if (task.attachments == null || task.attachments!.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text("No photos uploaded",
                              style: TextStyle(
                                  color: AppColors.textGrey, fontSize: 13)),
                        )
                      else
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: task.attachments!.length,
                            separatorBuilder: (context, i) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, i) =>
                                _buildPhotoThumbnail(task.attachments![i]),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        children: [
          TextSpan(
              text: label, style: const TextStyle(color: AppColors.textGrey)),
          TextSpan(
              text: value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSubtaskCard(Task task, Subtask subtask) {
    final isUpdating = _updatingSubtasks.contains(subtask.id);

    return GestureDetector(
      onTap: isUpdating
          ? null
          : () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text("Long press the card to change completion status"),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
      onLongPress: isUpdating
          ? null
          : () async {
              HapticFeedback.mediumImpact();

              // Set the updating state for this specific subtask
              setState(() {
                _updatingSubtasks.add(subtask.id);
              });

              try {
                final newIsCompleted = !subtask.isCompleted;

                // 1. Calculate new progress
                final totalSubtasks = task.subtasks?.length ?? 1;
                final currentCompletedCount =
                    task.subtasks?.where((s) => s.isCompleted).length ?? 0;
                final newCompletedCount =
                    currentCompletedCount + (newIsCompleted ? 1 : -1);

                final newProgress = ((newCompletedCount / totalSubtasks) * 100)
                    .toInt()
                    .clamp(0, 100);

                // 2. Determine auto status
                String? newStatusStr;
                if (newProgress == 100) {
                  newStatusStr = 'COMPLETED';
                } else if (newIsCompleted && task.status == TaskStatus.todo) {
                  newStatusStr = 'IN_PROGRESS';
                } else if (!newIsCompleted &&
                    task.status == TaskStatus.completed) {
                  newStatusStr = 'IN_PROGRESS';
                }

                // 3. Update the subtask via API
                await ref.read(taskControllerProvider.notifier).updateSubtask(
                  subtask.id,
                  task.id,
                  {'isCompleted': newIsCompleted},
                );

                // 4. Optionally update parent task if progress or status changed
                if (newProgress != (task.progress ?? 0) ||
                    newStatusStr != null) {
                  final taskUpdates = <String, dynamic>{
                    'progress': newProgress,
                  };
                  if (newStatusStr != null) {
                    taskUpdates['status'] = newStatusStr;
                  }

                  await ref.read(taskControllerProvider.notifier).updateTask(
                        task.id,
                        taskUpdates,
                      );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update subtask: $e")),
                  );
                }
              } finally {
                // Remove the updating state once the API call resolves
                if (mounted) {
                  setState(() {
                    _updatingSubtasks.remove(subtask.id);
                  });
                }
              }
            },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isUpdating ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subtask.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: subtask.isCompleted
                          ? AppColors.successGreen
                          : AppColors.alertRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: isUpdating
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            subtask.isCompleted ? "Complete" : "Incomplete",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _infoRow("Created: ", _formatDate(subtask.createdAt)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(TaskAttachment attachment) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(attachment.fileUrl),
            fit: BoxFit.cover,
            onError: (err, stack) {},
          ),
        ),
      ),
    );
  }
}
