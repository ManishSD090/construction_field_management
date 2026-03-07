import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/controllers/inventory/procurement_controller.dart';
import 'package:construction_erp/models/procurement.dart'; // Unified procurement models

class MaterialRequestHistoryScreen extends ConsumerStatefulWidget {
  const MaterialRequestHistoryScreen({super.key});

  @override
  ConsumerState<MaterialRequestHistoryScreen> createState() =>
      _MaterialRequestHistoryScreenState();
}

class _MaterialRequestHistoryScreenState
    extends ConsumerState<MaterialRequestHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    // Initial fetch (refresh without overriding existing data filters if any)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(procurementControllerProvider.notifier).refresh();
    });

    // Pagination listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final procState = ref.read(procurementControllerProvider).value;
        if (procState != null &&
            procState.hasMore &&
            !procState.isLoadingMore) {
          ref.read(procurementControllerProvider.notifier).loadNextPage();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final procStateAsync = ref.watch(procurementControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Material Requests",
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _selectedDate = null);
              ref.read(procurementControllerProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          )
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) {
                ref
                    .read(procurementControllerProvider.notifier)
                    .refresh(search: value);
              },
              decoration: InputDecoration(
                hintText: "Search Req #, Material, or Purpose",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(procurementControllerProvider.notifier)
                              .refresh();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. Date Picker & Filter Row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
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
                      if (pickedDate != null) {
                        setState(() => _selectedDate = pickedDate);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF0D6EFD)),
                        borderRadius: BorderRadius.circular(8),
                        color: _selectedDate != null
                            ? const Color(0xFFF0F7FF)
                            : Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate != null
                                ? DateFormat('dd MMM yyyy')
                                    .format(_selectedDate!)
                                : "Filter by Date",
                            style: TextStyle(
                              color: _selectedDate != null
                                  ? const Color(0xFF0D6EFD)
                                  : Colors.grey,
                              fontWeight: _selectedDate != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (_selectedDate != null)
                            GestureDetector(
                              onTap: () => setState(() => _selectedDate = null),
                              child: const Icon(Icons.close,
                                  color: Color(0xFF0D6EFD), size: 18),
                            )
                          else
                            const Icon(Icons.calendar_today,
                                color: Color(0xFF0D6EFD), size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Open advanced filters (e.g., status, urgency)
                  },
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text("Filter"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. History List
          Expanded(
            child: procStateAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text("Error: $err",
                    style: const TextStyle(color: Colors.red)),
              ),
              data: (procState) {
                // Apply local date filter to the managed state
                List<MaterialRequest> requests = procState.materialRequests;
                if (_selectedDate != null) {
                  requests = requests.where((r) {
                    return r.createdAt.year == _selectedDate!.year &&
                        r.createdAt.month == _selectedDate!.month &&
                        r.createdAt.day == _selectedDate!.day;
                  }).toList();
                }

                if (requests.isEmpty && !procState.isRefreshing) {
                  return const Center(
                    child: Text(
                      "No Material Requests found.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(procurementControllerProvider.notifier)
                      .refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        requests.length + (procState.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == requests.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _buildRequestCard(requests[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(MaterialRequest request) {
    final dateStr =
        DateFormat('dd MMM yyyy, hh:mm a').format(request.createdAt);

    // Smooth quantity formatting
    final qtyStr =
        request.quantity.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    final unit = request.unit.isNotEmpty ? request.unit : "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
          // Header: Item Name and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  request.materialName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Visual Info Box (Project & Purpose)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.construction, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        request.project?.name ?? "Unknown Project",
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Urgency Badge
                    if (request.urgency != 'MEDIUM')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: request.urgency == 'CRITICAL' ||
                                  request.urgency == 'HIGH'
                              ? Colors.red.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          request.urgency,
                          style: TextStyle(
                            color: request.urgency == 'CRITICAL' ||
                                    request.urgency == 'HIGH'
                                ? Colors.red
                                : Colors.grey[700],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        request.purpose,
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Footer: Request No and Quantity/Status Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Req #: ${request.requestNo}",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Qty: ',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      children: [
                        TextSpan(
                          text: '$qtyStr $unit',
                          style: const TextStyle(
                            color: Color(0xFF0D6EFD),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.status,
                      style: TextStyle(
                        color: _getStatusColor(request.status),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return const Color(0xFF00B48A); // Green
      case 'DELIVERED':
        return const Color(0xFF0D6EFD); // Blue
      case 'ORDERED':
        return Colors.purple;
      case 'REJECTED':
      case 'CANCELLED':
        return Colors.red;
      case 'REQUESTED':
      default:
        return Colors.orange;
    }
  }
}
