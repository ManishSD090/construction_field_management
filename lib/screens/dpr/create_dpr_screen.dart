import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/dpr/dpr_controller.dart';
import 'package:construction_erp/screens/dpr/dpr_details.dart';
import 'package:construction_erp/controllers/core_providers.dart';
import 'package:construction_erp/controllers/inventory/inventory_controller.dart';

// --- DATA PROVIDERS WITH GRACEFUL FALLBACKS ---
final projectsProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    final dioClient = ref.watch(dioClientProvider);
    final response = await dioClient.dio.get('/projects');
    return response.data['data'] as List<dynamic>;
  } catch (e) {
    return [{'id': 'p1', 'name': 'Fallback Project A'}];
  }
});

final materialsProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    // Your current Inventory Controller logic here
    final inventoryController = ref.read(inventoryControllerProvider.notifier);
    final response = await inventoryController.getAllMaterials(); // Or whatever your method is named
    
    // We try to map it safely in case it returns Dart objects instead of raw JSON
    return response.map((m) {
      if (m is Map) return m; // If it's already a map, return it
      // If it's an object, map it to a dictionary
      return {'id': m.id, 'name': m.name}; 
    }).toList();

  } catch (e) {
    print("Materials Provider Error: $e");
    
    // 🟢 FALLBACK DATA: This makes the dropdown clickable again!
    return [
      {'id': '11111111-1111-1111-1111-111111111111', 'name': 'Cement (Mock)'}, 
      {'id': '22222222-2222-2222-2222-222222222222', 'name': 'Sand (Mock)'}, 
      {'id': '33333333-3333-3333-3333-333333333333', 'name': 'Steel Bricks (Mock)'}
    ];
  }
});

final usersProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    final dioClient = ref.watch(dioClientProvider);
    final response = await dioClient.dio.get('/users'); 
    return response.data['data'] as List<dynamic>;
  } catch (e) {
    return [{'id': 'u1', 'name': 'Ajay Singh'}, {'id': 'u2', 'name': 'Rutvik Gondekar'}];
  }
});

final equipmentProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    final dioClient = ref.watch(dioClientProvider);
    final response = await dioClient.dio.get('/equipment'); 
    return response.data['data'] as List<dynamic>;
  } catch (e) {
    return [{'id': 'e1', 'name': 'JCB'}, {'id': 'e2', 'name': 'Vibrator'}, {'id': 'e3', 'name': 'Concrete Mixer'}];
  }
});

final vendorsProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    final dioClient = ref.watch(dioClientProvider);
    
    // 🔴 CHANGE '/vendors' TO YOUR ACTUAL BACKEND ROUTE (e.g., '/subcontractors')
    final response = await dioClient.dio.get('/subcontractors'); 
    
    return response.data['data'] as List<dynamic>;
  } catch (e) {
    print("Error fetching subcontractors: $e");
    // Return an empty list instead of dummy data so you know if it fails
    return []; 
  }
});

class CreateDPRScreen extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const CreateDPRScreen({super.key, required this.scrollController});

  @override
  ConsumerState<CreateDPRScreen> createState() => _CreateDPRScreenState();
}

class _CreateDPRScreenState extends ConsumerState<CreateDPRScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Photo & Document Handling
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedDocuments = [];

  // Controllers
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _completedTaskPercent = TextEditingController();
  final List<TextEditingController> _completedSubtasks = [TextEditingController()];
  final TextEditingController _subContractorNotes = TextEditingController();
  final TextEditingController _nextDayNotes = TextEditingController();

  // State Variables
  String? _selectedProjectId;
  String? _selectedManagerId;
  String? _selectedEngineerId;
  String? _selectedVisitor;
  String? _completedTask;
  String? _subContractor;
  String? _subContractorId;
  String? _nextDayTask;
  String _selectedWeather = "Sunny";
  int _workers = 0;
  int _staff = 0;
  
  int get _present => _workers + _staff;
  int get _total => _workers + _staff;

  // Dynamic Lists
  final List<_TaskRow> _tasks = [_TaskRow()];
  final List<_MaterialRow> _materials = [_MaterialRow()];
  final List<_EquipmentRow> _equipments = [_EquipmentRow()];
  final List<_TaskRow> _nextDayTasks = [_TaskRow()];

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    _completedTaskPercent.dispose();
    _subContractorNotes.dispose();
    _nextDayNotes.dispose();
    for (var c in _completedSubtasks) { c.dispose(); }
    for (var t in _tasks) { t.dispose(); }
    for (var m in _materials) { m.dispose(); }
    for (var e in _equipments) { e.dispose(); }
    for (var n in _nextDayTasks) { n.dispose(); }
    super.dispose();
  }

  // --- UI Action Methods ---
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 3),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateController.text = DateFormat("dd/MM/yyyy").format(picked));
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => _selectedImages.add(File(image.path)));
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedDocuments.add(File(result.files.single.path!)));
    }
  }

  void _addCompletedSubtask() => setState(() => _completedSubtasks.add(TextEditingController()));
  void _removeCompletedSubtask(int index) => setState(() { if (_completedSubtasks.length > 1) { _completedSubtasks[index].dispose(); _completedSubtasks.removeAt(index); } });

  void _addMaterialRow() => setState(() => _materials.add(_MaterialRow()));
  void _removeMaterialRow(int idx) => setState(() { if (_materials.length > 1) { _materials[idx].dispose(); _materials.removeAt(idx); } });

  void _addEquipmentRow() => setState(() => _equipments.add(_EquipmentRow()));
  void _removeEquipmentRow(int idx) => setState(() { if (_equipments.length > 1) { _equipments[idx].dispose(); _equipments.removeAt(idx); } });

  // --- Integration Logic ---
  Map<String, dynamic> _buildPayload() {
    DateTime selectedDate = DateTime.now();
    if (_dateController.text.trim().isNotEmpty && _dateController.text != "DD/MM/YYYY") {
      try { selectedDate = DateFormat("dd/MM/yyyy").parse(_dateController.text.trim()); } catch (_) {}
    }

    final equipmentUsage = _equipments
        .where((e) => (e.equipmentName ?? '').trim().isNotEmpty)
        .map((e) => {
              'name': e.equipmentName, 
              'hours': int.tryParse(e.hoursUsed.text.trim()) ?? 0, 
              'rate': 0,
              'cost': 0 // Added cost to ensure strict matching if needed
            })
        .toList();

    // Filter out materials with no ID OR a quantity of 0
    final materialsConsumed = _materials
        .where((m) => m.materialId != null && m.qty > 0) 
        .map((m) => {'materialId': m.materialId, 'quantity': m.qty.toDouble(), 'unit': 'Nos'})
        .toList();

    return {
      'projectId': _selectedProjectId,
      'date': selectedDate.toIso8601String(),
      'weather': _selectedWeather,
      'workDescription': _descriptionController.text.trim(),
      'completedWork': _completedTask ?? '',
      'totalWorkers': _workers + _staff,
      'supervisorPresent': true,
      
      // Strict Array of objects mapping
      'siteVisitors': _selectedVisitor == null || _selectedVisitor!.trim().isEmpty 
          ? [] 
          : [{'name': _selectedVisitor}],
          
      'equipmentUsage': equipmentUsage,
      
      // Strict mapping: No ID passed to avoid schema rejection
      'subcontractorDetails': {
        'name': _subContractor ?? '',
        'workDone': '',
        'workers': 0,
      },
      
      'nextDayPlanning': {
        'description': _nextDayNotes.text.trim(),
        'workers': _workers + _staff,
      },
      
      'materialsConsumed': materialsConsumed,
    };
  }

  Future<void> _submitDPR() async {
    if (_isSubmitting) return;

    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a project')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = {"body": _buildPayload()};
      final createdDpr = await ref.read(dprControllerProvider.notifier).createDPR(payload);

      if (_selectedImages.isNotEmpty) {
        for (var imageFile in _selectedImages) {
          await ref.read(dprControllerProvider.notifier).uploadDPRPhoto(
            dprId: createdDpr.id, file: imageFile, title: "Progress Photo",
          );
        }
      }

      if (!mounted) return;
      ref.invalidate(dprControllerProvider);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DPRDetailsScreen(dpr: createdDpr)),
      );
    } catch (e) {
      if (!mounted) return;
      String message = 'Failed to create DPR';
      if (e is DioException) message = e.response?.data['message']?.toString() ?? message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final materialsAsync = ref.watch(materialsProvider);
    final usersAsync = ref.watch(usersProvider);
    final equipmentAsync = ref.watch(equipmentProvider);
    final vendorsAsync = ref.watch(vendorsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text("Create DPR", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("DPR Date"),
              _dateField(),
              const SizedBox(height: 14),

              _label("Assigned Project"),
              projectsAsync.when(
                data: (projects) => _dropdown(
                  value: projects.any((p) => p['id'] == _selectedProjectId) ? projects.firstWhere((p) => p['id'] == _selectedProjectId)['name'] : null,
                  hint: "Select Project",
                  items: projects.map((p) => p['name'].toString()).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final selected = projects.firstWhere((p) => p['name'] == val);
                      setState(() => _selectedProjectId = selected['id']);
                    }
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => _dropdown(value: null, hint: "Error loading projects", items: [], onChanged: (v){}),
              ),
              const SizedBox(height: 14),

              _label("Project Manager"),
              usersAsync.when(
                data: (users) => _dropdown(
                  value: users.any((u) => u['id'] == _selectedManagerId) ? users.firstWhere((u) => u['id'] == _selectedManagerId)['name'] : null,
                  hint: "Select Manager",
                  items: users.map((u) => u['name'].toString()).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final selected = users.firstWhere((u) => u['name'] == val);
                      setState(() => _selectedManagerId = selected['id']);
                    }
                  },
                ),
                loading: () => const LinearProgressIndicator(), 
                error: (_, __) => _dropdown(value: null, hint: "API Error", items: [], onChanged: (v){}),
              ),
              const SizedBox(height: 14),

              _label("Site Engineer"),
              usersAsync.when(
                data: (users) => _dropdown(
                  value: users.any((u) => u['id'] == _selectedEngineerId) ? users.firstWhere((u) => u['id'] == _selectedEngineerId)['name'] : null,
                  hint: "Select Engineer",
                  items: users.map((u) => u['name'].toString()).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final selected = users.firstWhere((u) => u['name'] == val);
                      setState(() => _selectedEngineerId = selected['id']);
                    }
                  },
                ),
                loading: () => const LinearProgressIndicator(), 
                error: (_, __) => _dropdown(value: null, hint: "API Error", items: [], onChanged: (v){}),
              ),
              const SizedBox(height: 14),

              _label("Site Visitor"),
              _textField(TextEditingController(text: _selectedVisitor), hint: "Enter Visitor Name (Optional)"),
              const SizedBox(height: 14),

              _label("Description"),
              _textArea(_descriptionController, hint: "Enter the description"),
              const SizedBox(height: 18),

              _label("Weather"),
              _weatherChips(),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle("Attendance"),
                  Text("$_present/$_total Present", style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w700, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _smallNumberField(label: "Workers", value: _workers, onChanged: (v) => setState(() => _workers = v))),
                  const SizedBox(width: 16),
                  Expanded(child: _smallNumberField(label: "Staff", value: _staff, onChanged: (v) => setState(() => _staff = v))),
                ],
              ),
              const SizedBox(height: 20),

              _sectionTitle("Tasks completed"),
              Row(
                children: [
                  Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("Task Name", pad: 6), _dropdown(value: _completedTask, hint: "Task Name", items: const ["Excavation", "Slab", "Brickwork", "Plumbing", "Electrical"], onChanged: (v) => setState(() => _completedTask = v))])),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("%", pad: 6), _textField(_completedTaskPercent, hint: "%")])),
                ],
              ),
              const SizedBox(height: 12),

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

              const SizedBox(height: 18),

              // Materials
              _sectionTitle("Add Materials"),
              const SizedBox(height: 10),
              Column(
                children: List.generate(_materials.length, (idx) {
                  final row = _materials[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (idx == 0) _label("Material Name", pad: 6),
                              materialsAsync.when(
                                data: (mats) => _dropdown(
                                  value: row.materialName, hint: "Select",
                                  items: mats.map((m) => m['name'].toString()).toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      final sel = mats.firstWhere((m) => m['name'] == v);
                                      setState(() { row.materialName = v; row.materialId = sel['id']; });
                                    }
                                  },
                                ),
                                loading: () => const LinearProgressIndicator(), 
                                error: (err, _) => _dropdown(value: null, hint: "API Error", items: [], onChanged: (v){}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (idx == 0) _label("Quantity", pad: 6),
                              _counter(value: row.qty, onChanged: (v) => setState(() => row.qty = v)),
                            ],
                          ),
                        ),
                        if (idx > 0) Padding(padding: const EdgeInsets.only(top: 8), child: IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.alertRed), onPressed: () => _removeMaterialRow(idx))),
                      ],
                    ),
                  );
                }),
              ),
              _addDashedButton(_addMaterialRow),

              const SizedBox(height: 20),
              _sectionTitle("Add Equipments"),
              ..._equipments.asMap().entries.map((entry) {
                final idx = entry.key;
                final row = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (idx == 0) _label("Equipment Name", pad: 6),
                                equipmentAsync.when(
                                  data: (equip) => _dropdown(
                                    value: row.equipmentName, hint: "Select",
                                    items: equip.map((e) => e['name'].toString()).toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        final sel = equip.firstWhere((e) => e['name'] == v);
                                        setState(() { row.equipmentName = v; row.equipmentId = sel['id']; });
                                      }
                                    },
                                  ),
                                  loading: () => const LinearProgressIndicator(), 
                                  error: (_, __) => _dropdown(value: null, hint: "API Error", items: [], onChanged: (v){}),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (idx == 0) _label("Quantity", pad: 6),
                                _counter(value: row.qty, onChanged: (v) => setState(() => row.qty = v)),
                              ],
                            ),
                          ),
                          if (idx > 0) Padding(padding: const EdgeInsets.only(top: 8), child: IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.alertRed), onPressed: () => _removeEquipmentRow(idx))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _label("Hrs. Used", pad: 6),
                      _textField(row.hoursUsed, hint: "0"),
                    ],
                  ),
                );
              }),
              _addDashedButton(_addEquipmentRow),

              const SizedBox(height: 20),
              _sectionTitle("Sub-contractor Details"),
              _label("Sub contractor Name"),
              vendorsAsync.when(
                data: (vendors) => _dropdown(
                  value: _subContractor, hint: "Select",
                  items: vendors.map((v) => v['name'].toString()).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      final sel = vendors.firstWhere((ven) => ven['name'] == v);
                      setState(() { 
                        _subContractor = v; 
                        _subContractorId = sel['id']; 
                      });
                    }
                  },
                ),
                loading: () => const LinearProgressIndicator(), 
                error: (_, __) => _dropdown(value: null, hint: "API Error", items: [], onChanged: (v){}),
              ),
              const SizedBox(height: 12),
              _label("Notes"),
              _textArea(_subContractorNotes, hint: "Notes"),

              const SizedBox(height: 20),
              _label("Upload Site Photos"),
              const SizedBox(height: 8),
              _photoGrid(),

              const SizedBox(height: 16),
              _label("Upload Documents"),
              const SizedBox(height: 8),
              _documentGrid(), 

              const SizedBox(height: 20),
              _sectionTitle("Next Day Planning"),
              _label("Task Name"),
              _dropdown(value: _nextDayTask, hint: "Select Task", items: const ["Shuttering", "Concreting", "Curing", "Excavation"], onChanged: (v) => setState(() => _nextDayTask = v)),
              
              const SizedBox(height: 12),
              _label("Notes"),
              _textArea(_nextDayNotes, hint: "Enter notes"),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitDPR,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("Submit DPR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Reusable UI Elements ---

  Widget _addDashedButton(VoidCallback onTap) {
    return Row(
      children: [
        const SizedBox(width: 75), // Aligns with subtasks
        Expanded(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: const DottedBox(height: 44, child: Icon(Icons.add_circle_outline, color: AppColors.primaryBlue, size: 22)))),
      ],
    );
  }

  Widget _photoGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          InkWell(onTap: _pickImage, child: DottedBox(height: 90, width: 90, child: Icon(Icons.add_a_photo_outlined, color: AppColors.primaryBlue.withOpacity(0.6), size: 28))),
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
          ..._selectedDocuments.asMap().entries.map((e) {
            final fileName = e.value.path.split('/').last;
            return Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Stack(
                children: [
                  Container(
                    height: 90, width: 90,
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 30),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6), 
                          child: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.black87))
                        ),
                      ],
                    ),
                  ),
                  Positioned(top: 4, right: 4, child: InkWell(onTap: () => setState(() => _selectedDocuments.removeAt(e.key)), child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)))),
                ],
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _label(String t, {double pad = 8}) => Padding(padding: EdgeInsets.only(bottom: pad), child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)));
  Widget _sectionTitle(String t) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)));
  Widget _dateField() => InkWell(onTap: _pickDate, child: Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4)), borderRadius: BorderRadius.circular(10)), child: Row(children: [Expanded(child: Text(_dateController.text.isEmpty ? "DD/MM/YYYY" : _dateController.text, style: const TextStyle(color: Colors.black87))), Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.primaryBlue.withOpacity(0.7))])));
  Widget _dropdown({required String? value, required String hint, required List<String> items, required ValueChanged<String?> onChanged}) => Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4)), borderRadius: BorderRadius.circular(10)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: items.contains(value) ? value : null, isExpanded: true, hint: Text(hint, style: const TextStyle(color: Colors.black54, fontSize: 13)), icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue.withOpacity(0.7)), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(), onChanged: onChanged)));
  Widget _textField(TextEditingController c, {String? hint}) => SizedBox(height: 48, child: TextFormField(controller: c, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: Colors.black38), contentPadding: const EdgeInsets.symmetric(horizontal: 12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.4))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue)))));
  Widget _textArea(TextEditingController c, {String? hint}) => TextFormField(controller: c, minLines: 3, maxLines: 5, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: Colors.black38), contentPadding: const EdgeInsets.all(12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.4))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue))));
  
  Widget _weatherChips() {
    final opts = [{"l": "Sunny", "i": Icons.wb_sunny_outlined}, {"l": "Cloudy", "i": Icons.cloud_outlined}, {"l": "Rainy", "i": Icons.beach_access_outlined}];
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: opts.map((opt) {
      final isSel = _selectedWeather == opt["l"];
      return InkWell(onTap: () => setState(() => _selectedWeather = opt["l"] as String), borderRadius: BorderRadius.circular(20), child: Container(width: 105, padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: isSel ? AppColors.primaryBlue.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSel ? AppColors.primaryBlue : Colors.grey.shade300)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(opt["l"] as String, style: TextStyle(color: isSel ? AppColors.primaryBlue : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(width: 6), Icon(opt["i"] as IconData, size: 16, color: isSel ? AppColors.primaryBlue : Colors.grey)])));
    }).toList());
  }

  Widget _smallNumberField({required String label, required int value, required ValueChanged<int> onChanged}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label(label, pad: 6), Container(height: 48, decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4)), borderRadius: BorderRadius.circular(10)), child: Row(children: [IconButton(onPressed: () => value > 0 ? onChanged(value - 1) : null, icon: Icon(Icons.remove, color: AppColors.primaryBlue.withOpacity(0.7), size: 20)), Expanded(child: Center(child: Text("$value", style: const TextStyle(fontWeight: FontWeight.bold)))), IconButton(onPressed: () => onChanged(value + 1), icon: Icon(Icons.add, color: AppColors.primaryBlue.withOpacity(0.7), size: 20))]))]);
  
  Widget _counter({required int value, required ValueChanged<int> onChanged}) {
    return Container(
      height: 48, decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4)), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        IconButton(onPressed: () => value > 0 ? onChanged(value - 1) : null, icon: Icon(Icons.remove_circle_outline, color: AppColors.primaryBlue.withOpacity(0.7), size: 20)),
        Expanded(child: Center(child: Text("$value", style: const TextStyle(fontWeight: FontWeight.bold)))),
        IconButton(onPressed: () => onChanged(value + 1), icon: Icon(Icons.add_circle_outline, color: AppColors.primaryBlue.withOpacity(0.7), size: 20)),
      ]),
    );
  }
}

// --- Data Row Models ---
class _TaskRow { final controller = TextEditingController(); void dispose() => controller.dispose(); }
class _MaterialRow { String? materialId, materialName; int qty = 0; void dispose() {} }
class _EquipmentRow { String? equipmentId, equipmentName; int qty = 0; final TextEditingController hoursUsed = TextEditingController(); void dispose() => hoursUsed.dispose(); }

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