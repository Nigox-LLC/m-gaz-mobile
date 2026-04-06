import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_gaz/global_widget/global_app_bar.dart';
import 'package:m_gaz/ui/home/working_with_consumers/sub_page/create/create.dart';
import 'package:m_gaz/ui/home/working_with_consumers/sub_page/detail.dart';
import 'package:m_gaz/ui/home/working_with_consumers/widget/document_card.dart';
import '../../../core/common/words.dart';
import '../../../core/extension/navigator_extension.dart';
import '../../../core/utils/colors.dart';
import 'bloc/consumer_relations_bloc.dart';
import 'bloc/consumer_relations_state.dart';

class ConsumerRelationsScreen extends StatefulWidget {
  const ConsumerRelationsScreen({super.key});

  @override
  State<ConsumerRelationsScreen> createState() =>
      _ConsumerRelationsScreenState();
}

class _ConsumerRelationsScreenState extends State<ConsumerRelationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsumerRelationsBloc>().add(ConsumerRelationsFetched());
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<ConsumerRelationsBloc>().add(ConsumerRelationsLoadMore());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ==================== SCREEN BUILDER ====================
  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.cF5F5F5,
      appBar: _buildModernAppBar(),
      body: BlocBuilder<ConsumerRelationsBloc, ConsumerRelationsState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildBody(state, isTablet),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: isTablet ? 24 : 90),
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => push(EgxuCreateScreen()),
        ),
      ),
    );
  }

  // ==================== HELPER ====================
  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  // ==================== UI COMPONENTS ====================
  PreferredSizeWidget _buildModernAppBar() {
    return CustomGlobalAppBar(
      centerTitle: true,
      title: 'Istemolchilar bilan ishlash',
      showBack: false,
    );
  }

  Widget _buildBody(ConsumerRelationsState state, bool isTablet) {
    switch (state.status) {
      case ConsumerRelationsStatus.initial:
        return const SizedBox.shrink();

      case ConsumerRelationsStatus.loading:
        return _buildShimmerLoading(isTablet);

      case ConsumerRelationsStatus.fail:
        return _buildErrorState(state.errorMessage ?? "");

      case ConsumerRelationsStatus.success:
        if (state.documents.isEmpty) {
          return _buildEmptyState();
        }
        return _buildDocumentList(state, isTablet);

      case ConsumerRelationsStatus.exist:
      case ConsumerRelationsStatus.notExist:
        return const SizedBox.shrink();
    }
  }

  // ==================== SHIMMER LOADING ====================
  Widget _buildShimmerLoading(bool isTablet) {
    return isTablet
        ? GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.45,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => _buildShimmerCard(),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 8,
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
              'Xatolik yuz berdi',
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
                context.read<ConsumerRelationsBloc>().add(
                  ConsumerRelationsFetched(),
                );
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
              'Hujjatlar topilmadi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sizda hozircha hech qanday hujjat mavjud emas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DOCUMENT LIST (ADAPTIVE) ====================
  Widget _buildDocumentList(ConsumerRelationsState state, bool isTablet) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ConsumerRelationsBloc>().add(ConsumerRelationsFetched());
      },
      color: AppColors.c181D27,
      child: isTablet
          ? GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.45, // Tablet uchun optimallashtirilgan
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: state.documents.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.documents.length) {
                  return _buildLoadingMoreIndicator(isTablet);
                }
                return DocumentCard(
                  document: state.documents[index],
                  index: index,
                  onTap: () => push(
                    ConsumerRelationsDetailScreen(
                      documentId: state.documents[index].id ?? 0,
                    ),
                  ),
                );
              },
            )
          : Padding(
              padding: EdgeInsets.only(bottom: 80),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount:
                    state.documents.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.documents.length) {
                    return _buildLoadingMoreIndicator(isTablet);
                  }
                  return DocumentCard(
                    document: state.documents[index],
                    index: index,
                    onTap: () => push(
                      ConsumerRelationsDetailScreen(
                        documentId: state.documents[index].id ?? 0,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  // ==================== LOADING MORE INDICATOR ====================
  Widget _buildLoadingMoreIndicator(bool isTablet) {
    final widget = Center(
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
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.c181D27),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Yuklanmoqda...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );

    return isTablet ? GridTile(child: widget) : widget;
  }
}

// ==================== SHIMMER EFFECT (UNCHANGED) ====================

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
