import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/controllers/inventory/inventory_controller.dart';
import 'package:construction_erp/models/inventory.dart'; // Make sure the models are imported

class InventoryHistoryScreen extends ConsumerStatefulWidget {
  const InventoryHistoryScreen({super.key});

  @override
  ConsumerState<InventoryHistoryScreen> createState() =>
      _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState
    extends ConsumerState<InventoryHistoryScreen> {
  bool isMaterialSelected = false; // Matches Equipment tab by default

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  DateTime? _selectedDate;

  // Pagination and State
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;

  // Strongly typed list of Transfer objects
  final List<InventoryTransfer> _transfers = [];

  @override
  void initState() {
    super.initState();

    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTransfers(isRefresh: true);
    });

    // Pagination listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchTransfers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransfers({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _page = 1;
        _hasMore = true;
        _transfers.clear();
      });
    }

    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final res =
          await ref.read(inventoryControllerProvider.notifier).getTransfers(
                page: _page,
                limit: 20,
                search: _searchController.text.trim().isNotEmpty
                    ? _searchController.text.trim()
                    : null,
              );

      List<InventoryTransfer> newTransfers = [];
      Map<dynamic, dynamic> pagination = {};

      // Safely handle both mapped objects and raw JSON based on what the controller returns
      final rawData = res['data'] ?? res['transfers'] ?? [];
      pagination = res['pagination'] ?? {};

      if (rawData is List) {
        for (var item in rawData) {
          if (item is InventoryTransfer) {
            newTransfers.add(item); // Already parsed by controller
          } else if (item is Map<String, dynamic>) {
            newTransfers
                .add(InventoryTransfer.fromJson(item)); // Needs parsing
          }
        }
      }
    
      if (mounted) {
        setState(() {
          _transfers.addAll(newTransfers);
          _page++;
          _hasMore = _page <= (pagination['totalPages'] ?? 1);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading transfers: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // Flattens the transfers into individual items based on the active tab (Material/Equipment)
  List<Map<String, dynamic>> _getFlattenedItems() {
    List<Map<String, dynamic>> allItems = [];

    for (InventoryTransfer transfer in _transfers) {
      final List<InventoryTransferItem> items = transfer.items ?? [];

      for (InventoryTransferItem item in items) {
        final isMat = item.itemType == 'MATERIAL';

        // Filter by tab type
        if ((isMaterialSelected && isMat) || (!isMaterialSelected && !isMat)) {
          allItems.add({
            'transfer': transfer,
            'item': item,
          });
        }
      }
    }

    // Apply local date filter if selected
    if (_selectedDate != null) {
      allItems = allItems.where((entry) {
        final InventoryTransfer t = entry['transfer'];
        final DateTime d = t.transferDate;

        return d.year == _selectedDate!.year &&
            d.month == _selectedDate!.month &&
            d.day == _selectedDate!.day;
      }).toList();
    }

    return allItems;
  }

  @override
  Widget build(BuildContext context) {
    final flattenedItems = _getFlattenedItems();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Inventory History",
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => _fetchTransfers(isRefresh: true),
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
              onSubmitted: (value) => _fetchTransfers(isRefresh: true),
              decoration: InputDecoration(
                hintText: "Search Trf # or Description",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _fetchTransfers(isRefresh: true);
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

          // 2. Custom Toggle (Materials / Equipments)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildToggleButton("Materials", isMaterialSelected, () {
                  setState(() => isMaterialSelected = true);
                }),
                _buildToggleButton("Equipments", !isMaterialSelected, () {
                  setState(() => isMaterialSelected = false);
                }),
              ],
            ),
          ),

          // 3. Date Picker & Filter Row
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                              )),
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
                    // Advanced filter options can go here
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

          // 4. History List
          Expanded(
            child: _isLoading && _page == 1
                ? const Center(child: CircularProgressIndicator())
                : flattenedItems.isEmpty
                    ? Center(
                        child: Text(
                          "No ${isMaterialSelected ? 'Material' : 'Equipment'} transfers found.",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _fetchTransfers(isRefresh: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: flattenedItems.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == flattenedItems.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            return _buildHistoryCard(flattenedItems[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D6EFD) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data) {
    final InventoryTransfer transfer = data['transfer'];
    final InventoryTransferItem item = data['item'];

    // Resolve Names
    final itemName = isMaterialSelected
        ? (item.material?.name ?? "Unknown Material")
        : (item.equipment?.name ?? "Unknown Equipment");

    // Resolve Locations
    final fromLocStr = transfer.fromLocation.toString().toUpperCase();
    final toLocStr = transfer.toLocation.toString().toUpperCase();

    final isFromProject = fromLocStr.contains('PROJECT');
    final isToProject = toLocStr.contains('PROJECT');

    final fromStr = isFromProject
        ? (transfer.fromProject?.name ?? "Unknown Project")
        : "Global Warehouse";

    final toStr = isToProject
        ? (transfer.toProject?.name ?? "Unknown Project")
        : "Global Warehouse";

    // Format fields
    final status = transfer.status.toString().split('.').last;
    final trfNo = transfer.transferNo;
    final dateStr =
        DateFormat('dd MMM yyyy, hh:mm a').format(transfer.transferDate);

    // Formatting quantity smoothly without trailing zeros
    final rawQty = item.quantity;
    final qty = rawQty != null
        ? rawQty.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')
        : "1";
    final unit = isMaterialSelected ? (item.material?.unit ?? "") : "";

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
                  itemName,
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

          // Visual Transfer Path Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(isFromProject ? Icons.construction : Icons.inventory_2,
                    size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(fromStr,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.arrow_forward,
                      size: 16, color: Color(0xFF0D6EFD)),
                ),
                Icon(isToProject ? Icons.construction : Icons.inventory_2,
                    size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(toStr,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Footer: Transfer No and Quantity/Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trf #: $trfNo",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              if (isMaterialSelected)
                RichText(
                  text: TextSpan(
                    text: 'Qty: ',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    children: [
                      TextSpan(
                        text: '$qty $unit',
                        style: const TextStyle(
                            color: Color(0xFF0D6EFD),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'COMPLETED'
                        ? const Color(0xFFE8F1FF)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status == 'COMPLETED' ? "Assigned" : status,
                    style: TextStyle(
                        color: status == 'COMPLETED'
                            ? const Color(0xFF0D6EFD)
                            : Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }
}
