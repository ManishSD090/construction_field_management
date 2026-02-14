import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/task.dart';
import 'package:construction_erp/models/enums.dart'; // Ensure TaskStatus/Priority and EnumFormatter are here
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
    // Initial fetch or refresh based on projectId constraint
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
            // Linear loader for background refreshes (pagination/filtering)
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

            // Search Bar
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

            // Header Row
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

            // Task List
            // Removed Expanded to prevent RenderFlex overflow when inside a ScrollView
            RefreshIndicator(
              onRefresh: () =>
                  ref.read(taskControllerProvider.notifier).refresh(
                        projectId: widget.projectId,
                      ),
              child: ListView.builder(
                // shrinkWrap allows the ListView to take only required space
                shrinkWrap: true,
                // NeverScrollableScrollPhysics delegates scrolling to the parent (SingleChildScrollView)
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.tasks.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Pagination Loader
                  if (index == state.tasks.length) {
                    // Trigger load next page
                    if (!state.isLoadingMore) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref
                            .read(taskControllerProvider.notifier)
                            .loadNextPage();
                      });
                    }
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final task = state.tasks[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TaskCard(
                      task: task,
                      // Pass global refreshing state to indicate updates
                      isUpdating: state.isRefreshing,
                    ),
                  );
                },
              ),
            ),
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
    return InkWell(
      onTap: () {
        // Implement filter modal logic here
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
  bool _isLocalUpdating = false; // Add local loading state
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

  // --- COLOR LOGIC WITHIN WIDGET ---

  Color _getStatusColor(TaskStatus status) {
    // Normalize to SNAKE_CASE for robust comparison
    final normalized = _toSnake(status.name);

    if (normalized == 'COMPLETED' || normalized == 'DONE') {
      return AppColors.successGreen;
    }
    if (normalized == 'IN_PROGRESS' || normalized == 'DOING') {
      return const Color(0xFFF9A825);
    }
    if (normalized == 'REVIEW') return Colors.purple;
    if (normalized == 'BLOCKED') return AppColors.alertRed;
    return AppColors.textGrey; // TODO
  }

  Color _getPriorityColor(Priority priority) {
    final normalized = _toSnake(priority.name);

    if (normalized == 'CRITICAL' || normalized == 'HIGH') {
      return AppColors.alertRed;
    }
    if (normalized == 'MEDIUM') return const Color(0xFFF9A825);
    if (normalized == 'LOW') return AppColors.successGreen;
    return AppColors.primaryBlue;
  }

  // --- HELPER FOR UPDATES ---
  Future<void> _performUpdate(Future<void> Function() action) async {
    if (_isLocalUpdating) return;
    setState(() => _isLocalUpdating = true);
    try {
      await action();
    } catch (e) {
      debugPrint("Update failed: $e");
    } finally {
      if (mounted) {
        setState(() => _isLocalUpdating = false);
      }
    }
  }

  // --- ACTIONS ---

  Future<void> _toggleEditMode() async {
    if (_isEditing) {
      // SAVE CHANGES
      await _performUpdate(() async {
        final subtasks = widget.task.subtasks ?? [];
        final List<Map<String, dynamic>> updates = [];

        // 1. Check existing subtasks for text changes
        for (var sub in subtasks) {
          final controller = _controllers[sub.id];
          if (controller != null && controller.text.trim() != sub.description) {
            updates.add({
              'id': sub.id,
              'description': controller.text.trim(),
            });
          }
        }

        // 2. Bulk Update API Call
        if (updates.isNotEmpty) {
          await ref.read(taskControllerProvider.notifier).bulkUpdateSubtasks(
                widget.task.id,
                updates,
              );
        }

        // 3. Create new subtask if text exists
        await _submitNewSubtask(isInternalCall: true);
      });
    }
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _submitNewSubtask({bool isInternalCall = false}) async {
    final text = _newSubtaskController.text.trim();
    if (text.isNotEmpty) {
      // If called internally by _toggleEditMode, we don't want to double wrap in _performUpdate
      final action = () async {
        await ref
            .read(taskControllerProvider.notifier)
            .createSubtask(widget.task.id, text);
        _newSubtaskController.clear();
      };

      if (isInternalCall) {
        await action();
      } else {
        await _performUpdate(action);
      }
    }
  }

  Future<void> _handleSubtaskToggle(String subtaskId, bool isCompleted) async {
    await _performUpdate(() async {
      // 1. Optimistic Update via Controller
      await ref.read(taskControllerProvider.notifier).updateSubtask(
        subtaskId,
        widget.task.id,
        {'isCompleted': isCompleted},
      );

      // 2. Logic for Auto-Status Transition
      final subtasks = widget.task.subtasks ?? [];

      final updatedList = subtasks.map((s) {
        return s.id == subtaskId ? s.copyWith(isCompleted: isCompleted) : s;
      }).toList();

      final total = updatedList.length;
      final completed = updatedList.where((s) => s.isCompleted).length;
      final newProgress = total > 0 ? (completed / total * 100).toInt() : 0;

      final currentStatusStr = _toSnake(widget.task.status.name);

      // Auto-transition to REVIEW if all done
      if (total > 0 &&
          completed == total &&
          currentStatusStr != 'REVIEW' &&
          currentStatusStr != 'COMPLETED') {
        await ref.read(taskControllerProvider.notifier).updateTaskStatus(
              widget.task.id,
              'REVIEW',
              100,
            );
      }
      // Auto-transition to IN_PROGRESS if started
      else if (completed > 0 && currentStatusStr == 'TODO') {
        await ref.read(taskControllerProvider.notifier).updateTaskStatus(
              widget.task.id,
              'IN_PROGRESS',
              newProgress,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subtasks = widget.task.subtasks ?? [];
    final completedCount = subtasks.where((s) => s.isCompleted).length;
    final totalCount = subtasks.length;
    final double progress = totalCount > 0 ? completedCount / totalCount : 0;

    // Use local methods for colors
    final Color statusColor = _getStatusColor(widget.task.status);
    final Color priorityColor = _getPriorityColor(widget.task.priority);

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
                    // Title & Status Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Text(widget.task.title,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark))),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                _buildStatusPicker(context, statusColor),
                                const SizedBox(width: 8),
                                _buildSmallIcon(
                                    _isEditing
                                        ? Icons.check_circle
                                        : Icons.edit,
                                    _isEditing
                                        ? AppColors.successGreen
                                        : AppColors.primaryBlue,
                                    _toggleEditMode),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Priority & Progress Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            // Use existing extension toDisplayString()
                            "Priority: ${widget.task.priority.toDisplayString()}",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: priorityColor),
                          ),
                        ),
                        Text("$completedCount/$totalCount subtasks",
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textGrey)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Subtasks List
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

                    // Add New Subtask Input
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

              // Progress Bar
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

        // Updating Overlay (Global or Local)
        if (widget.isUpdating || _isLocalUpdating)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4), // Grayed out effect
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

  Widget _buildStatusPicker(BuildContext context, Color color) {
    final statuses = TaskStatus.values;

    return PopupMenuButton<TaskStatus>(
        onSelected: (newStatus) async {
          // Wrap in local update handler to show overlay
          await _performUpdate(() async {
            // Convert to SNAKE_CASE for API consistency
            await ref.read(taskControllerProvider.notifier).updateTaskStatus(
                widget.task.id,
                _toSnake(newStatus.name),
                widget.task.progress ?? 0);
          });
        },
        itemBuilder: (context) => statuses
            .map((s) => PopupMenuItem(
                value: s,
                // Use existing extension toDisplayString()
                child: Text(s.toDisplayString(),
                    style: const TextStyle(fontSize: 13))))
            .toList(),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(widget.task.status.toDisplayString(),
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 14, color: color)
            ])));
  }
}

// ==========================================================================
// UTILITIES
// ==========================================================================

String _toSnake(String value) {
  return value
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toUpperCase();
}
