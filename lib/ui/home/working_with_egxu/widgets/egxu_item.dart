// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:m_gaz/core/utils/colors.dart';
//
// class EgxuDoxumentItem extends StatelessWidget {
//   final dynamic document;
//   final int index;
//   final VoidCallback? onTap;
//
//   const EgxuDoxumentItem({
//     super.key,
//     required this.document,
//     required this.index,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final formattedDate =
//     DateFormat("dd.MM.yyyy | HH:mm").format(document.datetime);
//
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 300 + (index * 50)),
//       curve: Curves.easeOut,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: onTap,
//         child: Card(
//           margin: const EdgeInsets.only(bottom: 16),
//           elevation: 2,
//           shadowColor: Colors.black26,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//             side: BorderSide(color: AppColors.c1570EF, width: 1),
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               color: AppColors.white,
//             ),
//             child: Column(
//               children: [
//                 // ------------------ HEADER ------------------
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     gradient: AppColors.catalogGradient,
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(16),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.description_rounded,
//                           color: Colors.white, size: 30),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           document.consumers,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // ------------------ CONTENT ------------------
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       _buildDetailRow(
//                         icon: Icons.person_outline,
//                         label: 'Xodim',
//                         value: document.employee,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow(
//                         icon: Icons.location_on_outlined,
//                         label: 'Hudud',
//                         value: '${document.region}, ${document.district}',
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow(
//                         icon: Icons.work_outline,
//                         label: 'Faoliyat turi',
//                         value: document.typeOfActivity,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow(
//                         icon: Icons.sync_alt_rounded,
//                         label: 'O‘zgartirish',
//                         value: document.removal,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow(
//                         icon: Icons.local_gas_station_outlined,
//                         label: 'Gazdan foydalanish',
//                         value: document.gasUsage,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow(
//                         icon: Icons.view_list_rounded,
//                         label: 'Foydalanish turi',
//                         value: document.usageType,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow(
//                         icon: Icons.access_time,
//                         label: 'Vaqti',
//                         value: formattedDate,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // ------------------ FOOTER ------------------
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.c181D27.withValues(alpha: 0.05),
//                     borderRadius: const BorderRadius.vertical(
//                       bottom: Radius.circular(16),
//                     ),
//                     border: Border(
//                       top: BorderSide(color: AppColors.c1570EF, width: 1),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'ID: ${document.id}',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: AppColors.black,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       Icon(Icons.arrow_forward_ios_rounded,
//                           size: 16, color: AppColors.c1570EF),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ------------------ DETAIL ITEM ------------------
//   Widget _buildDetailRow({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Row(
//       children: [
//         Container(
//           width: 38,
//           height: 38,
//           decoration: BoxDecoration(
//             color: AppColors.c1570EF.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, size: 18, color: AppColors.c1570EF),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: AppColors.black.withValues(alpha: 0.7),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: AppColors.black,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
