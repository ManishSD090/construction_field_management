import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

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

  // Image Picker state
  bool _isUploadingPhoto = false;
  final ImagePicker _picker = ImagePicker();

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

  // Robust helper to safely extract the assignee name and type
  // from the nested assignments array structure regardless of model mapping
  String _getAssigneeDetails(Subtask subtask) {
    try {
      final dynamic s = subtask;

      // Let's try to access assignments list directly
      dynamic assignmentsList;
      try {
        assignmentsList = s.assignments;
      } catch (_) {
        try {
          // Fallback: Check if subtask has a toJson() method that captures the unmapped array
          assignmentsList = s.toJson()['assignments'];
        } catch (_) {}
      }

      if (assignmentsList != null &&
          assignmentsList is List &&
          assignmentsList.isNotEmpty) {
        final assignment = assignmentsList.first;

        // Safely extract properties handling both Dart Maps and Dart Objects
        String? workerType;
        dynamic siteStaff;
        dynamic subcontractorWorker;

        if (assignment is Map) {
          workerType = assignment['workerType'];
          siteStaff = assignment['siteStaff'];
          subcontractorWorker = assignment['subcontractorWorker'];
        } else {
          try {
            workerType = assignment.workerType;
          } catch (_) {}
          try {
            siteStaff = assignment.siteStaff;
          } catch (_) {}
          try {
            subcontractorWorker = assignment.subcontractorWorker;
          } catch (_) {}
        }

        if (workerType == 'SITE_STAFF' && siteStaff != null) {
          String name = 'Unknown';
          if (siteStaff is Map) {
            name = siteStaff['name'] ?? 'Unknown';
          } else {
            try {
              name = siteStaff.name;
            } catch (_) {}
          }
          return "Site Staff: $name";
        } else if (workerType == 'SUBCONTRACTOR' &&
            subcontractorWorker != null) {
          String name = 'Unknown';
          if (subcontractorWorker is Map) {
            name = subcontractorWorker['name'] ?? 'Unknown';
          } else {
            try {
              name = subcontractorWorker.name;
            } catch (_) {}
          }
          return "Subcontractor: $name";
        }
      }

      // Fallback for older backend structures just in case
      try {
        if (s.assignedTo != null) return "Site Staff: ${s.assignedTo.name}";
      } catch (_) {}
      try {
        if (s.worker != null) return "Site Staff: ${s.worker.name}";
      } catch (_) {}
      try {
        if (s.contractorWorker != null) {
          return "Subcontractor: ${s.contractorWorker.name}";
        }
      } catch (_) {}

      return "Unassigned";
    } catch (e) {
      if (kDebugMode) print("Error parsing assignee: $e");
      return "Unassigned";
    }
  }

  // ===========================================================================
  // PHOTO UPLOAD LOGIC
  // ===========================================================================

  void _showImageSourceActionSheet(String taskId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Upload Photo",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(taskId, ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primaryBlue),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(taskId, ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(String taskId, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Compress slightly for faster uploads
      );

      if (image != null) {
        setState(() => _isUploadingPhoto = true);

        // Call the controller method you already created
        await ref
            .read(taskControllerProvider.notifier)
            .uploadTaskAttachment(taskId, image.path);

        // Refresh the attachments specifically
        ref.invalidate(taskAttachmentsProvider(taskId));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Photo uploaded successfully!"),
                backgroundColor: AppColors.successGreen),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to upload photo: $e"),
              backgroundColor: AppColors.alertRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch both providers
    final taskAsync = ref.watch(taskDetailsProvider(widget.taskId));
    final attachmentsAsync = ref.watch(taskAttachmentsProvider(widget.taskId));

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
          onRefresh: () async {
            ref.invalidate(taskDetailsProvider(widget.taskId));
            ref.invalidate(taskAttachmentsProvider(widget.taskId));
          },
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
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Subtasks",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.info_outline,
                        size: 14, color: AppColors.textGrey),
                    SizedBox(width: 4),
                    Text(
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
                      .map((subtask) => _buildSubtaskCard(task, subtask)),

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
                      attachmentsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryBlue)),
                        ),
                        error: (err, stack) => const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Center(
                              child: Text("Error loading photos",
                                  style: TextStyle(color: AppColors.alertRed))),
                        ),
                        data: (attachments) {
                          // Filter to ensure we only show images in this gallery row
                          final photos = attachments.where((a) {
                            final url = a.fileUrl.toLowerCase();
                            return url.contains('.jpg') ||
                                url.contains('.jpeg') ||
                                url.contains('.png') ||
                                url.contains('.webp');
                          }).toList();

                          return SizedBox(
                            height: 90,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              // Add 1 to the count for the "Add Photo" button at the end
                              itemCount: photos.length + 1,
                              separatorBuilder: (context, i) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, i) {
                                // If it's the last item, show the "Add Photo" dashed box
                                if (i == photos.length) {
                                  return GestureDetector(
                                    onTap: _isUploadingPhoto
                                        ? null
                                        : () => _showImageSourceActionSheet(
                                            task.id),
                                    child: CustomPaint(
                                      painter: DashedRectPainter(
                                          color: AppColors.primaryBlue),
                                      child: Container(
                                        width: 90,
                                        height: 90,
                                        alignment: Alignment.center,
                                        child: _isUploadingPhoto
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: AppColors
                                                            .primaryBlue))
                                            : const Icon(
                                                Icons.add_circle_outline,
                                                color: AppColors.primaryBlue,
                                                size: 30),
                                      ),
                                    ),
                                  );
                                }

                                // Otherwise, render the existing photo
                                return _buildPhotoThumbnail(photos[i]);
                              },
                            ),
                          );
                        },
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
    final assigneeDetails = _getAssigneeDetails(subtask);

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
                    SnackBar(
                        content: Text("Failed to update subtask: $e"),
                        backgroundColor: AppColors.alertRed),
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
              const SizedBox(height: 8),
              _infoRow("Assigned to: ", assigneeDetails),
              const SizedBox(height: 4),
              _infoRow("Created: ", _formatDate(subtask.createdAt)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(TaskAttachment attachment) {
    // FIX: Android emulator needs 10.0.2.2 instead of localhost
    // This is safely wrapped to only execute during local development on Android.
    String imageUrl = attachment.fileUrl;
    if (kDebugMode &&
        !kIsWeb &&
        Platform.isAndroid &&
        imageUrl.contains('localhost')) {
      // imageUrl = imageUrl.replaceAll('localhost', '10.0.2.2');
      imageUrl = imageUrl.replaceAll('localhost', '192.168.1.10');
    }

    return GestureDetector(
      onTap: () {
        // Open a full-screen interactive viewer when tapped
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: AppColors.lightGrey,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              cacheWidth:
                  250, // Resizes the image in memory to act as a thumbnail
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter to draw a dashed rectangle border
class DashedRectPainter extends CustomPainter {
  final Color color;
  DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double dashWidth = 6, dashSpace = 4;
    double startX = 0, startY = 0;

    // Top edge
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
    // Right edge
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width, startY),
          Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
    // Bottom edge
    startX = size.width;
    while (startX > 0) {
      canvas.drawLine(Offset(startX, size.height),
          Offset(startX - dashWidth, size.height), paint);
      startX -= dashWidth + dashSpace;
    }
    // Left edge
    startY = size.height;
    while (startY > 0) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY - dashWidth), paint);
      startY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
