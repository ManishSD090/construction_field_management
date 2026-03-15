import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/dpr.dart';
import 'package:construction_erp/controllers/dpr/dpr_controller.dart';
import 'package:construction_erp/models/task.dart';
import 'package:construction_erp/screens/dpr/create_dpr_screen.dart'; 

class EditDPRScreen extends ConsumerStatefulWidget {
  final DailyProgressReport dpr;

  const EditDPRScreen({super.key, required this.dpr});

  @override
  ConsumerState<EditDPRScreen> createState() => _EditDPRScreenState();
}

class _EditDPRScreenState extends ConsumerState<EditDPRScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  late TextEditingController _nextDayNotes;
  
  late String _selectedWeather;
  late int _workers;
  late int _staff;
  String? _completedTask;
  String? _nextDayTask;

  // Row lists for dynamic fields
  late List<_EquipmentRow> _equipments;

  @override
  void initState() {
    super.initState();
    // Pre-populate controllers with existing data
    _dateController = TextEditingController(text: DateFormat("dd/MM/yyyy").format(widget.dpr.date));
    _descriptionController = TextEditingController(text: widget.dpr.workDescription);
    _nextDayNotes = TextEditingController(text: widget.dpr.nextDayNotes ?? widget.dpr.notes ?? "");
    
    _selectedWeather = widget.dpr.weather ?? "Sunny";
    _workers = widget.dpr.workersPresent ?? 0;
    _staff = widget.dpr.staffPresent ?? 0;
    _completedTask = widget.dpr.completedWork;
    _nextDayTask = widget.dpr.nextDayTaskName;

    // Map existing Equipment
    _equipments = widget.dpr.equipments.map((e) => _EquipmentRow()
      ..equipmentId = e.id
      ..equipmentName = e.name
      ..qty = e.qty
      ..hoursUsed.text = e.hoursUsed.toString()
    ).toList();
    
    if (_equipments.isEmpty) _equipments.add(_EquipmentRow());
  }

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    _nextDayNotes.dispose();
    for (var r in _equipments) { r.hoursUsed.dispose(); }
    super.dispose();
  }

  void _addEquipmentRow() => setState(() => _equipments.add(_EquipmentRow()));
  void _removeEquipmentRow(int idx) => setState(() { if (_equipments.length > 1) _equipments.removeAt(idx); });

  Future<void> _updateDPR() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      DateTime selectedDate = DateFormat("dd/MM/yyyy").parse(_dateController.text.trim());
      
      // BUILD PAYLOAD TO MATCH BACKEND CONTROLLER EXACTLY
      final payload = {
        'date': selectedDate.toIso8601String(),
        'weather': _selectedWeather,
        'workDescription': _descriptionController.text.trim(),
        'completedWork': _completedTask ?? '',
        'totalWorkers': _workers + _staff,
        'supervisorPresent': true,
        // Backend updateDPR accesses nextDayPlanning.description and nextDayPlanning.workers
        'nextDayPlanning': {
          'taskName': _nextDayTask ?? '',
          'description': _nextDayNotes.text.trim(),
          'workers': _workers + _staff, // Required for backend calculation
        },
        'equipmentUsage': _equipments
            .where((e) => e.equipmentName != null && e.equipmentName!.isNotEmpty)
            .map((e) => {
              'name': e.equipmentName, 
              'hours': int.tryParse(e.hoursUsed.text.trim()) ?? 0,
              'rate': 0, // Backend expects these for budget calculation
              'cost': 0
            }).toList(),
      };

      await ref.read(dprControllerProvider.notifier).updateDPR(widget.dpr.id, payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DPR Updated Successfully')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider(widget.dpr.projectId));
    final equipmentAsync = ref.watch(equipmentProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: Text("Edit ${widget.dpr.reportNo}", style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("DPR Date"),
              _dateField(),
              const SizedBox(height: 20),

              _label("Description"),
              _textArea(_descriptionController, hint: "Update work details..."),
              const SizedBox(height: 20),

              _label("Weather"),
              _weatherChips(),
              const SizedBox(height: 24),

              _sectionTitle("Attendance"),
              Row(
                children: [
                  Expanded(child: _smallNumberField(label: "Workers", value: _workers, onChanged: (v) => setState(() => _workers = v))),
                  const SizedBox(width: 16),
                  Expanded(child: _smallNumberField(label: "Staff", value: _staff, onChanged: (v) => setState(() => _staff = v))),
                ],
              ),
              const SizedBox(height: 24),

              _sectionTitle("Tasks Completed"),
              tasksAsync.when(
                data: (tasks) => _taskDropdown(
                  value: _completedTask,
                  tasks: tasks,
                  hint: "Select Task",
                  onChanged: (v) => setState(() => _completedTask = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text("Error loading tasks"),
              ),
              const SizedBox(height: 24),

              _sectionTitle("Equipments Used"),
              ..._equipments.asMap().entries.map((entry) {
                final idx = entry.key;
                final row = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: equipmentAsync.when(
                          data: (items) => _dropdown(
                            value: row.equipmentName,
                            hint: "Select",
                            items: items.map((e) => e['name'].toString()).toList(),
                            onChanged: (v) => setState(() => row.equipmentName = v),
                          ),
                          loading: () => const SizedBox(),
                          error: (_, __) => const Text("Error"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(width: 70, child: _textField(row.hoursUsed, hint: "Hrs")),
                      if (idx > 0) IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _removeEquipmentRow(idx)),
                    ],
                  ),
                );
              }),
              _addDashedButton(_addEquipmentRow),

              const SizedBox(height: 24),
              _sectionTitle("Next Day Planning"),
              _label("Task Name"),
              tasksAsync.when(
                data: (tasks) => _taskDropdown(
                  value: _nextDayTask,
                  tasks: tasks,
                  hint: "Select Task",
                  onChanged: (v) => setState(() => _nextDayTask = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text("Error loading tasks"),
              ),
              const SizedBox(height: 12),
              _label("Notes"),
              _textArea(_nextDayNotes, hint: "Update next day plans..."),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _updateDPR,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI HELPERS ---
  Widget _taskDropdown({required String? value, required List<Task> tasks, required String hint, required ValueChanged<String?> onChanged}) {
    final validTasks = tasks
        .where((t) => t.title.trim().isNotEmpty && t.title.toLowerCase() != "null")
        .map<String>((t) => t.title.trim())
        .toSet()
        .toList();

    return _dropdown(
      value: (value != null && validTasks.contains(value)) ? value : null,
      hint: hint,
      items: validTasks,
      onChanged: onChanged,
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)));
  Widget _sectionTitle(String t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)));
  Widget _dateField() => Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4)), borderRadius: BorderRadius.circular(10), color: Colors.grey.shade100), child: Row(children: [Expanded(child: Text(_dateController.text)), const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey)]));
  Widget _dropdown({required String? value, required String hint, required List<String> items, required ValueChanged<String?> onChanged}) => Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4)), borderRadius: BorderRadius.circular(10)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, isExpanded: true, hint: Text(hint, style: const TextStyle(color: Colors.black54, fontSize: 13)), icon: const Icon(Icons.keyboard_arrow_down), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(), onChanged: onChanged)));
  Widget _textField(TextEditingController c, {String? hint}) => SizedBox(height: 48, child: TextFormField(controller: c, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.4))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue)))));
  Widget _textArea(TextEditingController c, {String? hint}) => TextFormField(controller: c, minLines: 3, maxLines: 5, decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.all(12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.4))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue))));
  Widget _addDashedButton(VoidCallback onTap) => InkWell(onTap: onTap, child: Container(height: 44, width: double.infinity, decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.add_circle_outline, color: AppColors.primaryBlue)));

  Widget _weatherChips() {
    final opts = [{"l": "Sunny", "i": Icons.wb_sunny_outlined}, {"l": "Cloudy", "i": Icons.cloud_outlined}, {"l": "Rainy", "i": Icons.beach_access_outlined}];
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: opts.map((opt) {
      final isSel = _selectedWeather == opt["l"];
      return InkWell(onTap: () => setState(() => _selectedWeather = opt["l"] as String), borderRadius: BorderRadius.circular(20), child: Container(width: 105, padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: isSel ? AppColors.primaryBlue.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSel ? AppColors.primaryBlue : Colors.grey.shade300)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(opt["l"] as String, style: TextStyle(color: isSel ? AppColors.primaryBlue : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(width: 6), Icon(opt["i"] as IconData, size: 16, color: isSel ? AppColors.primaryBlue : Colors.grey)])));
    }).toList());
  }

  Widget _smallNumberField({required String label, required int value, required ValueChanged<int> onChanged}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label(label), Container(height: 48, decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4)), borderRadius: BorderRadius.circular(10)), child: Row(children: [IconButton(onPressed: () => value > 0 ? onChanged(value - 1) : null, icon: const Icon(Icons.remove, size: 20)), Expanded(child: Center(child: Text("$value", style: const TextStyle(fontWeight: FontWeight.bold)))), IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add, size: 20))]))]);
}

class _EquipmentRow { 
  String? equipmentId, equipmentName; 
  int qty = 0; 
  final TextEditingController hoursUsed = TextEditingController(); 
}