import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_gaz/global_widget/global_app_bar.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/ui/home/measurement_devices/technological-measuring/sub_page/teach_measure_detail_screen.dart';
import '../../../../core/common/words.dart';
import '../../../../core/extension/navigator_extension.dart';
import '../technological-measuring/bloc/tech_measures_bloc.dart';
import '../technological-measuring/bloc/tech_measures_event.dart';
import '../technological-measuring/bloc/tech_measures_state.dart';
import '../technological-measuring/widgets/tech_measure_card.dart';

class IndustrialCollectorsScreen extends StatefulWidget {
  const IndustrialCollectorsScreen({super.key});

  @override
  State<IndustrialCollectorsScreen> createState() =>
      _IndustrialCollectorsScreenState();
}

class _IndustrialCollectorsScreenState
    extends State<IndustrialCollectorsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TechMeasuresBloc>().add(TechMeasureLoad());
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TechMeasuresBloc>().add(TechMeasureLoadMore());
    }
  }

  Future<void> _onRefresh() async {
    context.read<TechMeasuresBloc>().add(TechMeasureLoad());
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cF5F5F5,
      appBar: CustomGlobalAppBar(
        title: Words.technologicalMeasuringDevices.tr(),
      ),
      body: BlocBuilder<TechMeasuresBloc, TechMeasuresState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildBody(state),
          );
        },
      ),
    );
  }

  // ==================== TABLET DETECTION ====================
  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  Widget _buildBody(TechMeasuresState state) {
    switch (state.status) {
      case TechMeasuresStatus.initial:
        return const SizedBox.shrink();

      case TechMeasuresStatus.loading:
        if (state.items.isEmpty) {
          return _buildShimmerLoading();
        }
        return _buildDocumentList(state);

      case TechMeasuresStatus.fail:
        return _buildErrorState(state.errorMessage ?? Words.errorOccurred.tr());

      case TechMeasuresStatus.success:
        if (state.items.isEmpty) {
          return _buildEmptyState();
        }
        return _buildDocumentList(state);
    }
  }

  // ==================== SHIMMER LOADING (ADAPTIVE) ====================
  Widget _buildShimmerLoading() {
    final bool isTablet = _isTablet(context);

    return isTablet
        ? GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => _buildShimmerCard(),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (context, index) => _buildShimmerCard(),
          );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ShimmerEffect(
        child: Column(
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(
                  4,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      height: 16,
                      width: double.infinity,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ERROR STATE ====================
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: AppColors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            Text(
              Words.errorOccurred.tr(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.black),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TechMeasuresBloc>().add(TechMeasureLoad());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(Words.retry.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.c181D27,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 100,
              color: AppColors.black.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              Words.documentsNotFound.tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              Words.noDocumentsAvailable.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DOCUMENT LIST (ADAPTIVE) ====================
  Widget _buildDocumentList(TechMeasuresState state) {
    final bool isTablet = _isTablet(context);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.c181D27,
      child: isTablet
          ? GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  return _buildLoadingMoreIndicator(true);
                }
                final item = state.items[index];
                return TechMeasureCard(
                  item: item,
                  index: index,
                  onTap: () {
                    debugPrint("CARD BOSILDI");
                    push(
                      TechMeasureDetailScreen(
                        documentId: state.items[index].id,
                      ),
                    );
                  },
                );
              },
            )
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  return _buildLoadingMoreIndicator(false);
                }
                final item = state.items[index];
                return TechMeasureCard(
                  item: item,
                  index: index,
                  onTap: () {
                    push(TechMeasureDetailScreen(documentId: item.id));
                  },
                );
              },
            ),
    );
  }

  // ==================== LOADING MORE INDICATOR (ADAPTIVE) ====================
  Widget _buildLoadingMoreIndicator(bool isTablet) {
    final indicator = Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(width: 12),
            Text(
              'Yuklanmoqda...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );

    return isTablet ? GridTile(child: indicator) : indicator;
  }
}

// ==================== SHIMMER EFFECT WIDGET ====================
class ShimmerEffect extends StatefulWidget {
  final Widget child;

  const ShimmerEffect({super.key, required this.child});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [Colors.grey, Colors.white, Colors.grey],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
