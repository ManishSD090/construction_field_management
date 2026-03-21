import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart'; // Replaced path_provider with file_picker
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:construction_erp/controllers/inventory/procurement_controller.dart';
import 'package:construction_erp/models/procurement.dart';
import 'package:construction_erp/screens/inventory/create_grn_screen.dart';
import 'package:construction_erp/screens/inventory/edit_po_screen.dart';

class PurchaseOrderDetailsScreen extends ConsumerStatefulWidget {
  final String poId;

  const PurchaseOrderDetailsScreen({super.key, required this.poId});

  @override
  ConsumerState<PurchaseOrderDetailsScreen> createState() =>
      _PurchaseOrderDetailsScreenState();
}

class _PurchaseOrderDetailsScreenState
    extends ConsumerState<PurchaseOrderDetailsScreen> {
  final currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  // --- REFRESH ACTION ---
  Future<void> _onRefresh() async {
    // Invalidate the provider to force a re-fetch
    ref.invalidate(poDetailsProvider(widget.poId));
    // Await the new future so the RefreshIndicator spins until data is loaded
    try {
      await ref.read(poDetailsProvider(widget.poId).future);
    } catch (_) {}
  }

  // --- ACTION DIALOGS ---

  void _showApprovePODialog(BuildContext context) {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Approve PO"),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            hintText: "Approval Notes (Optional)",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final notes = notesController.text.trim();
              ref.read(procurementControllerProvider.notifier).approvePO(
                  widget.poId,
                  notes: notes.isNotEmpty ? notes : null);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B48A)),
            child: const Text("Approve", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRejectPODialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reject PO"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: "Rejection Reason (Required)",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Reason is required"),
                      backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(ctx);
              ref.read(procurementControllerProvider.notifier).rejectPO(
                  widget.poId,
                  rejectionReason: reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel PO"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: "Cancellation Reason (Required)",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Back")),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Reason is required"),
                      backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(ctx);
              ref
                  .read(procurementControllerProvider.notifier)
                  .cancelPO(widget.poId, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text("Cancel PO", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePO(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Purchase Order"),
        content: const Text(
            "Are you sure you want to permanently delete this Purchase Order? This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(procurementControllerProvider.notifier)
                  .deletePurchaseOrder(widget.poId)
                  .then((_) {
                if (mounted) {
                  Navigator.pop(context); // Go back to the list screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Purchase Order deleted"),
                        backgroundColor: Colors.red),
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmMarkAsReceived(BuildContext context, String poId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Mark as Received"),
        content: const Text(
            "This will mark the PO as fully received bypassing the GRN process.\n\nNote: Inventory and budget expenses will NOT be automatically updated. Proceed?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(procurementControllerProvider.notifier)
                  .markAsReceived(poId, actualDelivery: DateTime.now());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- GRN ACTION DIALOGS ---

  void _showAcceptReceiptDialog(BuildContext context, GoodsReceipt receipt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Accept GRN"),
        content: Text(
            "Are you sure you want to accept all items in ${receipt.grNumber}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(procurementControllerProvider.notifier)
                    .acceptAllReceiptItems(receipt.id, widget.poId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("GRN Accepted Successfully"),
                      backgroundColor: Color(0xFF00B48A)));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Failed to accept GRN: $e"),
                      backgroundColor: Colors.red));
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B48A)),
            child: const Text("Accept", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRejectReceiptDialog(BuildContext context, GoodsReceipt receipt) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reject GRN"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Rejecting ${receipt.grNumber}. Please provide a reason:"),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: "Rejection Reason (Required)",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Reason is required"),
                      backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                await ref
                    .read(procurementControllerProvider.notifier)
                    .rejectAllReceiptItems(receipt.id, widget.poId,
                        rejectionReason: reasonController.text.trim());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("GRN Rejected"),
                      backgroundColor: Colors.orange));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Failed to reject GRN: $e"),
                      backgroundColor: Colors.red));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, GoodsReceipt receipt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Update Stock & Budget"),
        content: Text(
            "This will add the items from ${receipt.grNumber} to your project inventory and record the budget expense. Proceed?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(procurementControllerProvider.notifier)
                    .updateStockFromReceipt(receipt.id, widget.poId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Stock and Budget Updated Successfully!"),
                      backgroundColor: Color(0xFF0D6EFD)));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Failed to update stock: $e"),
                      backgroundColor: Colors.red));
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD)),
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- UI HELPERS ---

  Color _getStatusColor(String status) {
    switch (status) {
      case "DRAFT":
        return Colors.grey[700]!;
      case "PENDING_APPROVAL":
        return Colors.orange;
      case "APPROVED":
        return Colors.blue;
      case "ORDERED":
      case "PARTIALLY_RECEIVED":
        return Colors.purple;
      case "RECEIVED":
      case "PAID":
      case "CLOSED":
        return const Color(0xFF00B48A);
      case "CANCELLED":
      case "REJECTED":
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String _formatStatus(String status) {
    return status
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final poAsync = ref.watch(poDetailsProvider(widget.poId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("PO Details", style: TextStyle(color: Colors.white)),
        actions: poAsync.maybeWhen(
          data: (po) {
            final canEdit =
                po.status == 'DRAFT' || po.status == 'PENDING_APPROVAL';
            final canDelete = po.status == 'DRAFT';

            return [
              // PDF Preview Button
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                tooltip: 'Preview & Download PDF',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => POPDFPreviewScreen(
                        poId: po.id,
                        poNumber: po.poNumber,
                      ),
                    ),
                  );
                },
              ),
              if (canEdit)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: 'Edit PO',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPOScreen(po: po),
                        ));
                  },
                ),
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  tooltip: 'Delete PO',
                  onPressed: () => _confirmDeletePO(context),
                ),
            ];
          },
          orElse: () => [],
        ),
      ),
      body: poAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error: $err"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onRefresh,
                child: const Text("Retry"),
              )
            ],
          ),
        ),
        data: (po) {
          return Column(
            children: [
              Expanded(
                child: _buildOverviewTab(po),
              ),
              _buildBottomActionBar(po),
            ],
          );
        },
      ),
    );
  }

  // ==================== OVERVIEW CONTENT ====================

  Widget _buildOverviewTab(PurchaseOrder po) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF0D6EFD),
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh always works
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(po.poNumber,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF0D6EFD))),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(po.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatStatus(po.status),
                          style: TextStyle(
                              color: _getStatusColor(po.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(po.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.business, "Supplier", po.supplierName),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      Icons.construction, "Project", po.project?.name ?? "N/A"),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.calendar_today, "Order Date",
                      DateFormat('dd MMM yyyy').format(po.orderDate)),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.payment, "Payment Terms",
                      _formatStatus(po.paymentTerm)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // FINANCIAL SUMMARY
            const Text("Financial Summary",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildFinanceRow("Subtotal", po.subtotal),
                  const SizedBox(height: 4),
                  _buildFinanceRow("Tax (${po.taxRate ?? 0}%)", po.taxAmount),
                  if ((po.shippingCost ?? 0) > 0) ...[
                    const SizedBox(height: 4),
                    _buildFinanceRow("Shipping", po.shippingCost!),
                  ],
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Grand Total",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(currencyFormat.format(po.totalAmount),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF0D6EFD))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (po.paymentPercent ?? 0) / 100,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF00B48A),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Paid: ${currencyFormat.format(po.totalPaid ?? 0)}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      Text(
                          "Due: ${currencyFormat.format(po.totalDue ?? po.totalAmount)}",
                          style:
                              const TextStyle(fontSize: 12, color: Colors.red)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // LINE ITEMS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Line Items",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${po.items?.length ?? 0} items",
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            ...(po.items ?? []).map((item) => _buildLineItemCard(item)),

            // GOODS RECEIPTS (GRN) SECTION
            if (po.receipts != null && po.receipts!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Goods Receipts (GRN)",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("${po.receipts!.length} receipts",
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              ...po.receipts!.map((receipt) => _buildReceiptCard(receipt)),
            ]
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text("$label: ",
            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildFinanceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text(currencyFormat.format(amount),
            style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildLineItemCard(PurchaseOrderItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[200]!)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(item.description,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                Text(currencyFormat.format(item.totalPrice),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order Qty: ${item.quantity} ${item.unit}",
                    style: const TextStyle(fontSize: 12)),
                Text("@ ${currencyFormat.format(item.unitPrice)}/${item.unit}",
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Received: ${item.receivedQuantity} ${item.unit}",
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF00B48A))),
                Text("Pending: ${item.pendingQuantity} ${item.unit}",
                    style: TextStyle(
                        fontSize: 12,
                        color: item.pendingQuantity > 0
                            ? Colors.orange
                            : Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(GoodsReceipt receipt) {
    final bool showAcceptReject = receipt.inspectionStatus == 'PENDING';
    final bool showUpdateStock =
        receipt.inspectionStatus == 'PASSED' && !receipt.stockUpdated;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[200]!)),
      elevation: 0,
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(receipt.grNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD))),
                if (receipt.stockUpdated)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text("STOCK UPDATED",
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.bold)),
                  )
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                  "Date: ${DateFormat('dd MMM yyyy').format(receipt.receiptDate)}\nStatus: ${receipt.inspectionStatus}"),
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // GRN PDF Preview Button
                IconButton(
                  icon:
                      const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                  tooltip: 'Preview GRN PDF',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GRNPDFPreviewScreen(
                          receiptId: receipt.id,
                          grNumber: receipt.grNumber,
                        ),
                      ),
                    );
                  },
                ),
                Icon(
                  receipt.inspectionStatus == 'PASSED'
                      ? Icons.check_circle
                      : receipt.inspectionStatus == 'FAILED'
                          ? Icons.cancel
                          : Icons.pending,
                  color: receipt.inspectionStatus == 'PASSED'
                      ? const Color(0xFF00B48A)
                      : receipt.inspectionStatus == 'FAILED'
                          ? Colors.red
                          : Colors.orange,
                ),
              ],
            ),
          ),

          // Action Buttons for PENDING
          if (showAcceptReject || showUpdateStock) const Divider(height: 1),

          if (showAcceptReject)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showRejectReceiptDialog(context, receipt),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text("Reject",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _showAcceptReceiptDialog(context, receipt),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B48A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text("Accept GRN",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),

          // Action Button for PASSED but Stock NOT Updated
          if (showUpdateStock)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showUpdateStockDialog(context, receipt),
                    icon: const Icon(Icons.inventory,
                        size: 18, color: Colors.white),
                    label: const Text("Update Stock & Budget",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==================== BOTTOM ACTION BAR ====================

  Widget _buildBottomActionBar(PurchaseOrder po) {
    List<Widget> actions = [];

    if (po.status == 'DRAFT') {
      actions.add(_buildActionButton(
          "Submit for Approval", const Color(0xFF0D6EFD), () {
        ref
            .read(procurementControllerProvider.notifier)
            .submitPOForApproval(po.id);
      }));
    } else if (po.status == 'PENDING_APPROVAL') {
      // NEW: Added Approve and Reject Actions for PENDING_APPROVAL status
      actions.add(_buildActionButton(
          "Reject", Colors.red, () => _showRejectPODialog(context),
          isOutlined: true));
      actions.add(const SizedBox(width: 12));
      actions.add(_buildActionButton("Approve", const Color(0xFF00B48A), () {
        _showApprovePODialog(context);
      }));
    } else if (po.status == 'APPROVED') {
      actions.add(_buildActionButton(
          "Cancel PO", Colors.red, () => _showCancelDialog(context),
          isOutlined: true));
      actions.add(const SizedBox(width: 12));
      actions
          .add(_buildActionButton("Mark Ordered", const Color(0xFF0D6EFD), () {
        ref
            .read(procurementControllerProvider.notifier)
            .markAsOrdered(po.id, DateTime.now());
      }));
    } else if (po.status == 'ORDERED' || po.status == 'PARTIALLY_RECEIVED') {
      // Option to Bypass GRN entirely
      actions.add(_buildActionButton("Mark Received", Colors.orange,
          () => _confirmMarkAsReceived(context, po.id),
          isOutlined: true));
      actions.add(const SizedBox(width: 12));
      // Primary GRN Path
      actions.add(_buildActionButton("Create GRN", const Color(0xFF00B48A), () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateGRNScreen(
                      poId: po.id,
                    )));
      }));
    } else if (po.status == 'RECEIVED' || po.status == 'PARTIALLY_PAID') {
      // Only close PO option remains for these statuses
      actions.add(_buildActionButton("Close PO", Colors.grey[800]!, () {
        ref.read(procurementControllerProvider.notifier).closePO(po.id);
      }));
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: actions
              .map((w) => w is SizedBox ? w : Expanded(child: w))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed,
      {bool isOutlined = false}) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}

// ==========================================================================
// PO PDF PREVIEW & DOWNLOAD SCREEN
// ==========================================================================

class POPDFPreviewScreen extends ConsumerStatefulWidget {
  final String poId;
  final String poNumber;

  const POPDFPreviewScreen({
    super.key,
    required this.poId,
    required this.poNumber,
  });

  @override
  ConsumerState<POPDFPreviewScreen> createState() => _POPDFPreviewScreenState();
}

class _POPDFPreviewScreenState extends ConsumerState<POPDFPreviewScreen> {
  bool _isLoading = true;
  Uint8List? _pdfBytes;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPDF();
  }

  Future<void> _fetchPDF() async {
    try {
      // Fetch the base64 string using your preview function
      final base64String = await ref
          .read(procurementControllerProvider.notifier)
          .previewPurchaseOrderPDF(widget.poId);

      setState(() {
        _pdfBytes = base64Decode(base64String);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load PDF: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadPDF() async {
    if (_pdfBytes == null) return;

    try {
      // Prompt the user to choose where to save the file
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Purchase Order PDF',
        fileName: 'PO-${widget.poNumber}.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes:
            _pdfBytes, // FIX: This is strictly required for Android and iOS in file_picker
      );

      // User canceled the picker
      if (outputFile == null) {
        return;
      }

      // file_picker automatically writes the file on Android, iOS, and Web when bytes are provided.
      // On Desktop platforms, it only returns the path, so we manually write the bytes.
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final file = File(outputFile);
        await file.writeAsBytes(_pdfBytes!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("PDF saved successfully"),
          backgroundColor: Color(0xFF00B48A),
          duration: Duration(seconds: 4),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to save PDF: $e"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("PO-${widget.poNumber}",
            style: const TextStyle(color: Colors.white)),
        actions: [
          if (_pdfBytes != null)
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              tooltip: 'Download PDF',
              onPressed: _downloadPDF,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(_errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                  ),
                )
              : _pdfBytes != null
                  ? SfPdfViewer.memory(
                      _pdfBytes!,
                      canShowScrollHead: false,
                      canShowScrollStatus: false,
                    )
                  : const Center(child: Text("Could not load PDF")),
    );
  }
}

// ==========================================================================
// GRN PDF PREVIEW & DOWNLOAD SCREEN
// ==========================================================================

class GRNPDFPreviewScreen extends ConsumerStatefulWidget {
  final String receiptId;
  final String grNumber;

  const GRNPDFPreviewScreen({
    super.key,
    required this.receiptId,
    required this.grNumber,
  });

  @override
  ConsumerState<GRNPDFPreviewScreen> createState() =>
      _GRNPDFPreviewScreenState();
}

class _GRNPDFPreviewScreenState extends ConsumerState<GRNPDFPreviewScreen> {
  bool _isLoading = true;
  Uint8List? _pdfBytes;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPDF();
  }

  Future<void> _fetchPDF() async {
    try {
      // Fetch the base64 string using the GRN preview function
      final base64String = await ref
          .read(procurementControllerProvider.notifier)
          .previewGRNPDF(widget.receiptId);

      setState(() {
        _pdfBytes = base64Decode(base64String);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load PDF: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadPDF() async {
    if (_pdfBytes == null) return;

    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save GRN PDF',
        fileName: 'GRN-${widget.grNumber}.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: _pdfBytes,
      );

      if (outputFile == null) {
        return;
      }

      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final file = File(outputFile);
        await file.writeAsBytes(_pdfBytes!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("PDF saved successfully"),
          backgroundColor: Color(0xFF00B48A),
          duration: Duration(seconds: 4),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to save PDF: $e"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("GRN-${widget.grNumber}",
            style: const TextStyle(color: Colors.white)),
        actions: [
          if (_pdfBytes != null)
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              tooltip: 'Download PDF',
              onPressed: _downloadPDF,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(_errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                  ),
                )
              : _pdfBytes != null
                  ? SfPdfViewer.memory(
                      _pdfBytes!,
                      canShowScrollHead: false,
                      canShowScrollStatus: false,
                    )
                  : const Center(child: Text("Could not load PDF")),
    );
  }
}
