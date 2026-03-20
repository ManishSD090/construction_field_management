import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/wpr/wpr_controller.dart';
import 'package:construction_erp/screens/dpr//dpr_tab.dart'; // Add this line!

class CreateWPRScreen extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final String projectId;

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
  bool _isSubmitting = false;

  final TextEditingController _weekController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Dynamic list for Next Week Planning
  final List<_NextWeekTaskRow> _nextWeekTasks = [_NextWeekTaskRow()];
  
  Map<String, dynamic>? _previewData;
  DateTime? _weekStart;
  DateTime? _weekEnd;

  @override
  void dispose() {
    _weekController.dispose();
    _descriptionController.dispose();
    for (var task in _nextWeekTasks) { task.dispose(); }
    super.dispose();
  }

  void _addNextWeekTask() => setState(() => _nextWeekTasks.add(_NextWeekTaskRow()));
  void _removeNextWeekTask(int index) => setState(() { 
    if (_nextWeekTasks.length > 1) { 
      _nextWeekTasks[index].dispose(); 
      _nextWeekTasks.removeAt(index); 
    } 
  });

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
        _weekStart = startOfWeek;
        _weekEnd = endOfWeek;
        _weekController.text = "${DateFormat("dd MMM").format(startOfWeek)} - ${DateFormat("dd MMM yyyy").format(endOfWeek)}";
        _isLoadingPreview = true;
      });

      try {
        final response = await ref.read(wprControllerProvider.notifier).getWeeklyPreview(widget.projectId, startOfWeek);
        
        setState(() {
          if (response['hasData'] == true) {
            _previewData = response['data'];
            // Keep description intentionally blank
            _descriptionController.text = ''; 

            // Pre-fill next week tasks dynamically based on backend preview
            _nextWeekTasks.clear();
            final planning = _previewData?['nextWeekPlanning'] as List?;
            if (planning != null && planning.isNotEmpty) {
              for (var p in planning) {
                 final row = _NextWeekTaskRow();
                 row.taskName = p['task']?.toString();
                 row.notesController.text = p['description']?.toString() ?? '';
                 _nextWeekTasks.add(row);
              }
            } else {
              _nextWeekTasks.add(_NextWeekTaskRow());
            }
          } else {
            _previewData = null; 
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No DPRs found for this week.")));
          }
          _isLoadingPreview = false;
        });
      } catch (e) {
        setState(() => _isLoadingPreview = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching weekly data: $e")));
      }
    }
  }

  Future<void> _submitWPR() async {
    if (!_formKey.currentState!.validate() || _previewData == null || _weekStart == null) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final payload = {
        'projectId': widget.projectId,
        'weekStartDate': _weekStart!.toIso8601String(),
        'weekEndDate': _weekEnd!.toIso8601String(),
        'description': _descriptionController.text.trim(),
        'previewData': _previewData,
        'nextWeekPlanning': _nextWeekTasks.where((t) => t.taskName != null && t.taskName!.isNotEmpty).map((t) => {
           'task': t.taskName,
           'description': t.notesController.text.trim(),
        }).toList(),
      };

      await ref.read(wprControllerProvider.notifier).createWPR(payload);
      
      if (!mounted) return;
      ref.invalidate(wprListProvider(widget.projectId));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WPR Created Successfully!'), backgroundColor: Colors.green));
      Navigator.of(context).pop(); 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to submit WPR: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
      body: SingleChildScrollView(
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

              if (_isLoadingPreview)
                const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()))
              else if (_previewData != null) ...[
                
                _label("Weather"),
                _weatherWeeklyRow(),
                const SizedBox(height: 20),

                _label("Description"),
                _textArea(_descriptionController, hint: "Enter the weekly summary..."),
                const SizedBox(height: 24),

                _sectionHeader("Attendance", trailing: "${_previewData!['attendance']?['summary']?['totalPresent'] ?? '0'} Present"),
                _attendanceChartCard(),
                const SizedBox(height: 24),

                if ((_previewData!['subcontractors'] as List?)?.isNotEmpty ?? false) ...[
                  _sectionHeader("Sub Contractor Names"),
                  ...(_previewData!['subcontractors'] as List).map((sub) => _subContractorListCard(sub)),
                  const SizedBox(height: 24),
                ],

                _sectionHeader("Progress"),
                _progressIndicatorCard(),
                const SizedBox(height: 24),

                if ((_previewData!['tasks'] as List?)?.isNotEmpty ?? false) ...[
                  _sectionHeader("Tasks"),
                  ...(_previewData!['tasks'] as List).map((t) => _tasksListCard(t)),
                  const SizedBox(height: 24),
                ],

                if ((_previewData!['materials']?['consumed'] as List?)?.isNotEmpty ?? false) ...[
                  _sectionHeader("Materials Consumed"),
                  ...(_previewData!['materials']['consumed'] as List).map((m) => _materialsListCard(m)),
                  const SizedBox(height: 24),
                ],

                if ((_previewData!['equipment'] as List?)?.isNotEmpty ?? false) ...[
                  _sectionHeader("Equipments Used"),
                  ...(_previewData!['equipment'] as List).map((e) => _equipmentsListCard(e)),
                  const SizedBox(height: 24),
                ],

                if ((_previewData!['photos'] as List?)?.isNotEmpty ?? false) ...[
                  _sectionHeader("Photos"),
                  _photoGrid(),
                  const SizedBox(height: 24),
                ],

                const Text("Next Week Planning", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                ..._nextWeekTasks.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var row = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _label("Task Name")),
                            if (idx > 0) 
                              InkWell(
                                onTap: () => _removeNextWeekTask(idx),
                                child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.alertRed.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.remove, color: AppColors.alertRed, size: 18)),
                              ),
                          ],
                        ),
                        // For flexibility, keeping this a dropdown based on preview data. Alternatively, change to TextField.
                        _dropdown(
                          value: row.taskName,
                          hint: "Select Task",
                          items: ((_previewData!['nextWeekPlanning'] as List?) ?? []).map((t) => t['task']?.toString() ?? "Task").toSet().toList(),
                          onChanged: (v) => setState(() => row.taskName = v),
                        ),
                        const SizedBox(height: 12),
                        _label("Notes"),
                        _textArea(row.notesController, hint: "Enter planning notes..."),
                        const SizedBox(height: 10),
                      ],
                    ),
                  );
                }),
                
                _addDashedButton(_addNextWeekTask),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitWPR,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                    child: _isSubmitting 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Submit WPR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 40),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS BOUND TO REAL DATA ---

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
    final List weatherDays = _previewData!['weather'] ?? [];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weatherDays.map((w) => Column(children: [
          Text(w['day'] ?? "", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(w['code'] ?? "-", style: const TextStyle(fontSize: 18)),
        ])).toList(),
      ),
    );
  }

  Widget _attendanceChartCard() {
    final List daily = _previewData!['attendance']?['daily'] ?? [];
    final summary = _previewData!['attendance']?['summary'] ?? {};
    
    double maxCount = 10.0; 
    for (var day in daily) {
      if (((day['total'] ?? 0) as num) > maxCount) maxCount = ((day['total'] ?? 0) as num).toDouble();
    }

    return Container(
      padding: const EdgeInsets.all(16), decoration: _cardDeco(),
      child: Column(children: [
        SizedBox(
          height: 120, 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
            crossAxisAlignment: CrossAxisAlignment.end,
            children: daily.map((b) {
              double wHeight = (((b['workers'] ?? 0) as num) / maxCount) * 100;
              double sHeight = (((b['staff'] ?? 0) as num) / maxCount) * 100;
              
              if (wHeight == 0 && sHeight == 0) {
                 return Column(
                   mainAxisAlignment: MainAxisAlignment.end, 
                   children: [
                     const SizedBox(height: 100), 
                     const SizedBox(height: 4),
                     Text(b['date']?.toString() ?? "", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                   ]
                 );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.end, 
                children: [
                  if (wHeight > 0) Container(width: 12, height: wHeight, color: AppColors.primaryBlue),
                  if (sHeight > 0) Container(width: 12, height: sHeight, color: const Color(0xFF1ABC9C)),
                  const SizedBox(height: 4),
                  Text(b['date']?.toString() ?? "", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ]
              );
            }).toList()
          )
        ),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _LegendDot(color: AppColors.primaryBlue, label: "${summary['avgWorkers'] ?? 0} Workers (avg)"),
          const SizedBox(width: 15),
          _LegendDot(color: const Color(0xFF1ABC9C), label: "${summary['avgStaff'] ?? 0} Staff (avg)"),
        ])
      ]),
    );
  }

  Widget _subContractorListCard(dynamic sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12), decoration: _cardDeco(), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RowInfo(label: sub['name'] ?? "Unknown", value: sub['dates'] ?? "No dates recorded"),
          const SizedBox(height: 4),
          Text(sub['specialization'] ?? "General Work", style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ]
      )
    );
  }

  Widget _progressIndicatorCard() {
    final prog = _previewData!['progress'] ?? {};
    return Container(
      padding: const EdgeInsets.all(16), decoration: _cardDeco(), 
      child: Column(
        children: [
          _RowInfo(label: "Total Added This Week", value: prog['todayAdded']?.toString() ?? "0%", valueColor: Colors.green),
          const Divider(),
          _RowInfo(label: "Overall Progress", value: prog['currentOverall']?.toString() ?? "0%", valueColor: AppColors.primaryBlue),
        ],
      )
    );
  }

  Widget _tasksListCard(dynamic task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12), decoration: _cardDeco(), 
      child: _TaskRow(
        name: task['name']?.toString() ?? "Task", 
        status: task['status']?.toString() ?? "Pending", 
        color: task['status'] == 'Completed' ? Colors.green : AppColors.primaryBlue
      )
    );
  }

  Widget _materialsListCard(dynamic mat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12), decoration: _cardDeco(), 
      child: _RowInfo(label: mat['name']?.toString() ?? "Material", value: mat['quantity']?.toString() ?? "0", valueColor: AppColors.primaryBlue)
    );
  }

  Widget _equipmentsListCard(dynamic eq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12), decoration: _cardDeco(), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(eq['name']?.toString() ?? "Equipment", style: const TextStyle(fontSize: 13))), 
          Text(eq['hrsUsed']?.toString() ?? "0 Hrs", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue))
        ]
      )
    );
  }

  String _fixUrl(String url) => url.replaceAll('localhost', '172.16.9.36');

  Widget _photoGrid() {
    final List photos = _previewData!['photos'] ?? [];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, 
      child: Row(
        children: photos.map((p) => Padding(
          padding: const EdgeInsets.only(right: 12), 
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8), 
            child: Image.network(
              _fixUrl(p['thumbnail'] ?? ""), 
              height: 70, width: 100, fit: BoxFit.cover, 
              errorBuilder: (_,__,___) => Container(height: 70, width: 100, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey))
            )
          )
        )).toList()
      )
    );
  }

  // --- STYLING HELPERS ---
  Widget _addDashedButton(VoidCallback onTap) {
    return Row(
      children: [
        Expanded(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: const DottedBox(height: 44, child: Icon(Icons.add_circle_outline, color: AppColors.primaryBlue, size: 22)))),
      ],
    );
  }

  BoxDecoration _cardDeco() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200));
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)));
  Widget _sectionHeader(String title, {String? subTitle, String? trailing}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)), if (subTitle != null) ...[const SizedBox(width: 5), Text(subTitle, style: const TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600))], const Spacer(), if (trailing != null) Text(trailing, style: const TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold))]));
  Widget _textArea(TextEditingController c, {required String hint}) => TextFormField(controller: c, minLines: 2, maxLines: 4, decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.all(12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue))));
  
  Widget _dropdown({required String? value, required String hint, required List<String> items, required ValueChanged<String?> onChanged}) {
    // Allows custom input if backend tasks aren't sufficient
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12), 
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5))), 
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null, 
          isExpanded: true, 
          hint: Text(hint), 
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(), 
          onChanged: onChanged
        )
      )
    );
  }
}

// Support Classes
class _NextWeekTaskRow {
  String? taskName;
  final TextEditingController notesController = TextEditingController();
  void dispose() => notesController.dispose();
}

class _RowInfo extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool isBold;
  const _RowInfo({required this.label, required this.value, this.valueColor, this.isBold = false,});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor ?? AppColors.textDark))]));
}

class _TaskRow extends StatelessWidget {
  final String name, status;
  final Color color;
  const _TaskRow({required this.name, required this.status, required this.color});
  @override Widget build(BuildContext context) => Row(children: [Expanded(child: Text(name, style: const TextStyle(fontSize: 13))), const SizedBox(width: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)), child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))]);
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override Widget build(BuildContext context) => Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey))]);
}

class DottedBox extends StatelessWidget { final Widget child; final double? height, width; const DottedBox({super.key, required this.child, this.height, this.width}); @override Widget build(BuildContext context) { return CustomPaint(painter: _DottedPainter(), child: Container(height: height, width: width, alignment: Alignment.center, child: child)); } }
class _DottedPainter extends CustomPainter { @override void paint(Canvas canvas, Size size) { final paint = Paint()..color = AppColors.primaryBlue.withOpacity(0.5)..strokeWidth = 1.2..style = PaintingStyle.stroke; final path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(10))); double dashWidth = 6, dashSpace = 4, distance = 0; final dashedPath = Path(); for (final m in path.computeMetrics()) { while (distance < m.length) { dashedPath.addPath(m.extractPath(distance, distance + dashWidth), Offset.zero); distance += dashWidth + dashSpace; } } canvas.drawPath(dashedPath, paint); } @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false; }