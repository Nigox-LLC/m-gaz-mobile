import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:m_gaz/global_widget/global_app_bar.dart';
import 'package:m_gaz/ui/home/working_with_consumers/sub_page/create/create.dart';
import 'package:m_gaz/ui/home/working_with_consumers/sub_page/detail.dart';
import 'package:m_gaz/ui/home/working_with_consumers/widget/document_card.dart';
import 'package:m_gaz/ui/home/working_with_consumers/widget/filter_bottom_sheet.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsumerRelationsBloc>().add(ConsumerRelationsFetched());
    });
  }

  void _onSearchControllerChanged() {
    // suffix clear icon ko'rinishi uchun setState
    setState(() {});
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
    _searchController.removeListener(_onSearchControllerChanged);
    _searchController.dispose();
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
          return Column(
            children: [
              _buildSearchField(context, state),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildBody(state, isTablet),
                ),
              ),
            ],
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

  // ==================== SEARCH FIELD ====================
  Widget _buildSearchField(BuildContext context, ConsumerRelationsState state) {
    final hasQuery = _searchController.text.isNotEmpty;
    final filterActive =
        state.regionFilterId != null || state.districtFilterId != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(child: _buildSearchTextField(context, hasQuery)),
          const SizedBox(width: 8),
          _buildFilterButton(context, state, filterActive),
        ],
      ),
    );
  }

  Widget _buildSearchTextField(BuildContext context, bool hasQuery) {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        context.read<ConsumerRelationsBloc>().add(
          ConsumerRelationsSearchChanged(value),
        );
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: Words.search.tr(),
        hintStyle: const TextStyle(color: Colors.black45),
        prefixIcon: const Icon(Icons.search, color: Colors.black54),
        suffixIcon: hasQuery
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: () {
                  _searchController.clear();
                  context.read<ConsumerRelationsBloc>().add(
                    const ConsumerRelationsSearchChanged(''),
                  );
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.c181D27, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    ConsumerRelationsState state,
    bool active,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _openFilterSheet(context, state),
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/filter-funnel.svg',
                width: 22,
                colorFilter: ColorFilter.mode(
                  active ? AppColors.c1570EF : Colors.black87,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        if (active)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.c1570EF,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openFilterSheet(
    BuildContext context,
    ConsumerRelationsState state,
  ) async {
    final result = await showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        initialRegionId: state.regionFilterId,
        initialDistrictId: state.districtFilterId,
      ),
    );

    if (result == null || !context.mounted) return;

    if (result.cleared) {
      context.read<ConsumerRelationsBloc>().add(
        const ConsumerRelationsFilterChanged(
          clearRegion: true,
          clearDistrict: true,
        ),
      );
    } else {
      context.read<ConsumerRelationsBloc>().add(
        ConsumerRelationsFilterChanged(
          regionId: result.regionId,
          districtId: result.districtId,
          clearRegion: result.regionId == null,
          clearDistrict: result.districtId == null,
        ),
      );
    }
  }

  // ==================== HELPER ====================
  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  // ==================== UI COMPONENTS ====================
  PreferredSizeWidget _buildModernAppBar() {
    return CustomGlobalAppBar(
      centerTitle: true,
      title: Words.consumerRelations.tr(),
      showBack: false,
    );
  }

  Widget _buildBody(ConsumerRelationsState state, bool isTablet) {
    switch (state.documentsStatus) {
      // ✅ legacyStatus emas, documentsStatus
      case DocumentsStatus.initial:
        return const SizedBox.shrink();

      case DocumentsStatus.loading:
        return _buildShimmerLoading(isTablet);

      case DocumentsStatus.fail:
        return _buildErrorState(state.errorMessage ?? "");

      case DocumentsStatus.loaded:
        if (state.documents.isEmpty) {
          return _buildEmptyState();
        }
        return _buildDocumentList(state, isTablet);

      case DocumentsStatus.loadingMore:
        return _buildDocumentList(state, isTablet);
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
                      documentId: state.documents[index].id,
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
                        documentId: state.documents[index].id,
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
        child: Row(
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
              Words.loading.tr(),
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
