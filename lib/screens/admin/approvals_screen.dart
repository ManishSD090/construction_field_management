import 'package:construction_erp/screens/admin/budget_approval_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/screens/timeline/timeline_approval_details.dart';
import 'package:construction_erp/controllers/approval/approval_controller.dart';

class ApprovalsScreen extends ConsumerStatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  ConsumerState<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends ConsumerState<ApprovalsScreen> {
  int _selectedTab = 0; // 0 = Budget, 1 = Timeline

  bool _filterApproved = true;
  bool _filterRejected = true;

  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
                primary: AppColors.primaryBlue,
                onPrimary: Colors.white,
                onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingTimelinesAsync = ref.watch(pendingTimelinesProvider);
    final historyTimelinesAsync = ref.watch(historyTimelinesProvider);

    final pendingBudgetsAsync = ref.watch(pendingBudgetsProvider);
    final historyBudgetsAsync = ref.watch(historyBudgetsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Approvals",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(25)),
                  child: Row(
                    children: [
                      _buildTabButton("Budget", 0),
                      _buildTabButton("Timeline", 1),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300)),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      suffixIcon: Icon(Icons.mic, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _pickDate(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryBlue),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Text(
                                _selectedDate == null
                                    ? "MM/DD/YYYY"
                                    : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                                style: TextStyle(
                                    color: _selectedDate == null
                                        ? Colors.grey
                                        : AppColors.primaryBlue,
                                    fontSize: 13,
                                    fontWeight: _selectedDate == null
                                        ? FontWeight.normal
                                        : FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.calendar_month_outlined,
                                color: AppColors.primaryBlue, size: 18),
                          ],
                        ),
                      ),
                    ),
                    _buildFilterPopup(),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _selectedTab == 1
                  ? _buildCombinedTimelineView(
                      pendingTimelinesAsync, historyTimelinesAsync)
                  : _buildCombinedBudgetView(
                      pendingBudgetsAsync, historyBudgetsAsync),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(20)),
          alignment: Alignment.center,
          child: Text(text,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildFilterPopup() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            enabled: false,
            child: StatefulBuilder(
              builder: (context, setInnerState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                        title: const Text("Approved",
                            style: TextStyle(fontSize: 14)),
                        value: _filterApproved,
                        activeColor: AppColors.primaryBlue,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        visualDensity: VisualDensity.compact,
                        onChanged: (val) {
                          setInnerState(() => _filterApproved = val!);
                          setState(() {});
                        }),
                    CheckboxListTile(
                        title: const Text("Rejected",
                            style: TextStyle(fontSize: 14)),
                        value: _filterRejected,
                        activeColor: AppColors.primaryBlue,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        visualDensity: VisualDensity.compact,
                        onChanged: (val) {
                          setInnerState(() => _filterRejected = val!);
                          setState(() {});
                        }),
                    const SizedBox(height: 8),
                    SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue),
                            child: const Text("Apply filters",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11))))
                  ],
                );
              },
            ),
          ),
        ];
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(20)),
        child: const Row(children: [
          Text("Filter",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(width: 4),
          Icon(Icons.tune, size: 16)
        ]),
      ),
    );
  }

  // ==========================================
  // BUDGET UI
  // ==========================================

  Widget _buildCombinedBudgetView(
      AsyncValue<List<BudgetApprovalItem>> pendingAsync,
      AsyncValue<List<BudgetApprovalItem>> historyAsync) {
    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: () async {
        // Allow pull-to-refresh
        await Future.wait([
          ref.refresh(pendingBudgetsProvider.future),
          ref.refresh(historyBudgetsProvider.future),
        ]);
      },
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh works even if empty
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pending Approvals",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            pendingAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (items) {
                if (items.isEmpty) {
                  return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                          child: Text("No pending approvals",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic))));
                }
                return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        _buildRealBudgetCard(items[index], isPending: true));
              },
            ),
            const SizedBox(height: 32),
            const Text("Approval History",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (items) {
                final filteredItems = items.where((item) {
                  final statusStr = item.revision != null
                      ? (item.revision!.status?.toJson() ?? '').toUpperCase()
                      : item.budget.status.toJson().toUpperCase();

                  final isAppr = statusStr == 'APPROVED' ||
                      statusStr == 'ACTIVE' ||
                      statusStr == 'APPLIED';
                  final isRej = statusStr == 'REJECTED';

                  if (_filterApproved && isAppr) return true;
                  if (_filterRejected && isRej) return true;
                  return false;
                }).toList();

                if (filteredItems.isEmpty) {
                  return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                          child: Text("No history found",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic))));
                }
                return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) => _buildRealBudgetCard(
                        filteredItems[index],
                        isPending: false));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealBudgetCard(BudgetApprovalItem item,
      {required bool isPending}) {
    final bool isRevision = item.revision != null;
    final String statusStr = isRevision
        ? (item.revision!.status?.toJson() ?? '').toUpperCase()
        : item.budget.status.toJson().toUpperCase();

    final bool isApproved = statusStr == 'APPROVED' ||
        statusStr == 'ACTIVE' ||
        statusStr == 'APPLIED';
    final bool isRejected = statusStr == 'REJECTED';

    final String displayName =
        isRevision ? "REV: ${item.budget.name}" : item.budget.name;
    final String labelText = isRevision ? "Budget Revision" : "Base Budget";
    final String managerName = item.budget.createdBy?.name ?? 'System';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(displayName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                      overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 10),
              if (isPending)
                SizedBox(
                    height: 28,
                    child: ElevatedButton(
                        onPressed: () async {
                          // ✅ WAIT FOR SCREEN TO POP, THEN REFRESH!
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BudgetApprovalDetailsScreen(
                                          approvalItem: item)));
                          ref.invalidate(pendingBudgetsProvider);
                          ref.invalidate(historyBudgetsProvider);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D6EFD),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            elevation: 0),
                        child: const Text("View",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))))
              else if (isApproved || isRejected)
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: isApproved
                            ? const Color(0xFF009688)
                            : const Color(0xFFEF5350),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(isApproved ? 'Approved' : 'Rejected',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)))
            ],
          ),
          const SizedBox(height: 8),
          Text("Manager: $managerName",
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(labelText,
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryBlue.withOpacity(0.8))),
              Text("Sent: ${DateFormat('dd MMM yyyy').format(item.date)}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TIMELINE UI
  // ==========================================

  Widget _buildCombinedTimelineView(
      AsyncValue<List<TimelineApprovalItem>> pendingAsync,
      AsyncValue<List<TimelineApprovalItem>> historyAsync) {
    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: () async {
        // Allow pull-to-refresh
        await Future.wait([
          ref.refresh(pendingTimelinesProvider.future),
          ref.refresh(historyTimelinesProvider.future),
        ]);
      },
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh works
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pending Approvals",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            pendingAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (items) {
                if (items.isEmpty) {
                  return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                          child: Text("No pending approvals",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic))));
                }
                return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        _buildRealTimelineCard(items[index], isPending: true));
              },
            ),
            const SizedBox(height: 32),
            const Text("Approval History",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (items) {
                final filteredItems = items.where((item) {
                  final statusStr = item.version != null
                      ? item.version!.status.toJson().toUpperCase()
                      : item.timeline.status.toJson().toUpperCase();

                  final isAppr =
                      statusStr == 'APPROVED' || statusStr == 'ACTIVE';
                  final isRej = !isAppr;

                  if (_filterApproved && isAppr) return true;
                  if (_filterRejected && isRej) return true;
                  return false;
                }).toList();

                if (filteredItems.isEmpty) {
                  return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                          child: Text("No history found",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic))));
                }
                return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) => _buildRealTimelineCard(
                        filteredItems[index],
                        isPending: false));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimelineCard(TimelineApprovalItem item,
      {required bool isPending}) {
    final bool isVersion = item.version != null;
    final String statusStr = isVersion
        ? item.version!.status.toJson().toUpperCase()
        : item.timeline.status.toJson().toUpperCase();

    final bool isApproved = statusStr == 'APPROVED' || statusStr == 'ACTIVE';

    final String displayName = isVersion
        ? "V${item.version!.versionNumber} - ${item.version!.name}"
        : item.timeline.name;
    final String labelText =
        isVersion ? "Timeline: ${item.timeline.name}" : "Base Timeline";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(displayName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                      overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 10),
              if (isPending)
                SizedBox(
                    height: 28,
                    child: ElevatedButton(
                        onPressed: () async {
                          // ✅ WAIT FOR SCREEN TO POP, THEN REFRESH!
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TimelineApprovalDetailsScreen(
                                          approvalItem: item)));
                          ref.invalidate(pendingTimelinesProvider);
                          ref.invalidate(historyTimelinesProvider);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D6EFD),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            elevation: 0),
                        child: const Text("View",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))))
              else
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: isApproved
                            ? const Color(0xFF009688)
                            : const Color(0xFFEF5350),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(isApproved ? 'Approved' : 'Rejected',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)))
            ],
          ),
          const SizedBox(height: 8),
          Text("Manager: ${item.timeline.createdBy?.name ?? 'System'}",
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(labelText,
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue.withOpacity(0.8)),
                      overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 10),
              Text("Sent: ${DateFormat('dd MMM yyyy').format(item.date)}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
