import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/controllers/inventory/inventory_controller.dart'; // Adjust path if needed

class CreateEquipmentScreen extends ConsumerStatefulWidget {
  const CreateEquipmentScreen({super.key});

  @override
  ConsumerState<CreateEquipmentScreen> createState() =>
      _CreateEquipmentScreenState();
}

class _CreateEquipmentScreenState extends ConsumerState<CreateEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isOwned = true; // State for radio buttons

  // Controllers for API-required fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _serialNumController = TextEditingController();
  final TextEditingController _regNumController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _conditionController =
      TextEditingController(text: "Good");

  // Conditional Controllers
  final TextEditingController _purchaseCostController = TextEditingController();
  final TextEditingController _rentalProviderController =
      TextEditingController();
  final TextEditingController _rentalRateController = TextEditingController();
  final TextEditingController _fuelConsumptionController =
      TextEditingController();

  DateTime? _purchaseDate;

  // Dropdown States
  String _selectedFuelType = 'DIESEL';
  final List<String> _fuelTypes = [
    'DIESEL',
    'PETROL',
    'ELECTRIC',
    'HYBRID',
    'CNG',
    'LPG',
    'OTHER'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _typeController.dispose();
    _modelController.dispose();
    _manufacturerController.dispose();
    _serialNumController.dispose();
    _regNumController.dispose();
    _yearController.dispose();
    _conditionController.dispose();
    _purchaseCostController.dispose();
    _rentalProviderController.dispose();
    _rentalRateController.dispose();
    _fuelConsumptionController.dispose();
    super.dispose();
  }

  Future<void> _selectPurchaseDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D6EFD), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Map data according to your backend schema
      final Map<String, dynamic> payload = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim(),
        'type': _typeController.text.trim(),
        'model': _modelController.text.trim(),
        'manufacturer': _manufacturerController.text.trim(),
        'year': int.tryParse(_yearController.text) ?? DateTime.now().year,
        'serialNumber': _serialNumController.text.trim(),
        'registrationNumber': _regNumController.text.trim(),
        'condition': _conditionController.text.trim(),
        'status': 'AVAILABLE', // Default creation status
        'ownershipType': isOwned ? 'OWNED' : 'RENTED',
      };

      if (isOwned) {
        payload['purchaseCost'] =
            double.tryParse(_purchaseCostController.text) ?? 0.0;
        if (_purchaseDate != null) {
          // Convert to UTC before generating ISO string to ensure the 'Z' timezone marker is added
          payload['purchaseDate'] = _purchaseDate!.toUtc().toIso8601String();
        }
      } else {
        payload['rentalProvider'] = _rentalProviderController.text.trim();
        payload['rentalRate'] =
            double.tryParse(_rentalRateController.text) ?? 0.0;
        payload['rentalUnit'] = 'DAY';
      }

      payload['fuelType'] = _selectedFuelType;
      payload['fuelConsumption'] =
          double.tryParse(_fuelConsumptionController.text) ?? 0.0;

      // Call the controller
      await ref
          .read(inventoryControllerProvider.notifier)
          .createEquipment(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipment created successfully'),
            backgroundColor: Color(0xFF00B48A),
          ),
        );
        Navigator.pop(context); // Go back after success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create equipment: $e'),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create Equipment",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Equipment Name *"),
              _buildTextField(
                controller: _nameController,
                hint: "Enter the equipment name",
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Equipment Code"),
                        _buildTextField(
                          controller: _codeController,
                          hint: "EQ-EXC-001",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Type / Category *"),
                        _buildTextField(
                          controller: _typeController,
                          hint: "e.g. Excavator",
                          validator: (value) =>
                              value!.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Manufacturer *"),
                        _buildTextField(
                          controller: _manufacturerController,
                          hint: "e.g. Caterpillar",
                          validator: (value) =>
                              value!.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Model"),
                        _buildTextField(
                          controller: _modelController,
                          hint: "e.g. 320D2",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Serial Number"),
                        _buildTextField(
                          controller: _serialNumController,
                          hint: "S/N",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Manufacture Year"),
                        _buildTextField(
                          controller: _yearController,
                          hint: "YYYY",
                          isNumber: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel("Registration Number (If applicable)"),
              _buildTextField(
                controller: _regNumController,
                hint: "e.g. MH12-AB-1234",
              ),
              const SizedBox(height: 24),

              // Radio Buttons for Ownership
              const Text("Ownership Type",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildRadioButton("Owned", true),
                  const SizedBox(width: 20),
                  _buildRadioButton("Rented", false),
                ],
              ),
              const SizedBox(height: 16),

              // Conditionally show content based on radio selection
              if (isOwned) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Purchase Cost (₹)"),
                          _buildTextField(
                            controller: _purchaseCostController,
                            hint: "0.00",
                            isNumber: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Purchase Date"),
                          InkWell(
                            onTap: () => _selectPurchaseDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFF0D6EFD)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _purchaseDate == null
                                        ? 'Select Date'
                                        : DateFormat('dd MMM yyyy')
                                            .format(_purchaseDate!),
                                    style: TextStyle(
                                        color: _purchaseDate == null
                                            ? Colors.grey[400]
                                            : Colors.black87),
                                  ),
                                  const Icon(Icons.calendar_today,
                                      size: 18, color: Color(0xFF0D6EFD)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildLabel("Vendor / Rental Provider *"),
                _buildTextField(
                  controller: _rentalProviderController,
                  hint: "Enter vendor name",
                  validator: (value) =>
                      !isOwned && value!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                _buildLabel("Rent Per Day (₹) *"),
                _buildTextField(
                  controller: _rentalRateController,
                  hint: "0.00",
                  isNumber: true,
                  validator: (value) =>
                      !isOwned && value!.isEmpty ? "Required" : null,
                ),
              ],

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Fuel Type"),
                        _buildDropdown(
                          value: _selectedFuelType,
                          items: _fuelTypes,
                          onChanged: (val) =>
                              setState(() => _selectedFuelType = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Fuel Consumption (L/hr)"),
                        _buildTextField(
                          controller: _fuelConsumptionController,
                          hint: "0.0",
                          isNumber: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel("Current Condition"),
              _buildTextField(
                controller: _conditionController,
                hint: "e.g. Good, Needs Maintenance",
              ),

              const SizedBox(height: 40),

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
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Create Equipment",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

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

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0D6EFD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0D6EFD)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildRadioButton(String label, bool value) {
    return Row(
      children: [
        Radio<bool>(
          value: value,
          groupValue: isOwned,
          activeColor: const Color(0xFF0D6EFD),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                isOwned = val;
              });
            }
          },
        ),
        Text(label),
      ],
    );
  }
}
