import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:construction_erp/controllers/inventory/procurement_controller.dart';
import 'package:construction_erp/models/procurement.dart';
import 'package:construction_erp/screens/inventory/create_grn_screen.dart';
import 'package:construction_erp/screens/inventory/edit_po_screen.dart'; // To be implemented

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

  // --- ACTION DIALOGS ---

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
        error: (err, stack) => Center(child: Text("Error: $err")),
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
    return SingleChildScrollView(
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
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("${po.items?.length ?? 0} items",
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          ...(po.items ?? []).map((item) => _buildLineItemCard(item)),
        ],
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
      actions
          .add(_buildActionButton("Receive Goods", const Color(0xFF00B48A), () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateGRNScreen(
                      poId: po.id,
                    ))); // You can pass po.id to GRN screen here later
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
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
