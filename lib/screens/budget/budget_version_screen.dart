import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/project.dart';
import 'dart:math';

// Simple model for a Budget Item locally
class BudgetItem {
  String id;
  String particular;
  String quantity;
  double amount;

  BudgetItem({
    required this.id,
    required this.particular,
    required this.quantity,
    required this.amount,
  });
}

// ==========================================
// 1. VIEWER SCREEN (Read-Only View)
// ==========================================
class BudgetVersionScreen extends StatefulWidget {
  final Project project;

  const BudgetVersionScreen({super.key, required this.project});

  @override
  State<BudgetVersionScreen> createState() => _BudgetVersionScreenState();
}

class _BudgetVersionScreenState extends State<BudgetVersionScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  
  // ✅ FIX: Initialized immediately to prevent LateInitializationError
  String _projectName = "";
  String _managerName = "";
  
  List<BudgetItem> _items = [
    BudgetItem(id: '1', particular: 'Excavation Work', quantity: '1000', amount: 50000),
    BudgetItem(id: '2', particular: 'Cement Bags (ACC)', quantity: '500', amount: 200000),
    BudgetItem(id: '3', particular: 'Steel Rods (10mm)', quantity: '2000', amount: 120000),
    BudgetItem(id: '4', particular: 'Bricks (Red)', quantity: '10000', amount: 80000),
  ];

  @override
  void initState() {
    super.initState();
    _projectName = widget.project.name;
    _managerName = widget.project.createdBy?.name ?? "Manager Name";
  }

  double get _totalAmount => _items.fold(0, (sum, item) => sum + item.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Budget Version", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_projectName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        
                        // ✅ Edit Button -> Goes to New Edit Screen
                        InkWell(
                          onTap: () async {
                            final updatedList = await Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => EditBudgetScreen(initialItems: _items))
                            );
                            if (updatedList != null) {
                              setState(() => _items = updatedList);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                            child: const Icon(Icons.edit, size: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_managerName, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 25),

                    // Read-Only List
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.grey.shade50,
                      child: const Row(
                        children: [
                          SizedBox(width: 40, child: Text("Sr.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 3, child: Text("Particulars", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 2, child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 2, child: Text("Amount", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 15),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Row(
                          children: [
                            SizedBox(width: 40, child: Text("${index + 1}", style: const TextStyle(fontSize: 12, color: Colors.grey))),
                            Expanded(flex: 3, child: Text(item.particular, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                            Expanded(flex: 2, child: Text(item.quantity, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                            Expanded(flex: 2, child: Text(_currencyFormat.format(item.amount), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                          ],
                        );
                      },
                    ),
                    const Divider(thickness: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          const Spacer(flex: 3),
                          const Expanded(flex: 2, child: Text("Total", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(
                            flex: 3,
                            child: Text(
                              _currencyFormat.format(_totalAmount),
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. EDIT SCREEN (Matches your Screenshots)
// ==========================================
class EditBudgetScreen extends StatefulWidget {
  final List<BudgetItem> initialItems;

  const EditBudgetScreen({super.key, required this.initialItems});

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  late List<BudgetItem> _items;
  bool _isDeleteMode = false;
  final Set<String> _selectedIds = {};
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Deep copy
    _items = widget.initialItems.map((e) => BudgetItem(
      id: e.id, particular: e.particular, quantity: e.quantity, amount: e.amount
    )).toList();
  }

  void _addNewItem() {
    setState(() {
      _items.add(BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        particular: '',
        quantity: '',
        amount: 0,
      ));
    });
  }

  void _handleDelete() {
    if (!_isDeleteMode) {
      // Enable Delete Mode
      setState(() => _isDeleteMode = true);
    } else {
      if (_selectedIds.isEmpty) {
        // Disable Delete Mode if nothing selected
        setState(() => _isDeleteMode = false);
      } else {
        // Show Confirmation Dialog
        showDialog(
          context: context,
          builder: (context) => _buildDeleteConfirmation(),
        );
      }
    }
  }

  void _handleSave() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Are you sure you want to\nsave the Changes?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close confirm
                          _showSuccessDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6EFD), // Blue
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Yes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Changes Saved", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.teal,
                child: Icon(Icons.check, color: Colors.white, size: 40),
              )
            ],
          ),
        ),
      ),
    );
    // Auto close and return data
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context); // Pop Success Dialog
      Navigator.pop(context, _items); // Pop Edit Screen with data
    });
  }

  Widget _buildDeleteConfirmation() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Are you sure you want to\ndelete the Selected Items?", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _items.removeWhere((item) => _selectedIds.contains(item.id));
                    _selectedIds.clear();
                    _isDeleteMode = false;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 15),
            InkWell(onTap: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text("Budget Version", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const SizedBox(width: 30, child: Text("Sr. No.", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                const Expanded(flex: 4, child: Text("Particulars", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                const Expanded(flex: 2, child: Text("Quantity", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                const Expanded(flex: 2, child: Text("Amount", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                // TRASH ICON
                InkWell(
                  onTap: _handleDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red, 
                      borderRadius: BorderRadius.circular(4)
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length + 1, // +1 for Add Button
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return _buildAddButton();
                }
                final item = _items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 30, child: Text("${index + 1}", style: const TextStyle(fontSize: 12, color: Colors.black54))),
                      Expanded(
                        flex: 4,
                        child: _buildTextField(
                          value: item.particular,
                          onChanged: (val) => item.particular = val,
                          hint: "Particular Name"
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          value: item.quantity,
                          onChanged: (val) => item.quantity = val,
                          hint: "-",
                          isNumber: true
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          value: item.amount == 0 ? '' : _currencyFormat.format(item.amount),
                          onChanged: (val) {
                             String clean = val.replaceAll(',', '');
                             item.amount = double.tryParse(clean) ?? 0;
                          },
                          hint: "0",
                          isNumber: true
                        ),
                      ),
                      if (_isDeleteMode) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _selectedIds.contains(item.id),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedIds.add(item.id);
                                } else {
                                  _selectedIds.remove(item.id);
                                }
                              });
                            },
                            activeColor: const Color(0xFF0D6EFD),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                      ]
                    ],
                  ),
                );
              },
            ),
          ),

          // TOTALS & SAVE
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Number", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DB6AC), // Teal Green
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: Blue Outline Text Field ---
  Widget _buildTextField({required String value, required Function(String) onChanged, required String hint, bool isNumber = false}) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textAlign: isNumber ? TextAlign.center : TextAlign.left,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFF448AFF)), // Blue Border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFF448AFF), width: 1.5),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: Dashed Add Button ---
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _addNewItem,
      child: CustomPaint(
        painter: DashedRectPainter(color: const Color(0xFF448AFF), strokeWidth: 1.0, gap: 5.0),
        child: Container(
          height: 40,
          width: double.infinity,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF448AFF), width: 1.5)
            ),
            child: const Icon(Icons.add, size: 16, color: Color(0xFF448AFF)),
          ),
        ),
      ),
    );
  }
}

// Custom Painter for the Dashed Border (matches Screenshot 537)
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({this.color = Colors.black, this.strokeWidth = 1.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = size.width;
    double y = size.height;

    Path _topPath = getDashedPath(a: const Offset(0, 0), b: Offset(x, 0), gap: gap);
    Path _rightPath = getDashedPath(a: Offset(x, 0), b: Offset(x, y), gap: gap);
    Path _bottomPath = getDashedPath(a: Offset(0, y), b: Offset(x, y), gap: gap);
    Path _leftPath = getDashedPath(a: const Offset(0, 0), b: Offset(0, y), gap: gap);

    canvas.drawPath(_topPath, dashedPaint);
    canvas.drawPath(_rightPath, dashedPaint);
    canvas.drawPath(_bottomPath, dashedPaint);
    canvas.drawPath(_leftPath, dashedPaint);
  }

  Path getDashedPath({required Offset a, required Offset b, required double gap}) {
    Size size = Size(b.dx - a.dx, b.dy - a.dy);
    Path path = Path();
    path.moveTo(a.dx, a.dy);
    bool shouldDraw = true;
    Offset currentPoint = a;

    double radians = atan2(b.dy - a.dy, b.dx - a.dx);
    double distance = sqrt(pow(b.dx - a.dx, 2) + pow(b.dy - a.dy, 2));

    for (double i = 0; i < distance; i += gap) {
      if (shouldDraw) {
        path.relativeLineTo(gap * cos(radians), gap * sin(radians));
      } else {
        path.relativeMoveTo(gap * cos(radians), gap * sin(radians));
      }
      shouldDraw = !shouldDraw;
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}