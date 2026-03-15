import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/models/worker.dart';
import 'package:construction_erp/controllers/worker/worker_controller.dart';

class AddWorkerScreen extends ConsumerStatefulWidget {
  const AddWorkerScreen({super.key});

  @override
  ConsumerState<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends ConsumerState<AddWorkerScreen> {
  bool _isSelectionEnabled = false;
  final Set<String> _selectedWorkerIds = {};
  
  // Only Name and Search controllers are needed now
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  String? _aadharPath;
  final ImagePicker _picker = ImagePicker();

  bool get _hasSelection => _selectedWorkerIds.isNotEmpty;

  void _showCreateWorkerDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( 
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Center(child: Text("Create Worker", style: TextStyle(fontWeight: FontWeight.bold))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label("Worker Name"),
                _textField(_nameController, "Enter name"),
                const SizedBox(height: 16),
                _label("Aadhar Card Copy"),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setDialogState(() => _aadharPath = image.path);
                    }
                  },
                  icon: Icon(_aadharPath == null ? Icons.upload_file : Icons.check_circle, 
                        color: _aadharPath == null ? AppColors.primaryBlue : Colors.green),
                  label: Text(_aadharPath == null ? "Select File" : "File Selected"),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.isNotEmpty) {
                      final fields = {
                        'name': _nameController.text,
                        'status': 'ACTIVE',
                        'dailyWageRate': 500,
                        'phone': '',
                      };

                      await ref.read(workerControllerProvider.notifier).createWorker(
                        fields: fields,
                        aadharPath: _aadharPath,
                      );

                      _nameController.clear();
                      _aadharPath = null;
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text("Create", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🚨 RESTORED: Confirm Delete Dialog
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Workers"),
        content: Text("Are you sure you want to delete ${_selectedWorkerIds.length} selected worker(s)? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Cancel")
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); 
              
              try {
                for (String id in _selectedWorkerIds) {
                  await ref.read(workerControllerProvider.notifier).deleteWorker(id);
                }
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Workers deleted successfully"), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                 if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error deleting some workers"), backgroundColor: Colors.red),
                  );
                }
              } finally {
                setState(() {
                  _selectedWorkerIds.clear();
                  _isSelectionEnabled = false;
                });
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13));

  Widget _textField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workersAsync = ref.watch(workerControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text("Select Workers", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildListTitleRow(),
          const Divider(height: 1),
          Expanded(
            child: workersAsync.when(
              data: (workers) => _buildWorkerList(workers),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Center(child: Text("No workers found. Create one!")),
            ),
          ),
          // 🚨 RESTORED: Conditionally show bottom actions with delete button
          if (_isSelectionEnabled && _hasSelection) 
            workersAsync.maybeWhen(
              data: (workers) => _buildBottomActions(workers),
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      floatingActionButton: !_isSelectionEnabled
          ? FloatingActionButton(
              onPressed: _showCreateWorkerDialog,
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => ref.read(workerControllerProvider.notifier).fetchWorkersForAttendance(search: val),
        decoration: InputDecoration(
          hintText: "Search People",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildListTitleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Workers List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(_isSelectionEnabled ? Icons.check_box : Icons.check_box_outline_blank, color: AppColors.primaryBlue),
            onPressed: () => setState(() {
              _isSelectionEnabled = !_isSelectionEnabled;
              if (!_isSelectionEnabled) _selectedWorkerIds.clear(); 
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerList(List<Worker> workers) {
    return ListView.builder(
      itemCount: workers.length,
      itemBuilder: (context, index) {
        final worker = workers[index];
        final isSelected = _selectedWorkerIds.contains(worker.id);
        return ListTile(
          leading: _isSelectionEnabled ? Checkbox(
            value: isSelected,
            activeColor: AppColors.primaryBlue,
            onChanged: (val) => setState(() => val! ? _selectedWorkerIds.add(worker.id) : _selectedWorkerIds.remove(worker.id)),
          ) : null,
          title: Text(worker.name ?? ''),
          subtitle: Text(worker.workerId ?? ''),
          trailing: Text("₹${worker.dailyWageRate.toInt()}"),
          onTap: () {
            if (_isSelectionEnabled) {
              setState(() => isSelected ? _selectedWorkerIds.remove(worker.id) : _selectedWorkerIds.add(worker.id));
            }
          },
        );
      },
    );
  }

  // 🚨 RESTORED: Bottom actions bar with Delete and Add buttons
  Widget _buildBottomActions(List<Worker> allWorkers) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -2))
        ]
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _confirmDelete,
              child: const Icon(Icons.delete_outline),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue, 
                minimumSize: const Size(0, 50), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
              ),
              onPressed: () {
                final selectedWorkers = allWorkers.where((w) => _selectedWorkerIds.contains(w.id)).toList();
                Navigator.pop(context, selectedWorkers);
              },
              child: const Text("Add to Attendance", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}