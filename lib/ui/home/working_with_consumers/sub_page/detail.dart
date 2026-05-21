import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/services.dart';
import '../../../../core/common/words.dart';
import '../../../../core/utils/colors.dart';
import '../bloc/consumer_relations_bloc.dart';
import '../bloc/consumer_relations_state.dart';

class ConsumerRelationsDetailScreen extends StatefulWidget {
  final int documentId;

  const ConsumerRelationsDetailScreen({super.key, required this.documentId});

  @override
  State<ConsumerRelationsDetailScreen> createState() =>
      _ConsumerRelationsDetailScreenState();
}

class _ConsumerRelationsDetailScreenState
    extends State<ConsumerRelationsDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _loadDocument();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadDocument() {
    context.read<ConsumerRelationsBloc>().add(
      ConsumerRelationsDocumentFetched(widget.documentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cF9F9F9,
      body: BlocConsumer<ConsumerRelationsBloc, ConsumerRelationsState>(
        listener: (context, state) {
          if (state.detailStatus == DocumentDetailStatus.loaded) {
            _animationController.forward();
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildContent(state),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.c1570EF,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          Words.documentDetails.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(gradient: AppColors.catalogGradient),
        ),
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Widget _buildContent(ConsumerRelationsState state) {
    switch (state.detailStatus) {
      case DocumentDetailStatus.loading:
        return _buildSkeletonLoading();
      case DocumentDetailStatus.fail:
        return _buildErrorView(state.errorMessage);
      case DocumentDetailStatus.loaded:
        final document = state.selectedDocument;
        if (document == null) return _buildEmptyView();
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildDocumentContent(document),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ==================== SKELETON LOADING ====================
  Widget _buildSkeletonLoading() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSkeletonCard(),
          const SizedBox(height: 20),
          _buildSkeletonCard(),
          const SizedBox(height: 20),
          _buildSkeletonCard(),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== ERROR VIEW ====================
  Widget _buildErrorView(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.cFEF3F2,
                    AppColors.cFEF3F2.withValues(alpha: 0.5),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 72,
                color: AppColors.cF04438,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              Words.errorOccurred.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.c101623,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cFEF3F2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message ?? Words.unknown.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.c667085, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _loadDocument();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(Words.retry.tr()),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.c1570EF,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cF2F5F8,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              size: 64,
              color: AppColors.cD0D5DD,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            Words.fileNotFound.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.c667085,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Words.documentNotFound.tr(),
            style: TextStyle(fontSize: 14, color: AppColors.cA1A8B0),
          ),
        ],
      ),
    );
  }

  // ==================== MAIN CONTENT ====================
  Widget _buildDocumentContent(WorkingWithConsumersDetailModel doc) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
        _animationController.reset();
        _loadDocument();
      },
      color: AppColors.c1570EF,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(doc),
          const SizedBox(height: 24),
          _buildSectionTitle(
            Words.eghuElements.tr(),
            icon: Icons.devices_rounded,
          ),
          const SizedBox(height: 16),
          _buildEgxuList(doc.egxuList ?? []),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==================== HERO CARD ====================
  Widget _buildHeroCard(WorkingWithConsumersDetailModel doc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Hero(
        tag: 'document_card_${doc.id}',
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, AppColors.cFAFAFA],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.c1570EF.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppColors.catalogGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.c1570EF.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.description_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${Words.document.tr()} #${doc.id}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.c101623,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cECFDF3,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 12,
                                        color: AppColors.c027A48,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        doc.datetime != null
                                            ? _formatDate(doc.datetime!)
                                            : "-",
                                        style: TextStyle(
                                          color: AppColors.c027A48,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1, color: AppColors.cE5E5E5),
                      _buildInfoGrid([
                        _InfoItem(
                          icon: Icons.location_on_rounded,
                          label: Words.region.tr(),
                          value: doc.region?.name ?? "-",
                          color: AppColors.c17B26A,
                          bgColor: AppColors.cECFDF3,
                        ),
                        _InfoItem(
                          icon: Icons.location_city_rounded,
                          label: Words.district.tr(),
                          value: doc.district?.name ?? "-",
                          color: AppColors.c4E0D30,
                          bgColor: AppColors.cF2F5F8,
                        ),
                        _InfoItem(
                          icon: Icons.person_rounded,
                          label: Words.employee.tr(),
                          value: doc.employee?.fio ?? "-",
                          color: AppColors.c7B3AEB,
                          bgColor: AppColors.cF5F5F5,
                        ),
                        _InfoItem(
                          icon: Icons.people_rounded,
                          label: Words.consumer.tr(),
                          value: doc.consumers?.name ?? "-",
                          color: AppColors.cF38744,
                          bgColor: AppColors.cFEF3F2,
                        ),
                      ]),
                      if (doc.facial != null && doc.facial!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.badge_rounded,
                          label: 'FACIAL',
                          value: doc.facial!,
                          color: AppColors.cF79009,
                        ),
                      ],
                      if (doc.excelId != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.table_view_rounded,
                          label: Words.excelId.tr(),
                          value: doc.excelId.toString(),
                          color: AppColors.c00A6FB,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid(List<_InfoItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleColumn = constraints.maxWidth < 360;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: useSingleColumn ? 1 : 2,
            mainAxisExtent: useSingleColumn ? 82 : 96,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildInfoTile(item, compact: !useSingleColumn);
          },
        );
      },
    );
  }

  Widget _buildInfoTile(_InfoItem item, {required bool compact}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: item.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.color.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 14, color: item.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: compact ? 10.5 : 11,
                    color: item.color,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 5 : 6),
          Text(
            item.value,
            style: TextStyle(
              fontSize: compact ? 13 : 14,
              fontWeight: FontWeight.w600,
              color: AppColors.c101623,
              height: 1.2,
            ),
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.c101623,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: color.withValues(alpha: 0.5),
            size: 20,
          ),
        ],
      ),
    );
  }

  // ==================== SECTION TITLE ====================
  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 28,
            decoration: BoxDecoration(
              gradient: AppColors.catalogGradient,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          if (icon != null) ...[
            Icon(icon, size: 22, color: AppColors.c1570EF),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.c101623,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EGXU LIST ====================
  Widget _buildEgxuList(List<ConsumersEgxuItem> items) {
    if (items.isEmpty) {
      return _buildEmptyEgxuState();
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildEgxuCard(item, index);
      },
    );
  }

  Widget _buildEmptyEgxuState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cE5E5E5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cF2F5F8,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.devices_rounded,
              size: 48,
              color: AppColors.cD0D5DD,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ma\'lumotlar mavjud emas',
            style: TextStyle(
              color: AppColors.c667085,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'EGHU elementlari topilmadi',
            style: TextStyle(color: AppColors.cA1A8B0, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ==================== EGXU CARD ====================
  Widget _buildEgxuCard(ConsumersEgxuItem item, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              collapsedBackgroundColor: Colors.white,
              backgroundColor: AppColors.cF9F9F9,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              leading: _buildStatusAvatar(item.isActive ?? false),
              title: Text(
                'EGHU #${item.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.c101623,
                  letterSpacing: -0.3,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    _buildStatusChip(item.isActive ?? false),
                    if (item.egxuType?.name != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cF2F5F8,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.egxuType!.name!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.c535862,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.cA1A8B0,
              ),
              children: [
                const Divider(height: 1, color: AppColors.cE5E5E5),
                const SizedBox(height: 16),
                if (item.consumerRelationEgxu != null)
                  _buildGasInfoSection(item.consumerRelationEgxu!),
                if (item.gasEquipmentList?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  _buildEquipmentSection(item.gasEquipmentList!),
                ],
                if (item.companyInfo != null) ...[
                  const SizedBox(height: 16),
                  _buildCompanyInfoSection(item.companyInfo!),
                ],
                if (item.real?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  _buildMetersSection(item.real!),
                ],
                if (item.indicatorImages?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  _buildImagesSection(item.indicatorImages!),
                ],
                if (item.fromDate != null || item.toDate != null) ...[
                  const SizedBox(height: 16),
                  _buildDateSection(item.fromDate, item.toDate),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusAvatar(bool isActive) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [AppColors.c17B26A, AppColors.c027A48]
              : [AppColors.cF04438, AppColors.cD92D20],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (isActive ? AppColors.c17B26A : AppColors.cF04438)
                .withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        isActive ? Icons.check_rounded : Icons.close_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.cECFDF3 : AppColors.cFEF3F2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.c17B26A : AppColors.cF04438,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: isActive ? AppColors.c027A48 : AppColors.cD92D20,
          ),
          const SizedBox(width: 4),
          Text(
            isActive
                ? Words.active.tr().toUpperCase()
                : Words.inactive.tr().toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.c027A48 : AppColors.cD92D20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGasInfoSection(ConsumerRelationEgxu egxu) {
    return _buildDetailCard(
      title: Words.gasInfo.tr(),
      icon: Icons.gas_meter_rounded,
      color: AppColors.cF38744,
      child: Column(
        children: [
          _buildMetricCard(
            label: Words.extraGasUsage.tr(),
            value: '${egxu.additionalGas?.toStringAsFixed(2) ?? '0.00'} m³',
            icon: Icons.trending_up_rounded,
            color: AppColors.c17B26A,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            label: Words.violationGasUsage.tr(),
            value: '${egxu.violationGas?.toStringAsFixed(2) ?? '0.00'} m³',
            icon: Icons.warning_amber_rounded,
            color: AppColors.cF04438,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            label: Words.additionalResidue.tr(),
            value: '${egxu.additionalBalance?.toStringAsFixed(2) ?? '0.00'} m³',
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.c17B26A,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            label: Words.monthStartIndicator.tr(),
            value: '${egxu.monthStartReading?.toStringAsFixed(2) ?? '0.00'} m³',
            icon: Icons.timeline_rounded,
            color: AppColors.c667085,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            label: Words.monthEndIndicator.tr(),
            value: '${egxu.monthEndReading?.toStringAsFixed(2) ?? '0.00'} m³',
            icon: Icons.timeline_rounded,
            color: AppColors.c667085,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            label: Words.indicatorDifference.tr(),
            value: '${egxu.readingDifference?.toStringAsFixed(2) ?? '0.00'} m³',
            icon: Icons.compare_arrows_rounded,
            color: AppColors.cF38744,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            label: Words.totalGasUsage.tr(),
            value: '${egxu.totalGas?.toStringAsFixed(2) ?? '0.00'} m³',
            icon: Icons.local_gas_station_rounded,
            color: AppColors.c17B26A,
          ),
          const SizedBox(height: 12),
          if (egxu.reasonsForViolations != null &&
              egxu.reasonsForViolations!.isNotEmpty)
            _buildMetricCard(
              label: Words.violationReason.tr(),
              value: egxu.reasonsForViolations!,
              icon: Icons.error_outline_rounded,
              color: AppColors.cF04438,
            ),
          const SizedBox(height: 12),
          _buildMetricCard(
            label: Words.gtpExist.tr(),
            value: egxu.grpExists == true ? Words.yes.tr() : Words.no.tr(),
            icon: Icons.check_circle_outline_rounded,
            color: egxu.grpExists == true
                ? AppColors.c17B26A
                : AppColors.cF04438,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            label: Words.gtpLoss.tr(),
            value: '${egxu.grpLoss?.toStringAsFixed(2) ?? '0.00'} m³',
            icon: Icons.warning_amber_rounded,
            color: AppColors.cF38744,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            label: Words.status.tr(),
            value: egxu.isActive == true
                ? Words.active.tr()
                : Words.inactive.tr(),
            icon: Icons.toggle_on_rounded,
            color: egxu.isActive == true
                ? AppColors.c17B26A
                : AppColors.cF04438,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            label: Words.activityType.tr(),
            value: egxu.workActivity == true ? Words.yes.tr() : Words.no.tr(),
            icon: Icons.work_rounded,
            color: egxu.workActivity == true
                ? AppColors.c17B26A
                : AppColors.cF04438,
          ),
          const SizedBox(height: 12),
          if (egxu.movGrpAfterEgxu != null)
            _buildMetricCard(
              label: Words.moveGtpAfterEghu.tr(),
              value: egxu.movGrpAfterEgxu!,
              icon: Icons.swap_horiz_rounded,
              color: AppColors.c667085,
            ),
          const SizedBox(height: 12),
          if (egxu.gaz != null)
            _buildMetricCard(
              label: Words.gas.tr(),
              value: egxu.gaz!,
              icon: Icons.local_fire_department_rounded,
              color: AppColors.cF04438,
            ),
          const SizedBox(height: 12),
          if (egxu.counterStatus != null)
            _buildMetricCard(
              label: Words.meterStatus.tr(),
              value: egxu.counterStatus!,
              icon: Icons.speed_rounded,
              color: AppColors.c667085,
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.12), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.c535862,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EQUIPMENT SECTION ====================
  Widget _buildEquipmentSection(List<ConsumersGasEquipmentItem> equipment) {
    return _buildDetailCard(
      title: Words.gasEquipmentInfo.tr(),
      icon: Icons.build_rounded,
      color: AppColors.c7B3AEB,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxHeight: 200),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: equipment.map((item) {
              final gas = item.gasEquipment;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.c7B3AEB.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.c7B3AEB.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.build, size: 20, color: AppColors.c7B3AEB),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gas?.name ?? '-',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.c7B3AEB,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${Words.quantity.tr()}: ${item.quantity} • ${Words.hourlyGasConsumption.tr()}: ${gas?.hourlyGasConsumption ?? '-'} m³',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.c7B3AEB,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyInfoSection(ConsumersCompanyInfo? companyInfo) {
    if (companyInfo == null) return const SizedBox();

    return _buildDetailCard(
      title: Words.companyInfo.tr(),
      icon: Icons.business_rounded,
      color: AppColors.c535862,
      child: Column(
        children: [
          _buildCompanyInfoTile(
            Icons.numbers,
            Words.accountNumber.tr(),
            companyInfo.accountNumber,
          ),
          const SizedBox(height: 12),
          _buildCompanyInfoTile(
            Icons.description,
            Words.contractNumber.tr(),
            companyInfo.contractNumber,
          ),
          const SizedBox(height: 12),
          _buildCompanyInfoTile(
            Icons.person,
            Words.directorName.tr(),
            companyInfo.companyDirector,
          ),
          const SizedBox(height: 12),
          _buildCompanyInfoTile(
            Icons.apartment,
            Words.ministry.tr(),
            companyInfo.ministry?.name,
          ),
          const SizedBox(height: 12),
          _buildCompanyInfoTile(
            Icons.date_range,
            Words.contractStart.tr(),
            companyInfo.contractDate,
          ),
          const SizedBox(height: 12),
          _buildCompanyInfoTile(
            Icons.date_range,
            Words.contractEnd.tr(),
            companyInfo.contractEndDate,
          ),
          const SizedBox(height: 12),
          _buildCompanyInfoTile(Icons.badge, 'STIR', companyInfo.companyTin),
          const SizedBox(height: 12),
          _buildCompanyInfoTile(
            Icons.phone,
            Words.phone.tr(),
            companyInfo.phone,
          ),
          const SizedBox(height: 12),
          _buildCompanyInfoTile(Icons.email, 'Email', companyInfo.email),
          const SizedBox(height: 12),
          _buildCompanyInfoTile(
            Icons.location_on,
            Words.address.tr(),
            companyInfo.address,
          ),
          const SizedBox(height: 12),
          _buildCompanyInfoTile(
            Icons.category,
            Words.type.tr(),
            companyInfo.typeConsumers,
          ),
          const SizedBox(height: 12),
          _buildCompanyInfoTile(
            Icons.wb_sunny,
            Words.season.tr(),
            companyInfo.season,
          ),
          const SizedBox(height: 12),
          _buildCompanyInfoTile(
            Icons.check_circle,
            Words.activeShort.tr(),
            companyInfo.isActive == true ? Words.yes.tr() : Words.no.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoTile(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.c535862.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.c535862),
        ),
        const SizedBox(width: 14),
        // Label va Value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppColors.c667085),
              ),
              const SizedBox(height: 4),
              Text(
                value != null && value.isNotEmpty ? value : '-',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.c101623,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== METERS SECTION ====================
  Widget _buildMetersSection(List<ConsumersRealItem> meters) {
    return _buildDetailCard(
      title: Words.counters.tr(),
      icon: Icons.speed_rounded,
      color: AppColors.c17B26A,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: meters.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final meter = meters[index];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cF9F9F9,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.c17B26A.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.gas_meter,
                    size: 24,
                    color: AppColors.c17B26A,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meter.realNumber ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.c101623,
                          fontSize: 15,
                        ),
                      ),

                      if (meter.employee?.fio != null)
                        Text(
                          '${Words.worker.tr()}: ${meter.employee!.fio}',
                          style: TextStyle(
                            color: AppColors.c667085,
                            fontSize: 12,
                          ),
                        ),
                      if (meter.connectionPoint?.name != null)
                        Text(
                          '${Words.connectionPoint.tr()}: ${meter.connectionPoint!.name}',
                          style: TextStyle(
                            color: AppColors.c667085,
                            fontSize: 12,
                          ),
                        ),
                      if (meter.installedDate != null)
                        Text(
                          '${Words.installedDateLabel.tr()}: ${_formatDate(meter.installedDate)}',
                          style: TextStyle(
                            color: AppColors.c667085,
                            fontSize: 12,
                          ),
                        ),
                      if (meter.qrCode != null)
                        Text(
                          'QR: ${meter.qrCode}',
                          style: TextStyle(
                            color: AppColors.c667085,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.c17B26A.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.c17B26A,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== IMAGES SECTION WITH ZOOM ====================
  Widget _buildImagesSection(List<ConsumersIndicatorImage> images) {
    return _buildDetailCard(
      title: Words.indicatorImages.tr(),
      icon: Icons.image_rounded,
      color: AppColors.cF79009,
      child: SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final img = images[index];
            return GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _showFullScreenImage(img.image);
              },
              child: Hero(
                tag: 'image_${img.id}',
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: img.image != null
                        ? Image.network(
                            img.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.cF2F5F8,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 32,
                                    color: AppColors.cD0D5DD,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Words.imageLoadFailed.tr(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.cA1A8B0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.cF2F5F8,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 32,
                              color: AppColors.cD0D5DD,
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Full screen image with zoom capability
  void _showFullScreenImage(String? imageUrl) {
    if (imageUrl == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Background blur
            Container(
              color: Colors.black.withValues(alpha: 0.92),
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: PhotoView(
                    imageProvider: NetworkImage(imageUrl),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                    initialScale: PhotoViewComputedScale.contained,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    loadingBuilder: (context, event) => Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        color: AppColors.cF2F5F8,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64,
                            color: AppColors.cD0D5DD,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            Words.imageLoadFailed.tr(),
                            style: TextStyle(
                              color: AppColors.c667085,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 48,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            // Info text
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    Words.zoomHint.tr(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
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

  // ==================== DATE SECTION ====================
  Widget _buildDateSection(String? fromDate, String? toDate) {
    return _buildDetailCard(
      title: Words.validityPeriod.tr(),
      icon: Icons.date_range_rounded,
      color: AppColors.c00A6FB,
      child: Row(
        children: [
          Expanded(
            child: _buildDateCard(
              Words.start.tr(),
              fromDate,
              Icons.play_arrow_rounded,
              AppColors.c17B26A,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cF2F5F8,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward,
              size: 16,
              color: AppColors.cA1A8B0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildDateCard(
              Words.end.tr(),
              toDate,
              Icons.stop_rounded,
              AppColors.cF04438,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(
    String label,
    String? date,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.08), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date != null ? _formatDate(date) : '-',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DETAIL CARD ====================
  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cE5E5E5.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.12),
                      color.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.c101623,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.cE5E5E5),
          child,
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) return "-";
    return DateFormat('dd.MM.yyyy').format(parsedDate);
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });
}
