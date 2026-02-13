import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/task.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/controllers/task/task_controller.dart';

class ProjectTasksTab extends ConsumerStatefulWidget {
  final bool showAppBar;
  final String? projectId;

  const ProjectTasksTab({
    super.key,
    this.showAppBar = false,
    this.projectId,
  });

  @override
  ConsumerState<ProjectTasksTab> createState() => _ProjectTasksTabState();
}

class _ProjectTasksTabState extends ConsumerState<ProjectTasksTab> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.projectId != null) {
        ref
            .read(taskControllerProvider.notifier)
            .refresh(projectId: widget.projectId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(taskControllerProvider.notifier).refresh(search: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskControllerProvider);

    return taskState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error: $err")),
      data: (state) {
        Widget content = Column(
          children: [
            if (state.isRefreshing)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: AppColors.textGrey),
                  hintText: "Search Tasks",
                  hintStyle: TextStyle(color: AppColors.textGrey),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.mic, color: AppColors.textGrey),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tasks list",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark),
                ),
                _buildFilterButton(),
              ],
            ),
            const SizedBox(height: 15),
            RefreshIndicator(
              onRefresh: () =>
                  ref.read(taskControllerProvider.notifier).refresh(),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.tasks.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.tasks.length) {
                    ref.read(taskControllerProvider.notifier).loadNextPage();
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  final task = state.tasks[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TaskCard(
                      task: task,
                      isUpdating: state.isRefreshing,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 80),
          ],
        );

        if (widget.showAppBar) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: AppColors.primaryBlue,
              elevation: 0,
              centerTitle: true,
              title: const Text("All Tasks",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: content,
            ),
          );
        } else {
          return content;
        }
      },
    );
  }

  Widget _buildFilterButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlue),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Text("Filter",
              style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          SizedBox(width: 4),
          Icon(Icons.tune, size: 14, color: AppColors.primaryBlue)
        ],
      ),
    );
  }
}

class TaskCard extends ConsumerStatefulWidget {
  final Task task;
  final bool isUpdating;

  const TaskCard({
    super.key,
    required this.task,
    required this.isUpdating,
  });

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _isEditing = false;
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _newSubtaskController = TextEditingController();

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _newSubtaskController.dispose();
    super.dispose();
  }

  Future<void> _toggleEditMode() async {
    if (_isEditing) {
      // Gather all updates to send in one bulk request
      final subtasks = widget.task.subtasks ?? [];
      final List<Map<String, dynamic>> updates = [];

      for (var sub in subtasks) {
        final controller = _controllers[sub.id];
        if (controller != null && controller.text.trim() != sub.description) {
          updates.add({
            'id': sub.id,
            'description': controller.text.trim(),
          });
        }
      }

      // 1. Bulk Update existing modified subtasks
      if (updates.isNotEmpty) {
        await ref.read(taskControllerProvider.notifier).bulkUpdateSubtasks(
              widget.task.id,
              updates,
            );
      }

      // 2. Submit new inline subtask if present
      await _submitNewSubtask();
    }
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _submitNewSubtask() async {
    final text = _newSubtaskController.text.trim();
    if (text.isNotEmpty) {
      await ref
          .read(taskControllerProvider.notifier)
          .createSubtask(widget.task.id, text);
      _newSubtaskController.clear();
    }
  }

  Future<void> _handleSubtaskToggle(String subtaskId, bool isCompleted) async {
    await ref.read(taskControllerProvider.notifier).updateSubtask(
      subtaskId,
      widget.task.id,
      {'isCompleted': isCompleted},
    );

    final subtasks = widget.task.subtasks ?? [];
    final updatedList = subtasks
        .map(
            (s) => s.id == subtaskId ? s.copyWith(isCompleted: isCompleted) : s)
        .toList();
    final total = updatedList.length;
    final completed = updatedList.where((s) => s.isCompleted).length;

    // Auto-transition logic
    if (total > 0 && completed == total) {
      await ref
          .read(taskControllerProvider.notifier)
          .updateTaskStatus(widget.task.id, 'REVIEW', 100);
    } else if (completed > 0 &&
        widget.task.status.toJson().toUpperCase() == 'TODO') {
      await ref.read(taskControllerProvider.notifier).updateTaskStatus(
          widget.task.id, 'IN_PROGRESS', (completed / total * 100).toInt());
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtasks = widget.task.subtasks ?? [];
    final completedCount = subtasks.where((s) => s.isCompleted).length;
    final totalCount = subtasks.length;
    final double progress = totalCount > 0 ? completedCount / totalCount : 0;
    final Color statusColor = _getStatusColor(widget.task.status.toJson());

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2))
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(widget.task.title,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark))),
                        Row(
                          children: [
                            _buildStatusPicker(
                                context,
                                widget.task.status.toDisplayString(),
                                statusColor),
                            const SizedBox(width: 8),
                            _buildSmallIcon(
                                _isEditing ? Icons.check_circle : Icons.edit,
                                _isEditing
                                    ? AppColors.successGreen
                                    : AppColors.primaryBlue,
                                _toggleEditMode),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Priority: ${widget.task.priority.toDisplayString()}",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getPriorityColor(
                                    widget.task.priority.toJson()))),
                        Text("$completedCount/$totalCount subtasks",
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textGrey)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    if (subtasks.isEmpty && !_isEditing)
                      const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No subtasks defined",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textGrey))),
                    ...subtasks.map((sub) {
                      if (_isEditing) {
                        _controllers.putIfAbsent(sub.id,
                            () => TextEditingController(text: sub.description));
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: TextField(
                            controller: _controllers[sub.id],
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                                hintText: "Subtask description",
                                isDense: true,
                                border: UnderlineInputBorder()),
                          ),
                        );
                      } else {
                        return CheckboxListTile(
                          value: sub.isCompleted,
                          dense: true,
                          activeColor: AppColors.primaryBlue,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          title: Text(sub.description,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: sub.isCompleted
                                      ? AppColors.textGrey
                                      : AppColors.textDark,
                                  decoration: sub.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null)),
                          onChanged: (val) {
                            if (val != null) _handleSubtaskToggle(sub.id, val);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }
                    }),
                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: _newSubtaskController,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: "Add new subtask...",
                            isDense: true,
                            prefixIcon: const Icon(Icons.add,
                                size: 18, color: AppColors.primaryBlue),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppColors.lightGrey)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onSubmitted: (val) => _submitNewSubtask(),
                        ),
                      ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: AppColors.lightGrey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(progress == 1.0
                      ? AppColors.successGreen
                      : AppColors.primaryBlue),
                ),
              ),
            ],
          ),
        ),
        if (widget.isUpdating)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5))),
            ),
          ),
      ],
    );
  }

  Widget _buildSmallIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, color: color, size: 16)));
  }

  Widget _buildStatusPicker(
      BuildContext context, String currentStatus, Color color) {
    final List<String> statuses = [
      'TODO',
      'IN_PROGRESS',
      'REVIEW',
      'COMPLETED',
      'BLOCKED'
    ];
    return PopupMenuButton<String>(
        onSelected: (newStatus) {
          ref.read(taskControllerProvider.notifier).updateTaskStatus(
              widget.task.id, newStatus, widget.task.progress ?? 0);
        },
        itemBuilder: (context) => statuses
            .map((s) => PopupMenuItem(
                value: s,
                child: Text(s.replaceAll('_', ' '),
                    style: const TextStyle(fontSize: 13))))
            .toList(),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(currentStatus.replaceAll('_', ' '),
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 14, color: color)
            ])));
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return AppColors.successGreen;
      case 'IN_PROGRESS':
        return const Color(0xFFF9A825);
      case 'TODO':
        return AppColors.textGrey;
      case 'BLOCKED':
        return AppColors.alertRed;
      default:
        return AppColors.primaryBlue;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return AppColors.alertRed;
      case 'MEDIUM':
        return const Color(0xFFF9A825);
      case 'LOW':
        return AppColors.successGreen;
      default:
        return AppColors.primaryBlue;
    }
  }
}
