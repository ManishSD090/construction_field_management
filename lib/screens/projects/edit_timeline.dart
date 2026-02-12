import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/timeline/timeline_controller.dart';
import 'package:construction_erp/models/timeline.dart';

class EditTimelineScreen extends ConsumerStatefulWidget {
  final String timelineId;

  const EditTimelineScreen({
    super.key,
    required this.timelineId,
  });

  @override
  ConsumerState<EditTimelineScreen> createState() => _EditTimelineScreenState();
}

class _EditTimelineScreenState extends ConsumerState<EditTimelineScreen> {
  Timeline? _timeline;
  bool _isLoading = true;

  // Version Control
  String? _selectedVersionId;
  List<TimelineVersion> _versions = [];
  bool _isLoadingVersions = true;

  @override
  void initState() {
    super.initState();
    _fetchVersions();
  }

  // Reference the working pattern from TimelineTab
  Future<void> _fetchVersions() async {
    try {
      final versions = await ref
          .read(timelineControllerProvider.notifier)
          .getTimelineVersions(widget.timelineId);

      if (mounted) {
        setState(() {
          _versions = versions;
          if (versions.isNotEmpty) {
            _selectedVersionId = versions.first.id;
          }
          _isLoadingVersions = false;
        });
        _loadTimelineData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingVersions = false);
        _loadTimelineData();
      }
    }
  }

  Future<void> _loadTimelineData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch the main timeline structure
      final timeline = await ref
          .read(timelineControllerProvider.notifier)
          .getTimelineById(widget.timelineId);

      List<TimelineTask>? tasksToShow = timeline.timelineTasks;

      // 2. Fetch specific version tasks if needed (Matches TimelineTab pattern)
      if (_selectedVersionId != null && _versions.isNotEmpty) {
        final selectedVer = _versions.firstWhere(
          (v) => v.id == _selectedVersionId,
          orElse: () => _versions.first,
        );

        // Fetch version detail to get tasks specific to this version
        final versionDetail = await ref
            .read(timelineControllerProvider.notifier)
            .getTimelineVersionById(
                widget.timelineId, selectedVer.versionNumber);
        tasksToShow = versionDetail.timelineTasks;
      }

      setState(() {
        _timeline = timeline.copyWith(timelineTasks: tasksToShow);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Failed to load data: $e");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.alertRed),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.successGreen),
    );
  }

  void _deleteTask(TimelineTask task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text(
            "Are you sure you want to permanently remove this task from the timeline?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(timelineControllerProvider.notifier)
            .removeTaskFromTimeline(widget.timelineId, task.taskId);
        _showSuccess("Task removed successfully");
        await _loadTimelineData();
      } catch (e) {
        _showError("Failed to remove task: $e");
        setState(() => _isLoading = false);
      }
    }
  }

  void _openHeaderEditor() {
    if (_timeline == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HeaderFormSheet(
        timeline: _timeline!,
        onSaved: () => _loadTimelineData(),
      ),
    );
  }

  void _openTaskEditor({TimelineTask? task}) {
    if (_timeline == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _TaskFormScreen(
          timeline: _timeline!,
          existingTask: task,
          onSaved: () => _loadTimelineData(),
        ),
      ),
    );
  }

  Map<String, Map<int, List<TimelineTask>>> _groupTasks(
      List<TimelineTask> tasks) {
    tasks.sort((a, b) {
      int cmp = a.year.compareTo(b.year);
      if (cmp != 0) return cmp;
      cmp = a.month.compareTo(b.month);
      if (cmp != 0) return cmp;
      cmp = a.week.compareTo(b.week);
      if (cmp != 0) return cmp;
      return a.order.compareTo(b.order);
    });

    final Map<String, Map<int, List<TimelineTask>>> grouped = {};

    for (var task in tasks) {
      final monthName =
          DateFormat('MMMM yyyy').format(DateTime(task.year, task.month));
      if (!grouped.containsKey(monthName)) grouped[monthName] = {};
      if (!grouped[monthName]!.containsKey(task.week))
        grouped[monthName]![task.week] = [];
      grouped[monthName]![task.week]!.add(task);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Manage Timeline",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskEditor(),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Task",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading || _timeline == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchVersions();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- VERSION SELECTOR (Reference: TimelineTab) ---
                    if (!_isLoadingVersions && _versions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: _buildVersionSelector(),
                      ),

                    // --- TIMELINE HEADER CARD ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Timeline Details",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue)),
                        TextButton.icon(
                          onPressed: _openHeaderEditor,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text("Edit Info"),
                        )
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_timeline!.name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          if (_timeline!.description != null &&
                              _timeline!.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(_timeline!.description!,
                                style: TextStyle(color: Colors.grey.shade700)),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 16, color: AppColors.primaryBlue),
                              const SizedBox(width: 8),
                              Text(
                                  "${DateFormat('dd MMM yyyy').format(_timeline!.startDate)}  -  ${DateFormat('dd MMM yyyy').format(_timeline!.endDate)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- TASKS LIST ---
                    const Text("Scheduled Tasks",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue)),
                    const SizedBox(height: 15),

                    if (_timeline!.timelineTasks == null ||
                        _timeline!.timelineTasks!.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.assignment_outlined,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text("No tasks added yet.",
                                style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      )
                    else
                      _buildGroupedTaskList(),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildVersionSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVersionId,
          isExpanded: true,
          hint: const Text("Select Version"),
          icon: const Icon(Icons.history, color: AppColors.primaryBlue),
          items: _versions.map((version) {
            bool isBaseline = version.isBaseline;
            String label = "V${version.versionNumber} - ${version.name}";
            return DropdownMenuItem<String>(
              value: version.id,
              child: Row(
                children: [
                  Expanded(
                      child: Text(label,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis)),
                  if (isBaseline)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green)),
                      child: const Text("BASELINE",
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    )
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null && val != _selectedVersionId) {
              setState(() {
                _selectedVersionId = val;
                _loadTimelineData();
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildGroupedTaskList() {
    final groupedTasks = _groupTasks(_timeline!.timelineTasks!);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedTasks.length,
      itemBuilder: (context, index) {
        String monthKey = groupedTasks.keys.elementAt(index);
        Map<int, List<TimelineTask>> weeklyGroups = groupedTasks[monthKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                monthKey,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
            ...weeklyGroups.entries.map((entry) {
              return _buildWeeklyTaskItem(entry.key, entry.value);
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildWeeklyTaskItem(int weekNum, List<TimelineTask> tasks) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF3B71CA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  "$weekNum",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Fixes overflow inside IntrinsicHeight
                  children: tasks.map((task) => _buildTaskTile(task)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTile(TimelineTask tt) {
    final title = tt.task?.title ?? 'Unknown Task';
    final isCritical = tt.isCritical;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87),
                      ),
                    ),
                    if (isCritical)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text("CRITICAL",
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tt.task?.description ?? (tt.notes ?? 'No description'),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.primaryBlue, size: 20),
                onPressed: () => _openTaskEditor(task: tt),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.alertRed, size: 20),
                onPressed: () => _deleteTask(tt),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HEADER FORM BOTTOM SHEET
// ============================================================================

class _HeaderFormSheet extends ConsumerStatefulWidget {
  final Timeline timeline;
  final VoidCallback onSaved;

  const _HeaderFormSheet({required this.timeline, required this.onSaved});

  @override
  ConsumerState<_HeaderFormSheet> createState() => _HeaderFormSheetState();
}

class _HeaderFormSheetState extends ConsumerState<_HeaderFormSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _startCtrl;
  late TextEditingController _endCtrl;
  late TextEditingController _commentCtrl;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.timeline.name);
    _descCtrl = TextEditingController(text: widget.timeline.description ?? '');
    _commentCtrl = TextEditingController();

    _startDate = widget.timeline.startDate;
    _endDate = widget.timeline.endDate;
    _startCtrl = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(_startDate!));
    _endCtrl =
        TextEditingController(text: DateFormat('yyyy-MM-dd').format(_endDate!));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
            _endCtrl.text = '';
          }
        } else {
          _endDate = picked;
          _endCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Name and dates are required."),
          backgroundColor: AppColors.alertRed));
      return;
    }

    setState(() => _isSaving = true);

    final payload = {
      "name": _nameCtrl.text.trim(),
      if (_descCtrl.text.trim().isNotEmpty)
        "description": _descCtrl.text.trim(),
      "startDate": DateFormat('yyyy-MM-dd').format(_startDate!),
      "endDate": DateFormat('yyyy-MM-dd').format(_endDate!),
      if (_commentCtrl.text.trim().isNotEmpty)
        "versionComment": _commentCtrl.text.trim(),
    };

    try {
      await ref
          .read(timelineControllerProvider.notifier)
          .updateTimeline(widget.timeline.id, payload);
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()), backgroundColor: AppColors.alertRed));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Edit Timeline Details",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context))
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField("Timeline Name", _nameCtrl),
            const SizedBox(height: 15),
            _buildTextField("Description", _descCtrl, maxLines: 2),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                    child: _buildDatePicker("Start Date", _startCtrl, true)),
                const SizedBox(width: 15),
                Expanded(child: _buildDatePicker("End Date", _endCtrl, false)),
              ],
            ),
            const SizedBox(height: 15),
            _buildTextField("Version Comment (Reason for edit)", _commentCtrl),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(
      String label, TextEditingController controller, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _selectDate(context, isStart),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: AbsorbPointer(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// TASK FORM SCREEN
// ============================================================================

class SubtaskData {
  String? id;
  TextEditingController controller;
  SubtaskData({this.id, required String text})
      : controller = TextEditingController(text: text);
  void dispose() => controller.dispose();
}

class _TaskFormScreen extends ConsumerStatefulWidget {
  final Timeline timeline;
  final TimelineTask? existingTask;
  final VoidCallback onSaved;

  const _TaskFormScreen(
      {required this.timeline, this.existingTask, required this.onSaved});

  @override
  ConsumerState<_TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<_TaskFormScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _hoursCtrl;
  late TextEditingController _pStartCtrl;
  late TextEditingController _pEndCtrl;

  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedWeek;
  String _priority = 'MEDIUM';
  bool _isCritical = false;
  DateTime? _pStart;
  DateTime? _pEnd;
  bool _isSaving = false;

  final List<int> _weeks = [1, 2, 3, 4, 5];
  final List<String> _priorities = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];
  final List<SubtaskData> _subtasks = [];

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;

    _titleCtrl = TextEditingController(text: t?.task?.title ?? '');
    _descCtrl =
        TextEditingController(text: t?.task?.description ?? (t?.notes ?? ''));
    _hoursCtrl =
        TextEditingController(text: t?.task?.estimatedHours?.toString() ?? '');

    _selectedYear = t?.year;
    _selectedMonth = t?.month;
    _selectedWeek = t?.week;
    _priority = t?.task?.priority.name.toUpperCase() ?? 'MEDIUM';
    _isCritical = t?.isCritical ?? false;

    _pStart = t?.plannedStartDate;
    _pEnd = t?.plannedEndDate;
    _pStartCtrl = TextEditingController(
        text: _pStart != null ? DateFormat('yyyy-MM-dd').format(_pStart!) : '');
    _pEndCtrl = TextEditingController(
        text: _pEnd != null ? DateFormat('yyyy-MM-dd').format(_pEnd!) : '');

    if (t?.task?.subtasks != null && t!.task!.subtasks!.isNotEmpty) {
      for (var sub in t.task!.subtasks!) {
        _subtasks.add(SubtaskData(id: sub.id, text: sub.description));
      }
    } else {
      _subtasks.add(SubtaskData(text: ''));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _hoursCtrl.dispose();
    _pStartCtrl.dispose();
    _pEndCtrl.dispose();
    for (var sub in _subtasks) {
      sub.dispose();
    }
    super.dispose();
  }

  List<int> _getAvailableYears() {
    int startY = widget.timeline.startDate.year;
    int endY = widget.timeline.endDate.year;
    return List.generate(endY - startY + 1, (i) => startY + i);
  }

  List<int> _getAvailableMonths() {
    if (_selectedYear == null) return [];
    int startY = widget.timeline.startDate.year;
    int endY = widget.timeline.endDate.year;
    int startM = widget.timeline.startDate.month;
    int endM = widget.timeline.endDate.month;

    if (startY == endY)
      return List.generate(endM - startM + 1, (i) => startM + i);
    if (_selectedYear == startY)
      return List.generate(12 - startM + 1, (i) => startM + i);
    if (_selectedYear == endY) return List.generate(endM, (i) => i + 1);
    return List.generate(12, (i) => i + 1);
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_pStart ?? widget.timeline.startDate)
          : (_pEnd ?? _pStart ?? widget.timeline.startDate),
      firstDate: widget.timeline.startDate,
      lastDate: widget.timeline.endDate,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _pStart = picked;
          _pStartCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
          if (_pEnd != null && _pEnd!.isBefore(_pStart!)) {
            _pEnd = null;
            _pEndCtrl.text = '';
          }
        } else {
          _pEnd = picked;
          _pEndCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty ||
        _selectedYear == null ||
        _selectedMonth == null ||
        _selectedWeek == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Title and scheduling details are required."),
          backgroundColor: AppColors.alertRed));
      return;
    }

    setState(() => _isSaving = true);

    List<Map<String, dynamic>> validSubtasks = _subtasks
        .where((s) => s.controller.text.trim().isNotEmpty)
        .map((s) => {
              if (s.id != null) "id": s.id,
              "description": s.controller.text.trim()
            })
        .toList();

    try {
      if (widget.existingTask != null) {
        final payload = {
          "year": _selectedYear,
          "month": _selectedMonth,
          "week": _selectedWeek,
          "isCritical": _isCritical,
          "notes": _descCtrl.text.trim(),
          if (_pStart != null)
            "plannedStartDate": DateFormat('yyyy-MM-dd').format(_pStart!),
          if (_pEnd != null)
            "plannedEndDate": DateFormat('yyyy-MM-dd').format(_pEnd!),
          "title": _titleCtrl.text.trim(),
          "priority": _priority,
          "estimatedHours": int.tryParse(_hoursCtrl.text.trim()) ?? 0,
          "subtasks": validSubtasks,
        };

        await ref
            .read(timelineControllerProvider.notifier)
            .updateTimelineTaskDetails(
                widget.timeline.id, widget.existingTask!.taskId, payload);
      } else {
        String? versionId = widget.timeline.timelineVersions?.isNotEmpty == true
            ? widget.timeline.timelineVersions!.first.id
            : null;

        final payload = {
          "title": _titleCtrl.text.trim(),
          if (_descCtrl.text.trim().isNotEmpty)
            "description": _descCtrl.text.trim(),
          "year": _selectedYear,
          "month": _selectedMonth,
          "week": _selectedWeek,
          "isCritical": _isCritical,
          "priority": _priority,
          "estimatedHours": int.tryParse(_hoursCtrl.text.trim()) ?? 0,
          if (_pStart != null)
            "plannedStartDate": DateFormat('yyyy-MM-dd').format(_pStart!),
          if (_pEnd != null)
            "plannedEndDate": DateFormat('yyyy-MM-dd').format(_pEnd!),
          "subtasks": validSubtasks,
          if (versionId != null) "timelineVersionId": versionId,
        };
        await ref
            .read(timelineControllerProvider.notifier)
            .createTaskAndAddToTimeline(widget.timeline.id, payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Task saved successfully!"),
            backgroundColor: AppColors.successGreen));
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()), backgroundColor: AppColors.alertRed));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
        title: Text(widget.existingTask == null ? "New Task" : "Edit Task",
            style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Task Title"),
            _buildTextField(_titleCtrl, "E.g., Excavation Work"),
            _buildLabel("Description"),
            _buildTextField(_descCtrl, "E.g., Site excavation and preparation",
                maxLines: 2),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                    child: _buildDropdown<int>("Year", _getAvailableYears(),
                        _selectedYear, (y) => y.toString(), (val) {
                  setState(() {
                    _selectedYear = val;
                    _selectedMonth = null;
                  });
                })),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildDropdown<int>(
                        "Month",
                        _getAvailableMonths(),
                        _selectedMonth,
                        (m) => [
                              "Jan",
                              "Feb",
                              "Mar",
                              "Apr",
                              "May",
                              "Jun",
                              "Jul",
                              "Aug",
                              "Sep",
                              "Oct",
                              "Nov",
                              "Dec"
                            ][m - 1], (val) {
                  setState(() => _selectedMonth = val);
                })),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildDropdown<int>(
                        "Week", _weeks, _selectedWeek, (w) => "Wk $w", (val) {
                  setState(() => _selectedWeek = val);
                })),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                    child: _buildDropdown<String>(
                        "Priority",
                        _priorities,
                        _priority,
                        (p) => p,
                        (val) => setState(() => _priority = val!))),
                const SizedBox(width: 15),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Est. Hours"),
                    _buildTextField(_hoursCtrl, "E.g., 40",
                        inputType: TextInputType.number),
                  ],
                )),
              ],
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              title: const Text("Is Critical Task?",
                  style: TextStyle(fontSize: 14)),
              value: _isCritical,
              onChanged: (val) => setState(() => _isCritical = val ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.alertRed,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child:
                        _buildDatePicker("Planned Start", _pStartCtrl, true)),
                const SizedBox(width: 15),
                Expanded(
                    child: _buildDatePicker("Planned End", _pEndCtrl, false)),
              ],
            ),
            const SizedBox(height: 25),
            const Divider(),
            const Text("Subtasks",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _subtasks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                          child: _buildTextField(_subtasks[index].controller,
                              "Subtask description")),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: AppColors.alertRed),
                        onPressed: () => setState(() {
                          _subtasks[index].dispose();
                          _subtasks.removeAt(index);
                        }),
                      )
                    ],
                  ),
                );
              },
            ),
            TextButton.icon(
              onPressed: () =>
                  setState(() => _subtasks.add(SubtaskData(text: ""))),
              icon: const Icon(Icons.add, color: AppColors.primaryBlue),
              label: const Text("Add Subtask",
                  style: TextStyle(color: AppColors.primaryBlue)),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Task",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87)));

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300)),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      ),
    );
  }

  Widget _buildDropdown<T>(String label, List<T> items, T? selectedValue,
      String Function(T) labelBuilder, ValueChanged<T?>? onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: onChanged == null ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: selectedValue,
              hint: const Text("Select", style: TextStyle(fontSize: 13)),
              isExpanded: true,
              items: items
                  .map((T value) => DropdownMenuItem<T>(
                      value: value,
                      child: Text(labelBuilder(value),
                          style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(
      String label, TextEditingController controller, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        GestureDetector(
          onTap: () => _selectDate(isStart),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300)),
            child: AbsorbPointer(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "YYYY-MM-DD",
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: Icon(Icons.calendar_month_outlined, size: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
