// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:m_gaz/core/utils/colors.dart';
// import 'package:m_gaz/ui/home/working_with_egxu/bloc/egxu_bloc.dart';
// import 'package:m_gaz/ui/home/working_with_egxu/bloc/egxu_event.dart';
// import 'package:m_gaz/ui/home/working_with_egxu/bloc/egxu_state.dart';
// import 'package:easy_localization/easy_localization.dart';
// import '../../../../../core/common/words.dart';
// import '../../../../../core/models/egxu/egxu_detail/working_with_egxu_detail.dart';
// import '../../../../../core/models/egxu/egxu_detail/gas_equipment_item.dart';
//
// class WorkingWithEgxuDetailScreen extends StatefulWidget {
//   final int id;
//
//   const WorkingWithEgxuDetailScreen({super.key, required this.id});
//
//   @override
//   State<WorkingWithEgxuDetailScreen> createState() =>
//       _WorkingWithEgxuDetailScreenState();
// }
//
// class _WorkingWithEgxuDetailScreenState
//     extends State<WorkingWithEgxuDetailScreen>
//     with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
//   late AnimationController _animationController;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 600),
//     );
//     _loadData();
//   }
//
//   void _loadData() {
//     context.read<WorkingWIthEgxuBloc>().add(
//       WorkingWithWEGXUDetailFetched(widget.id),
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   bool get wantKeepAlive => true;
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final theme = Theme.of(context);
//     return Scaffold(
//       backgroundColor: AppColors.cF5F5F5,
//       body: BlocBuilder<WorkingWIthEgxuBloc, WorkingWithEgxuState>(
//         builder: (context, state) {
//           return RefreshIndicator(
//             onRefresh: _handleRefresh,
//             color: AppColors.c002266,
//             backgroundColor: Colors.white,
//             strokeWidth: 3,
//             child: CustomScrollView(
//               physics: const BouncingScrollPhysics(),
//               slivers: [
//                 SliverAppBar(
//                   pinned: true,
//                   stretch: true,
//                   elevation: 0,
//                   backgroundColor: AppColors.c002266,
//                   expandedHeight: 180,
//                   automaticallyImplyLeading: false,
//                   flexibleSpace: FlexibleSpaceBar(
//                     titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
//                     title: Text(
//                       'EGXU Tafsilotlari',
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         color: Colors.white,
//                       ),
//                     ),
//                     background: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             AppColors.c002266,
//                             AppColors.c002266.withValues(alpha: 0.85),
//                           ],
//                         ),
//                       ),
//                       child: SafeArea(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 20,
//                           ),
//                           child: Row(
//                             children: [
//                               _buildHeaderAvatar(),
//                               SizedBox(width: 12),
//                               Expanded(child: _buildHeaderSubtitle(state)),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // content
//                 SliverToBoxAdapter(child: SizedBox(height: 12)),
//                 if (state.status == WorkingWithEgxuStatus.loading) ...[
//                   SliverPadding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     sliver: SliverList(
//                       delegate: SliverChildBuilderDelegate(
//                         (_, i) => _ModernShimmer(height: i == 0 ? 160 : 120),
//                         childCount: 4,
//                       ),
//                     ),
//                   ),
//                 ] else if (state.status == WorkingWithEgxuStatus.fail) ...[
//                   SliverFillRemaining(
//                     hasScrollBody: false,
//                     child: _ModernError(
//                       message: state.errorMessage,
//                       onRetry: _loadData,
//                     ),
//                   ),
//                 ] else if (state.status == WorkingWithEgxuStatus.success) ...[
//                   if (state.selectedDocument == null)
//                     SliverFillRemaining(
//                       hasScrollBody: false,
//                       child: Center(child: Text(Words.noData.tr())),
//                     )
//                   else
//                     ..._buildSuccessSlivers(state.selectedDocument!),
//                 ] else ...[
//                   SliverFillRemaining(
//                     hasScrollBody: false,
//                     child: Center(child: Text(Words.noData.tr())),
//                   ),
//                 ],
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildHeaderAvatar() {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
//         child: Container(
//           width: 84,
//           height: 84,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
//             gradient: LinearGradient(
//               colors: [
//                 Colors.white.withValues(alpha: 0.06),
//                 Colors.white.withValues(alpha: 0.02),
//               ],
//             ),
//           ),
//           child: Icon(Icons.build_circle, size: 44, color: Colors.white),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeaderSubtitle(WorkingWithEgxuState state) {
//     final detail = state.selectedDocument;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           'Tafsilotlar va gaz anjomlari',
//           style: TextStyle(
//             color: Colors.white.withValues(alpha: 0.95),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         SizedBox(height: 6),
//         Text(
//           detail != null
//               ? 'ID: ${detail.id}  •  ${detail.region.name}, ${detail.district.name}'
//               : 'Ma\'lumot yuklanmoqda...',
//           style: TextStyle(
//             color: Colors.white.withValues(alpha: 0.9),
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
//
//   List<Widget> _buildSuccessSlivers(WorkingWithEgxuDetail detail) {
//     final dateFormatted = DateFormat(
//       "yyyy-MM-dd HH:mm",
//     ).format(detail.datetime);
//     return [
//       SliverToBoxAdapter(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
//           child: _InfoCard(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _HeaderBadge(
//                   icon: Icons.info_outline,
//                   title: 'Asosiy Ma\'lumotlar',
//                 ),
//                 SizedBox(height: 12),
//                 _InfoRow(label: 'Sana va vaqt', value: dateFormatted),
//                 _InfoRow(
//                   label: 'Hudud',
//                   value: '${detail.region.name}, ${detail.district.name}',
//                 ),
//                 _InfoRow(
//                   label: 'Faoliyat turi',
//                   value: detail.typeOfActivity.name,
//                 ),
//                 _InfoRow(label: "Xodim", value: detail.employee.fio),
//               ],
//             ),
//           ),
//         ),
//       ),
//
//       SliverToBoxAdapter(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
//           child: Row(
//             children: [
//               Icon(Icons.build, color: AppColors.c002266),
//               SizedBox(width: 8),
//               Text(
//                 "Gaz Anjomlari Ro'yxati",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//             ],
//           ),
//         ),
//       ),
//
//       SliverPadding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         sliver: SliverList(
//           delegate: SliverChildBuilderDelegate((context, index) {
//             final item = detail.gasEquipmentList[index];
//             return _ModernGasCard(item: item, index: index);
//           }, childCount: detail.gasEquipmentList.length),
//         ),
//       ),
//
//       SliverToBoxAdapter(child: SizedBox(height: 24)),
//     ];
//   }
//
//   Future<void> _handleRefresh() async {
//     _animationController.reset();
//     _loadData();
//     await Future.delayed(Duration(milliseconds: 600));
//   }
// }
//
// // ----------------- Small reusable widgets -----------------
//
// class _InfoCard extends StatelessWidget {
//   final Widget child;
//
//   const _InfoCard({required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       elevation: 4,
//       borderRadius: BorderRadius.circular(16),
//       color: Colors.white,
//       child: Padding(padding: const EdgeInsets.all(16), child: child),
//     );
//   }
// }
//
// class _HeaderBadge extends StatelessWidget {
//   final IconData icon;
//   final String title;
//
//   const _HeaderBadge({required this.icon, required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             color: AppColors.c002266.withValues(alpha: 0.08),
//           ),
//           child: Icon(icon, color: AppColors.c002266),
//         ),
//         SizedBox(width: 8),
//         Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
//       ],
//     );
//   }
// }
//
// class _InfoRow extends StatelessWidget {
//   final String label;
//   final String value;
//
//   const _InfoRow({required this.label, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(
//               label,
//               style: TextStyle(color: Colors.black54, fontSize: 13),
//             ),
//           ),
//           Expanded(
//             flex: 5,
//             child: Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _ModernShimmer extends StatefulWidget {
//   final double height;
//
//   const _ModernShimmer({required this.height});
//
//   @override
//   State<_ModernShimmer> createState() => _ModernShimmerState();
// }
//
// class _ModernShimmerState extends State<_ModernShimmer>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1200),
//     )..repeat();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           height: widget.height,
//           color: Colors.grey.shade200,
//           child: AnimatedBuilder(
//             animation: _controller,
//             builder: (context, _) {
//               return FractionallySizedBox(
//                 alignment: Alignment(-1 + _controller.value * 2, 0),
//                 widthFactor: 0.3,
//                 child: Container(color: Colors.white.withValues(alpha: 0.5)),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
//
// class _ModernError extends StatelessWidget {
//   final String? message;
//   final VoidCallback onRetry;
//
//   const _ModernError({this.message, required this.onRetry});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.error_outline, size: 72, color: Colors.redAccent),
//             SizedBox(height: 12),
//             Text(
//               Words.errorOccurred.tr(),
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             SizedBox(height: 6),
//             Text(message ?? Words.unknown.tr(), textAlign: TextAlign.center),
//             SizedBox(height: 14),
//             ElevatedButton(
//               onPressed: onRetry,
//               child: Text(Words.retry.tr()),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _ModernGasCard extends StatefulWidget {
//   final GasEquipmentItem item;
//   final int index;
//
//   const _ModernGasCard({required this.item, required this.index});
//
//   @override
//   State<_ModernGasCard> createState() => _ModernGasCardState();
// }
//
// class _ModernGasCardState extends State<_ModernGasCard>
//     with SingleTickerProviderStateMixin {
//   bool _expanded = false;
//   late AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 360),
//     );
//     Future.delayed(
//       Duration(milliseconds: widget.index * 50),
//       () => _controller.forward(),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final item = widget.item;
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Opacity(opacity: _controller.value, child: child);
//       },
//       child: GestureDetector(
//         onTap: () => setState(() => _expanded = !_expanded),
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.04),
//                 blurRadius: 12,
//                 offset: Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(14.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: AppColors.c002266.withValues(alpha: 0.08),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(Icons.build, color: AppColors.c002266),
//                     ),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         item.gasEquipment.name,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                     AnimatedRotation(
//                       duration: Duration(milliseconds: 300),
//                       turns: _expanded ? 0.5 : 0,
//                       child: Icon(Icons.expand_more),
//                     ),
//                   ],
//                 ),
//
//                 SizedBox(height: 10),
//
//                 AnimatedCrossFade(
//                   firstChild: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _detailRow('Stamp raqami', item.stampNumber),
//                       SizedBox(height: 6),
//                       _detailRow('Soni', item.quantity.toString()),
//                     ],
//                   ),
//                   secondChild: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _detailRow('Stamp raqami', item.stampNumber),
//                       SizedBox(height: 6),
//                       _detailRow('Soni', item.quantity.toString()),
//                       SizedBox(height: 8),
//                       Divider(),
//                       SizedBox(height: 8),
//                       _detailRow(
//                         'Soatlik gaz iste\'moli',
//                         item.hourlyGasConsumption,
//                       ),
//                       SizedBox(height: 6),
//                       _detailRow(
//                         'Kunlik gaz iste\'moli',
//                         item.dailyGasConsumption,
//                       ),
//                       SizedBox(height: 6),
//                       _detailRow('Nosozlik sababi', item.replacementReason),
//                     ],
//                   ),
//                   crossFadeState: _expanded
//                       ? CrossFadeState.showSecond
//                       : CrossFadeState.showFirst,
//                   duration: Duration(milliseconds: 300),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _detailRow(String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 3,
//           child: Text(
//             label,
//             style: TextStyle(color: Colors.black54, fontSize: 13),
//           ),
//         ),
//         Expanded(
//           flex: 5,
//           child: Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
//         ),
//       ],
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
