import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/controllers/inventory/inventory_controller.dart';
import 'package:construction_erp/models/material.dart' as erp_mat;

// Helper class to manage state for multiple material entries
class _MaterialEntry {
  String? materialId;
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  DateTime? purchaseDate;
  DateTime? expiryDate;

  void dispose() {
    qtyController.dispose();
    priceController.dispose();
    batchController.dispose();
    notesController.dispose();
  }
}

class AddMaterialToProjectScreen extends ConsumerStatefulWidget {
  final String projectId;

  const AddMaterialToProjectScreen({super.key, required this.projectId});

  @override
  ConsumerState<AddMaterialToProjectScreen> createState() =>
      _AddMaterialToProjectScreenState();
}

class _AddMaterialToProjectScreenState
    extends ConsumerState<AddMaterialToProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetchingData = true;

  List<erp_mat.Material> _materials = [];

  // List to hold dynamic material entries for bulk adding
  final List<_MaterialEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    // Initialize with at least one entry
    _entries.add(_MaterialEntry());
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    try {
      final materials = await ref
          .read(inventoryControllerProvider.notifier)
          .getAllMaterials(limit: 100);
      setState(() {
        _materials = materials;
        if (_materials.isNotEmpty) {
          // Set the default dropdown value for the initial entry
          _entries[0].materialId = _materials.first.id;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load materials: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (var entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    setState(() {
      final newEntry = _MaterialEntry();
      if (_materials.isNotEmpty) {
        newEntry.materialId = _materials.first.id;
      }
      _entries.add(newEntry);
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _entries[index].dispose();
      _entries.removeAt(index);
    });
  }

  Future<void> _selectDate(
      BuildContext context, int index, bool isPurchaseDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: isPurchaseDate ? DateTime(2000) : DateTime.now(),
      lastDate: isPurchaseDate ? DateTime.now() : DateTime(2101),
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
        if (isPurchaseDate) {
          _entries[index].purchaseDate = picked;
        } else {
          _entries[index].expiryDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Verify all entries have a material selected
    if (_entries.any((e) => e.materialId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a material for all entries.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Map multiple entries into the bulk payload format
      final List<Map<String, dynamic>> itemsPayload = _entries.map((entry) {
        final item = {
          'materialId': entry.materialId,
          'initialQuantity': double.tryParse(entry.qtyController.text) ?? 0.0,
          'unitPrice': double.tryParse(entry.priceController.text) ?? 0.0,
          'batchNumber': entry.batchController.text.trim(),
          'notes': entry.notesController.text.trim(),
        };

        if (entry.purchaseDate != null) {
          item['purchaseDate'] = entry.purchaseDate!.toUtc().toIso8601String();
        }
        if (entry.expiryDate != null) {
          item['expiryDate'] = entry.expiryDate!.toUtc().toIso8601String();
        }
        return item;
      }).toList();

      await ref
          .read(inventoryControllerProvider.notifier)
          .addBulkMaterialsToProject(widget.projectId, itemsPayload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materials added to project successfully'),
            backgroundColor: Color(0xFF00B48A),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add materials: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[50], // Slightly off-white for better card contrast
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Materials to Project",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Generate dynamic cards for each material entry
                    ..._entries.asMap().entries.map((mapEntry) {
                      int index = mapEntry.key;
                      _MaterialEntry entry = mapEntry.value;
                      return _buildMaterialCard(index, entry);
                    }),

                    const SizedBox(height: 16),

                    // Add Another Material Button
                    Center(
                      child: TextButton.icon(
                        onPressed: _addEntry,
                        icon: const Icon(Icons.add_circle_outline,
                            color: Color(0xFF0D6EFD)),
                        label: const Text(
                          "Add Another Material",
                          style: TextStyle(
                            color: Color(0xFF0D6EFD),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
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
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Add to Project",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMaterialCard(int index, _MaterialEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Material #${index + 1}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D6EFD),
                ),
              ),
              if (_entries.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeEntry(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const Divider(height: 24),
          _buildLabel("Select Material *"),
          _buildMaterialDropdown(index, entry),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Initial Quantity *"),
                    _buildTextField(
                      controller: entry.qtyController,
                      hint: "0.0",
                      isNumber: true,
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Unit Price (₹) *"),
                    _buildTextField(
                      controller: entry.priceController,
                      hint: "0.00",
                      isNumber: true,
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLabel("Batch Number"),
          _buildTextField(
            controller: entry.batchController,
            hint: "e.g. BATCH-001",
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Purchase Date"),
                    InkWell(
                      onTap: () => _selectDate(context, index, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF0D6EFD)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.purchaseDate == null
                                  ? 'Select'
                                  : DateFormat('dd MMM yyyy')
                                      .format(entry.purchaseDate!),
                              style: TextStyle(
                                color: entry.purchaseDate == null
                                    ? Colors.grey[400]
                                    : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(Icons.calendar_today,
                                size: 16, color: Color(0xFF0D6EFD)),
                          ],
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
                    _buildLabel("Expiry Date"),
                    InkWell(
                      onTap: () => _selectDate(context, index, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF0D6EFD)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.expiryDate == null
                                  ? 'Select'
                                  : DateFormat('dd MMM yyyy')
                                      .format(entry.expiryDate!),
                              style: TextStyle(
                                color: entry.expiryDate == null
                                    ? Colors.grey[400]
                                    : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(Icons.calendar_today,
                                size: 16, color: Color(0xFF0D6EFD)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLabel("Notes"),
          _buildTextField(
            controller: entry.notesController,
            hint: "Any additional remarks",
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0D6EFD), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildMaterialDropdown(int index, _MaterialEntry entry) {
    if (_materials.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Text("No materials available. Create one first.",
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF0D6EFD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: entry.materialId,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0D6EFD)),
          items: _materials.map((erp_mat.Material mat) {
            return DropdownMenuItem<String>(
              value: mat.id,
              child: Text("${mat.name} (${mat.materialCode ?? 'No code'})",
                  style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _entries[index].materialId = newValue;
              });
            }
          },
        ),
      ),
    );
  }
}
