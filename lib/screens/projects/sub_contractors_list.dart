// import 'package:flutter/material.dart';
// import 'package:construction_erp/core/services/app_colors.dart';
// // ✅ Import the Details Screen
// import 'package:construction_erp/screens/projects/sub_contractor_details.dart';

// class SubContractorsList extends StatefulWidget {
//   const SubContractorsList({super.key});

//   @override
//   State<SubContractorsList> createState() => _SubContractorsListState();
// }

// class _SubContractorsListState extends State<SubContractorsList> {
//   // Dummy Data for the list
//   final List<Map<String, dynamic>> _subContractors = [
//     {
//       "name": "Sample Name",
//       "workType": "Electrician",
//       "project": "Sample Project Name 1",
//       "status": "Completed"
//     },
//     {
//       "name": "Sample Name",
//       "workType": "Plumbing",
//       "project": "Sample Project Name 2",
//       "status": "Ongoing"
//     },
//     {
//       "name": "Sample Name",
//       "workType": "Plumbing",
//       "project": "Sample Project Name 2",
//       "status": "Pending"
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // --- 1. Search Bar ---
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: const TextField(
//             decoration: InputDecoration(
//               icon: Icon(Icons.search, color: Colors.grey),
//               hintText: "Search People",
//               hintStyle: TextStyle(color: Colors.grey),
//               border: InputBorder.none,
//               suffixIcon: Icon(Icons.mic, color: Colors.grey),
//             ),
//           ),
//         ),

//         const SizedBox(height: 20),

//         // --- 2. Header Row (Title & Filter) ---
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               "Sub-contractors List",
//               style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87),
//             ),
//             Row(
//               children: [
//                 // Delete Icon Box
//                 Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: AppColors.alertRed,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: const Icon(Icons.delete_outline,
//                       color: Colors.white, size: 18),
//                 ),
//                 const SizedBox(width: 8),
//                 // Filter Chip
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade400),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Row(
//                     children: [
//                       Text("Filter By",
//                           style: TextStyle(
//                               fontSize: 12, fontWeight: FontWeight.bold)),
//                       SizedBox(width: 4),
//                       Icon(Icons.tune, size: 14)
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),

//         const SizedBox(height: 15),

//         // --- 3. List of Sub-contractors ---
//         ListView.separated(
//           shrinkWrap: true, // Important for nesting in SingleChildScrollView
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: _subContractors.length,
//           separatorBuilder: (context, index) => const SizedBox(height: 15),
//           itemBuilder: (context, index) {
//             final item = _subContractors[index];
//             return _buildSubContractorCard(item);
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildSubContractorCard(Map<String, dynamic> item) {
//     Color statusColor;
//     switch (item['status']) {
//       case 'Completed':
//         statusColor = const Color(0xFF009688); // Teal Green
//         break;
//       case 'Ongoing':
//         statusColor = const Color(0xFFFFC107); // Amber/Yellow
//         break;
//       case 'Pending':
//         statusColor = const Color(0xFFEF5350); // Red
//         break;
//       default:
//         statusColor = Colors.grey;
//     }

//     // ✅ Wrap Container in InkWell for tap navigation
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 SubContractorDetailsScreen(subContractor: item),
//           ),
//         );
//       },
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade200),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.03),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             )
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   item['name'],
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: statusColor,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     item['status'],
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             RichText(
//               text: TextSpan(
//                 style: const TextStyle(fontSize: 13, color: Colors.grey),
//                 children: [
//                   const TextSpan(text: "Work Type: "),
//                   TextSpan(
//                     text: item['workType'],
//                     style: const TextStyle(color: AppColors.primaryBlue),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 4),
//             RichText(
//               text: TextSpan(
//                 style: const TextStyle(fontSize: 13, color: Colors.grey),
//                 children: [
//                   const TextSpan(text: "Project Name: "),
//                   TextSpan(
//                     text: item['project'],
//                     style: const TextStyle(color: AppColors.primaryBlue),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/screens/projects/sub_contractor_details.dart';

class SubContractorsList extends StatefulWidget {
  const SubContractorsList({super.key});

  @override
  State<SubContractorsList> createState() => _SubContractorsListState();
}

class _SubContractorsListState extends State<SubContractorsList> {
  // Dummy Data for the list
  final List<Map<String, dynamic>> _subContractors = [
    {
      "name": "Sample Name",
      "workType": "Electrician",
      "project": "Sample Project Name 1",
      "status": "Completed"
    },
    {
      "name": "Sample Name",
      "workType": "Plumbing",
      "project": "Sample Project Name 2",
      "status": "Ongoing"
    },
    {
      "name": "Sample Name",
      "workType": "Plumbing",
      "project": "Sample Project Name 2",
      "status": "Pending"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. Search Bar ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.search, color: Colors.grey),
              hintText: "Search People",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              suffixIcon: Icon(Icons.mic, color: Colors.grey),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // --- 2. Header Row (Title & Filter) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Sub-contractors List",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            Row(
              children: [
                // Delete Icon Box
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.alertRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                // Filter Chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Text("Filter By",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.tune, size: 14)
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 15),

        // --- 3. List of Sub-contractors ---
        ListView.separated(
          shrinkWrap: true, // Important for nesting in SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _subContractors.length,
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final item = _subContractors[index];
            return _buildSubContractorCard(item);
          },
        ),
      ],
    );
  }

  Widget _buildSubContractorCard(Map<String, dynamic> item) {
    Color statusColor;
    switch (item['status']) {
      case 'Completed':
        statusColor = const Color(0xFF009688); // Teal Green
        break;
      case 'Ongoing':
        statusColor = const Color(0xFFFFC107); // Amber/Yellow
        break;
      case 'Pending':
        statusColor = const Color(0xFFEF5350); // Red
        break;
      default:
        statusColor = Colors.grey;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SubContractorDetailsScreen(subContractor: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // ✅ Aligns items to the top
          children: [
            // Left Content (Expanded to take available space)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        margin: const EdgeInsets.only(
                            left: 0), // Adds margin from left
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['status'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      children: [
                        const TextSpan(text: "Work Type: "),
                        TextSpan(
                          text: item['workType'],
                          style: const TextStyle(color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      children: [
                        const TextSpan(text: "Project Name: "),
                        TextSpan(
                          text: item['project'],
                          style: const TextStyle(color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ✅ Arrow Icon with Margin from Top
            Padding(
              padding: const EdgeInsets.only(top: 50.0), // Adds margin from top
              child:
                  const Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
