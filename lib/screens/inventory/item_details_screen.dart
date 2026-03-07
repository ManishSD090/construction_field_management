import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/routes.dart';

// Models & Controllers
import 'package:construction_erp/models/material.dart' as erp_mat;
import 'package:construction_erp/models/equipment.dart';
import 'package:construction_erp/models/project.dart';
import 'package:construction_erp/models/enums.dart';
import 'package:construction_erp/controllers/inventory/inventory_controller.dart';
import 'package:construction_erp/controllers/project/project_controller.dart';
import 'package:construction_erp/controllers/inventory/procurement_controller.dart'; // Added Procurement Controller

class ItemDetailsScreen extends ConsumerStatefulWidget {
  final bool isMaterial;
  final String itemId;
  final String itemName;
  final bool isGlobalContext;
  final String? projectId;

  final double? totalQty;
  final double? usedQty;
  final double? availableQty;

  const ItemDetailsScreen({
    super.key,
    required this.isMaterial,
    required this.itemId,
    required this.itemName,
    required this.isGlobalContext,
    this.projectId,
    this.totalQty,
    this.usedQty,
    this.availableQty,
  });

  @override
  ConsumerState<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends ConsumerState<ItemDetailsScreen> {
  final currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  // Controllers for Transfer Modal
  final TextEditingController _transferQtyController = TextEditingController();
  final TextEditingController _transferDescController = TextEditingController();
  String? _selectedTransferProjectId;
  DateTime? _transferDate;
  bool _isTransferToProject = true;

  // Controllers for Request Modal (Material Request)
  final TextEditingController _reqQtyController = TextEditingController();
  final TextEditingController _reqVendorNameController =
      TextEditingController();
  final TextEditingController _reqPurposeController =
      TextEditingController(); // Required by backend
  String? _selectedReqProjectId; // Required by backend
  String _selectedUrgency = 'MEDIUM'; // Default urgency
  DateTime? _reqDate; // Expected Delivery

  // Controllers for Add Stock Modal
  final TextEditingController _addStockQtyController = TextEditingController();
  final TextEditingController _addStockPriceController =
      TextEditingController();
  final TextEditingController _addStockBatchController =
      TextEditingController();
  final TextEditingController _addStockNotesController =
      TextEditingController();
  DateTime? _addStockPurchaseDate;
  DateTime? _addStockExpiryDate;

  // Controllers for Assign Equipment Modal
  String? _selectedAssignProjectId;
  final TextEditingController _assignRateController = TextEditingController();
  final TextEditingController _assignFuelCostController =
      TextEditingController();

  String _formatDate(dynamic date) {
    if (date == null) return "N/A";
    if (date is DateTime) return DateFormat('dd MMM yyyy').format(date);
    if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) return DateFormat('dd MMM yyyy').format(parsed);
    }
    return "N/A";
  }

  Future<void> _selectDate(
      BuildContext context, Function(DateTime) onDateSelected,
      {DateTime? firstDate, DateTime? lastDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2101),
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
      onDateSelected(picked);
    }
  }

  @override
  void dispose() {
    _transferQtyController.dispose();
    _transferDescController.dispose();
    _reqQtyController.dispose();
    _reqVendorNameController.dispose();
    _reqPurposeController.dispose();
    _addStockQtyController.dispose();
    _addStockPriceController.dispose();
    _addStockBatchController.dispose();
    _addStockNotesController.dispose();
    _assignRateController.dispose();
    _assignFuelCostController.dispose();
    super.dispose();
  }

  // --- API Submission Methods ---

  void _submitTransfer() async {
    final qty = double.tryParse(_transferQtyController.text) ?? 0;

    if (widget.isMaterial) {
      if (qty <= 0) return;
      if (widget.availableQty != null && qty > widget.availableQty!) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfer quantity cannot exceed available stock.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final payload = <String, dynamic>{
      'fromLocation': widget.isGlobalContext ? 'GLOBAL' : 'PROJECT',
      'toLocation': _isTransferToProject ? 'PROJECT' : 'GLOBAL',
      'description': _transferDescController.text.trim(),
    };

    if (!widget.isGlobalContext && widget.projectId != null) {
      payload['fromProjectId'] = widget.projectId!;
    }

    if (_isTransferToProject) {
      if (_selectedTransferProjectId == null ||
          _selectedTransferProjectId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a destination project'),
              backgroundColor: Colors.red),
        );
        return;
      }
      payload['toProjectId'] = _selectedTransferProjectId!;
    }

    if (_transferDate != null) {
      payload['transferDate'] = _transferDate!.toUtc().toIso8601String();
    }

    payload['items'] = <Map<String, dynamic>>[
      {
        'itemType': widget.isMaterial ? 'MATERIAL' : 'EQUIPMENT',
        if (widget.isMaterial) 'materialId': widget.itemId,
        if (!widget.isMaterial) 'equipmentId': widget.itemId,
        if (widget.isMaterial) 'quantity': qty,
      }
    ];

    try {
      await ref
          .read(inventoryControllerProvider.notifier)
          .initiateTransfer(payload);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Transfer Initiated Successfully'),
              backgroundColor: Color(0xFF00B48A)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to transfer: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _submitRequest(String unit) async {
    if (_selectedReqProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a project'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final qty = double.tryParse(_reqQtyController.text) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid quantity'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final purpose = _reqPurposeController.text.trim();
    if (purpose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Purpose is required'), backgroundColor: Colors.red),
      );
      return;
    }

    final payload = {
      'projectId': _selectedReqProjectId,
      'materialId': widget.itemId,
      'materialName': widget.itemName,
      'quantity': qty,
      'unit': unit,
      'purpose': purpose,
      'urgency': _selectedUrgency,
      'supplier': _reqVendorNameController.text.trim(),
      if (_reqDate != null)
        'expectedDelivery': _reqDate!.toUtc().toIso8601String(),
    };

    try {
      await ref
          .read(procurementControllerProvider.notifier)
          .createMaterialRequest(payload);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Material Request Created'),
              backgroundColor: Color(0xFF00B48A)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to create request: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _submitAddStock() async {
    final qty = double.tryParse(_addStockQtyController.text) ?? 0;
    if (qty <= 0) return;

    try {
      final payload = {
        'materialId': widget.isMaterial ? widget.itemId : null,
        'quantity': qty,
        'unitPrice': double.tryParse(_addStockPriceController.text) ?? 0,
        'notes': _addStockNotesController.text.trim(),
      };

      if (widget.isMaterial) {
        payload['batchNumber'] = _addStockBatchController.text.trim();
        if (_addStockPurchaseDate != null) {
          payload['purchaseDate'] =
              _addStockPurchaseDate!.toUtc().toIso8601String();
        }
        if (_addStockExpiryDate != null) {
          payload['expiryDate'] =
              _addStockExpiryDate!.toUtc().toIso8601String();
        }
      }

      await ref
          .read(inventoryControllerProvider.notifier)
          .addOpeningStock(payload);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Stock added successfully'),
              backgroundColor: Color(0xFF00B48A)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add stock: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _submitAssignEquipment() async {
    if (_selectedAssignProjectId == null || _selectedAssignProjectId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Destination Project is required'),
            backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final payload = {
        'projectId': _selectedAssignProjectId,
        'assignedRate': double.tryParse(_assignRateController.text) ?? 0.0,
        'assignedFuelCost':
            double.tryParse(_assignFuelCostController.text) ?? 0.0,
      };

      await ref
          .read(inventoryControllerProvider.notifier)
          .assignEquipment(widget.itemId, payload);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Equipment assigned successfully'),
              backgroundColor: Color(0xFF00B48A)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to assign equipment: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _submitReleaseEquipment() async {
    try {
      await ref
          .read(inventoryControllerProvider.notifier)
          .releaseEquipment(widget.itemId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Equipment released successfully'),
              backgroundColor: Color(0xFF00B48A)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to release equipment: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<dynamic> itemDataAsync = widget.isMaterial
        ? ref.watch(materialDetailsProvider(widget.itemId))
        : ref.watch(equipmentDetailsProvider(widget.itemId));

    final projectStateAsync = ref.watch(projectControllerProvider);
    final List<Project> projectList = projectStateAsync.value?.projects ?? [];

    // Pre-select project if we are in project context
    if (!widget.isGlobalContext &&
        widget.projectId != null &&
        _selectedReqProjectId == null) {
      _selectedReqProjectId = widget.projectId;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.isMaterial ? "Material Details" : "Equipment Details",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: itemDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text("Failed to load details:\n$error",
                  textAlign: TextAlign.center),
            ],
          ),
        ),
        data: (data) {
          String unit = '';
          if (widget.isMaterial && data is erp_mat.Material) {
            unit = data.unit ?? '';
          }

          String leftButtonLabel;
          VoidCallback onLeftButtonPressed;
          Color leftButtonColor = const Color(0xFF00B48A);

          if (widget.isMaterial) {
            leftButtonLabel = widget.isGlobalContext ? "Add Stock" : "Request";
            onLeftButtonPressed = widget.isGlobalContext
                ? () => _showAddStockModal(context, unit)
                : () => _showRequestModal(context, projectList, unit);
          } else {
            leftButtonLabel = widget.isGlobalContext
                ? "Assign to Project"
                : "Release Equipment";
            leftButtonColor = widget.isGlobalContext
                ? const Color(0xFF00B48A)
                : Colors.orange;
            onLeftButtonPressed = widget.isGlobalContext
                ? () => _showAssignModal(context, projectList)
                : () => _confirmReleaseModal(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.itemName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(data),
                const SizedBox(height: 16),
                _buildVendorCard(data),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onLeftButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: leftButtonColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(leftButtonLabel,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    if (widget.isMaterial) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _showTransferModal(context, projectList, unit),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D6EFD),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("Transfer",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildInfoCard(dynamic data) {
    final matData = widget.isMaterial ? (data as erp_mat.Material) : null;
    final eqData = !widget.isMaterial ? (data as Equipment) : null;

    final eqOwnership =
        eqData?.ownershipType.toString().split('.').last.toUpperCase() ?? '';
    final eqStatus =
        eqData?.status.toString().split('.').last.toUpperCase() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isMaterial ? "Material Info" : "Equipment Info",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.grey[100], shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 16, color: Colors.grey),
              )
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow("Name:", widget.itemName),
          const SizedBox(height: 12),
          if (widget.isMaterial) ...[
            _buildInfoRow("Code:", matData?.materialCode ?? "N/A"),
            const SizedBox(height: 12),
            _buildInfoRow("Unit:", matData?.unit ?? "Units"),
            const SizedBox(height: 12),
            _buildInfoRow("Cost per unit:",
                currencyFormat.format(matData?.unitPrice ?? 0)),
            const SizedBox(height: 12),
            _buildInfoRow("Total Quantity:",
                "${widget.totalQty?.toStringAsFixed(1) ?? '0'} ${matData?.unit ?? ''}"),
            const SizedBox(height: 12),
            _buildInfoRow("Used/Consumed:",
                "${widget.usedQty?.toStringAsFixed(1) ?? '0'} ${matData?.unit ?? ''}"),
            const SizedBox(height: 12),
            _buildInfoRow("Available:",
                "${widget.availableQty?.toStringAsFixed(1) ?? '0'} ${matData?.unit ?? ''}"),
            const SizedBox(height: 12),
            _buildInfoRow("Global Low Stock Threshold:",
                "${matData?.minimumStock ?? 0} ${matData?.unit ?? ''}"),
          ] else ...[
            _buildInfoRow("Code:", eqData?.code ?? eqData?.type ?? "N/A"),
            const SizedBox(height: 12),
            _buildInfoRow("Type:", eqData?.type ?? "N/A"),
            const SizedBox(height: 12),
            _buildInfoRow("Model:", eqData?.model ?? "N/A"),
            const SizedBox(height: 12),
            _buildInfoRow("Manufacturer:", eqData?.manufacturer ?? "N/A"),
            const SizedBox(height: 12),
            _buildInfoRow("Year:", eqData?.year?.toString() ?? "N/A"),
            const SizedBox(height: 12),
            _buildInfoRow("Serial Number:", eqData?.serialNumber ?? "N/A"),
            const SizedBox(height: 12),
            if (eqData?.registrationNumber != null) ...[
              _buildInfoRow("Reg Number:", eqData!.registrationNumber!),
              const SizedBox(height: 12),
            ],
            _buildInfoRow("Status:", eqStatus),
            const SizedBox(height: 12),
            _buildInfoRow("Condition:", eqData?.condition ?? "N/A"),
            const SizedBox(height: 12),
            _buildInfoRow("Ownership:", eqOwnership),
            const SizedBox(height: 12),
            _buildInfoRow(
                eqOwnership == 'RENTED' ? "Rent/Day:" : "Purchase Cost:",
                currencyFormat
                    .format(eqData?.rentalRate ?? eqData?.purchaseCost ?? 0)),
            const SizedBox(height: 12),
            if (eqData?.fuelType != null) ...[
              _buildInfoRow("Fuel Type:", eqData!.fuelType!.toDisplayString()),
              const SizedBox(height: 12),
            ],
            _buildInfoRow(
                "Last Service:", _formatDate(eqData?.lastServiceDate)),
            const SizedBox(height: 12),
            _buildInfoRow(
                "Next Service:", _formatDate(eqData?.nextServiceDate)),
          ],
        ],
      ),
    );
  }

  Widget _buildVendorCard(dynamic data) {
    final matData = widget.isMaterial ? (data as erp_mat.Material) : null;
    final eqData = !widget.isMaterial ? (data as Equipment) : null;

    final vendorName = widget.isMaterial
        ? (matData?.supplier ?? "No Vendor assigned")
        : (eqData?.rentalProvider ??
            eqData?.manufacturer ??
            "No Vendor assigned");

    final vendorContact =
        widget.isMaterial ? (matData?.supplierContact ?? "N/A") : "N/A";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Vendor Info",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.grey[100], shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 16, color: Colors.grey),
              )
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow("Name:", vendorName),
          const SizedBox(height: 12),
          _buildInfoRow("Contact Info:", vendorContact),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(color: Colors.black87)),
        ),
        Expanded(
          flex: 3,
          child:
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // --- Modals / Popups ---

  void _showAddStockModal(BuildContext context, String unit) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          widget.isMaterial
                              ? "Add Material Stock"
                              : "Add Equipment Stock",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField("Quantity to Add *",
                              controller: _addStockQtyController,
                              isNumber: true,
                              suffixText: unit.isNotEmpty ? unit : null),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField("Unit Price (₹)",
                              controller: _addStockPriceController,
                              isNumber: true),
                        ),
                      ],
                    ),
                    if (widget.isMaterial) ...[
                      const SizedBox(height: 12),
                      _buildTextField("Batch Number",
                          controller: _addStockBatchController),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Purchase Date",
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.black87)),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () => _selectDate(context, (date) {
                                    setModalState(
                                        () => _addStockPurchaseDate = date);
                                  }, lastDate: DateTime.now()),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFF0D6EFD)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(_addStockPurchaseDate == null
                                        ? 'Select'
                                        : DateFormat('dd MMM yy')
                                            .format(_addStockPurchaseDate!)),
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
                                const Text("Expiry Date",
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.black87)),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () => _selectDate(context, (date) {
                                    setModalState(
                                        () => _addStockExpiryDate = date);
                                  }, firstDate: DateTime.now()),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFF0D6EFD)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(_addStockExpiryDate == null
                                        ? 'Select'
                                        : DateFormat('dd MMM yy')
                                            .format(_addStockExpiryDate!)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildTextField("Notes",
                        controller: _addStockNotesController),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitAddStock,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B48A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Submit Stock",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _showRequestModal(
      BuildContext context, List<Project> projectList, String unit) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, size: 20),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Request Material",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Project Dropdown
                    const Text("Project *",
                        style: TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF0D6EFD)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedReqProjectId,
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Color(0xFF0D6EFD)),
                          hint: const Text("Select Project"),
                          items: projectList.map((Project proj) {
                            return DropdownMenuItem<String>(
                              value: proj.id,
                              child: Text(proj.name ?? 'Unknown Project',
                                  style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: widget.isGlobalContext
                              ? (String? val) {
                                  setModalState(() {
                                    _selectedReqProjectId = val;
                                  });
                                }
                              : null, // Disabled if already in a project context
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField("Quantity *",
                              controller: _reqQtyController,
                              isNumber: true,
                              suffixText: unit.isNotEmpty ? unit : null),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Urgency",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black87)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical:
                                        2), // Tighter vertical padding to match TextField height
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF0D6EFD)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: _selectedUrgency,
                                    icon: const Icon(Icons.keyboard_arrow_down,
                                        color: Color(0xFF0D6EFD)),
                                    items: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']
                                        .map((String urgency) {
                                      return DropdownMenuItem<String>(
                                        value: urgency,
                                        child: Text(urgency,
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      );
                                    }).toList(),
                                    onChanged: (String? val) {
                                      if (val != null) {
                                        setModalState(() {
                                          _selectedUrgency = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _buildTextField("Purpose *",
                        controller: _reqPurposeController),
                    const SizedBox(height: 12),

                    _buildTextField("Preferred Vendor (Optional)",
                        controller: _reqVendorNameController),
                    const SizedBox(height: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Required By Date",
                            style:
                                TextStyle(fontSize: 13, color: Colors.black87)),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _selectDate(context, (date) {
                            setModalState(() => _reqDate = date);
                          }, firstDate: DateTime.now()),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFF0D6EFD)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(_reqDate == null
                                ? 'Select Date'
                                : DateFormat('dd MMM yyyy').format(_reqDate!)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submitRequest(unit),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B48A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Submit Request",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _showAssignModal(BuildContext context, List<Project> projectList) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, size: 20),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Assign Equipment",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("Destination Project *",
                        style: TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF0D6EFD)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedAssignProjectId,
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Color(0xFF0D6EFD)),
                          hint: const Text("Select Project"),
                          items: projectList.map((Project proj) {
                            return DropdownMenuItem<String>(
                              value: proj.id,
                              child: Text(proj.name ?? 'Unknown Project',
                                  style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (String? val) {
                            setModalState(() {
                              _selectedAssignProjectId = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField("Assigned Rate (₹)",
                              controller: _assignRateController,
                              isNumber: true),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField("Assigned Fuel Cost (₹)",
                              controller: _assignFuelCostController,
                              isNumber: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitAssignEquipment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B48A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Assign to Project",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _confirmReleaseModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Release Equipment"),
        content: const Text(
            "Are you sure you want to release this equipment back to the Global Inventory?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitReleaseEquipment();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Release", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTransferModal(
      BuildContext context, List<Project> projectList, String unit) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          widget.isMaterial
                              ? "Transfer Material"
                              : "Transfer Equipment",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Destination Toggle
                    const Text("Transfer To",
                        style: TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text("Project",
                                style: TextStyle(fontSize: 14)),
                            value: true,
                            groupValue: _isTransferToProject,
                            contentPadding: EdgeInsets.zero,
                            activeColor: const Color(0xFF0D6EFD),
                            onChanged: (val) {
                              setModalState(() => _isTransferToProject = val!);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text("Global",
                                style: TextStyle(fontSize: 14)),
                            value: false,
                            groupValue: _isTransferToProject,
                            contentPadding: EdgeInsets.zero,
                            activeColor: const Color(0xFF0D6EFD),
                            onChanged: (val) {
                              setModalState(() => _isTransferToProject = val!);
                            },
                          ),
                        ),
                      ],
                    ),

                    if (_isTransferToProject) ...[
                      const SizedBox(height: 12),
                      const Text("Destination Project *",
                          style:
                              TextStyle(fontSize: 13, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF0D6EFD)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedTransferProjectId,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Color(0xFF0D6EFD)),
                            hint: const Text("Select Project"),
                            items: projectList.map((Project proj) {
                              return DropdownMenuItem<String>(
                                value: proj.id,
                                child: Text(proj.name ?? 'Unknown Project',
                                    style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (String? val) {
                              setModalState(() {
                                _selectedTransferProjectId = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    if (widget.isMaterial) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Quantity to Transfer *",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black87)),
                              Text(
                                  "Available: ${widget.availableQty?.toStringAsFixed(1) ?? '0'} $unit",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF00B48A),
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _transferQtyController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              suffixText: unit,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Color(0xFF0D6EFD)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xFF0D6EFD), width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Transfer Date",
                            style:
                                TextStyle(fontSize: 13, color: Colors.black87)),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _selectDate(context, (date) {
                            setModalState(() => _transferDate = date);
                          }),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFF0D6EFD)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(_transferDate == null
                                ? 'Select Date'
                                : DateFormat('dd MMM yyyy')
                                    .format(_transferDate!)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _buildTextField("Description / Notes",
                        controller: _transferDescController),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitTransfer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6EFD),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Initiate Transfer",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildTextField(String label,
      {TextEditingController? controller,
      bool isNumber = false,
      String? suffixText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(
            suffixText: suffixText,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12), // Adjusted to match dropdown heights nicely
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D6EFD), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
