import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'dart:ui';

class CreateDPRScreen extends StatefulWidget {
  const CreateDPRScreen({super.key});

  @override
  State<CreateDPRScreen> createState() => _CreateDPRScreenState();
}

class _CreateDPRScreenState extends State<CreateDPRScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _visitorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _workersController = TextEditingController();
  final TextEditingController _staffController = TextEditingController();
  final TextEditingController _bottomVisitorController =
      TextEditingController();

  // Task Controllers
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _subtask1Controller =
      TextEditingController(); // Static Subtask 1
  final List<TextEditingController> _dynamicSubtasks = []; // Subtask 2, 3...

  String _selectedWeather = 'Sunny';
  int _materialQty = 0;
  int _equipmentQty = 0;

  @override
  void dispose() {
    _dateController.dispose();
    _visitorController.dispose();
    _descriptionController.dispose();
    _workersController.dispose();
    _staffController.dispose();
    _bottomVisitorController.dispose();
    _taskNameController.dispose();
    _subtask1Controller.dispose();
    for (var c in _dynamicSubtasks) c.dispose();
    super.dispose();
  }

  void _addSubtask() {
    setState(() {
      _dynamicSubtasks.add(TextEditingController());
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      _dynamicSubtasks[index].dispose();
      _dynamicSubtasks.removeAt(index);
    });
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create DPR",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Date
              _buildLabel("DPR Date"),
              _buildDatePicker(),
              const SizedBox(height: 16),

              // 2. Dropdowns
              _buildLabel("Assigned Project"),
              _buildDropdown("Select Project"),
              const SizedBox(height: 16),

              _buildLabel("Project Manager"),
              _buildDropdown("Select Manager"),
              const SizedBox(height: 16),

              _buildLabel("Site Engineer"),
              _buildDropdown("Select Engineer"),
              const SizedBox(height: 16),

              // 3. Visitor & Desc
              _buildLabel("Site Visitor"),
              _buildTextField(_visitorController),
              const SizedBox(height: 16),

              _buildLabel("Description"),
              _buildTextField(_descriptionController,
                  hint: "Enter the description"),
              const SizedBox(height: 16),

              // 4. Weather
              _buildLabel("Weather"),
              _buildWeatherSelector(),
              const SizedBox(height: 20),

              // 5. Attendance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel("Attendance", padding: 0),
                  const Text("18/20 Present",
                      style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(_workersController,
                          label: "Workers")),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _buildTextField(_staffController, label: "Staff")),
                ],
              ),
              const SizedBox(height: 24),

              // 6. Tasks Completed (The Complex Part)
              const Text("Tasks completed",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),

              // Task Name
              _buildLabel("Task Name"),
              _buildTextField(_taskNameController),
              const SizedBox(height: 12),

              // Subtask 1 (Static)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 80,
                    child: Text("Subtask 1",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                  ),
                  Expanded(child: _buildTextField(_subtask1Controller)),
                ],
              ),
              const SizedBox(height: 12),

              // Dynamic Subtasks (Subtask 2, 3...)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _dynamicSubtasks.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text("Subtask ${index + 2}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14)),
                      ),
                      Expanded(child: _buildTextField(_dynamicSubtasks[index])),
                      const SizedBox(width: 8),
                      // Remove Button
                      InkWell(
                        onTap: () => _removeSubtask(index),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.remove,
                              color: Colors.red, size: 18),
                        ),
                      )
                    ],
                  );
                },
              ),
              if (_dynamicSubtasks.isNotEmpty) const SizedBox(height: 12),

              // Add Subtask Button (Dotted)
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text("Subtask ${_dynamicSubtasks.length + 2}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _addSubtask,
                      borderRadius: BorderRadius.circular(8),
                      child: const DottedBox(
                          child: Icon(Icons.add_circle_outline,
                              color: AppColors.primaryBlue, size: 22)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 7. Add Tasks (Group)
              const Text("Add tasks",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildAddTaskGroup(),
              const SizedBox(height: 12),
              _buildAddTaskGroup(),
              const SizedBox(height: 24),

              // 8. Materials
              const Text("Add Materials",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Material Name"),
                            _buildDropdown("")
                          ])),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 1,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildLabel("Quantity"),
                            _buildCounter(_materialQty,
                                (v) => setState(() => _materialQty = v))
                          ])),
                ],
              ),
              const SizedBox(height: 12),
              const DottedBox(
                  height: 45,
                  child: Icon(Icons.add_circle_outline,
                      color: AppColors.primaryBlue)),
              const SizedBox(height: 24),

              // 9. Equipments
              const Text("Add Equipments",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Equipment Name"),
                            _buildDropdown("")
                          ])),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 1,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildLabel("Quantity"),
                            _buildCounter(_equipmentQty,
                                (v) => setState(() => _equipmentQty = v))
                          ])),
                ],
              ),
              const SizedBox(height: 12),
              const DottedBox(
                  height: 45,
                  child: Icon(Icons.add_circle_outline,
                      color: AppColors.primaryBlue)),
              const SizedBox(height: 24),

              // 10. Uploads
              _buildLabel("Upload Site Photos"),
              const DottedBox(
                  height: 100,
                  width: 100,
                  child: Icon(Icons.add_circle_outline,
                      color: AppColors.primaryBlue, size: 30)),
              const SizedBox(height: 16),

              _buildLabel("Upload Documents"),
              const DottedBox(
                  height: 100,
                  width: 100,
                  child: Icon(Icons.add_circle_outline,
                      color: AppColors.primaryBlue, size: 30)),
              const SizedBox(height: 24),

              // 11. Bottom Visitor
              _buildLabel("Site Visitor"),
              _buildTextField(_bottomVisitorController,
                  hint: "Enter the description"),
              const SizedBox(height: 30),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: const Text("Submit DPR",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildLabel(String text, {double padding = 6}) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black87)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl,
      {String? hint, String? label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500))),
        SizedBox(
          height: 48,
          child: TextFormField(
            controller: ctrl,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.blue[100], fontSize: 14),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryBlue)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: AppColors.primaryBlue, width: 1.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String hint) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.primaryBlue),
          hint: Text(hint.isEmpty ? "Select" : hint,
              style: TextStyle(
                  color: hint.isEmpty ? Colors.black87 : Colors.blue[100],
                  fontSize: 14)),
          items: const [],
          onChanged: (v) {},
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () {},
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Select Date",
                style: TextStyle(color: Colors.black54)), // Placeholder
            Icon(Icons.calendar_today_outlined,
                color: AppColors.primaryBlue, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherSelector() {
    final options = [
      {'label': 'Sunny', 'icon': Icons.wb_sunny_outlined},
      {'label': 'Cloudy', 'icon': Icons.cloud_outlined},
      {'label': 'Rainy', 'icon': Icons.thunderstorm_outlined},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: options.map((opt) {
        bool isSelected = _selectedWeather == opt['label'];
        return InkWell(
          onTap: () =>
              setState(() => _selectedWeather = opt['label'] as String),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 100, // Fixed width for uniformity
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : const Color(0xFFE3F2FD),
              border: Border.all(
                  color:
                      isSelected ? AppColors.primaryBlue : Colors.transparent),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(opt['label'] as String,
                    style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.blue[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(width: 6),
                Icon(opt['icon'] as IconData,
                    size: 16,
                    color:
                        isSelected ? AppColors.primaryBlue : Colors.blue[700]),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCounter(int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
            onTap: () => value > 0 ? onChanged(value - 1) : null,
            child: const Icon(Icons.remove_circle_outline,
                color: AppColors.primaryBlue, size: 22)),
        Container(
          width: 50,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryBlue),
              borderRadius: BorderRadius.circular(8)),
          child: Text("$value",
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        InkWell(
            onTap: () => onChanged(value + 1),
            child: const Icon(Icons.add_circle_outline,
                color: AppColors.primaryBlue, size: 22)),
      ],
    );
  }

  Widget _buildAddTaskGroup() {
    return Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Task Name"),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: _buildDropdown("")),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 25), // Spacer for Label alignment
                  Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryBlue),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text("%",
                        style: TextStyle(color: AppColors.primaryBlue)),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            const SizedBox(
                width: 80,
                child: Text("Subtask 1",
                    style: TextStyle(fontWeight: FontWeight.w500))),
            const Expanded(
                child: const DottedBox(
                    height: 40,
                    child: const Icon(Icons.add_circle_outline,
                        color: AppColors.primaryBlue, size: 20))),
          ],
        )
      ],
    );
  }
}

// Custom Dotted Box Widget
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

    final path = Path();
    // Simple rounded rect path
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8)));

    // Create dashed path manually or use a simple hack:
    // Since Flutter doesn't have native DashPath, we draw simple border.
    // For true dotted effect in production, use 'dotted_border' package.
    // Simulating with a light solid line for now as per "blue border" request in standard code.

    // To actually draw dots/dashes without package:
    double dashWidth = 5, dashSpace = 3, distance = 0;
    Path dashedPath = Path();
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(oldDelegate) => false;
}