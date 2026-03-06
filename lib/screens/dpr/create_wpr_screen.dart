import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';

class CreateWPRScreen extends StatefulWidget {
  final ScrollController scrollController;

  const CreateWPRScreen({super.key, required this.scrollController});

  @override
  State<CreateWPRScreen> createState() => _CreateWPRScreenState();
}

class _CreateWPRScreenState extends State<CreateWPRScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _weekController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _subContractorNotesController =
      TextEditingController();
  final TextEditingController _nextWeekNotesController =
      TextEditingController();

  String _selectedWeather = "Cloudy";
  String? _selectedSubContractor;
  String? _selectedNextWeekTask;

  final List<_WprTaskRow> _taskRows = [_WprTaskRow()];
  final List<_WprMaterialRow> _materialRows = [_WprMaterialRow()];
  final List<_WprEquipmentRow> _equipmentRows = [_WprEquipmentRow()];

  final List<_AttendanceBarData> _attendanceBars = [
    _AttendanceBarData(day: "12", workers: 42, staff: 32),
    _AttendanceBarData(day: "13", workers: 38, staff: 28),
    _AttendanceBarData(day: "14", workers: 44, staff: 35),
    _AttendanceBarData(day: "15", workers: 46, staff: 36),
    _AttendanceBarData(day: "16", workers: 40, staff: 30),
    _AttendanceBarData(day: "17", workers: 45, staff: 34),
  ];

  @override
  void dispose() {
    _weekController.dispose();
    _descriptionController.dispose();
    _subContractorNotesController.dispose();
    _nextWeekNotesController.dispose();

    for (final row in _taskRows) {
      row.dispose();
    }
    for (final row in _materialRows) {
      row.dispose();
    }
    for (final row in _equipmentRows) {
      row.dispose();
    }

    super.dispose();
  }

  Future<void> _pickWeek() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      final startOfWeek = picked.subtract(Duration(days: picked.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      _weekController.text =
          "${DateFormat("dd MMM").format(startOfWeek)} - ${DateFormat("dd MMM yyyy").format(endOfWeek)}";
      setState(() {});
    }
  }

  void _addTaskRow() {
    setState(() {
      _taskRows.add(_WprTaskRow());
    });
  }

  void _removeTaskRow(int index) {
    if (_taskRows.length == 1) return;
    setState(() {
      _taskRows[index].dispose();
      _taskRows.removeAt(index);
    });
  }

  void _addMaterialRow() {
    setState(() {
      _materialRows.add(_WprMaterialRow());
    });
  }

  void _removeMaterialRow(int index) {
    if (_materialRows.length == 1) return;
    setState(() {
      _materialRows[index].dispose();
      _materialRows.removeAt(index);
    });
  }

  void _addEquipmentRow() {
    setState(() {
      _equipmentRows.add(_WprEquipmentRow());
    });
  }

  void _removeEquipmentRow(int index) {
    if (_equipmentRows.length == 1) return;
    setState(() {
      _equipmentRows[index].dispose();
      _equipmentRows.removeAt(index);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create WPR",
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
              _label("WPR Week"),
              _dateField(),
              const SizedBox(height: 14),

              _label("Weather"),
              _weatherIconsRow(),
              const SizedBox(height: 14),

              _label("Description"),
              _textArea(
                _descriptionController,
                hint: "Enter the description",
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 18),

              _sectionTitle("Attendance"),
              const SizedBox(height: 10),
              _attendanceChartCard(),
              const SizedBox(height: 18),

              _sectionTitle("Sub Contractor Name"),
              const SizedBox(height: 10),
              _subContractorCard(),
              const SizedBox(height: 18),

              _sectionTitle("Progress"),
              const SizedBox(height: 10),
              _progressCard(),
              const SizedBox(height: 18),

              _sectionTitle("Tasks completed"),
              const SizedBox(height: 10),
              _tasksCard(),
              const SizedBox(height: 18),

              _sectionTitle("Materials"),
              const SizedBox(height: 10),
              _materialsCard(),
              const SizedBox(height: 18),

              _sectionTitle("Equipments"),
              const SizedBox(height: 10),
              _equipmentsCard(),
              const SizedBox(height: 18),

              _sectionTitle("Budget"),
              const SizedBox(height: 10),
              _budgetCard(),
              const SizedBox(height: 18),

              _sectionTitle("Photos"),
              const SizedBox(height: 10),
              _uploadGrid(),
              const SizedBox(height: 18),

              _sectionTitle("Documents"),
              const SizedBox(height: 10),
              _uploadGrid(),
              const SizedBox(height: 18),

              _sectionTitle("Next Week Planning"),
              const SizedBox(height: 10),
              _label("Task Name"),
              _dropdown(
                value: _selectedNextWeekTask,
                hint: "Task Name",
                items: const [
                  "Excavation",
                  "Brickwork",
                  "Concreting",
                  "Shuttering"
                ],
                onChanged: (v) => setState(() => _selectedNextWeekTask = v),
              ),
              const SizedBox(height: 12),
              _label("Notes"),
              _textArea(
                _nextWeekNotesController,
                hint: "Notes",
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Submit WPR",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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

  Widget _dateField() {
    final showText = _weekController.text.isEmpty
        ? "WPR Week"
        : _weekController.text;

    return InkWell(
      onTap: _pickWeek,
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
                  fontSize: 14,
                  color: _weekController.text.isEmpty
                      ? Colors.black54
                      : AppColors.textDark,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherIconsRow() {
    final weatherItems = [
      {"label": "Sunny", "icon": Icons.wb_sunny_outlined},
      {"label": "Cloudy", "icon": Icons.cloud_outlined},
      {"label": "Rainy", "icon": Icons.thunderstorm_outlined},
      {"label": "Windy", "icon": Icons.air},
      {"label": "Foggy", "icon": Icons.blur_on_outlined},
      {"label": "Storm", "icon": Icons.flash_on_outlined},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weatherItems.map((item) {
          final label = item["label"] as String;
          final icon = item["icon"] as IconData;
          final isSelected = _selectedWeather == label;

          return GestureDetector(
            onTap: () => setState(() => _selectedWeather = label),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color:
                      isSelected ? AppColors.primaryBlue : AppColors.textGrey,
                ),
                const SizedBox(height: 4),
                Container(
                  height: 6,
                  width: 6,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primaryBlue : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _attendanceChartCard() {
    const maxValue = 50.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.8)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("50",
                        style:
                            TextStyle(fontSize: 10, color: AppColors.textGrey)),
                    Text("40",
                        style:
                            TextStyle(fontSize: 10, color: AppColors.textGrey)),
                    Text("30",
                        style:
                            TextStyle(fontSize: 10, color: AppColors.textGrey)),
                    Text("20",
                        style:
                            TextStyle(fontSize: 10, color: AppColors.textGrey)),
                    Text("10",
                        style:
                            TextStyle(fontSize: 10, color: AppColors.textGrey)),
                    Text("0",
                        style:
                            TextStyle(fontSize: 10, color: AppColors.textGrey)),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _attendanceBars.map((bar) {
                      final workerHeight = (bar.workers / maxValue) * 110;
                      final staffHeight = (bar.staff / maxValue) * 110;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 10,
                                height: workerHeight,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 10,
                                height: staffHeight,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF20B486),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            bar.day,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppColors.primaryBlue, label: "Workers"),
              SizedBox(width: 18),
              _LegendDot(color: Color(0xFF20B486), label: "Staff"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _subContractorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.8)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Sub-Contractor",
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                ),
              ),
              Text(
                _selectedSubContractor ?? "6 workers",
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Sub-Contracting",
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                ),
              ),
              Text(
                _subContractorNotesController.text.trim().isEmpty
                    ? "-"
                    : _subContractorNotesController.text.trim(),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressCard() {
    const progress = 24.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 12,
              backgroundColor: AppColors.lightGrey.withOpacity(0.3),
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: 10),
          _infoRow("Today Progress Added", "-1.5%"),
          _infoRow("Current Overall Progress", "-29.5%"),
        ],
      ),
    );
  }

  Widget _tasksCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.8)),
      ),
      child: Column(
        children: [
          ...List.generate(_taskRows.length, (index) {
            final row = _taskRows[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: _textField(row.taskName, hint: "Task Name"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        row.percentController.text.trim().isEmpty
                            ? "- %"
                            : "${row.percentController.text.trim()} %",
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _removeTaskRow(index),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppColors.alertRed,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          }),
          InkWell(
            onTap: _addTaskRow,
            borderRadius: BorderRadius.circular(10),
            child: const DottedBox(
              height: 44,
              child: Icon(
                Icons.add_circle_outline,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _materialsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.8)),
      ),
      child: Column(
        children: [
          ...List.generate(_materialRows.length, (index) {
            final row = _materialRows[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: _textField(row.nameController, hint: "Name"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        row.qtyController.text.trim().isEmpty
                            ? "Quantity Used"
                            : row.qtyController.text.trim(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _removeMaterialRow(index),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppColors.alertRed,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          }),
          InkWell(
            onTap: _addMaterialRow,
            borderRadius: BorderRadius.circular(10),
            child: const DottedBox(
              height: 44,
              child: Icon(
                Icons.add_circle_outline,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _equipmentsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.8)),
      ),
      child: Column(
        children: [
          ...List.generate(_equipmentRows.length, (index) {
            final row = _equipmentRows[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: _textField(row.nameController, hint: "Name"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        row.hrsUsedController.text.trim().isEmpty
                            ? "Hrs Used"
                            : row.hrsUsedController.text.trim(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        row.fuelController.text.trim().isEmpty
                            ? "Fuel"
                            : row.fuelController.text.trim(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _removeEquipmentRow(index),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppColors.alertRed,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          }),
          InkWell(
            onTap: _addEquipmentRow,
            borderRadius: BorderRadius.circular(10),
            child: const DottedBox(
              height: 44,
              child: Icon(
                Icons.add_circle_outline,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _budgetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.8)),
      ),
      child: const Column(
        children: [
          _BudgetRow(title: "Labour", value: "₹1,20,000"),
          _BudgetRow(title: "Material", value: "₹40,000"),
          _BudgetRow(title: "Equipment", value: "₹25,000"),
          _BudgetRow(title: "Sub-contractor", value: "₹35,000"),
          Divider(height: 20),
          _BudgetRow(title: "Total", value: "₹2,20,000", isBold: true),
        ],
      ),
    );
  }

  Widget _uploadGrid() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.8)),
      ),
      child: const Wrap(
        spacing: 10,
        runSpacing: 10,
        children: const [
          _UploadBox(),
          _UploadBox(),
          _UploadBox(),
        ],
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
          hint: Text(
            hint,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.primaryBlue,
          ),
          items: items
              .map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller, {
    String? hint,
  }) {
    return SizedBox(
      height: 44,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primaryBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.primaryBlue,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _textArea(
    TextEditingController controller, {
    String? hint,
    int minLines = 2,
    int maxLines = 4,
  }) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.primaryBlue, width: 1.4),
        ),
      ),
    );
  }

  Widget _smallCounterField({
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBlue),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () => value > 0 ? onChanged(value - 1) : null,
                  child: const Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
                Text(
                  "$value",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                InkWell(
                  onTap: () => onChanged(value + 1),
                  child: Icon(
                    Icons.add_circle_outline,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;

  const _BudgetRow({
    required this.title,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: isBold ? AppColors.textDark : AppColors.textGrey,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primaryBlue,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: 58,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightGrey),
      ),
    );
  }
}

class _AttendanceBarData {
  final String day;
  final double workers;
  final double staff;

  _AttendanceBarData({
    required this.day,
    required this.workers,
    required this.staff,
  });
}

class _WprTaskRow {
  final TextEditingController taskName = TextEditingController();
  final TextEditingController percentController = TextEditingController();

  void dispose() {
    taskName.dispose();
    percentController.dispose();
  }
}

class _WprMaterialRow {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  void dispose() {
    nameController.dispose();
    qtyController.dispose();
  }
}

class _WprEquipmentRow {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController hrsUsedController = TextEditingController();
  final TextEditingController fuelController = TextEditingController();

  void dispose() {
    nameController.dispose();
    hrsUsedController.dispose();
    fuelController.dispose();
  }
}

class DottedBox extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;

  const DottedBox({
    super.key,
    required this.child,
    this.height,
    this.width,
  });

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

    double dashWidth = 5;
    double dashSpace = 3;
    double distance = 0;
    final dashedPath = Path();

    for (final metric in path.computeMetrics()) {
      distance = 0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
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