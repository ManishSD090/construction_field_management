// import 'package:flutter/material.dart';
// import 'package:construction_erp/core/services/app_colors.dart';

// class BudgetApprovalDetailsScreen extends StatefulWidget {
//   final Map<String, dynamic> approvalData;

//   const BudgetApprovalDetailsScreen({super.key, required this.approvalData});

//   @override
//   State<BudgetApprovalDetailsScreen> createState() =>
//       _BudgetApprovalDetailsScreenState();
// }

// class _BudgetApprovalDetailsScreenState
//     extends State<BudgetApprovalDetailsScreen> {
//   final TextEditingController _remarksController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   // Dummy Particulars Data matching the visual list
//   final List<Map<String, String>> _particulars = List.generate(
//     6,
//     (index) => {
//       "sr": "${index + 1}".padLeft(2, '0'),
//       "name": "Particular 1",
//       "qty": "Number",
//       "amt": "Amount",
//     },
//   );

//   @override
//   void dispose() {
//     _remarksController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50], // Light background
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryBlue,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Budget Approvals",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 )
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // --- HEADER SECTION ---
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.approvalData['project'] ?? "Project Name",
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             widget.approvalData['location'] ?? "Location",
//                             style: const TextStyle(
//                                 fontSize: 12, color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         const SizedBox(height: 30),
//                         Text(
//                           "Sent: ${widget.approvalData['sent'] ?? '13 Oct 2026'}",
//                           style:
//                               const TextStyle(fontSize: 10, color: Colors.grey),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           "Received: ${widget.approvalData['received'] ?? '12 JAN 2026'}",
//                           style:
//                               const TextStyle(fontSize: 10, color: Colors.grey),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),

//                 const SizedBox(height: 0),
//                 Text(
//                   widget.approvalData['manager'] ?? "Manager Name",
//                   style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87),
//                 ),

//                 const SizedBox(height: 20),

//                 // --- TABLE HEADER ---
//                 const Row(
//                   children: [
//                     SizedBox(
//                         width: 50,
//                         child: Text("Sr. No.",
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 13))),
//                     Expanded(
//                         flex: 4,
//                         child: Text("Particulars",
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 13))),
//                     Expanded(
//                         flex: 2,
//                         child: Text("Quantity",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 13))),
//                     Expanded(
//                         flex: 2,
//                         child: Text("Amount",
//                             textAlign: TextAlign.right,
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 13))),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 const Divider(thickness: 1, color: Colors.grey),
//                 const SizedBox(height: 8),

//                 // --- TABLE LIST ---
//                 ListView.separated(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: _particulars.length,
//                   separatorBuilder: (c, i) => const SizedBox(height: 16),
//                   itemBuilder: (context, index) {
//                     final item = _particulars[index];
//                     return Row(
//                       children: [
//                         SizedBox(
//                             width: 50,
//                             child: Text(item['sr']!,
//                                 style: const TextStyle(
//                                     fontSize: 13, color: Colors.black87))),
//                         Expanded(
//                             flex: 4,
//                             child: Text(item['name']!,
//                                 style: const TextStyle(
//                                     fontSize: 13, color: Colors.black87))),
//                         Expanded(
//                             flex: 2,
//                             child: Text(item['qty']!,
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                     fontSize: 13, color: Colors.black87))),
//                         Expanded(
//                             flex: 2,
//                             child: Text(item['amt']!,
//                                 textAlign: TextAlign.right,
//                                 style: const TextStyle(
//                                     fontSize: 13, color: Colors.black87))),
//                       ],
//                     );
//                   },
//                 ),

//                 const SizedBox(
//                     height: 100), // Spacing to push bottom section down

//                 // --- REMARKS SECTION ---
//                 const Text("Remarks",
//                     style:
//                         TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                   controller: _remarksController,
//                   maxLines: 1,
//                   style: const TextStyle(fontSize: 14),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Please enter remarks';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     hintText: "Approval/Reject Remarks",
//                     hintStyle: const TextStyle(color: Colors.grey),
//                     contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 14),
//                     // Border Styles
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: const BorderSide(
//                           color: Color(0xFF0D6EFD), width: 1.5),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: const BorderSide(color: Colors.red),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // --- ACTION BUTTONS ---
//                 Row(
//                   children: [
//                     Expanded(
//                       child: SizedBox(
//                         height: 45,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             if (_formKey.currentState!.validate()) {
//                               Navigator.pop(context);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content: Text("Budget Approved")),
//                               );
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF4CAF50), // Green
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                             elevation: 0,
//                           ),
//                           child: const Text("Approve",
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16)),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: SizedBox(
//                         height: 45,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             if (_formKey.currentState!.validate()) {
//                               Navigator.pop(context);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content: Text("Budget Rejected"),
//                                     backgroundColor: Colors.red),
//                               );
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFFEF5350), // Red
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                             elevation: 0,
//                           ),
//                           child: const Text("Reject",
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16)),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';

class BudgetApprovalDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> approvalData;

  const BudgetApprovalDetailsScreen({super.key, required this.approvalData});

  @override
  State<BudgetApprovalDetailsScreen> createState() =>
      _BudgetApprovalDetailsScreenState();
}

class _BudgetApprovalDetailsScreenState
    extends State<BudgetApprovalDetailsScreen> {
  final TextEditingController _remarksController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> _particulars = List.generate(
    6,
    (index) => {
      "sr": "${index + 1}".padLeft(2, '0'),
      "name": "Particular 1",
      "qty": "Number",
      "amt": "Amount",
    },
  );

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  // ✅ Custom Popup Function
  void _showStatusDialog({required bool isApproved}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isApproved ? "Budget Approved" : "Budget Rejected",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? const Color(0xFF009688) // Green for Approved
                        : const Color(0xFFEF5350), // Red for Rejected
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                      isApproved ? Icons.check : Icons.close, // Check or Cross
                      color: Colors.white,
                      size: 30),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Close dialog and screen after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close Dialog
        Navigator.pop(context); // Go back to list
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Budget Approvals",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.approvalData['project'] ?? "Project Name",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.approvalData['location'] ?? "Location",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Sent: ${widget.approvalData['sent'] ?? '13 Oct 2026'}",
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Received: ${widget.approvalData['received'] ?? '12 JAN 2026'}",
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 10),
                Text(
                  widget.approvalData['manager'] ?? "Manager Name",
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),

                const SizedBox(height: 20),

                // Table Header
                const Row(
                  children: [
                    SizedBox(
                        width: 50,
                        child: Text("Sr. No.",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(
                        flex: 4,
                        child: Text("Particulars",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(
                        flex: 2,
                        child: Text("Quantity",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(
                        flex: 2,
                        child: Text("Amount",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13))),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(thickness: 1, color: Colors.grey),
                const SizedBox(height: 8),

                // Table List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _particulars.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = _particulars[index];
                    return Row(
                      children: [
                        SizedBox(
                            width: 50,
                            child: Text(item['sr']!,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black87))),
                        Expanded(
                            flex: 4,
                            child: Text(item['name']!,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black87))),
                        Expanded(
                            flex: 2,
                            child: Text(item['qty']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black87))),
                        Expanded(
                            flex: 2,
                            child: Text(item['amt']!,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black87))),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 100),

                // Remarks
                const Text("Remarks",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _remarksController,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 14),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter remarks';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Approval/Reject Remarks",
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0D6EFD))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0D6EFD))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFF0D6EFD), width: 1.5)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red)),
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _showStatusDialog(
                                  isApproved: true); // Show Approved Popup
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Text("Approve",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _showStatusDialog(
                                  isApproved: false); // Show Rejected Popup
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF5350),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Text("Reject",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
