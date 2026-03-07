import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/screens/inventory/create_po_screen.dart';
import 'package:construction_erp/screens/inventory/create_grn_screen.dart';
import 'package:construction_erp/screens/inventory/purchase_order_details_screen.dart';
import 'package:construction_erp/controllers/inventory/procurement_controller.dart';
import 'package:construction_erp/models/procurement.dart';

class PurchaseOrderListScreen extends ConsumerStatefulWidget {
  const PurchaseOrderListScreen({super.key});

  @override
  ConsumerState<PurchaseOrderListScreen> createState() =>
      _PurchaseOrderListScreenState();
}

class _PurchaseOrderListScreenState
    extends ConsumerState<PurchaseOrderListScreen> {
  // State Variables
  String _selectedFilter = 'All';
  DateTime? _selectedDate;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Map UI filters to Backend Statuses
  final List<String> _filterOptions = [
    'All',
    'DRAFT',
    'PENDING_APPROVAL',
    'APPROVED',
    'ORDERED',
    'RECEIVED',
    'CLOSED'
  ];

  @override
  void initState() {
    super.initState();

    // Initial fetch
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D6EFD), // Blue Header
              onPrimary: Colors.white, // White text
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final procStateAsync = ref.watch(procurementControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Purchase Orders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _selectedDate = null);
              ref.read(procurementControllerProvider.notifier).refresh(
                  search: '',
                  status: _selectedFilter == 'All' ? null : _selectedFilter);
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          )
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) {
                ref
                    .read(procurementControllerProvider.notifier)
                    .refresh(search: value);
              },
              decoration: InputDecoration(
                hintText: "Search PO #, Title, Supplier...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(procurementControllerProvider.notifier)
                              .refresh(search: '');
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

          // Filter & Date Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Date Picker Button
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
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
                            _selectedDate == null
                                ? "MM/DD/YYYY"
                                : DateFormat('MM/dd/yyyy')
                                    .format(_selectedDate!),
                            style: TextStyle(
                              color: _selectedDate == null
                                  ? Colors.grey
                                  : const Color(0xFF0D6EFD),
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

                // Popup Menu Filter
                PopupMenuButton<String>(
                  initialValue: _selectedFilter,
                  onSelected: (String newValue) {
                    setState(() {
                      _selectedFilter = newValue;
                    });
                    // Trigger backend refresh with the status filter
                    ref.read(procurementControllerProvider.notifier).refresh(
                          status: newValue == 'All' ? null : newValue,
                        );
                  },
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (BuildContext context) =>
                      _filterOptions.map((String option) {
                    return _buildPopupMenuItem(option);
                  }).toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF0D6EFD)),
                      color: _selectedFilter != 'All'
                          ? const Color(0xFFE8F1FF)
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tune,
                            size: 18, color: Color(0xFF0D6EFD)),
                        const SizedBox(width: 8),
                        Text(
                          _selectedFilter == 'All'
                              ? "Filter"
                              : _formatStatus(_selectedFilter),
                          style: const TextStyle(
                            color: Color(0xFF0D6EFD),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // List Items
          Expanded(
            child: procStateAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text("Error: $err",
                    style: const TextStyle(color: Colors.red)),
              ),
              data: (procState) {
                // Apply local date filter if selected (since API doesn't handle exact date match easily in our current setup)
                List<PurchaseOrder> orders = procState.purchaseOrders;
                if (_selectedDate != null) {
                  orders = orders.where((o) {
                    return o.createdAt.year == _selectedDate!.year &&
                        o.createdAt.month == _selectedDate!.month &&
                        o.createdAt.day == _selectedDate!.day;
                  }).toList();
                }

                if (orders.isEmpty && !procState.isRefreshing) {
                  return const Center(
                      child: Text("No orders found",
                          style: TextStyle(color: Colors.grey)));
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(procurementControllerProvider.notifier)
                      .refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        orders.length + (procState.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == orders.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _buildOrderCard(orders[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePOScreen()),
          );
        },
        backgroundColor: const Color(0xFF0D6EFD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value) {
    bool isSelected = _selectedFilter == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatStatus(value),
            style: TextStyle(
              color: isSelected ? const Color(0xFF0D6EFD) : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected)
            const Icon(Icons.check, size: 18, color: Color(0xFF0D6EFD)),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    if (status == 'All') return status;
    return status
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Widget _buildOrderCard(PurchaseOrder order) {
    Color statusColor;
    bool showCreateGRN = false;

    switch (order.status) {
      case "DRAFT":
        statusColor = Colors.grey[700]!;
        break;
      case "PENDING_APPROVAL":
        statusColor = Colors.orange;
        break;
      case "APPROVED":
        statusColor = Colors.blue;
        break;
      case "ORDERED":
      case "PARTIALLY_RECEIVED":
        statusColor = Colors.purple;
        showCreateGRN =
            true; // Can receive goods if ordered or partially received
        break;
      case "RECEIVED":
      case "PAID":
      case "CLOSED":
        statusColor = const Color(0xFF00B48A); // Green
        break;
      case "CANCELLED":
      case "REJECTED":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.black;
    }

    final dateStr = DateFormat('dd MMM yyyy').format(order.createdAt);
    final totalFormatted =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
            .format(order.totalAmount);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseOrderDetailsScreen(poId: order.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  order.poNumber,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatStatus(order.status),
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(order.supplierName,
                        style:
                            TextStyle(color: Colors.grey[800], fontSize: 13)),
                  ],
                ),
                Text(totalFormatted,
                    style: const TextStyle(
                        color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold)),
              ],
            ),
            if (showCreateGRN) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to Create GRN screen, optionally passing the PO ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateGRNScreen(
                                  poId: order.id,
                                )), // Update to pass order.id if needed
                      );
                    },
                    icon: const Icon(Icons.inventory,
                        size: 14, color: Colors.white),
                    label: const Text("Create GRN",
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
