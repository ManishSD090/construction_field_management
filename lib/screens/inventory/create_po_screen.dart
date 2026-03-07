import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/controllers/inventory/procurement_controller.dart';
import 'package:construction_erp/controllers/inventory/inventory_controller.dart';
import 'package:construction_erp/controllers/project/project_controller.dart';
import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/models/procurement.dart';
import 'package:construction_erp/models/material.dart' as erp_mat;

class CreatePOScreen extends ConsumerStatefulWidget {
  const CreatePOScreen({super.key});

  @override
  ConsumerState<CreatePOScreen> createState() => _CreatePOScreenState();
}

class _CreatePOScreenState extends ConsumerState<CreatePOScreen> {
  final _formKey = GlobalKey<FormState>();

  // PO Header Controllers
  final TextEditingController _titleController = TextEditingController();

  // Custom Supplier Controllers
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _supplierPhoneController =
      TextEditingController();
  final TextEditingController _supplierAddressController =
      TextEditingController();
  final TextEditingController _supplierGstController = TextEditingController();

  // Item Form Controllers
  final TextEditingController _itemDescController = TextEditingController();
  final TextEditingController _itemQtyController = TextEditingController();
  final TextEditingController _itemUnitController =
      TextEditingController(text: 'Nos');
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _itemGstController =
      TextEditingController(text: '18');

  // State Variables
  String? _selectedProjectId;
  String? _selectedSupplierId;
  DateTime? _expectedDate;
  bool _isLoading = false;
  bool _isCustomSupplier = false;

  // Multiple Items State
  List<Map<String, dynamic>> _addedItems = [];
  String? _selectedMaterialId;

  // Temporary dummy suppliers (Replace with your actual SupplierController when ready)
  final List<Map<String, String>> _dummySuppliers = [
    {'id': 'sup-1', 'name': 'Acme Cements Ltd.'},
    {'id': 'sup-2', 'name': 'BuildRight Steel'},
    {'id': 'sup-3', 'name': 'City Hardware Traders'},
  ];

  @override
  void initState() {
    super.initState();
    // Fetch materials and pending requests when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryControllerProvider.notifier).refresh();
      // Optionally refresh procurement to get the latest material requests
      // ref.read(procurementControllerProvider.notifier).refresh();
    });

    // Add listeners to update the total amount dynamically
    _itemQtyController.addListener(() => setState(() {}));
    _itemPriceController.addListener(() => setState(() {}));
    _itemGstController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _supplierNameController.dispose();
    _supplierPhoneController.dispose();
    _supplierAddressController.dispose();
    _supplierGstController.dispose();
    _itemDescController.dispose();
    _itemQtyController.dispose();
    _itemUnitController.dispose();
    _itemPriceController.dispose();
    _itemGstController.dispose();
    super.dispose();
  }

  double get _calculatedTotal {
    return _addedItems.fold(0.0, (sum, item) {
      final qty = item['quantity'] as double;
      final price = item['unitPrice'] as double;
      final gst = item['taxPercent'] as double? ?? 0.0;
      final subtotal = qty * price;
      return sum + subtotal + (subtotal * gst / 100);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
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

  // --- ITEM MANAGEMENT ---

  void _addItem() {
    final desc = _itemDescController.text.trim();
    final qty = double.tryParse(_itemQtyController.text) ?? 0;
    final price = double.tryParse(_itemPriceController.text) ?? 0;

    if (desc.isEmpty) {
      _showError("Description is required");
      return;
    }
    if (qty <= 0 || price <= 0) {
      _showError("Quantity and Unit Price must be > 0");
      return;
    }

    setState(() {
      _addedItems.add({
        'materialId': _selectedMaterialId,
        'description': desc,
        'quantity': qty,
        'unit': _itemUnitController.text.trim(),
        'unitPrice': price,
        'taxPercent': double.tryParse(_itemGstController.text) ?? 0.0,
      });

      // Reset item form
      _selectedMaterialId = null;
      _itemDescController.clear();
      _itemQtyController.clear();
      _itemUnitController.text = 'Nos';
      _itemPriceController.clear();
      _itemGstController.text = '18';

      // Hide keyboard after adding item
      FocusScope.of(context).unfocus();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _addedItems.removeAt(index);
    });
  }

  void _loadFromMaterialRequest() {
    final procState = ref.read(procurementControllerProvider).value;
    if (procState == null) return;

    // Filter requests that need fulfilling (Approved or Requested)
    final pendingRequests = procState.materialRequests
        .where((mr) => mr.status == 'APPROVED' || mr.status == 'REQUESTED')
        .toList();

    if (pendingRequests.isEmpty) {
      _showError("No pending material requests found.");
      return;
    }

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (ctx) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Select Material Request",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: pendingRequests.length,
                    itemBuilder: (context, index) {
                      final req = pendingRequests[index];
                      return ListTile(
                        title: Text(req.materialName),
                        subtitle: Text(
                            "Req #: ${req.requestNo} • Qty: ${req.quantity} ${req.unit}"),
                        trailing: const Icon(Icons.add_circle,
                            color: Color(0xFF0D6EFD)),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedMaterialId = req.materialId;
                            _itemDescController.text = req.materialName;
                            _itemQtyController.text = req.quantity.toString();
                            _itemUnitController.text = req.unit;
                            // Estimate unit price if available
                            if (req.estimatedCost != null && req.quantity > 0) {
                              _itemPriceController.text =
                                  (req.estimatedCost! / req.quantity)
                                      .toStringAsFixed(2);
                            }
                            if (_selectedProjectId == null) {
                              _selectedProjectId = req.projectId;
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  // --- SUBMISSION ---

  void _submitPO() async {
    if (_isCustomSupplier) {
      if (_supplierNameController.text.trim().isEmpty) {
        _showError('Please enter a Supplier Name');
        return;
      }
    } else {
      if (_selectedSupplierId == null) {
        _showError('Please select a supplier from the list');
        return;
      }
    }

    if (_selectedProjectId == null) {
      _showError('Please select a project location');
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      _showError('Please enter a PO Title');
      return;
    }

    if (_addedItems.isEmpty) {
      _showError(
          'Please add at least one item to the PO list before submitting.');
      return;
    }

    setState(() => _isLoading = true);

    final payload = <String, dynamic>{
      'projectId': _selectedProjectId,
      'title': _titleController.text.trim(),
      'type': 'MATERIAL',
      if (_expectedDate != null)
        'expectedDelivery': _expectedDate!.toUtc().toIso8601String(),
      'items': _addedItems,
    };

    if (_isCustomSupplier) {
      payload['supplierName'] = _supplierNameController.text.trim();
      payload['supplierContact'] = _supplierPhoneController.text.trim();
      payload['supplierAddress'] = _supplierAddressController.text.trim();
      payload['supplierGST'] = _supplierGstController.text.trim();
    } else {
      payload['supplierId'] = _selectedSupplierId;
    }

    try {
      await ref
          .read(procurementControllerProvider.notifier)
          .createPurchaseOrder(payload);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase Order Created Successfully'),
            backgroundColor: Color(0xFF00B48A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to create PO: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectStateAsync = ref.watch(projectControllerProvider);
    final List<Project> projectList = projectStateAsync.value?.projects ?? [];

    // Dynamically fetch materials based on selected project
    List<erp_mat.Material> projectMaterials = [];
    bool isMaterialsLoading = false;

    if (_selectedProjectId != null) {
      final invAsync = ref.watch(projectInventoryProvider(_selectedProjectId!));
      invAsync.when(
        data: (data) {
          final rawMaterials = data['materials'] as List? ?? [];
          for (var item in rawMaterials) {
            if (item['material'] != null) {
              projectMaterials.add(erp_mat.Material.fromJson(item['material']));
            } else {
              // Fallback just in case the API structure wraps it differently
              try {
                projectMaterials.add(erp_mat.Material.fromJson(item));
              } catch (_) {}
            }
          }
        },
        loading: () => isMaterialsLoading = true,
        error: (e, s) => null,
      );
    }

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
          "Create PO",
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
                    // =================== HEADER SECTION ===================
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel("Supplier *"),
                        Row(
                          children: [
                            const Text("Enter Manually",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54)),
                            Switch(
                              value: _isCustomSupplier,
                              onChanged: (val) {
                                setState(() {
                                  _isCustomSupplier = val;
                                  if (val) _selectedSupplierId = null;
                                });
                              },
                              activeColor: const Color(0xFF0D6EFD),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (!_isCustomSupplier) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF0D6EFD)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedSupplierId,
                            hint: const Text("Select Supplier"),
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Color(0xFF0D6EFD)),
                            items: _dummySuppliers.map((supplier) {
                              return DropdownMenuItem<String>(
                                value: supplier['id'],
                                child: Text(supplier['name']!),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _selectedSupplierId = value),
                          ),
                        ),
                      ),
                    ] else ...[
                      _buildTextField("Supplier Name *",
                          controller: _supplierNameController),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField("Contact Number",
                                controller: _supplierPhoneController,
                                isNumber: true),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField("GST Number",
                                controller: _supplierGstController),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField("Address",
                          controller: _supplierAddressController),
                    ],

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Location (Project) *"),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF0D6EFD)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: _selectedProjectId,
                                    hint: const Text("Select Project"),
                                    icon: const Icon(Icons.keyboard_arrow_down,
                                        color: Color(0xFF0D6EFD)),
                                    items: projectList.map((proj) {
                                      return DropdownMenuItem<String>(
                                        value: proj.id,
                                        child: Text(
                                            proj.name ?? 'Unknown Project',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                      );
                                    }).toList(),
                                    onChanged: (value) => setState(() {
                                      if (_selectedProjectId != value) {
                                        _selectedMaterialId =
                                            null; // reset selected material when project changes
                                      }
                                      _selectedProjectId = value;
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Expected Date"),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF0D6EFD)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _expectedDate == null
                                      ? "Select Date"
                                      : DateFormat('dd MMM yy')
                                          .format(_expectedDate!),
                                  style: TextStyle(
                                      color: _expectedDate == null
                                          ? Colors.grey[400]
                                          : Colors.black87,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // =================== ADDED ITEMS LIST ===================
                    if (_addedItems.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Added Items",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D6EFD))),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: const Color(0xFFE8F1FF),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text("${_addedItems.length} items",
                                style: const TextStyle(
                                    color: Color(0xFF0D6EFD),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _addedItems.length,
                        itemBuilder: (context, index) {
                          final item = _addedItems[index];
                          final subtotal = item['quantity'] * item['unitPrice'];
                          final tax = subtotal * (item['taxPercent'] / 100);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey[200]!)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              title: Text(item['description'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              subtitle: Text(
                                  "${item['quantity']} ${item['unit']} @ ₹${item['unitPrice']} \nGST: ${item['taxPercent']}%"),
                              isThreeLine: true,
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                      "₹${(subtotal + tax).toStringAsFixed(0)}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0D6EFD))),
                                  InkWell(
                                    onTap: () => _removeItem(index),
                                    child: const Padding(
                                      padding: EdgeInsets.only(top: 4.0),
                                      child: Icon(Icons.delete_outline,
                                          color: Colors.red, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // =================== VISUALLY DISTINCT ADD NEW ITEM FORM ===================
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFFF8FAFC), // Very light blue/gray background
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Add New Line Item",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D6EFD))),
                              TextButton.icon(
                                onPressed: _loadFromMaterialRequest,
                                icon: const Icon(Icons.assignment_returned,
                                    size: 16),
                                label: const Text("From Request"),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF00B48A),
                                  padding: EdgeInsets.zero,
                                ),
                              )
                            ],
                          ),
                          const Divider(height: 16),

                          _buildLabel("Select Material (Optional)"),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFF0D6EFD)),
                              borderRadius: BorderRadius.circular(8),
                              color: _selectedProjectId == null
                                  ? Colors.grey[200]
                                  : Colors.white,
                            ),
                            child: isMaterialsLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text("Loading materials...",
                                        style: TextStyle(color: Colors.grey)),
                                  )
                                : DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: _selectedMaterialId,
                                      hint: Text(_selectedProjectId == null
                                          ? "Select a project first"
                                          : "Choose from inventory"),
                                      icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Color(0xFF0D6EFD)),
                                      items: projectMaterials.map((mat) {
                                        return DropdownMenuItem<String>(
                                          value: mat.id,
                                          child: Text(mat.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                        );
                                      }).toList(),
                                      onChanged: _selectedProjectId == null
                                          ? null
                                          : (value) {
                                              setState(() {
                                                _selectedMaterialId = value;
                                                if (value != null) {
                                                  final mat = projectMaterials
                                                      .firstWhere(
                                                          (m) => m.id == value);
                                                  _itemDescController.text =
                                                      mat.name;
                                                  _itemUnitController.text =
                                                      mat.unit ?? 'Nos';
                                                  if (mat.unitPrice != null) {
                                                    _itemPriceController.text =
                                                        mat.unitPrice
                                                            .toString();
                                                  }
                                                }
                                              });
                                            },
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 12),

                          _buildLabel("Description *"),
                          _buildTextField("e.g. Portland Cement 50kg",
                              controller: _itemDescController, isWhiteBg: true),
                          const SizedBox(height: 12),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel("Qty *"),
                                    _buildTextField("0.0",
                                        controller: _itemQtyController,
                                        isNumber: true,
                                        isWhiteBg: true),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel("Unit *"),
                                    _buildTextField("Nos",
                                        controller: _itemUnitController,
                                        isWhiteBg: true),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel("Price(₹)*"),
                                    _buildTextField("0.00",
                                        controller: _itemPriceController,
                                        isNumber: true,
                                        isWhiteBg: true),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel("GST %"),
                                    _buildTextField("18",
                                        controller: _itemGstController,
                                        isNumber: true,
                                        isWhiteBg: true),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // PROMINENT ADD ITEM BUTTON
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _addItem,
                              icon: const Icon(Icons.add_shopping_cart,
                                  color: Colors.white, size: 20),
                              label: const Text("Add Item to List",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF0D6EFD), // Strong Blue
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =================== TOTALS & SUBMIT ===================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Grand Total",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(
                                    locale: 'en_IN',
                                    symbol: '₹',
                                    decimalDigits: 0)
                                .format(_calculatedTotal),
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // FINAL SUBMIT BUTTON - Made Green to distinguish from 'Add Item'
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitPO,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xFF00B48A), // Distinct Green for final submit
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text("Create Purchase Order",
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
      {TextEditingController? controller,
      bool isNumber = false,
      bool isWhiteBg = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: isWhiteBg,
        fillColor: isWhiteBg ? Colors.white : Colors.transparent,
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
