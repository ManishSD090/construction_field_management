import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/wpr/wpr_controller.dart';
import 'package:construction_erp/models/enums.dart';

class CreateWPRScreen extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final String projectId; // Added to fetch correct preview data

  const CreateWPRScreen({
    super.key, 
    required this.scrollController,
    required this.projectId,
  });

  @override
  ConsumerState<CreateWPRScreen> createState() => _CreateWPRScreenState();
}

class _CreateWPRScreenState extends ConsumerState<CreateWPRScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingPreview = false;

  final TextEditingController _weekController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nextWeekNotesController = TextEditingController();

  String? _selectedNextWeekTask;
  Map<String, dynamic>? _previewData;

  @override
  void dispose() {
    _weekController.dispose();
    _descriptionController.dispose();
    _nextWeekNotesController.dispose();
    super.dispose();
  }

  // --- LOGIC: Fetch Aggregated Data for the Selected Week ---
  Future<void> _handleWeekSelection() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      final startOfWeek = picked.subtract(Duration(days: picked.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      
      setState(() {
        _weekController.text = "${DateFormat("dd MMM").format(startOfWeek)} - ${DateFormat("dd MMM yyyy").format(endOfWeek)}";
        _isLoadingPreview = true;
      });

      try {
        // Fetch real aggregated data from backend
        final data = await ref.read(wprControllerProvider.notifier)
            .getWeeklyPreview(widget.projectId, startOfWeek);
        
        setState(() {
          _previewData = data;
          _isLoadingPreview = false;
        });
      } catch (e) {
        setState(() => _isLoadingPreview = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching weekly data: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text("Create WPR", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: _isLoadingPreview 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("WPR Week"),
                  _dateField(),
                  const SizedBox(height: 20),

                  _label("Weather"),
                  _weatherWeeklyRow(),
                  const SizedBox(height: 20),

                  _label("Description"),
                  _textArea(_descriptionController, hint: "Enter the weekly summary..."),
                  const SizedBox(height: 24),

                  _sectionHeader("Attendance", trailing: "${_previewData?['presentCount'] ?? '0'}/30 Present"),
                  _attendanceChartCard(),
                  const SizedBox(height: 24),

                  _sectionHeader("Sub Contractor Names"),
                  _subContractorListCard(),
                  const SizedBox(height: 24),

                  _sectionHeader("Progress"),
                  _progressIndicatorCard(),
                  const SizedBox(height: 24),

                  _sectionHeader("Tasks", subTitle: "subtasks"),
                  _tasksListCard(),
                  const SizedBox(height: 24),

                  _sectionHeader("Materials"),
                  _materialsListCard(),
                  const SizedBox(height: 24),

                  _sectionHeader("Equipments"),
                  _equipmentsListCard(),
                  const SizedBox(height: 24),

                  _sectionHeader("Budget"),
                  _budgetSummaryCard(),
                  const SizedBox(height: 24),

                  _sectionHeader("Photos"),
                  _placeholderGrid(),
                  const SizedBox(height: 24),

                  const Text("Next Week Planning", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _label("Task Name"),
                  _dropdown(
                    value: _selectedNextWeekTask,
                    hint: "Select Task",
                    items: ["Foundation Pouring", "Excavation", "Brickwork"],
                    onChanged: (v) => setState(() => _selectedNextWeekTask = v),
                  ),
                  const SizedBox(height: 12),
                  _label("Notes"),
                  _textArea(_nextWeekNotesController, hint: "Enter planning notes..."),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                      child: const Text("Submit WPR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  // --- REFINED UI COMPONENTS ---

  Widget _dateField() {
    return InkWell(
      onTap: _handleWeekSelection,
      child: Container(
        height: 48, padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5))),
        child: Row(children: [
          Expanded(child: Text(_weekController.text.isEmpty ? "Select Week" : _weekController.text)),
          const Icon(Icons.calendar_today_outlined, color: AppColors.primaryBlue, size: 20),
        ]),
      ),
    );
  }

  Widget _weatherWeeklyRow() {
    final days = ["01", "02", "03", "04", "05", "06", "07"];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((day) => Column(children: [
          Text(day, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          const Icon(Icons.wb_sunny_outlined, size: 18, color: AppColors.primaryBlue),
        ])).toList(),
      ),
    );
  }

  Widget _attendanceChartCard() {
    final List<dynamic> bars = _previewData?['attendanceHistory'] ?? [
      {'workers': 10.0, 'staff': 5.0}, {'workers': 15.0, 'staff': 8.0}, {'workers': 12.0, 'staff': 6.0},
      {'workers': 20.0, 'staff': 10.0}, {'workers': 18.0, 'staff': 7.0}, {'workers': 14.0, 'staff': 5.0}, {'workers': 16.0, 'staff': 9.0}
    ];

    return Container(
      padding: const EdgeInsets.all(16), decoration: _cardDeco(),
      child: Column(children: [
        SizedBox(height: 120, child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.end,
          children: bars.map((b) => Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Container(width: 10, height: (b['workers'] as num).toDouble() * 2, color: AppColors.primaryBlue),
            Container(width: 10, height: (b['staff'] as num).toDouble() * 2, color: const Color(0xFF1ABC9C)),
          ])).toList())),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _LegendDot(color: AppColors.primaryBlue, label: "${_previewData?['avgWorkers'] ?? 28} Workers (avg)"),
          const SizedBox(width: 15),
          _LegendDot(color: const Color(0xFF1ABC9C), label: "${_previewData?['avgStaff'] ?? 7} Staff (avg)"),
        ])
      ]),
    );
  }

  Widget _budgetSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(12), decoration: _cardDeco(),
      child: Column(children: [
        _RowInfo(label: "Labour", value: "₹${_previewData?['totalLaborCost'] ?? '1,20,000'}", valueColor: AppColors.primaryBlue),
        _RowInfo(label: "Material", value: "₹${_previewData?['totalMaterialCost'] ?? '40,000'}", valueColor: AppColors.primaryBlue),
        _RowInfo(label: "Equipment", value: "₹${_previewData?['totalEquipmentCost'] ?? '25,000'}", valueColor: AppColors.primaryBlue),
        const Divider(),
        _RowInfo(label: "Total", value: "₹${_previewData?['totalBudgetUsed'] ?? '1,85,000'}", valueColor: AppColors.primaryBlue, isBold: true),
      ]),
    );
  }

  // --- SHARED UI HELPERS ---
  Widget _subContractorListCard() => Container(padding: const EdgeInsets.all(12), decoration: _cardDeco(), child: const _RowInfo(label: "Sub-Contractor", value: "Mocked Workers"));
  Widget _progressIndicatorCard() => Container(padding: const EdgeInsets.all(16), decoration: _cardDeco(), child: const _RowInfo(label: "Overall Progress", value: "29.5%", valueColor: AppColors.primaryBlue));
  Widget _tasksListCard() => Container(padding: const EdgeInsets.all(12), decoration: _cardDeco(), child: const _TaskRow(name: "Mock Task", count: "1/1", status: "Completed", color: Colors.green));
  Widget _materialsListCard() => Container(padding: const EdgeInsets.all(12), decoration: _cardDeco(), child: const _RowInfo(label: "Mock Material", value: "10 Units", valueColor: AppColors.primaryBlue));
  Widget _equipmentsListCard() => Container(padding: const EdgeInsets.all(12), decoration: _cardDeco(), child: const _EquipRow(name: "Mock Equip", hours: "5 Hrs", fuel: "10L"));
  Widget _placeholderGrid() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(3, (index) => Container(height: 70, width: 100, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)))));
  BoxDecoration _cardDeco() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200));
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)));
  Widget _sectionHeader(String title, {String? subTitle, String? trailing}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)), if (subTitle != null) ...[const SizedBox(width: 5), Text(subTitle, style: const TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600))], const Spacer(), if (trailing != null) Text(trailing, style: const TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold))]));
  Widget _textArea(TextEditingController c, {required String hint}) => TextFormField(controller: c, minLines: 2, maxLines: 4, decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.all(12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue))));
  Widget _dropdown({required String? value, required String hint, required List<String> items, required ValueChanged<String?> onChanged}) => Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5))), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, isExpanded: true, hint: Text(hint), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChanged)));
}

// Support Classes
class _RowInfo extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool isBold;
  const _RowInfo({required this.label, required this.value, this.valueColor, this.isBold = false});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor ?? AppColors.textDark))]));
}

class _TaskRow extends StatelessWidget {
  final String name, count, status;
  final Color color;
  const _TaskRow({required this.name, required this.count, required this.status, required this.color});
  @override Widget build(BuildContext context) => Row(children: [Expanded(child: Text(name, style: const TextStyle(fontSize: 13))), Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)), const SizedBox(width: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)), child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))]);
}

class _EquipRow extends StatelessWidget {
  final String name, hours, fuel;
  const _EquipRow({required this.name, required this.hours, required this.fuel});
  @override Widget build(BuildContext context) => Row(children: [Expanded(child: Text(name, style: const TextStyle(fontSize: 13))), Text(hours, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)), const SizedBox(width: 15), Text(fuel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue))]);
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override Widget build(BuildContext context) => Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey))]);
}