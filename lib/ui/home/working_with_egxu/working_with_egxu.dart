// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:m_gaz/core/extension/navigator_extension.dart';
// import 'package:m_gaz/ui/home/working_with_egxu/subpage/create/create_egxu_screen.dart';
// import 'package:m_gaz/ui/home/working_with_egxu/subpage/detail/detail.dart';
// import 'package:m_gaz/ui/home/working_with_egxu/widgets/egxu_item.dart';
// import '../../../core/common/words.dart';
// import '../../../core/utils/colors.dart';
// import '../../../global_widget/global_app_bar.dart';
// import '../consumer_relations/consumer_relations_screen.dart';
// import 'bloc/egxu_bloc.dart';
// import 'bloc/egxu_event.dart';
// import 'bloc/egxu_state.dart';
//
// class WorkingWithEGXUScreen extends StatefulWidget {
//   const WorkingWithEGXUScreen({super.key});
//
//   @override
//   State<WorkingWithEGXUScreen> createState() => _WorkingWithEGXUScreenState();
// }
//
// class _WorkingWithEGXUScreenState extends State<WorkingWithEGXUScreen> {
//   final _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<WorkingWIthEgxuBloc>().add(WorkingWithEGXUFetched());
//     });
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 300) {
//       context.read<WorkingWIthEgxuBloc>().add(WorkingWithEGXULoadMore());
//     }
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   // ==================== SCREEN BUILDER ====================
//   @override
//   Widget build(BuildContext context) {
//     final isTablet = MediaQuery.of(context).size.width > 600;
//
//     return Scaffold(
//       backgroundColor: AppColors.cF5F5F5,
//       appBar: CustomGlobalAppBar(
//         centerTitle: true,
//         title: Words.workingWithEgxu.tr(),
//         showBack: false,
//       ),
//       body: BlocBuilder<WorkingWIthEgxuBloc, WorkingWithEgxuState>(
//         builder: (context, state) {
//           return AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             child: _buildBody(state, isTablet),
//           );
//         },
//       ),
//
//       floatingActionButton: Padding(
//         padding: EdgeInsets.only(bottom: isTablet ? 24 : 90),
//         child: FloatingActionButton(
//           child: const Icon(Icons.add),
//           onPressed: () => push(CreateEgxuScreen()),
//         ),
//       ),
//     );
//   }
//
//   // ==================== BODY ====================
//   Widget _buildBody(WorkingWithEgxuState state, bool isTablet) {
//     switch (state.status) {
//       case WorkingWithEgxuStatus.initial:
//         return const SizedBox.shrink();
//
//       case WorkingWithEgxuStatus.loading:
//         return _buildShimmerLoading(isTablet);
//
//       case WorkingWithEgxuStatus.fail:
//         return _buildErrorState(state.errorMessage ?? "");
//
//       case WorkingWithEgxuStatus.success:
//         if (state.documents.isEmpty) {
//           return _buildEmptyState();
//         }
//         return _buildDocumentList(state, isTablet);
//     }
//   }
//
//   // ==================== SHIMMER LOADING ====================
//   Widget _buildShimmerLoading(bool isTablet) {
//     return isTablet
//         ? GridView.builder(
//             padding: const EdgeInsets.all(16),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 1.45,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//             ),
//             itemCount: 6,
//             itemBuilder: (context, index) => _buildShimmerCard(),
//           )
//         : ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: 8,
//             itemBuilder: (context, index) => _buildShimmerCard(),
//           );
//   }
//
//   Widget _buildShimmerCard() {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: const ShimmerEffect(child: SizedBox(height: 150)),
//     );
//   }
//
//   // ==================== ERROR ====================
//   Widget _buildErrorState(String errorMessage) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 80, color: AppColors.red),
//           const SizedBox(height: 16),
//           Text(Words.errorOccurred.tr()),
//           const SizedBox(height: 8),
//           Text(errorMessage),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () => context.read<WorkingWIthEgxuBloc>().add(
//               WorkingWithEGXUFetched(),
//             ),
//             child: Text(Words.retry.tr()),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ==================== EMPTY ====================
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.inbox_outlined,
//             size: 100,
//             color: AppColors.black.withValues(alpha: 0.5),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             Words.noData.tr(),
//             style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ==================== LIST ====================
//   Widget _buildDocumentList(WorkingWithEgxuState state, bool isTablet) {
//     return RefreshIndicator(
//       onRefresh: () async {
//         context.read<WorkingWIthEgxuBloc>().add(WorkingWithEGXUFetched());
//       },
//       color: AppColors.c181D27,
//       child: isTablet
//           ? GridView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(16),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 1.45,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//               ),
//               itemCount: state.documents.length + (state.isLoadingMore ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index == state.documents.length) {
//                   return _buildLoadingMoreIndicator(isTablet);
//                 }
//
//                 return EgxuDoxumentItem(
//                   document: state.documents[index], // EGXUDocument
//                   index: index,
//                 );
//               },
//             )
//           : ListView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(16),
//               itemCount: state.documents.length + (state.isLoadingMore ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index == state.documents.length) {
//                   return _buildLoadingMoreIndicator(isTablet);
//                 }
//
//                 return EgxuDoxumentItem(
//                   document: state.documents[index],
//                   index: index,
//                   onTap: () => push(
//                     WorkingWithEgxuDetailScreen(id: state.documents[index].id),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
//
//   // ==================== LOADING MORE ====================
//   Widget _buildLoadingMoreIndicator(bool isTablet) {
//     final widget = Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(strokeWidth: 3),
//             const SizedBox(width: 16),
//             Text(Words.loading.tr()),
//           ],
//         ),
//       ),
//     );
//
//     return isTablet ? GridTile(child: widget) : widget;
//   }
// }
