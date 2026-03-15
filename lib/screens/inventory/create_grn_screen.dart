import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/controllers/inventory/procurement_controller.dart';
import 'package:construction_erp/models/procurement.dart';

class CreateGRNScreen extends ConsumerStatefulWidget {
  final String poId;

  const CreateGRNScreen({super.key, required this.poId});

  @override
  ConsumerState<CreateGRNScreen> createState() => _CreateGRNScreenState();
}

class _CreateGRNScreenState extends ConsumerState<CreateGRNScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _challanController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final Map<String, TextEditingController> _qtyControllers = {};

  String _selectedQuality = 'GOOD';
  bool _isLoading = false;

  final List<String> _qualityOptions = [
    'EXCELLENT',
    'GOOD',
    'AVERAGE',
    'POOR',
    'REJECT'
  ];

  @override
  void dispose() {
    _challanController.dispose();
    _remarksController.dispose();
    for (var controller in _qtyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitGRN() async {
    final itemsToReceive = <Map<String, dynamic>>[];

    _qtyControllers.forEach((itemId, controller) {
      final qty = double.tryParse(controller.text) ?? 0;
      if (qty > 0) {
        itemsToReceive.add({
          'poItemId': itemId,
          'receivedQuantity': qty,
          'qualityRating': _selectedQuality,
        });
      }
    });

    if (itemsToReceive.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please enter received quantities for at least one item.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final payload = {
      'deliveryChallanNo': _challanController.text.trim(),
      'notes': _remarksController.text.trim(),
      'items': itemsToReceive,
    };

    try {
      await ref
          .read(procurementControllerProvider.notifier)
          .createGoodsReceipt(widget.poId, payload);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Goods Receipt Created Successfully'),
              backgroundColor: Color(0xFF00B48A)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to create GRN: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final poAsync = ref.watch(poDetailsProvider(widget.poId));

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Create GRN",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: poAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF0D6EFD))),
            error: (err, stack) => Center(
                child: Text("Error loading PO: $err",
                    style: const TextStyle(color: Colors.red))),
            data: (po) {
              // Filter out items that are fully received
              final pendingItems = po.items
                      ?.where((item) => item.pendingQuantity > 0)
                      .toList() ??
                  [];

              if (pendingItems.isEmpty) {
                return const Center(
                    child: Text("All items in this PO have been received.",
                        style: TextStyle(color: Colors.grey, fontSize: 16)));
              }

              // Initialize controllers for new pending items
              for (var item in pendingItems) {
                if (!_qtyControllers.containsKey(item.id)) {
                  // Pre-fill with the pending quantity to save time
                  _qtyControllers[item.id] = TextEditingController(
                      text: item.pendingQuantity
                          .toStringAsFixed(1)
                          .replaceAll(RegExp(r'\.0$'), ''));
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(po.project?.name ?? "Project Location",
                              style: const TextStyle(color: Colors.grey)),
                          Text(
                              "Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(po.supplierName,
                                  style: const TextStyle(
                                      color: Color(0xFF0D6EFD),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                          Text("PO: ${po.poNumber}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildLabel("Delivery Challan No. (Optional)"),
                      _buildTextField("e.g. DC-2023-001",
                          controller: _challanController),
                      const SizedBox(height: 20),

                      // Table Header
                      const Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text("Sr.",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13))),
                          Expanded(
                              flex: 3,
                              child: Text("Particulars",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13))),
                          Expanded(
                              flex: 2,
                              child: Text("Pending",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                  textAlign: TextAlign.center)),
                          Expanded(
                              flex: 2,
                              child: Text("Received",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                  textAlign: TextAlign.center)),
                        ],
                      ),
                      const Divider(color: Colors.black),

                      // Table Rows
                      ...List.generate(pendingItems.length, (index) {
                        return _buildGRNRow(index + 1, pendingItems[index]);
                      }),

                      const Divider(color: Colors.black),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Quality Check"),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFF0D6EFD)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: _selectedQuality,
                                      icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Color(0xFF0D6EFD)),
                                      items:
                                          _qualityOptions.map((String option) {
                                        return DropdownMenuItem<String>(
                                          value: option,
                                          child: Text(option),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(
                                              () => _selectedQuality = value);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(
                                    "Rate Supplier"), // Placeholder for future feature
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFF0D6EFD)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: '5 Stars',
                                      icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Color(0xFF0D6EFD)),
                                      items: const [
                                        DropdownMenuItem(
                                            value: '5 Stars',
                                            child: Text("5 Stars")),
                                        DropdownMenuItem(
                                            value: '4 Stars',
                                            child: Text("4 Stars")),
                                        DropdownMenuItem(
                                            value: '3 Stars',
                                            child: Text("3 Stars")),
                                      ],
                                      onChanged: (value) {},
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildLabel("Remarks"),
                      _buildTextField("Any notes about the delivery...",
                          controller: _remarksController),

                      const SizedBox(height: 16),
                      _buildLabel("Upload Goods Photos"),
                      // Dashed Box with Plus
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF0D6EFD),
                              style: BorderStyle
                                  .solid), // Use DottedBorder package for dashed
                        ),
                        child: const Center(
                          child: Icon(Icons.add_circle_outline,
                              color: Color(0xFF0D6EFD), size: 30),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildLabel("Receipt Attachment"),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.description, size: 18),
                        label: const Text("Select file"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: Color(0xFF0D6EFD)),
                        ),
                      ),
                      const Text(
                          "Upload a jpeg, jpg, png, pdf no larger than 10 MB",
                          style: TextStyle(fontSize: 11, color: Colors.grey)),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitGRN,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D6EFD),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text("Submit GRN",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            }));
  }

  Widget _buildGRNRow(int index, PurchaseOrderItem item) {
    final pendingQtyStr =
        item.pendingQuantity.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 1,
              child: Text(index.toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 13))),
          Expanded(
              flex: 3,
              child: Text(item.description,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500))),
          Expanded(
              flex: 2,
              child: Text("$pendingQtyStr ${item.unit}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.orange))),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 35,
              child: TextField(
                controller: _qtyControllers[item.id],
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide:
                        const BorderSide(color: Color(0xFF0D6EFD), width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.black87)),
    );
  }

  Widget _buildTextField(String hint, {TextEditingController? controller}) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0D6EFD), width: 2),
        ),
      ),
    );
  }
}
