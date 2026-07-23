import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/models/grs/grs_detail_model/grs_detail_model.dart';
import '../../../../../core/models/grs/grs_detail_model/grs_egxu_item.dart';
import '../../../../../core/utils/app_date_formatter.dart';
import '../bloc/grs_measurement_devices_bloc.dart';
import '../bloc/grs_measurement_devices_event.dart';
import '../bloc/grs_measurement_devices_state.dart';
import '../../../../../core/common/words.dart';

class GrsDetailScreen extends StatefulWidget {
  final int grsId;
  const GrsDetailScreen({super.key, required this.grsId});

  @override
  State<GrsDetailScreen> createState() => _GrsDetailScreenState();
}

class _GrsDetailScreenState extends State<GrsDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<GrsMeasurementDevicesBloc>().add(
      GrsMeasurementDevicesDetailFetched(widget.grsId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          Words.gtsDetails.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [_buildAnimatedRefreshButton()],
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: BlocBuilder<GrsMeasurementDevicesBloc, GrsMeasurementDevicesState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _buildStateContent(state),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedRefreshButton() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF1976D2),
              ),
            ),
            onPressed: _loadData,
            tooltip: Words.refresh.tr(),
          ),
        );
      },
    );
  }

  Widget _buildStateContent(GrsMeasurementDevicesState state) {
    switch (state.status) {
      case GrsMeasurementDevicesStatus.loading:
        return _buildModernSkeleton();
      case GrsMeasurementDevicesStatus.fail:
        return _buildFuturisticError(
          state.errorMessage ?? Words.unknownError.tr(),
        );
      case GrsMeasurementDevicesStatus.success:
        return _buildModernBody(state.grsDetail);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildModernSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFuturisticError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 24),
            Text(
              Words.errorOccurred.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildGlowingButton(
              onPressed: _loadData,
              label: Words.retry.tr(),
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowingButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: const Color(0xFF1976D2).withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildModernBody(GrsDetailModel? model) {
    if (model == null) return _buildEmptyState(Words.noData.tr());

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      color: const Color(0xFF1976D2),
      backgroundColor: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildGlassmorphicMainCard(model),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _buildSectionTitle(Words.eghuDevices.tr(), Icons.sensors),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(top: 16)),
          if (model.egxuList?.isEmpty ?? true)
            SliverFillRemaining(child: _buildEmptyState(Words.noEghuData.tr()))
          else
            SliverToBoxAdapter(
              child: _buildHorizontalEgxuCarousel(model.egxuList!),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicMainCard(GrsDetailModel model) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[100]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(Words.generalInfo.tr(), Icons.info_outline),
            const SizedBox(height: 24),
            _buildDataRow(
              Icons.location_on,
              Words.region.tr(),
              model.region?.name ?? '-',
            ),
            _buildDataRow(
              Icons.map,
              Words.district.tr(),
              model.district?.name ?? '-',
            ),
            _buildDataRow(
              Icons.person,
              Words.employee.tr(),
              model.employee?.fio ?? '-',
            ),
            _buildDataRow(
              Icons.factory,
              Words.gtsh.tr(),
              model.gtsh?.name ?? '-',
            ),
            _buildDataRow(
              Icons.calendar_today,
              Words.date.tr(),
              _formatDate(model.dateTime),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: const Color(0xFF1976D2), size: 24),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1976D2), size: 22),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalEgxuCarousel(List<GrsEgxuItem> items) {
    return SizedBox(
      height: 360,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 20),
            child: _buildEgxuGlassCard(items[index]),
          );
        },
      ),
    );
  }

  Widget _buildEgxuGlassCard(GrsEgxuItem item) {
    final isActive = item.isActive ?? false;
    return GestureDetector(
      onTap: () => _navigateToEgxuDetail(item),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.82,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [
                    Colors.green.withValues(alpha: 0.1),
                    Colors.green.withValues(alpha: 0.05),
                  ]
                : [Colors.white, Colors.grey[100]!],
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isActive
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEgxuCardHeader(item, isActive),
              const Spacer(),
              _buildTimelineSection(item),
              const SizedBox(height: 20),
              _buildPreviewChips(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEgxuCardHeader(GrsEgxuItem item, bool isActive) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isActive
                  ? [Colors.green, Colors.green[700]!]
                  : [Colors.grey[400]!, Colors.grey[600]!],
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isActive ? Icons.sensors_rounded : Icons.sensor_door_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.egxuType?.name ?? Words.unknown.tr(),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              // _buildAnimatedStatusChip(isActive: isActive),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
      ],
    );
  }

  Widget _buildTimelineSection(GrsEgxuItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimelineItem(
          Icons.play_circle,
          Words.startTime.tr(),
          _formatDate(item.fromDate),
        ),
        const SizedBox(height: 10),
        _buildTimelineItem(
          Icons.stop_circle,
          Words.endTime.tr(),
          _formatDate(item.toDate),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF1976D2)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewChips(GrsEgxuItem item) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (item.real?.isNotEmpty == true)
          _buildCountChip(
            '${Words.real.tr()}: ${item.real!.length}',
            Colors.cyan,
          ),
        if (item.gasEquipmentList?.isNotEmpty == true)
          _buildCountChip(
            '${Words.gas.tr()}: ${item.gasEquipmentList!.length}',
            Colors.orange,
          ),
        if (item.certificates?.isNotEmpty == true)
          _buildCountChip(
            '${Words.cert.tr()}: ${item.certificates!.length}',
            Colors.purple,
          ),
      ],
    );
  }

  Widget _buildCountChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  void _navigateToEgxuDetail(GrsEgxuItem item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EgxuDetailScreen(item: item),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 18),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    return AppDateFormatter.dateTime(date, fallback: Words.unknown.tr());
  }
}

// ===================================================================
// EGXU DETAIL SCREEN - LIGHT THEME WITHOUT STEPPER NUMBERS
// ===================================================================

class EgxuDetailScreen extends StatelessWidget {
  final GrsEgxuItem item;
  const EgxuDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Header with gradient and icon
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                item.egxuType?.name ?? Words.eghuDetailed.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1976D2).withValues(alpha: 0.1),
                      Colors.grey[50]!,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1976D2),
                          const Color(0xFF42A5F5),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1976D2).withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sensors_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content Sections without step numbers
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Information Section
                  _buildSectionHeader(Words.mainInfo.tr(), Icons.info),
                  const SizedBox(height: 16),
                  _buildMainInfoCard(),
                  const SizedBox(height: 32),

                  // Timeline Section
                  _buildSectionHeader(
                    Words.eghuTimeRange.tr(),
                    Icons.access_time,
                  ),
                  const SizedBox(height: 16),
                  _buildTimelineCard(),
                  const SizedBox(height: 32),

                  // Factory Numbers Section
                  if (item.oneFactory != null || item.twoFactory != null) ...[
                    _buildSectionHeader(
                      Words.factoryNumbers.tr(),
                      Icons.numbers,
                    ),
                    const SizedBox(height: 16),
                    _buildFactoryNumbersCard(),
                    const SizedBox(height: 32),
                  ],

                  // Gas Consumption Section
                  if (item.gasEquipmentList?.isNotEmpty == true) ...[
                    _buildSectionHeader(
                      Words.gasConsumption.tr(),
                      Icons.local_fire_department,
                    ),
                    const SizedBox(height: 16),
                    _buildGasConsumptionCard(),
                    const SizedBox(height: 32),
                  ],

                  // Real Devices Section (Tamg'alar)
                  if (item.real?.isNotEmpty == true) ...[
                    _buildSectionHeader(
                      Words.activeDevicesStamps.tr(),
                      Icons.router,
                    ),
                    const SizedBox(height: 16),
                    _buildRealDevicesCard(),
                    const SizedBox(height: 32),
                  ],

                  // Images Section
                  if (item.indicatorImages?.isNotEmpty == true) ...[
                    _buildSectionHeader(Words.images.tr(), Icons.photo_library),
                    const SizedBox(height: 16),
                    _buildImagesCard(),
                    const SizedBox(height: 32),
                  ],

                  // Certificates Section
                  if (item.certificates?.isNotEmpty == true) ...[
                    _buildSectionHeader(
                      Words.certificates.tr(),
                      Icons.verified,
                    ),
                    const SizedBox(height: 16),
                    _buildCertificatesCard(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1976D2), size: 22),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMainInfoCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            Icons.calendar_today,
            Words.startTime.tr(),
            _formatDate(item.fromDate),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.event_available,
            Words.endTime.tr(),
            _formatDate(item.toDate),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.timelapse,
            Words.duration.tr(),
            _calculateDuration(item.fromDate, item.toDate),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.check_circle,
            Words.status.tr(),
            item.isActive == true ? Words.active.tr() : Words.inactive.tr(),
            valueColor: item.isActive == true ? Colors.green : Colors.grey,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.label,
            Words.type.tr(),
            item.egxuType?.name ?? Words.unknown.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineItem(
            Icons.play_circle_outline,
            Words.start.tr(),
            _formatDate(item.fromDate),
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            Icons.stop_circle_outlined,
            Words.end.tr(),
            _formatDate(item.toDate),
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildFactoryNumbersCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.oneFactory != null)
            _buildInfoRow(
              Icons.confirmation_number,
              Words.factoryOne.tr(),
              item.oneFactory!,
            ),
          if (item.oneFactory != null && item.twoFactory != null)
            const SizedBox(height: 12),
          if (item.twoFactory != null)
            _buildInfoRow(
              Icons.confirmation_number,
              Words.factoryTwo.tr(),
              item.twoFactory!,
            ),
        ],
      ),
    );
  }

  Widget _buildGasConsumptionCard() {
    final equipment = item.gasEquipmentList!;
    return _buildGlassCard(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: equipment.length,
        separatorBuilder: (context, index) =>
            const Divider(color: Colors.black12, height: 20, thickness: 1),
        itemBuilder: (context, index) {
          final eq = equipment[index];
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.fireplace,
                  size: 20,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eq.gasEquipment?.name ?? Words.unknownEquipment.tr(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Words.hourlyGasConsumption.tr()}: ${eq.hourlyGasConsumption ?? 0} m³',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${eq.quantity ?? 0} ta',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRealDevicesCard() {
    final devices = item.real!;
    return _buildGlassCard(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[100]!],
              ),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.router,
                        size: 20,
                        color: device.isActive == true
                            ? Colors.cyan[700]
                            : Colors.grey,
                      ),
                      const Spacer(),
                      _buildStatusDot(device.isActive == true),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    device.realNumber ?? Words.unknown.tr(),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.connectionPoint?.name ?? '-',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    device.qrCode ?? '-',
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagesCard() {
    final images = item.indicatorImages!;
    return _buildGlassCard(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final img = images[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              img.image ?? '',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: Colors.grey[500],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCertificatesCard() {
    final certificates = item.certificates!;
    return _buildGlassCard(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: certificates.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final cert = certificates[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withValues(alpha: 0.05),
                  Colors.deepPurple.withValues(alpha: 0.03),
                ],
              ),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.verified,
                          color: Colors.purple[700],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cert.certificateType ?? Words.certificate.tr(),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildCertDetail(
                    Icons.badge,
                    Words.number.tr(),
                    cert.certificateNumber ?? '-',
                  ),
                  const SizedBox(height: 8),
                  _buildCertDetail(
                    Icons.calendar_today,
                    Words.givenDate.tr(),
                    AppDateFormatter.dateFromString(cert.issuedDate),
                  ),
                  const SizedBox(height: 8),
                  _buildCertDetail(
                    Icons.hourglass_empty,
                    Words.validityPeriod.tr(),
                    _formatDate(cert.expiryDate),
                  ),
                  if (cert.egxuImage?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        cert.egxuImage!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[100]!],
        ),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF1976D2)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCertDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.green : Colors.grey,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }

  String _calculateDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return Words.unknown.tr();
    final duration = end.difference(start);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    return '$days ${Words.days.tr()} $hours ${Words.hours.tr()}';
  }

  String _formatDate(DateTime? date) {
    return AppDateFormatter.dateTime(date, fallback: Words.unknown.tr());
  }
}
