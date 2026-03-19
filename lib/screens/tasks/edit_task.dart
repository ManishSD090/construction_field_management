import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/task.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/controllers/task/task_controller.dart';
import 'package:construction_erp/controllers/project/project_controller.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final String taskId;
  final String projectId;

  const EditTaskScreen({
    super.key,
    required this.taskId,
    required this.projectId,
  });

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  String _assignedType = 'Workers';

  // Local map to temporarily hold assignee names for UI feedback
  final Map<String, String> _localAssignees = {};

  // Image Picker state
  bool _isUploadingPhoto = false;
  final ImagePicker _picker = ImagePicker();

  // Helper to format status text
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

        // Call the controller method
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

  // ===========================================================================
  // TASK MANAGER (MAIN TASK ASSIGNEE) LOGIC
  // ===========================================================================

  void _showTaskManagerPicker(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Assign Task Manager",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textGrey),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: ref
                      .read(projectControllerProvider.notifier)
                      .getProjectTeam(widget.projectId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryBlue));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error fetching team: ${snapshot.error}",
                          style: const TextStyle(color: AppColors.alertRed),
                        ),
                      );
                    }

                    final team = snapshot.data ?? [];

                    if (team.isEmpty) {
                      return const Center(
                        child: Text(
                          "No team members assigned to this project.",
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: team.length,
                      separatorBuilder: (context, i) =>
                          Divider(color: Colors.grey.shade200),
                      itemBuilder: (context, index) {
                        final assignment = team[index];
                        final user = assignment['user'] ?? {};
                        final userName = user['name'] ?? 'Unknown User';
                        final userDesignation =
                            user['designation'] ?? 'Team Member';

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primaryBlue.withOpacity(0.1),
                            child: const Icon(Icons.person_outline,
                                color: AppColors.primaryBlue),
                          ),
                          title: Text(userName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(userDesignation,
                              style: const TextStyle(
                                  color: AppColors.textGrey, fontSize: 13)),
                          onTap: () async {
                            // Close bottom sheet
                            Navigator.pop(context);

                            try {
                              // Trigger Backend API Assignment for the root Task
                              await ref
                                  .read(taskControllerProvider.notifier)
                                  .updateTask(
                                      task.id, {'assignedToId': user['id']});

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Task Manager assigned successfully!"),
                                      backgroundColor: AppColors.successGreen),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Failed to assign task manager: $e"),
                                      backgroundColor: AppColors.alertRed),
                                );
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // SUBTASK WORKER ASSIGNMENT LOGIC
  // ===========================================================================

  void _showAssigneePicker(Task task, Subtask subtask) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
            // Use StatefulBuilder to manage _assignedType state inside bottom sheet
            builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Assign Worker",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textGrey),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    InkWell(
                      onTap: () => setModalState(
                          () => _assignedType = 'Sub-contractors'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: 'Sub-contractors',
                            groupValue: _assignedType,
                            activeColor: AppColors.primaryBlue,
                            onChanged: (value) =>
                                setModalState(() => _assignedType = value!),
                          ),
                          const Text("Sub-contractors",
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    InkWell(
                      onTap: () =>
                          setModalState(() => _assignedType = 'Workers'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: 'Workers',
                            groupValue: _assignedType,
                            activeColor: AppColors.primaryBlue,
                            onChanged: (value) =>
                                setModalState(() => _assignedType = value!),
                          ),
                          const Text("Workers", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: Colors.grey.shade300, thickness: 1),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _assignedType == 'Workers'
                        ? ref
                            .read(taskControllerProvider.notifier)
                            .getAllSiteStaff()
                        // .getAllSiteStaff(projectId: widget.projectId) // Can be filter by projectId
                        : ref
                            .read(taskControllerProvider.notifier)
                            .getSubcontractorWorkersByProjectId(
                                widget.projectId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primaryBlue));
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error fetching workers: ${snapshot.error}",
                            style: const TextStyle(color: AppColors.alertRed),
                          ),
                        );
                      }

                      final workers = snapshot.data ?? [];

                      if (workers.isEmpty) {
                        return Center(
                          child: Text(
                            _assignedType == 'Workers'
                                ? "No site staff available."
                                : "No subcontractor workers available.",
                            style: const TextStyle(color: AppColors.textGrey),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: workers.length,
                        separatorBuilder: (context, i) =>
                            Divider(color: Colors.grey.shade200),
                        itemBuilder: (context, workerIndex) {
                          final worker = workers[workerIndex];

                          // Handle slight differences in returned data structures
                          final workerName = worker['name'] ?? 'Unknown';
                          final workerSubtitle = _assignedType == 'Workers'
                              ? (worker['designation'] ?? 'Site Staff')
                              : (worker['contractor']?['name'] ??
                                  'Subcontractor');

                          // Format the label correctly matching our new UI display
                          final typeLabel = _assignedType == 'Workers'
                              ? 'Site Staff'
                              : 'Subcontractor';
                          final formattedWorkerLabel =
                              "$typeLabel: $workerName";

                          // Determine if this worker is currently assigned to this subtask
                          final currentAssignee = _localAssignees[subtask.id] ??
                              _getAssigneeDetails(subtask);
                          final isSelected =
                              currentAssignee == formattedWorkerLabel;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.primaryBlue.withOpacity(0.1),
                              child: const Icon(Icons.person,
                                  color: AppColors.primaryBlue),
                            ),
                            title: Text(workerName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(workerSubtitle,
                                style: const TextStyle(
                                    color: AppColors.textGrey, fontSize: 13)),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle,
                                    color: AppColors.primaryBlue)
                                : null,
                            onTap: () async {
                              // Close bottom sheet
                              Navigator.pop(context);

                              try {
                                // Trigger Backend API Assignment
                                await ref
                                    .read(taskControllerProvider.notifier)
                                    .assignSubtaskToWorker(
                                      workerId: worker['id'],
                                      subtaskId: subtask.id,
                                      taskId: task.id,
                                      projectId: widget.projectId,
                                      workerType: _assignedType == 'Workers'
                                          ? 'SITE_STAFF'
                                          : 'SUBCONTRACTOR',
                                    );

                                // Update local UI state for immediate feedback using the formatted label
                                if (mounted) {
                                  setState(() {
                                    _localAssignees[subtask.id] =
                                        formattedWorkerLabel;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Worker assigned successfully!"),
                                        backgroundColor:
                                            AppColors.successGreen),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("Failed to assign worker: $e"),
                                        backgroundColor: AppColors.alertRed),
                                  );
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          "Edit Task",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      // Positioned Update Button at the bottom
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        color: AppColors.bgGrey,
        child: ElevatedButton(
          onPressed: () {
            // Update Logic: The assignments happen instantly via the picker,
            // so this button acts as a confirmation/return button.
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Task updates saved!")),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            "Update",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: taskAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (task) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                ],
              ),
              const SizedBox(height: 6),

              // Subtitle Row (Project Name)
              Text(
                task.project?.name ?? "ABC Infrastructure Pvt Ltd",
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 25),

              // Main Task Manager Assignment Section
              const Text(
                "Task Manager",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _showTaskManagerPicker(task),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: task.assignedTo != null
                            ? AppColors.primaryBlue
                            : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        task.assignedTo?.name ?? "Select Task Manager",
                        style: TextStyle(
                            color: task.assignedTo != null
                                ? AppColors.textDark
                                : AppColors.textGrey,
                            fontSize: 13,
                            fontWeight: task.assignedTo != null
                                ? FontWeight.w500
                                : FontWeight.normal),
                      ),
                      Icon(Icons.keyboard_arrow_down,
                          color: task.assignedTo != null
                              ? AppColors.primaryBlue
                              : AppColors.textGrey,
                          size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Subtasks Section
              const Text(
                "Subtasks & Assignments",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 12),

              if (task.subtasks == null || task.subtasks!.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text("No subtasks available to assign.",
                        style: TextStyle(color: AppColors.textGrey)),
                  ),
                )
              else
                ...task.subtasks!.map((subtask) {
                  return _buildEditableSubtaskCard(task, subtask);
                }),

              const SizedBox(height: 20),

              // Photos Section
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
                          color: AppColors.textDark),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: Colors.grey.shade200, thickness: 1),
                    const SizedBox(height: 15),
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
                            itemCount: photos.length + 1,
                            separatorBuilder: (context, i) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              if (i == photos.length) {
                                return GestureDetector(
                                  onTap: _isUploadingPhoto
                                      ? null
                                      : () =>
                                          _showImageSourceActionSheet(task.id),
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
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.primaryBlue))
                                          : const Icon(Icons.add_circle_outline,
                                              color: AppColors.primaryBlue,
                                              size: 30),
                                    ),
                                  ),
                                );
                              }
                              return _buildPhotoThumbnail(photos[i]);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableSubtaskCard(Task task, Subtask subtask) {
    final title = subtask.description;
    final isComplete = subtask.isCompleted;

    // Safely extract the already assigned worker with their type
    final assigneeDetails =
        _localAssignees[subtask.id] ?? _getAssigneeDetails(subtask);

    return Container(
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
                  title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark),
                ),
              ),
              // Static container in edit mode - no interactions for toggling completion here
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isComplete ? AppColors.successGreen : AppColors.alertRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isComplete ? "Complete" : "Incomplete",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Assigned to",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 6),
          // Worker Picker Interactive Dropdown
          InkWell(
            onTap: () => _showAssigneePicker(task, subtask),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                    color: assigneeDetails != "Unassigned"
                        ? AppColors.primaryBlue
                        : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    assigneeDetails,
                    style: TextStyle(
                        color: assigneeDetails != "Unassigned"
                            ? AppColors.textDark
                            : AppColors.textGrey,
                        fontSize: 13,
                        fontWeight: assigneeDetails != "Unassigned"
                            ? FontWeight.w500
                            : FontWeight.normal),
                  ),
                  Icon(Icons.keyboard_arrow_down,
                      color: assigneeDetails != "Unassigned"
                          ? AppColors.primaryBlue
                          : AppColors.textGrey,
                      size: 20),
                ],
              ),
            ),
          ),
        ],
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
