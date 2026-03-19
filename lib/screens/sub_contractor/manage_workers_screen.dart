import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/subcontractor/subcontractor_controller.dart';
import 'package:intl/intl.dart';

class ManageWorkersScreen extends ConsumerStatefulWidget {
  final String contractorId;

  const ManageWorkersScreen({super.key, required this.contractorId});

  @override
  ConsumerState<ManageWorkersScreen> createState() =>
      _ManageWorkersScreenState();
}

class _ManageWorkersScreenState extends ConsumerState<ManageWorkersScreen> {
  final ScrollController _scrollController = ScrollController();
  final currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  List<dynamic> _workers = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchWorkers(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _fetchWorkers(refresh: false);
    }
  }

  Future<void> _fetchWorkers({required bool refresh}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMore = true;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final response = await ref
          .read(subcontractorControllerProvider.notifier)
          .getContractorWorkers(
            widget.contractorId,
            page: _currentPage,
            search: _searchQuery,
          );

      final List<dynamic> newWorkers = response['data'] ?? [];
      final pagination = response['pagination'] ?? {};

      setState(() {
        if (refresh) {
          _workers = newWorkers;
        } else {
          _workers.addAll(newWorkers);
        }
        _hasMore = _currentPage < (pagination['pages'] ?? 1);
        if (_hasMore) _currentPage++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to fetch workers: $e"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  // --- Helper to safely parse skillSet array ---
  String _getSkillText(Map<String, dynamic> worker) {
    if (worker['skillSet'] != null && worker['skillSet'] is List) {
      final List skills = worker['skillSet'];
      if (skills.isNotEmpty) {
        return skills.join(', ');
      }
    }
    // Fallback for older endpoints or empty arrays
    return worker['skill'] ?? 'N/A';
  }

  // ==========================================================================
  // ADD WORKER BOTTOM SHEET
  // ==========================================================================
  void _showAddWorkerSheet() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final aadharCtrl = TextEditingController();
    final skillCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    final wageRateCtrl = TextEditingController();
    String selectedWageType = 'DAILY';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Add New Worker",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue)),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField("Full Name *", nameCtrl,
                        validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 12),
                    _buildTextField("Phone Number *", phoneCtrl,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 12),
                    _buildTextField("Aadhar Number", aadharCtrl,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    _buildTextField("Skill / Trade *", skillCtrl,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                        hint: 'e.g. Mason, Helper (comma separated)'),
                    const SizedBox(height: 12),
                    _buildTextField("Experience (Years)", expCtrl,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedWageType,
                            decoration: InputDecoration(
                              labelText: "Wage Type",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'DAILY', child: Text("Daily")),
                              DropdownMenuItem(
                                  value: 'HOURLY', child: Text("Hourly")),
                            ],
                            onChanged: (val) =>
                                setModalState(() => selectedWageType = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField("Wage Rate *", wageRateCtrl,
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Required' : null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    // Parse skills string into a list of strings
                                    final List<String> skillSet = skillCtrl.text
                                        .trim()
                                        .split(',')
                                        .map((s) => s.trim())
                                        .where((s) => s.isNotEmpty)
                                        .toList();

                                    await ref
                                        .read(subcontractorControllerProvider
                                            .notifier)
                                        .addWorker(
                                      widget.contractorId,
                                      {
                                        'name': nameCtrl.text.trim(),
                                        'phone': phoneCtrl.text.trim(),
                                        'aadharNumber':
                                            aadharCtrl.text.trim().isEmpty
                                                ? null
                                                : aadharCtrl.text.trim(),
                                        'skillSet':
                                            skillSet, // Passing the array to backend
                                        'experience': expCtrl.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : int.tryParse(expCtrl.text.trim()),
                                        'wageType': selectedWageType,
                                        'wageRate': double.tryParse(
                                                wageRateCtrl.text.trim()) ??
                                            0.0,
                                      },
                                    );
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Worker added successfully"),
                                            backgroundColor: Colors.green),
                                      );
                                      _fetchWorkers(refresh: true);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text("Error: $e"),
                                            backgroundColor: Colors.red),
                                      );
                                    }
                                  } finally {
                                    if (context.mounted) {
                                      setModalState(() => isSubmitting = false);
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text("Save Worker",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator,
      String? hint}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  // ==========================================================================
  // WORKER DETAILS BOTTOM SHEET
  // ==========================================================================
  void _showWorkerDetailsSheet(String workerId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: FutureBuilder<Map<String, dynamic>>(
            future: ref
                .read(subcontractorControllerProvider.notifier)
                .getSubcontractorWorkerDetails(workerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text("Error loading details: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red)));
              }

              final worker = snapshot.data!;
              final stats = worker['statistics'] ?? {};
              final String skillText = _getSkillText(worker);

              return SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              AppColors.primaryBlue.withOpacity(0.1),
                          child: Text(worker['name'][0].toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 24,
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(worker['name'],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: worker['isAvailable']
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  worker['isAvailable']
                                      ? 'Available'
                                      : 'Assigned',
                                  style: TextStyle(
                                      color: worker['isAvailable']
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text("Worker Details",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue)),
                    const Divider(),
                    _infoRow("Skill", skillText),
                    _infoRow("Phone", worker['phone'] ?? 'N/A'),
                    _infoRow("Wage Rate",
                        "${currencyFormat.format(worker['wageRate'] ?? 0)} / ${worker['wageType']}"),
                    _infoRow("Aadhar", worker['aadharNumber'] ?? 'N/A'),
                    const SizedBox(height: 24),
                    const Text("Attendance & Earnings (Lifetime)",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue)),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                            child: _statBox(
                                "Total Days",
                                "${stats['totalDays'] ?? 0}",
                                Icons.calendar_month)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _statBox(
                                "Present",
                                "${stats['presentDays'] ?? 0}",
                                Icons.check_circle_outline,
                                color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _statBox(
                                "Total Hours",
                                "${stats['totalHours'] ?? 0}h",
                                Icons.timer_outlined)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _statBox(
                                "Earnings",
                                currencyFormat
                                    .format(stats['totalEarnings'] ?? 0),
                                Icons.account_balance_wallet_outlined,
                                color: AppColors.primaryBlue)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, IconData icon,
      {Color color = Colors.black87}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // ==========================================================================
  // BUILD METHOD
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text("Manage Workers",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (val) {
                _searchQuery = val;
                // Debounce search ideally, but for now simple direct call is fine
                _fetchWorkers(refresh: true);
              },
              decoration: InputDecoration(
                hintText: 'Search by name, phone or skill...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workers.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => _fetchWorkers(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _workers.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _workers.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final worker = _workers[index];
                      final bool isAvailable = worker['isAvailable'] ?? true;
                      final bool isActive = worker['isActive'] ?? true;

                      // Using the new helper to get the skills String
                      final String skillText = _getSkillText(worker);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!)),
                        elevation: 0,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primaryBlue.withOpacity(0.1),
                            child: Text(worker['name'][0].toUpperCase(),
                                style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text(worker['name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("Skill: $skillText",
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(
                                  "Rate: ${currencyFormat.format(worker['wageRate'] ?? 0)}/${worker['wageType']}",
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 13)),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: !isActive
                                      ? Colors.red.withOpacity(0.1)
                                      : isAvailable
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  !isActive
                                      ? 'Inactive'
                                      : isAvailable
                                          ? 'Available'
                                          : 'Assigned',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: !isActive
                                        ? Colors.red
                                        : isAvailable
                                            ? Colors.green
                                            : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showWorkerDetailsSheet(worker['id']),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWorkerSheet,
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text("Add Worker",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No workers found",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54)),
          const SizedBox(height: 8),
          Text("Add your first worker to this contractor.",
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
