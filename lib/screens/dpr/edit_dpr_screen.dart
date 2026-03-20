import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/dpr.dart';
import 'package:construction_erp/controllers/dpr/dpr_controller.dart';
import 'package:construction_erp/models/task.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/controllers/task/task_controller.dart';

// --- DATA PROVIDER FOR TASKS ---
final tasksProvider = FutureProvider.family<List<Task>, String?>((ref, projectId) async {
  if (projectId == null || projectId.isEmpty) return [];
  final taskController = ref.read(taskControllerProvider.notifier);
  return await taskController.getAllTasksForProject(projectId);
});

class EditDPRScreen extends ConsumerStatefulWidget {
  final DailyProgressReport dpr;

  const EditDPRScreen({super.key, required this.dpr});

  @override
  ConsumerState<EditDPRScreen> createState() => _EditDPRScreenState();
}

class _EditDPRScreenState extends ConsumerState<EditDPRScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // --- MEDIA HANDLING ---
  final List<File> _selectedImages = []; 
  final List<File> _selectedDocuments = [];
  final ImagePicker _picker = ImagePicker();
  
  // Store actual objects so we can access their IDs for deletion
  late List<dynamic> _existingPhotos;
  late List<dynamic> _existingDocuments;
  final List<String> _deletedMediaIds = []; // Tracks IDs of media to delete on save

  // --- CONTROLLERS FOR EDITABLE FIELDS (Aligned with Backend) ---
  late TextEditingController _descriptionController;
  late TextEditingController _pendingWorkController;
  late TextEditingController _challengesController;
  late TextEditingController _safetyObservationsController;
  late TextEditingController _qualityChecksController;
  late TextEditingController _issuesFoundController;
  late TextEditingController _nextDayPlanController;
  
  // Tasks
  late TextEditingController _completedTaskPercent;
  final List<TextEditingController> _completedSubtasks = [];

  String? _completedTask;
  String? _nextDayTask;

  // --- READ-ONLY DATA ---
  late String _dateText;
  late String _selectedWeather;
  late int _workers;
  late int _staff;

  @override
  void initState() {
    super.initState();
    
    // 1. Hunt for the pre-filled completed task & percentage
    String? initTaskName = widget.dpr.completedWork;
    String initPercent = "";
    
    if (widget.dpr.tasksCompleted.isNotEmpty) {
      initTaskName = widget.dpr.tasksCompleted.first.name;
      initPercent = widget.dpr.tasksCompleted.first.percent?.toString() ?? "";
      
      for (var sub in widget.dpr.tasksCompleted.first.subtasks) {
        _completedSubtasks.add(TextEditingController(text: sub.name));
      }
    }
    
    if (_completedSubtasks.isEmpty) _completedSubtasks.add(TextEditingController());

    // Initialize Editable Fields
    _descriptionController = TextEditingController(text: widget.dpr.workDescription);
    _pendingWorkController = TextEditingController(text: widget.dpr.pendingWork ?? "");
    _challengesController = TextEditingController(text: widget.dpr.challenges ?? "");
    _safetyObservationsController = TextEditingController(text: widget.dpr.safetyObservations ?? "");
    _qualityChecksController = TextEditingController(text: widget.dpr.qualityChecks ?? "");
    _issuesFoundController = TextEditingController(text: widget.dpr.issuesFound ?? "");
    _completedTaskPercent = TextEditingController(text: initPercent);
    _completedTask = (initTaskName != null && initTaskName.trim().isNotEmpty) ? initTaskName.trim() : null;

    // "Unpack" the combined nextDayPlan string to restore the Dropdown & Text
    String rawNextDay = widget.dpr.nextDayPlan ?? widget.dpr.nextDayNotes ?? "";
    if (rawNextDay.startsWith("Task: ")) {
      int newlineIndex = rawNextDay.indexOf('\n');
      if (newlineIndex != -1) {
        _nextDayTask = rawNextDay.substring(6, newlineIndex).trim();
        _nextDayPlanController = TextEditingController(text: rawNextDay.substring(newlineIndex + 1).trim());
      } else {
        _nextDayTask = rawNextDay.substring(6).trim();
        _nextDayPlanController = TextEditingController(text: "");
      }
    } else {
      _nextDayPlanController = TextEditingController(text: rawNextDay);
    }

    // Separate photos and documents correctly keeping the full objects
    _existingPhotos = widget.dpr.photos.where((p) {
      final url = (p.imageUrl ?? "").toLowerCase();
      return !url.endsWith('.pdf') && !url.endsWith('.doc') && !url.endsWith('.docx') && !url.endsWith('.txt');
    }).toList();

    _existingDocuments = widget.dpr.photos.where((p) {
      final url = (p.imageUrl ?? "").toLowerCase();
      return url.endsWith('.pdf') || url.endsWith('.doc') || url.endsWith('.docx') || url.endsWith('.txt');
    }).toList();

    // Read-Only Fields
    _dateText = DateFormat("dd/MM/yyyy").format(widget.dpr.date);
    _selectedWeather = widget.dpr.weather ?? "Sunny";
    _workers = widget.dpr.totalWorkers ?? widget.dpr.workersPresent ?? 0;
    _staff = widget.dpr.staffPresent ?? 0;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _pendingWorkController.dispose();
    _challengesController.dispose();
    _safetyObservationsController.dispose();
    _qualityChecksController.dispose();
    _issuesFoundController.dispose();
    _nextDayPlanController.dispose();
    _completedTaskPercent.dispose();
    for (var c in _completedSubtasks) { c.dispose(); }
    super.dispose();
  }

  void _addCompletedSubtask() => setState(() => _completedSubtasks.add(TextEditingController()));
  void _removeCompletedSubtask(int index) => setState(() { if (_completedSubtasks.length > 1) { _completedSubtasks[index].dispose(); _completedSubtasks.removeAt(index); } });

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => _selectedImages.add(File(image.path)));
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx', 'txt']);
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedDocuments.add(File(result.files.single.path!)));
    }
  }

  Future<void> _updateDPR() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      // Create a combined string for completed work to satisfy Prisma's String field
      String finalCompletedWork = _completedTask ?? '';

      // 🚨 FIX: Append percentage matching the parser format
      if (_completedTaskPercent.text.trim().isNotEmpty) {
        finalCompletedWork += " (${_completedTaskPercent.text.trim()}%)";
      }
      
      // 🚨 FIX: Ensure a space before "Subtasks:" so the parser can split it cleanly
      if (_completedSubtasks.isNotEmpty) {
        final subTasksText = _completedSubtasks.where((c) => c.text.trim().isNotEmpty).map((c) => c.text.trim()).join(", ");
        if (subTasksText.isNotEmpty) {
          finalCompletedWork += " Subtasks: $subTasksText";
        }
      }

      // Re-pack the Next Day Plan string to match the Create logic
      String formattedNextDayPlan = _nextDayPlanController.text.trim();
      if (_nextDayTask != null && _nextDayTask!.isNotEmpty) {
        formattedNextDayPlan = "Task: $_nextDayTask\n$formattedNextDayPlan";
      }

      final payload = {
        'weather': _selectedWeather,
        'workDescription': _descriptionController.text.trim(),
        'completedWork': finalCompletedWork,
        'pendingWork': _pendingWorkController.text.trim(),
        'challenges': _challengesController.text.trim(),
        'safetyObservations': _safetyObservationsController.text.trim(),
        'qualityChecks': _qualityChecksController.text.trim(),
        'issuesFound': _issuesFoundController.text.trim(),
        'nextDayPlan': formattedNextDayPlan, 
      };

      // 1. Update text data
      await ref.read(dprControllerProvider.notifier).updateDPR(widget.dpr.id, payload);

      // 2. Process Deletions on the backend
      if (_deletedMediaIds.isNotEmpty) {
        final dio = ref.read(dioClientProvider).dio;
        for (String id in _deletedMediaIds) {
          try {
            await dio.delete('/dpr-photos/$id');
          } catch (e) {
            debugPrint("Failed to delete media $id: $e");
          }
        }
      }

      // 3. Process New Uploads
      if (_selectedImages.isNotEmpty) {
        for (var imageFile in _selectedImages) {
          final ext = imageFile.path.toLowerCase();
          if (ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png')) {
            await ref.read(dprControllerProvider.notifier).uploadDPRPhoto(
              dprId: widget.dpr.id, 
              file: imageFile, 
              title: "Update Photo",
            );
          }
        }
      }
      
      if (_selectedDocuments.isNotEmpty) {
        for (var docFile in _selectedDocuments) {
          // Future Document API endpoint
          // await ref.read(dprControllerProvider.notifier).uploadDPRPhoto(dprId: widget.dpr.id, file: docFile, title: "Document");
        }
      }

      if (!mounted) return;
      ref.invalidate(dprControllerProvider); // Refreshes the list screen
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DPR Updated Successfully')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectId = widget.dpr.projectId;
    final tasksAsync = ref.watch(tasksProvider(projectId));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: Text("Edit ${widget.dpr.reportNo}", style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- READ ONLY SECTIONS ---
              _label("DPR Date"),
              _readOnlyField(_dateText, Icons.calendar_today_outlined),
              const SizedBox(height: 14),

              _label("Weather"),
              _weatherChipsReadOnly(),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle("Attendance (Read-Only)"),
                  Text("${_workers + _staff} Present", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _readOnlyNumberField(label: "Workers", value: _workers)),
                  const SizedBox(width: 16),
                  Expanded(child: _readOnlyNumberField(label: "Staff", value: _staff)),
                ],
              ),
              const SizedBox(height: 20),

              // --- EDITABLE SECTIONS ---
              const Text("Editable Details", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 16),

              _label("Work Description"),
              _textArea(_descriptionController, hint: "Update work details..."),
              const SizedBox(height: 16),

              _label("Pending Work"),
              _textArea(_pendingWorkController, hint: "What work is pending?"),
              const SizedBox(height: 16),

              _label("Challenges / Roadblocks"),
              _textArea(_challengesController, hint: "Any challenges faced today?"),
              const SizedBox(height: 20),

              _sectionTitle("Tasks completed"),
              Row(
                children: [
                  Expanded(
                    flex: 4, 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        _label("Task Name", pad: 6), 
                        tasksAsync.when(
                          data: (tasks) => _taskDropdown(
                            value: _completedTask,
                            tasks: tasks,
                            hint: "Select Task or Subtask",
                            onChanged: (val) {
                              if (val == null) return;
                              
                              setState(() {
                                _completedTask = val;
                                
                                // 1. Clear current subtasks to make room for the new ones
                                _completedSubtasks.clear(); 
                                
                                try {
                                  // 2. Find the selected task
                                  final selectedTask = tasks.firstWhere((t) => t.title == val);
                                  
                                  // 3. Bulletproof Auto-Fill Subtasks Logic
                                  dynamic dynamicTask = selectedTask;
                                  if (dynamicTask.subtasks != null && (dynamicTask.subtasks as List).isNotEmpty) {
                                    for (var sub in dynamicTask.subtasks) {
                                      String subTitle = '';
                                      
                                      // Safely try common property names without crashing Dart
                                      try { subTitle = sub.name ?? ''; } catch (_) {}
                                      if (subTitle.isEmpty) { try { subTitle = sub.title ?? ''; } catch (_) {} }
                                      if (subTitle.isEmpty) { try { subTitle = sub.description ?? ''; } catch (_) {} }
                                      if (subTitle.isEmpty) { try { subTitle = sub.subtaskName ?? ''; } catch (_) {} }
                                      
                                      if (subTitle.trim().isNotEmpty) {
                                        _completedSubtasks.add(TextEditingController(text: subTitle.trim()));
                                      }
                                    }
                                  }
                                } catch (_) {
                                  // If they selected a subtask instead of a main task, it will safely skip auto-fill
                                }
                                
                                // 4. If no subtasks were found/added, give them one empty field
                                if (_completedSubtasks.isEmpty) {
                                  _completedSubtasks.add(TextEditingController());
                                }
                              });
                            },
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => _dropdown(value: null, hint: "API Error", items: [], onChanged: (v) {}),
                        )
                      ]
                    )
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2, 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        _label("%", pad: 6), 
                        _textField(_completedTaskPercent, hint: "%")
                      ]
                    )
                  ),
                ],
              ),
              
              // Dynamic Subtasks
              Column(
                children: List.generate(_completedSubtasks.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(width: 75, child: Text("Subtask ${i + 1}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                        Expanded(child: _textField(_completedSubtasks[i], hint: "Subtask name")),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _removeCompletedSubtask(i),
                          child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.alertRed.withOpacity(0.12), shape: BoxShape.circle), child: const Icon(Icons.remove, color: AppColors.alertRed, size: 18)),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              _addDashedButton(_addCompletedSubtask),
              const SizedBox(height: 20),

              // --- ADDITIONAL BACKEND FIELDS ---
              _sectionTitle("Site Observations"),
              const SizedBox(height: 10),
              
              _label("Safety Observations"),
              _textArea(_safetyObservationsController, hint: "Any safety issues or notes..."),
              const SizedBox(height: 16),

              _label("Quality Checks"),
              _textArea(_qualityChecksController, hint: "Quality checks performed..."),
              const SizedBox(height: 16),

              _label("Issues Found"),
              _textArea(_issuesFoundController, hint: "Any defects or issues..."),
              const SizedBox(height: 20),

              _label("Update Site Photos"),
              const SizedBox(height: 8),
              _photoGrid(),
              const SizedBox(height: 16),

              _label("Update Documents"),
              const SizedBox(height: 8),
              _documentGrid(),
              const SizedBox(height: 20),

              _sectionTitle("Next Day Planning"),
              _label("Task Name", pad: 6),
              tasksAsync.when(
                data: (tasks) => _taskDropdown(
                  value: _nextDayTask,
                  tasks: tasks,
                  hint: "Select Task or Subtask",
                  onChanged: (v) => setState(() => _nextDayTask = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => _dropdown(value: null, hint: "API Error", items: [], onChanged: (v) {}),
              ),
              const SizedBox(height: 12),
              _label("Next Day Plan / Notes"),
              _textArea(_nextDayPlanController, hint: "What is planned for tomorrow?"),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _updateDPR,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---
  Widget _label(String t, {double pad = 8}) => Padding(padding: EdgeInsets.only(bottom: pad), child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)));
  Widget _sectionTitle(String t) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)));

  Widget _readOnlyField(String text, IconData? icon) {
    return Container(
      height: 48, padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10), color: Colors.grey.shade100),
      child: Row(children: [
        Expanded(child: Text(text, style: const TextStyle(color: Colors.black54, fontSize: 13))),
        if (icon != null) Icon(icon, size: 20, color: Colors.grey.shade400),
      ]),
    );
  }

  Widget _readOnlyNumberField({required String label, required int value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, pad: 6),
        Container(
          height: 48, decoration: BoxDecoration(color: Colors.grey.shade100, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const IconButton(onPressed: null, icon: Icon(Icons.remove, size: 20, color: Colors.black12)),
            Expanded(child: Center(child: Text("$value", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)))),
            const IconButton(onPressed: null, icon: Icon(Icons.add, size: 20, color: Colors.black12))
          ]),
        ),
      ]
    );
  }

  Widget _weatherChipsReadOnly() {
    final opts = [{"l": "Sunny", "i": Icons.wb_sunny_outlined}, {"l": "Cloudy", "i": Icons.cloud_outlined}, {"l": "Rainy", "i": Icons.beach_access_outlined}];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: opts.map((opt) {
        final isSel = _selectedWeather == opt["l"];
        return Container(
          width: 105, padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: isSel ? Colors.grey.shade200 : Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSel ? Colors.grey.shade400 : Colors.grey.shade200)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(opt["l"] as String, style: TextStyle(color: isSel ? Colors.grey.shade600 : Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 6),
              Icon(opt["i"] as IconData, size: 16, color: isSel ? Colors.grey.shade600 : Colors.grey.shade400)
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _addDashedButton(VoidCallback onTap) {
    return Row(
      children: [
        const SizedBox(width: 75), // Aligns with subtasks
        Expanded(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: const DottedBox(height: 44, child: Icon(Icons.add_circle_outline, color: AppColors.primaryBlue, size: 22)))),
      ],
    );
  }

  Widget _dropdown({required String? value, required String hint, required List<String> items, required ValueChanged<String?> onChanged}) => Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4)), borderRadius: BorderRadius.circular(10)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: items.contains(value) ? value : null, isExpanded: true, hint: Text(hint, style: const TextStyle(color: Colors.black54, fontSize: 13)), icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue.withOpacity(0.7)), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(), onChanged: onChanged)));
  Widget _textField(TextEditingController c, {String? hint}) => SizedBox(height: 48, child: TextFormField(controller: c, keyboardType: hint == "%" ? TextInputType.number : TextInputType.text, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: Colors.black38), contentPadding: const EdgeInsets.symmetric(horizontal: 12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.4))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue)))));
  Widget _textArea(TextEditingController c, {String? hint}) => TextFormField(controller: c, minLines: 3, maxLines: 5, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: Colors.black38), contentPadding: const EdgeInsets.all(12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.4))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue))));

  // Safety try-catch to prevent NoSuchMethodError when reading dynamic tasks
  Widget _taskDropdown({required String? value, required String hint, required List<Task> tasks, required ValueChanged<String?> onChanged}) {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var task in tasks) {
      if (task.title.trim().isEmpty || task.title.toLowerCase() == 'null') continue;
      menuItems.add(DropdownMenuItem(value: task.title, child: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryBlue))));
      dynamic dynamicTask = task;
      try {
        if (dynamicTask.subtasks != null) {
          for (var sub in dynamicTask.subtasks) {
            String subTitle = '';
            try { subTitle = sub.name ?? ''; } catch (_) {}
            if (subTitle.isEmpty) try { subTitle = sub.title ?? ''; } catch (_) {}
            if (subTitle.isEmpty) try { subTitle = sub.description ?? ''; } catch (_) {}
            
            if (subTitle.isNotEmpty) {
              menuItems.add(DropdownMenuItem(value: subTitle, child: Padding(padding: const EdgeInsets.only(left: 12.0), child: Text("— $subTitle", style: const TextStyle(fontSize: 13, color: Colors.black87)))));
            }
          }
        }
      } catch (_) {}
    }

    if (value != null && value.trim().isNotEmpty && !menuItems.any((item) => item.value == value)) {
      menuItems.add(DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87))));
    }

    if (menuItems.isEmpty) return _dropdown(value: null, hint: "No tasks assigned", items: [], onChanged: onChanged);

    return Container(
      height: 48, padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4)), borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true, hint: Text(hint, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue.withOpacity(0.7)),
          items: menuItems, onChanged: onChanged,
        ),
      ),
    );
  }

  // Apply _fixUrl to properly load images on device if localhost is accidentally retrieved
  String _fixUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (url.contains('localhost')) {
      return url.replaceAll('localhost', '172.16.9.36'); 
    }
    return url;
  }

  // --- COMBINED MEDIA GRIDS ---
  Widget _photoGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          InkWell(onTap: _pickImage, child: DottedBox(height: 90, width: 90, child: Icon(Icons.add_a_photo_outlined, color: AppColors.primaryBlue.withOpacity(0.6), size: 28))),
          
          // Iterating over the actual objects to save IDs on delete
          ..._existingPhotos.asMap().entries.map((e) {
            final photoObj = e.value;
            final url = photoObj.imageUrl ?? "";
            
            return Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Stack(children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(_fixUrl(url), height: 90, width: 90, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(height: 90, width: 90, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey)))),
                Positioned(top: 4, right: 4, child: InkWell(
                  onTap: () {
                    setState(() {
                      _deletedMediaIds.add(photoObj.id); // Save ID for deletion
                      _existingPhotos.removeAt(e.key);   // Remove from UI immediately
                    });
                  }, 
                  child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white))
                )),
              ]),
            );
          }),
          
          ..._selectedImages.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Stack(children: [
              ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(e.value, height: 90, width: 90, fit: BoxFit.cover)),
              Positioned(top: 4, right: 4, child: InkWell(onTap: () => setState(() => _selectedImages.removeAt(e.key)), child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)))),
            ]),
          ))
        ],
      ),
    );
  }

  Widget _documentGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          InkWell(onTap: _pickDocument, child: DottedBox(height: 90, width: 90, child: Icon(Icons.add_circle_outline, color: AppColors.primaryBlue.withOpacity(0.6), size: 28))),
          
          // Iterating over the actual objects to save IDs on delete
          ..._existingDocuments.asMap().entries.map((e) {
            final docObj = e.value;
            final url = (docObj is DPRPhoto) ? (docObj.imageUrl ?? "") : ((docObj as dynamic).fileUrl ?? "");
            final fileName = url.split('/').last.split('?').first; 
            
            return Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Stack(
                children: [
                  Container(height: 90, width: 90, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.description, color: Colors.blueAccent, size: 30), const SizedBox(height: 8), Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.black87)))]),),
                  Positioned(top: 4, right: 4, child: InkWell(
                    onTap: () {
                      setState(() {
                         // Some documents might not have IDs if they are local placeholder objects, safely grab id
                         try { _deletedMediaIds.add(docObj.id); } catch(_) {}
                         _existingDocuments.removeAt(e.key);
                      });
                    }, 
                    child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white))
                  )),
                ],
              ),
            );
          }),
          
          ..._selectedDocuments.asMap().entries.map((e) {
            final fileName = e.value.path.split('/').last;
            return Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Stack(
                children: [
                  Container(height: 90, width: 90, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 30), const SizedBox(height: 8), Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.black87)))]),),
                  Positioned(top: 4, right: 4, child: InkWell(onTap: () => setState(() => _selectedDocuments.removeAt(e.key)), child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)))),
                ],
              ),
            );
          })
        ],
      ),
    );
  }
}

// --- Dotted Box ---
class DottedBox extends StatelessWidget {
  final Widget child; final double? height, width;
  const DottedBox({super.key, required this.child, this.height, this.width});
  @override Widget build(BuildContext context) { return CustomPaint(painter: _DottedPainter(), child: Container(height: height, width: width, alignment: Alignment.center, child: child)); }
}

class _DottedPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primaryBlue.withOpacity(0.5)..strokeWidth = 1.2..style = PaintingStyle.stroke;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(10)));
    double dashWidth = 6, dashSpace = 4, distance = 0;
    final dashedPath = Path();
    for (final m in path.computeMetrics()) {
      while (distance < m.length) { dashedPath.addPath(m.extractPath(distance, distance + dashWidth), Offset.zero); distance += dashWidth + dashSpace; }
    }
    canvas.drawPath(dashedPath, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}