import 'package:construction_erp/screens/inventory/material_request_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Ensure this exists
import 'package:construction_erp/screens/inventory/inventory_history_screen.dart'; // Adjust path
import 'package:construction_erp/screens/inventory/item_details_screen.dart'; // Adjust path
import 'package:construction_erp/screens/projects/add_material_to_project.dart';
import 'package:construction_erp/screens/projects/assign_equipment_to_project.dart';

import 'package:construction_erp/controllers/inventory/inventory_controller.dart'; // Adjust path as needed

class ProjectInventoryScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectInventoryScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectInventoryScreen> createState() =>
      _ProjectInventoryScreenState();
}

class _ProjectInventoryScreenState
    extends ConsumerState<ProjectInventoryScreen> {
  bool isMaterialSelected = true;
  final TextEditingController _searchController = TextEditingController();
  final currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(inventoryControllerProvider.notifier)
          .switchToProjectView(widget.projectId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryStateAsync = ref.watch(inventoryControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Project Inventory",
            style: TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.access_time, color: Colors.white),
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onSelected: (value) {
              if (value == 'transfer') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InventoryHistoryScreen(),
                  ),
                );
              } else if (value == 'request') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MaterialRequestHistoryScreen(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'transfer',
                child: Text('Transfer History'),
              ),
              const PopupMenuItem<String>(
                value: 'request',
                child: Text('Request History'),
              ),
            ],
          ),
        ],
      ),
      body: inventoryStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text("Error loading inventory:\n$error",
                  textAlign: TextAlign.center),
              TextButton(
                onPressed: () =>
                    ref.read(inventoryControllerProvider.notifier).refresh(),
                child: const Text("Retry"),
              )
            ],
          ),
        ),
        data: (state) {
          final summary = state.summary;
          final materialsCount =
              summary['materialCount'] ?? state.inventoryItems.length;
          final equipmentCount =
              summary['equipmentCount'] ?? state.equipmentList.length;
          final materialsValue = summary['totalMaterialValue'] ?? 0;
          final equipmentValue = summary['totalEquipmentValue'] ?? 0;

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(inventoryControllerProvider.notifier).refresh();
            },
            child: Column(
              children: [
                // 1. Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) {
                      ref
                          .read(inventoryControllerProvider.notifier)
                          .refresh(search: value);
                    },
                    decoration: InputDecoration(
                      hintText: "Search Name",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(inventoryControllerProvider.notifier)
                              .refresh(search: '');
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // 2. Custom Toggle
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

                // 3. Stats Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${isMaterialSelected ? materialsCount : equipmentCount} Total On-Site",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D6EFD)),
                        ),
                        Text(
                          "${currencyFormat.format(isMaterialSelected ? materialsValue : equipmentValue)} Site Value",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D6EFD)),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. List Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        isMaterialSelected
                            ? "Project Materials"
                            : "Project Equipments",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.tune, size: 18),
                        label: const Text("Filter"),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(indent: 16, endIndent: 16),

                // 5. Grid List
                Expanded(
                  child: isMaterialSelected
                      ? _buildMaterialsGrid(state.inventoryItems)
                      : _buildEquipmentGrid(state.equipmentList),
                ),
              ],
            ),
          );
        },
      ),
      // FAB LOGIC UPDATED FOR PROJECT CONTEXT
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isMaterialSelected) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AddMaterialToProjectScreen(projectId: widget.projectId)),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AssignEquipmentToProjectScreen(
                      projectId: widget.projectId)),
            );
          }
        },
        backgroundColor: const Color(0xFF0D6EFD),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isMaterialSelected ? "Add Material" : "Assign Equipment",
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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

  Widget _buildMaterialsGrid(List inventoryItems) {
    if (inventoryItems.isEmpty) {
      return const Center(child: Text("No materials on site."));
    }
    return GridView.builder(
      // Added padding below to ensure FAB doesn't block the last elements
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 16.0, bottom: 88.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio:
            0.95, // Increased from 0.85 to make the card shorter and fit the content better
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: inventoryItems.length,
      itemBuilder: (context, index) {
        final item = inventoryItems[index];

        final materialName = item.material?.name ?? "Unknown Material";
        final materialCode = item.material?.materialCode ?? "N/A";
        final unit = item.material?.unit ?? "";
        final minStock = item.material?.minimumStock ?? 10.0;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailsScreen(
                  isMaterial: true,
                  isGlobalContext: false,
                  projectId: widget.projectId,
                  itemId: item.material?.id ?? "",
                  itemName: materialName,
                  totalQty: item.quantityTotal,
                  usedQty: item.quantityUsed,
                  availableQty: item.quantityAvailable,
                ),
              ),
            );
          },
          child: Container(
            // Tightly reduced the bottom padding to remove extra space below the quantities
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(materialName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    if (item.quantityAvailable < minStock)
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Icon(Icons.warning_amber_rounded,
                            color: Colors.red, size: 22),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  materialCode,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                _buildQuantityRow("Received:", "${item.quantityTotal} $unit"),
                const SizedBox(height: 4),
                _buildQuantityRow("Consumed:", "${item.quantityUsed} $unit"),
                const SizedBox(height: 4),
                _buildQuantityRow(
                    "Available:", "${item.quantityAvailable} $unit"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantityRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13),
        children: [
          TextSpan(
              text: "$label ", style: TextStyle(color: Colors.grey.shade600)),
          TextSpan(
              text: value,
              style: const TextStyle(
                  color: Color(0xFF0D6EFD), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEquipmentGrid(List equipmentList) {
    if (equipmentList.isEmpty) {
      return const Center(child: Text("No equipment on this site."));
    }
    return GridView.builder(
      // Added bottom padding (88.0) to ensure the FAB does not cover the last row of items
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 16.0, bottom: 88.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio:
            1.15, // Decreased from 1.55 to give more vertical height
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: equipmentList.length,
      itemBuilder: (context, index) {
        final equip = equipmentList[index];

        // Safely extract and format strings (e.g., IN_USE -> In use)
        final rawOwnership = equip.ownershipType.toString().split('.').last;
        final rawStatus = equip.status.toString().split('.').last;

        final ownershipStr = rawOwnership.isNotEmpty
            ? rawOwnership[0].toUpperCase() +
                rawOwnership.substring(1).toLowerCase()
            : '';

        final formattedStatus = rawStatus.isNotEmpty
            ? rawStatus.replaceAll('_', ' ').toLowerCase()
            : '';
        final statusStr = formattedStatus.isNotEmpty
            ? formattedStatus[0].toUpperCase() + formattedStatus.substring(1)
            : '';

        // Determine badge color based on status
        Color statusColor =
            const Color(0xFF0D6EFD); // Default Blue for 'In use'
        if (rawStatus.toUpperCase() == 'AVAILABLE') {
          statusColor = const Color(0xFF00C4B4); // Teal/Green for Available
        } else if (rawStatus.toUpperCase() == 'MAINTENANCE' ||
            rawStatus.toUpperCase() == 'BROKEN') {
          statusColor = Colors.orange;
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailsScreen(
                  isGlobalContext: true,
                  isMaterial: false,
                  itemId: equip.id ?? "",
                  itemName: equip.name,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Ensures elements are spaced perfectly
              children: [
                Expanded(
                  // Expanded ensures the text takes remaining height without overflowing bounds
                  child: Text(
                    equip.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        equip.code ?? equip.type,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusStr,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  ownershipStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0D6EFD), // Blue text for ownership
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
