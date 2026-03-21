import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/controllers/inventory/procurement_controller.dart';
import 'package:construction_erp/models/procurement.dart';

class EditPOScreen extends ConsumerStatefulWidget {
  final PurchaseOrder po;

  const EditPOScreen({super.key, required this.po});

  @override
  ConsumerState<EditPOScreen> createState() => _EditPOScreenState();
}

class _EditPOScreenState extends ConsumerState<EditPOScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers mapped exactly to backend updatePurchaseOrder fields
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _deliveryAddressController;
  late TextEditingController _deliveryInstructionsController;
  late TextEditingController _notesController;
  late TextEditingController _termsController;

  // New Controllers for financial updates
  late TextEditingController _shippingCostController;
  late TextEditingController _otherChargesController;

  DateTime? _expectedDate;
  DateTime? _actualDeliveryDate; // New field for actual delivery
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the controllers with existing PO data
    _titleController = TextEditingController(text: widget.po.title);
    _descriptionController =
        TextEditingController(text: widget.po.description ?? '');
    _deliveryAddressController =
        TextEditingController(text: widget.po.deliveryAddress ?? '');
    _deliveryInstructionsController =
        TextEditingController(text: widget.po.deliveryInstructions ?? '');
    _notesController = TextEditingController(text: widget.po.notes ?? '');
    _termsController = TextEditingController(text: widget.po.terms ?? '');

    // New fields initialization
    _shippingCostController = TextEditingController(
        text: widget.po.shippingCost != null
            ? widget.po.shippingCost.toString()
            : '');
    // Assuming otherCharges is present in your PO model. If it's stored differently, adjust here.
    // We use a fallback to empty string if it's null.
    _otherChargesController = TextEditingController(text: '');

    _expectedDate = widget.po.expectedDelivery;
    // Assuming actualDelivery is present in your PO model
    // _actualDeliveryDate = widget.po.actualDelivery;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _deliveryAddressController.dispose();
    _deliveryInstructionsController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    _shippingCostController.dispose();
    _otherChargesController.dispose();
    super.dispose();
  }

  Future<void> _selectExpectedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D6EFD),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _expectedDate = picked;
      });
    }
  }

  Future<void> _selectActualDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _actualDeliveryDate ?? DateTime.now(),
      firstDate: DateTime(2000), // Actual delivery could be in the past
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D6EFD),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _actualDeliveryDate = picked;
      });
    }
  }

  void _submitUpdate() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('PO Title is required'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Build the payload mapping strictly to the backend route expectations
    final payload = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      if (_expectedDate != null)
        'expectedDelivery': _expectedDate!.toUtc().toIso8601String(),
      if (_actualDeliveryDate != null)
        'actualDelivery': _actualDeliveryDate!.toUtc().toIso8601String(),
      'deliveryAddress': _deliveryAddressController.text.trim(),
      'deliveryInstructions': _deliveryInstructionsController.text.trim(),
      'notes': _notesController.text.trim(),
      'terms': _termsController.text.trim(),
    };

    // Safely parse numbers for shipping and other charges
    if (_shippingCostController.text.trim().isNotEmpty) {
      payload['shippingCost'] =
          double.tryParse(_shippingCostController.text.trim());
    }
    if (_otherChargesController.text.trim().isNotEmpty) {
      payload['otherCharges'] =
          double.tryParse(_otherChargesController.text.trim());
    }

    try {
      await ref
          .read(procurementControllerProvider.notifier)
          .updatePurchaseOrder(widget.po.id, payload);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase Order Updated Successfully'),
            backgroundColor: Color(0xFF00B48A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update PO: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Edit PO",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D6EFD)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =================== READ-ONLY CONTEXT ===================
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.po.poNumber,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF0D6EFD))),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.po.status,
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.storefront,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(widget.po.supplierName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.construction,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      widget.po.project?.name ??
                                          "Unknown Project",
                                      style: const TextStyle(
                                          color: Colors.black87))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // =================== EDITABLE FIELDS ===================
                    const Text("General Details",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D6EFD))),
                    const Divider(),
                    const SizedBox(height: 8),

                    _buildLabel("PO Title *"),
                    _buildTextField("e.g. Cement Order for Block A",
                        controller: _titleController),
                    const SizedBox(height: 16),

                    _buildLabel("Description (Optional)"),
                    _buildTextField("Brief description of this order...",
                        controller: _descriptionController),
                    const SizedBox(height: 16),

                    _buildLabel("Expected Date"),
                    InkWell(
                      onTap: () => _selectExpectedDate(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF0D6EFD)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _expectedDate == null
                                  ? "Select Date"
                                  : DateFormat('dd MMM yyyy')
                                      .format(_expectedDate!),
                              style: TextStyle(
                                  color: _expectedDate == null
                                      ? Colors.grey[400]
                                      : Colors.black87,
                                  fontSize: 14),
                            ),
                            const Icon(Icons.calendar_today,
                                size: 18, color: Color(0xFF0D6EFD)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Actual Delivery Date (Optional)"),
                    InkWell(
                      onTap: () => _selectActualDate(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF0D6EFD)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _actualDeliveryDate == null
                                  ? "Select Date"
                                  : DateFormat('dd MMM yyyy')
                                      .format(_actualDeliveryDate!),
                              style: TextStyle(
                                  color: _actualDeliveryDate == null
                                      ? Colors.grey[400]
                                      : Colors.black87,
                                  fontSize: 14),
                            ),
                            const Icon(Icons.check_circle_outline,
                                size: 18, color: Color(0xFF0D6EFD)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text("Financial Details",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D6EFD))),
                    const Divider(),
                    const SizedBox(height: 8),

                    _buildLabel("Shipping Cost"),
                    _buildTextField("0.00",
                        controller: _shippingCostController, isNumber: true),
                    const SizedBox(height: 16),

                    _buildLabel("Other Charges"),
                    _buildTextField("0.00",
                        controller: _otherChargesController, isNumber: true),
                    const SizedBox(height: 24),

                    const Text("Delivery & Logistics",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D6EFD))),
                    const Divider(),
                    const SizedBox(height: 8),

                    _buildLabel("Delivery Address"),
                    _buildTextField("Full address for delivery",
                        controller: _deliveryAddressController),
                    const SizedBox(height: 16),

                    _buildLabel("Delivery Instructions"),
                    _buildTextField("e.g. Deliver to North Gate only",
                        controller: _deliveryInstructionsController),
                    const SizedBox(height: 24),

                    const Text("Additional Information",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D6EFD))),
                    const Divider(),
                    const SizedBox(height: 8),

                    _buildLabel("Terms & Conditions"),
                    _buildTextField("Custom terms for this order",
                        controller: _termsController),
                    const SizedBox(height: 16),

                    _buildLabel("Internal Notes"),
                    _buildTextField("Notes for internal team",
                        controller: _notesController),

                    const SizedBox(height: 30),

                    // =================== SUBMIT BUTTON ===================
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6EFD),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text("Update Purchase Order",
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

  Widget _buildTextField(String hint,
      {TextEditingController? controller, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
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
