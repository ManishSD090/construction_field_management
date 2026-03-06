import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';

// ✅ Model to manage independent state for each person
class WorkerAttendance {
  final String name;
  String status; // Present, Absent, etc.
  String multiplier; // x1.0, x1.5, etc.
  double baseRate;

  WorkerAttendance({
    required this.name,
    this.status = 'Present',
    this.multiplier = 'x1.0',
    this.baseRate = 600.0,
  });

  // Calculate dynamic rate based on status and multiplier
  double get currentRate => status == 'Absent' ? 0.0 : baseRate;
}

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  String _selectedRole = 'Workers';
  DateTime _selectedDate = DateTime.now();

  // ✅ Data State
  final List<WorkerAttendance> _workers = [
    WorkerAttendance(name: "Person Name"),
    WorkerAttendance(name: "Person Name", status: 'Week off'),
    WorkerAttendance(name: "Person Name", status: 'Paid Leave'),
    WorkerAttendance(name: "Person Name", status: 'Absent'),
  ];

  // ✅ Filter State
  final List<String> _statusOptions = [
    'Present',
    'Absent',
    'Week Off',
    'Paid Leave'
  ];
  final List<String> _multiplierOptions = ['x1.0', 'x1.5', 'x1.75', 'x2.0'];
  final Map<String, bool> _activeFilters = {
    'Present': false,
    'Absent': false,
    'Week Off': false,
    'Paid Leave': false,
  };

  // ✅ Computed logic for the List
  List<WorkerAttendance> get _filteredList {
    bool noFiltersSelected = !_activeFilters.values.contains(true);
    if (noFiltersSelected) return _workers;
    return _workers.where((w) => _activeFilters[w.status] == true).toList();
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate totals for the summary UI
    double totalPayroll =
        _filteredList.fold(0, (sum, item) => sum + item.currentRate);
    int presentCount = _workers.where((w) => w.status == 'Present').length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text("Attendance", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildToggle(),
          _buildSummary(totalPayroll),
          _buildFilterRow(),
          _buildListHeader(presentCount),
          _buildList(),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: ['Workers', 'Staff'].map((role) {
          bool isSelected = _selectedRole == role;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = role),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(role,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummary(double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total Payroll:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text("₹${total.toInt()}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MM/dd/yyyy').format(_selectedDate),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13)),
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: AppColors.primaryBlue),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // ✅ Working Multi-select Filter
          PopupMenuButton<String>(
            offset: const Offset(0, 45),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: StatefulBuilder(
                  builder: (context, setPopupState) => Column(
                    children: _statusOptions
                        .map((status) => CheckboxListTile(
                              title: Text(status,
                                  style: const TextStyle(fontSize: 13)),
                              value: _activeFilters[status],
                              onChanged: (val) {
                                setPopupState(
                                    () => _activeFilters[status] = val!);
                                setState(() {}); // Updates the List view
                              },
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20)),
              child: const Row(children: [
                Text("Filter"),
                SizedBox(width: 6),
                Icon(Icons.tune, size: 16)
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(int present) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
              text: TextSpan(
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  children: [
                TextSpan(
                    text: "$present/${_workers.length} ",
                    style: const TextStyle(color: AppColors.primaryBlue)),
                const TextSpan(text: "Present"),
              ])),
          Text("+ Add $_selectedRole",
              style: const TextStyle(
                  color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _filteredList.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final worker = _filteredList[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100)),
            child: Row(
              children: [
                Expanded(
                    child: Text(worker.name,
                        style: const TextStyle(fontWeight: FontWeight.w500))),
                Text("₹${worker.currentRate.toInt()}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                // ✅ Independent Multiplier Dropdown
                _buildDropdown(
                  value: worker.multiplier,
                  options: _multiplierOptions,
                  color: AppColors.primaryBlue,
                  onChanged: (val) => setState(() => worker.multiplier = val!),
                ),
                const SizedBox(width: 8),
                // ✅ Independent Status Dropdown
                _buildDropdown(
                  value: worker.status,
                  options: _statusOptions,
                  isStatus: true,
                  onChanged: (val) => setState(() => worker.status = val!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdown(
      {required String value,
      required List<String> options,
      required Function(String?) onChanged,
      bool isStatus = false,
      Color? color}) {
    Color displayColor = color ?? _getStatusColor(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isStatus ? displayColor.withOpacity(0.1) : Colors.white,
        border: Border.all(
            color:
                isStatus ? Colors.transparent : displayColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : options.first,
          icon: Icon(Icons.keyboard_arrow_down, size: 14, color: displayColor),
          style: TextStyle(
              color: displayColor, fontSize: 11, fontWeight: FontWeight.bold),
          onChanged: onChanged,
          items: options
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
        ),
      ),
    );
  }

  Color _getStatusColor(String s) {
    if (s == 'Present') return Colors.green;
    if (s == 'Absent') return Colors.red;
    if (s == 'Week off') return Colors.orange;
    return Colors.blue;
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: ElevatedButton(
        onPressed: () => _showDialog(),
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D6EFD),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        child: const Text("Submit",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Are you sure you want to\nsubmit attendance?",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            const Text("Once you submit you can't edit/update it later",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 12)),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text("Yes",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}
