import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/task.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/controllers/task/task_controller.dart';

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
  // since the base Task model might not deeply nest SubtaskAssignments.
  final Map<String, String> _localAssignees = {};

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

  void _showAssigneePicker(Task task, Subtask subtask) {
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
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _assignedType == 'Workers'
                      ? ref
                          .read(taskControllerProvider.notifier)
                          .getAllSiteStaff()
                      : ref
                          .read(taskControllerProvider.notifier)
                          .getSubcontractorWorkers(widget.projectId),
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

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primaryBlue.withOpacity(0.1),
                            child: const Icon(Icons.person,
                                color: AppColors.primaryBlue),
                          ),
                          title: Text(workerName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(workerSubtitle,
                              style: const TextStyle(
                                  color: AppColors.textGrey, fontSize: 13)),
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

                              // Update local UI state for immediate feedback
                              if (mounted) {
                                setState(() {
                                  _localAssignees[subtask.id] = workerName;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Worker assigned successfully!"),
                                      backgroundColor: AppColors.successGreen),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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

              // Assigned To Selection
              const Text(
                "Assign Subtasks To",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  InkWell(
                    onTap: () =>
                        setState(() => _assignedType = 'Sub-contractors'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          value: 'Sub-contractors',
                          groupValue: _assignedType,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (value) =>
                              setState(() => _assignedType = value!),
                        ),
                        const Text("Sub-contractors",
                            style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: () => setState(() => _assignedType = 'Workers'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          value: 'Workers',
                          groupValue: _assignedType,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (value) =>
                              setState(() => _assignedType = value!),
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

              // Subtasks Section
              const Text(
                "Subtasks",
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
                }).toList(),

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

                    // Show existing photos
                    if (task.attachments != null &&
                        task.attachments!.isNotEmpty)
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: task.attachments!.length,
                          separatorBuilder: (context, i) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, i) => AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      task.attachments![i].fileUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      // Dashed Add Photo Placeholder
                      CustomPaint(
                        painter:
                            DashedRectPainter(color: AppColors.primaryBlue),
                        child: Container(
                          width: 90,
                          height: 90,
                          alignment: Alignment.center,
                          child: const Icon(Icons.add_circle_outline,
                              color: AppColors.primaryBlue, size: 30),
                        ),
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
    final isCompleted = subtask.isCompleted;
    final assigneeName = _localAssignees[subtask.id];

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
                      isCompleted ? AppColors.successGreen : AppColors.alertRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isCompleted ? "Complete" : "Incomplete",
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
                    color: assigneeName != null
                        ? AppColors.primaryBlue
                        : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    assigneeName ?? "Select $_assignedType",
                    style: TextStyle(
                        color: assigneeName != null
                            ? AppColors.textDark
                            : AppColors.textGrey,
                        fontSize: 13,
                        fontWeight: assigneeName != null
                            ? FontWeight.w500
                            : FontWeight.normal),
                  ),
                  Icon(Icons.keyboard_arrow_down,
                      color: assigneeName != null
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
