import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/screens/dpr/dpr_details.dart';
import 'package:construction_erp/models/dpr.dart';
import 'package:construction_erp/models/enums.dart';

class CreateDPRScreen extends StatefulWidget {
  final ScrollController scrollController;

  const CreateDPRScreen({super.key, required this.scrollController});

  @override
  State<CreateDPRScreen> createState() => _CreateDPRScreenState();
}

class _CreateDPRScreenState extends State<CreateDPRScreen> {
  final _formKey = GlobalKey<FormState>();

  // Date
  final TextEditingController _dateController = TextEditingController();

  // Dropdown selections (dummy)
  String? _selectedProject;
  String? _selectedManager;
  String? _selectedEngineer;
  String? _selectedVisitor;
  String _selectedWeather = "Sunny";

  // Description
  final TextEditingController _descriptionController = TextEditingController();

  // Attendance
  int _workers = 0;
  int _staff = 0;
  int _present = 0;
  int _total = 0;

  // Tasks Completed
  String? _completedTask;
  final TextEditingController _completedTaskPercent = TextEditingController();
  final List<TextEditingController> _completedSubtasks = [TextEditingController()];

  // Materials rows
  final List<_MaterialRow> _materials = [_MaterialRow()];

  // Equipments rows
  final List<_EquipmentRow> _equipments = [_EquipmentRow()];

  // Sub contractor
  String? _subContractor;
  final TextEditingController _subContractorNotes = TextEditingController();

  // Next day planning
  String? _nextDayTask;
  final TextEditingController _nextDayNotes = TextEditingController();

  DailyProgressReport _buildDummyDpr() {
    final now = DateTime.now();

    DateTime date = now;
    if (_dateController.text.trim().isNotEmpty) {
      try {
        date = DateFormat("dd MMM yyyy").parse(_dateController.text.trim());
      } catch (_) {}
    }

    return DailyProgressReport(
  id: "temp_${now.millisecondsSinceEpoch}",
  reportNo: "DPR-${now.millisecondsSinceEpoch}",
  projectId: _selectedProject ?? "Project A",

  preparedById: "temp_user",
  preparedBy: null,

  date: date,
  weather: _selectedWeather,

  workDescription: _descriptionController.text.trim().isEmpty
      ? "-"
      : _descriptionController.text.trim(),

  siteVisitor: _selectedVisitor,

  // Attendance
  workersPresent: _workers,
  workersTotal: _workers,
  staffPresent: _staff,
  staffTotal: _staff,
  totalWorkers: _workers + _staff,

  // Tasks (structured)
  tasksCompleted: _completedTask == null
      ? []
      : [
          DPRTask(
            name: _completedTask!,
            percent: int.tryParse(_completedTaskPercent.text),
            status: TaskStatus.todo,
            subtasks: _completedSubtasks
                .where((c) => c.text.trim().isNotEmpty)
                .map((c) => DPRSubtask(name: c.text.trim()))
                .toList(),
          )
        ],

        // Materials (structured)
        materials: _materials
            .where((m) => (m.materialName ?? "").trim().isNotEmpty)
            .map((m) => DPRMaterial(
                  name: m.materialName!,
                  qtyUsed: m.qty,
                ))
            .toList(),

        // Equipments (structured)
        equipments: _equipments
            .where((e) => (e.equipmentName ?? "").trim().isNotEmpty)
            .map((e) => DPREquipment(
                  name: e.equipmentName!,
                  qty: e.qty,
                  hoursUsed: int.tryParse(e.hoursUsed.text) ?? 0,
                  fuel: "", // keep empty for now
                ))
            .toList(),

        // Subcontractor
        subContractorName: _subContractor,
        subContractorNotes: _subContractorNotes.text.trim(),

        // Next day plan
        nextDayTaskName: _nextDayTask,
        nextDayNotes: _nextDayNotes.text.trim(),

        status: TaskStatus.todo,
        createdAt: now,
        updatedAt: now,

        photos: const [],
        documents: const [],
      );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    _completedTaskPercent.dispose();
    for (final c in _completedSubtasks) {
      c.dispose();
    }
    for (final m in _materials) {
      m.dispose();
    }
    for (final e in _equipments) {
      e.dispose();
    }
    _subContractorNotes.dispose();
    _nextDayNotes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 5),
      initialDate: now,
    );
    if (picked != null) {
      _dateController.text = DateFormat("dd MMM yyyy").format(picked);
      setState(() {});
    }
  }

  void _addCompletedSubtask() {
    setState(() => _completedSubtasks.add(TextEditingController()));
  }

  void _removeCompletedSubtask(int index) {
    if (_completedSubtasks.length == 1) return;
    setState(() {
      _completedSubtasks[index].dispose();
      _completedSubtasks.removeAt(index);
    });
  }

  void _addMaterialRow() => setState(() => _materials.add(_MaterialRow()));
  void _removeMaterialRow(int idx) {
    if (_materials.length == 1) return;
    setState(() {
      _materials[idx].dispose();
      _materials.removeAt(idx);
    });
  }

  void _addEquipmentRow() => setState(() => _equipments.add(_EquipmentRow()));
  void _removeEquipmentRow(int idx) {
    if (_equipments.length == 1) return;
    setState(() {
      _equipments[idx].dispose();
      _equipments.removeAt(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(50),
          ),
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          "Create DPR",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("DPR Date"),
              _dateField(),
              const SizedBox(height: 14),

              _label("Assigned Project"),
              _dropdown(
                value: _selectedProject,
                hint: "Select Project",
                items: const ["Project A", "Project B"],
                onChanged: (v) => setState(() => _selectedProject = v),
              ),
              const SizedBox(height: 14),

              _label("Project Manager"),
              _dropdown(
                value: _selectedManager,
                hint: "Select Manager",
                items: const ["Manager 1", "Manager 2"],
                onChanged: (v) => setState(() => _selectedManager = v),
              ),
              const SizedBox(height: 14),

              _label("Site Engineer"),
              _dropdown(
                value: _selectedEngineer,
                hint: "Select Engineer",
                items: const ["Engineer 1", "Engineer 2"],
                onChanged: (v) => setState(() => _selectedEngineer = v),
              ),
              const SizedBox(height: 14),

              _label("Site Visitor"),
              _dropdown(
                value: _selectedVisitor,
                hint: "Site Visitor",
                items: const ["Visitor A", "Visitor B"],
                onChanged: (v) => setState(() => _selectedVisitor = v),
              ),
              const SizedBox(height: 14),

              _label("Description"),
              _textArea(_descriptionController, hint: "Enter the description"),
              const SizedBox(height: 16),

              _label("Weather"),
              _weatherChips(),
              const SizedBox(height: 18),

              // Attendance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle("Attendance"),
                  Text(
                    "${_present}/${_total} present",
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _smallNumberField(
                      label: "Workers",
                      value: _workers,
                      onChanged: (v) => setState(() => _workers = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _smallNumberField(
                      label: "Staff",
                      value: _staff,
                      onChanged: (v) => setState(() => _staff = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Tasks completed
              _sectionTitle("Tasks completed"),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Task Name", pad: 6),
                        _dropdown(
                          value: _completedTask,
                          hint: "Task Name",
                          items: const ["Excavation", "Slab", "Brickwork"],
                          onChanged: (v) => setState(() => _completedTask = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("%", pad: 6),
                        _textField(_completedTaskPercent, hint: "%"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // subtasks rows
              Column(
                children: List.generate(_completedSubtasks.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 75,
                          child: Text(
                            "Subtask ${i + 1}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _textField(_completedSubtasks[i],
                              hint: "Subtask name"),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _removeCompletedSubtask(i),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.alertRed.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.remove,
                                color: AppColors.alertRed, size: 18),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              Row(
                children: [
                  const SizedBox(width: 75),
                  Expanded(
                    child: InkWell(
                      onTap: _addCompletedSubtask,
                      borderRadius: BorderRadius.circular(10),
                      child: const DottedBox(
                        height: 44,
                        child: Icon(Icons.add_circle_outline,
                            color: AppColors.primaryBlue, size: 22),
                      ),
                    ),
                  ),
                ],
              ),

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
                              _label("Material Name", pad: 6),
                              _dropdown(
                                value: row.materialName,
                                hint: "Material Name",
                                items: const ["Cement", "Sand", "Steel"],
                                onChanged: (v) =>
                                    setState(() => row.materialName = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("Quantity", pad: 6),
                              _counter(
                                value: row.qty,
                                onChanged: (v) => setState(() => row.qty = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 26),
                          child: InkWell(
                            onTap: () => _removeMaterialRow(idx),
                            child: const Icon(Icons.delete_outline,
                                color: AppColors.alertRed),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              InkWell(
                onTap: _addMaterialRow,
                borderRadius: BorderRadius.circular(10),
                child: const DottedBox(
                  height: 44,
                  child: Icon(Icons.add_circle_outline,
                      color: AppColors.primaryBlue),
                ),
              ),

              const SizedBox(height: 18),

              // Equipment
              _sectionTitle("Add Equipments"),
              const SizedBox(height: 10),
              Column(
                children: List.generate(_equipments.length, (idx) {
                  final row = _equipments[idx];
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
                                  _label("Equipment Name", pad: 6),
                                  _dropdown(
                                    value: row.equipmentName,
                                    hint: "Equipment Name",
                                    items: const ["JCB", "Vibrator", "Mixer"],
                                    onChanged: (v) => setState(
                                        () => row.equipmentName = v),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label("Quantity", pad: 6),
                                  _counter(
                                    value: row.qty,
                                    onChanged: (v) =>
                                        setState(() => row.qty = v),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(top: 26),
                              child: InkWell(
                                onTap: () => _removeEquipmentRow(idx),
                                child: const Icon(Icons.delete_outline,
                                    color: AppColors.alertRed),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _label("Hrs. Used", pad: 6),
                        _textField(row.hoursUsed, hint: "Hrs. Used"),
                      ],
                    ),
                  );
                }),
              ),
              InkWell(
                onTap: _addEquipmentRow,
                borderRadius: BorderRadius.circular(10),
                child: const DottedBox(
                  height: 44,
                  child: Icon(Icons.add_circle_outline,
                      color: AppColors.primaryBlue),
                ),
              ),

              const SizedBox(height: 18),

              // Sub contractor
              _sectionTitle("Sub-contractor Details"),
              const SizedBox(height: 10),
              _label("Sub contractor Name"),
              _dropdown(
                value: _subContractor,
                hint: "Sub contractor Name",
                items: const ["Vendor A", "Vendor B"],
                onChanged: (v) => setState(() => _subContractor = v),
              ),
              const SizedBox(height: 12),
              _label("Notes"),
              _textArea(_subContractorNotes, hint: "Notes"),
              const SizedBox(height: 18),

              // Uploads
              _label("Upload Site Photos"),
              const SizedBox(height: 8),
              const Row(
                children: const [
                  DottedBox(
                    height: 90,
                    width: 90,
                    child: Icon(Icons.add_circle_outline,
                        color: AppColors.primaryBlue, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _label("Upload Documents"),
              const SizedBox(height: 8),
              const Row(
                children: const [
                  DottedBox(
                    height: 90,
                    width: 90,
                    child: Icon(Icons.add_circle_outline,
                        color: AppColors.primaryBlue, size: 28),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Next day planning
              _sectionTitle("Next Day Planning"),
              const SizedBox(height: 10),
              _label("Task Name"),
              _dropdown(
                value: _nextDayTask,
                hint: "Task Name",
                items: const ["Shuttering", "Concreting", "Curing"],
                onChanged: (v) => setState(() => _nextDayTask = v),
              ),
              const SizedBox(height: 12),
              _label("Notes"),
              _textArea(_nextDayNotes, hint: "Notes"),
              const SizedBox(height: 22),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final createdDpr = _buildDummyDpr();

                    final nav = Navigator.of(context, rootNavigator: true);
                    nav.pop(); // close bottom sheet

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      nav.push(
                        MaterialPageRoute(
                          builder: (_) => DPRDetailsScreen(dpr: createdDpr),
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Submit DPR",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI helpers ----------------

  Widget _sectionTitle(String t) => Text(
        t,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      );

  Widget _label(String t, {double pad = 8}) => Padding(
        padding: EdgeInsets.only(bottom: pad),
        child: Text(
          t,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      );

  Widget _dateField() {
    final showText = _dateController.text.isNotEmpty
        ? _dateController.text
        : "DD/MM/YYYY";
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                showText,
                style: TextStyle(
                  color: _dateController.text.isEmpty
                      ? Colors.black54
                      : AppColors.textDark,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                color: AppColors.primaryBlue, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint,
              style: const TextStyle(color: Colors.black54, fontSize: 14)),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.primaryBlue),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _textField(TextEditingController c, {String? hint}) {
    return SizedBox(
      height: 48,
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primaryBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _textArea(TextEditingController c, {String? hint}) {
    return TextFormField(
      controller: c,
      minLines: 3,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _weatherChips() {
    final options = [
      {"label": "Sunny", "icon": Icons.wb_sunny_outlined},
      {"label": "Cloudy", "icon": Icons.cloud_outlined},
      {"label": "Rainy", "icon": Icons.thunderstorm_outlined},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: options.map((opt) {
        final label = opt["label"] as String;
        final icon = opt["icon"] as IconData;
        final isSelected = _selectedWeather == label;

        return InkWell(
          onTap: () => setState(() => _selectedWeather = label),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 102,
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : Colors.blue.shade800,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(icon,
                    size: 16,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : Colors.blue.shade800),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _smallNumberField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, pad: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryBlue),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => value > 0 ? onChanged(value - 1) : null,
                child: const Icon(Icons.remove_circle_outline,
                    color: AppColors.primaryBlue),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "$value",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              InkWell(
                onTap: () => onChanged(value + 1),
                child: const Icon(Icons.add_circle_outline,
                    color: AppColors.primaryBlue),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _counter({
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => value > 0 ? onChanged(value - 1) : null,
            child: const Icon(Icons.remove_circle_outline,
                color: AppColors.primaryBlue),
          ),
          Expanded(
            child: Center(
              child: Text(
                "$value",
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          InkWell(
            onTap: () => onChanged(value + 1),
            child: const Icon(Icons.add_circle_outline,
                color: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }
}

// ---------------- Models for dynamic rows ----------------

class _MaterialRow {
  String? materialName;
  int qty = 0;

  void dispose() {}
}

class _EquipmentRow {
  String? equipmentName;
  int qty = 0;
  final TextEditingController hoursUsed = TextEditingController();

  void dispose() {
    hoursUsed.dispose();
  }
}

// ---------------- Dotted box (your existing one is fine) ----------------

class DottedBox extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;

  const DottedBox({super.key, required this.child, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedPainter(),
      child: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child: child,
      ),
    );
  }
}

class _DottedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10),
    );

    final path = Path()..addRRect(rrect);

    double dashWidth = 5, dashSpace = 3, distance = 0;
    final dashedPath = Path();

    for (final m in path.computeMetrics()) {
      distance = 0;
      while (distance < m.length) {
        dashedPath.addPath(
          m.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}