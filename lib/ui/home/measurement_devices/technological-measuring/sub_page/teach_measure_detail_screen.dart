import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/global_widget/global_app_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/models/technological-measuring/teach_measure_detail/teach_measure_certificate.dart';
import '../../../../../core/models/technological-measuring/teach_measure_detail/teach_measure_detail.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/common/words.dart';
import '../../../../../core/models/technological-measuring/teach_measure_detail/teach_measure_egxu_type.dart';
import '../../../../../core/models/technological-measuring/teach_measure_detail/teach_measure_hourly_indicator_image.dart';
import '../../../../../core/models/technological-measuring/teach_measure_detail/teach_measure_item.dart';
import '../../../../../core/models/technological-measuring/teach_measure_detail/teach_measure_real_item.dart';
import '../bloc/tech_measures_bloc.dart';
import '../bloc/tech_measures_event.dart';
import '../bloc/tech_measures_state.dart';

class TechMeasureDetailScreen extends StatefulWidget {
  final int documentId;

  const TechMeasureDetailScreen({super.key, required this.documentId});

  @override
  State<TechMeasureDetailScreen> createState() =>
      _TechMeasureDetailScreenState();
}

class _TechMeasureDetailScreenState extends State<TechMeasureDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  void _loadDocument() {
    context.read<TechMeasuresBloc>().add(
      TechMeasureDetailFetched(widget.documentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomGlobalAppBar(
        title: Words.documentDetails.tr(),
        centerTitle: true,
      ),
      body: BlocBuilder<TechMeasuresBloc, TechMeasuresState>(
        builder: (context, state) {
          return switch (state.status) {
            TechMeasuresStatus.loading => _buildShimmerLoading(),
            TechMeasuresStatus.fail => _buildErrorView(
              context,
              state.errorMessage,
            ),
            TechMeasuresStatus.success =>
              state.teachMeasureDetail == null
                  ? _buildEmptyView()
                  : _buildDocumentContent(state.teachMeasureDetail!),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildShimmerCard(height: 180),
          const SizedBox(height: 16),
          _buildShimmerCard(height: 300),
        ],
      ),
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 72, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              Words.errorOccurred.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.red.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? Words.unknown.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDocument,
              icon: const Icon(Icons.refresh),
              label: Text(Words.retry.tr()),
              style: ElevatedButton.styleFrom(
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

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            Words.documentsNotFound.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentContent(TeachMeasureDetail doc) {
    return RefreshIndicator(
      onRefresh: () async => _loadDocument(),
      color: Colors.blue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainInfoCard(doc),
            const SizedBox(height: 20),
            _buildSectionHeader(Words.eghuElements.tr()),
            const SizedBox(height: 12),
            _buildEgxuList(doc.egxuList),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfoCard(TeachMeasureDetail doc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${Words.document.tr()} #${doc.id}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(doc.datetime),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          _buildInfoRow(
            icon: Icons.location_on,
            label: Words.region.tr(),
            value: doc.region.name ?? "",
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.location_city,
            label: Words.district.tr(),
            value: doc.district.name ?? "",
            color: Colors.blue.shade700,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.person,
            label: Words.employee.tr(),
            value: doc.employee.fio ?? "",
            color: Colors.purple.shade700,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.people,
            label: Words.consumer.tr(),
            value: 'N/A',
            color: Colors.teal.shade700,
          ),
          if (doc.gtsh.name.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.factory,
              label: Words.gtsh.tr(),
              value: doc.gtsh.name,
              color: Colors.orange.shade700,
            ),
          ],
          if (doc.technoMeasuringDevices.name.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.electrical_services,
              label: Words.technologicalDevice.tr(),
              value: doc.technoMeasuringDevices.name,
              color: Colors.indigo.shade700,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.list_alt, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEgxuList(List<TeachMeasureItem> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildEgxuCard(items[index]),
    );
  }

  Widget _buildEgxuCard(TeachMeasureItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        collapsedBackgroundColor: Colors.white,
        backgroundColor: Colors.grey.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: _buildStatusIcon(item.isActive),
        title: Text(
          'EGHU #${item.id}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _buildStatusChip(item.isActive),
        ),
        children: [
          _buildSubSection(Words.eghuType.tr(), Icons.build),
          _buildEgxuTypeInfo(item.egxuType),
          const SizedBox(height: 16),
          if (item.oneFactory != null || item.twoFactory != null) ...[
            _buildSubSection(Words.factories.tr(), Icons.factory_outlined),
            _buildFactoriesInfo(item.oneFactory, item.twoFactory),
            const SizedBox(height: 16),
          ],
          if (item.real.isNotEmpty) ...[
            _buildSubSection(
              '${Words.counters.tr()} (${item.real.length})',
              Icons.devices,
            ),
            _buildRealDevicesList(item.real),
            const SizedBox(height: 16),
          ],
          if (item.certificates.isNotEmpty) ...[
            _buildSubSection(Words.certificates.tr(), Icons.verified),
            _buildCertificatesList(item.certificates),
            const SizedBox(height: 16),
          ],
          if (item.hourlyListIndicator.isNotEmpty) ...[
            _buildSubSection(Words.hourlyIndicators.tr(), Icons.analytics),
            _buildHourlyIndicatorsList(item.hourlyListIndicator),
            const SizedBox(height: 16),
          ],
          if (item.fromDate != null || item.toDate != null) ...[
            _buildSubSection(Words.validityPeriod.tr(), Icons.date_range),
            _buildDateRange(item.fromDate, item.toDate),
          ],
        ],
      ),
    );
  }

  Widget _buildEgxuTypeInfo(TeachMeasureEgxuType egxuType) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.build_rounded, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              egxuType.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactoriesInfo(String? oneFactory, String? twoFactory) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.factory_rounded, color: Colors.blue.shade700),
                const SizedBox(height: 4),
                Text(
                  Words.factoryOne.tr(),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  oneFactory ?? '-',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.factory_outlined, color: Colors.orange.shade700),
                const SizedBox(height: 4),
                Text(
                  Words.factoryTwo.tr(),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  twoFactory ?? '-',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(bool isActive) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isActive ? Icons.check_circle : Icons.cancel,
        color: isActive ? Colors.green : Colors.red,
        size: 24,
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive
            ? Words.active.tr().toUpperCase()
            : Words.inactive.tr().toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.green.shade800 : Colors.red.shade800,
        ),
      ),
    );
  }

  Widget _buildSubSection(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
              fontSize: 14,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 13),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealDevicesList(List<TeachMeasureRealItem> items) {
    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: item.isActive ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: item.isActive
                  ? Colors.green.shade200
                  : Colors.red.shade200,
            ),
          ),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            leading: Icon(
              item.isActive ? Icons.check_circle : Icons.cancel,
              color: item.isActive ? Colors.green : Colors.red,
              size: 24,
            ),
            title: Text(
              item.realNumber,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDeviceDetail(Icons.qr_code_2, 'QR', item.qrCode),
                  const SizedBox(height: 2),
                  _buildDeviceDetail(
                    Icons.date_range,
                    Words.installed.tr(),
                    _formatDate(item.installedDate),
                  ),
                  const SizedBox(height: 2),
                  _buildDeviceDetail(
                    Icons.location_pin,
                    Words.location.tr(),
                    item.sealInstalledLocation,
                  ),
                  const SizedBox(height: 2),
                  _buildDeviceDetail(
                    Icons.access_time,
                    Words.created.tr(),
                    _formatDateTime(item.created),
                  ),
                ],
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
              onPressed: () => _showQRDialog(context, item.qrCode),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeviceDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCertificatesList(List<TeachMeasureCertificate> certificates) {
    return Column(
      children: certificates.map((cert) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_outlined, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cert.certificateNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      cert.certificateType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${Words.validityPeriod.tr()}: ${_formatDate(cert.expiryDate)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(cert.isActive),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHourlyIndicatorsList(
    List<TeachMeasureHourlyListIndicator> indicators,
  ) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: indicators.length,
        itemBuilder: (context, index) {
          final indicator = indicators[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      size: 18,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Words.indicator.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  indicator.indicator.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDateTime(indicator.timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                _buildStatusChip(indicator.isActive),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateRange(DateTime? from, DateTime? to) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.start, color: Colors.green.shade700),
                const SizedBox(height: 4),
                Text(
                  Words.startDate.tr(),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  from != null ? _formatDate(from) : '-',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.event, color: Colors.red.shade700),
                const SizedBox(height: 4),
                Text(
                  Words.endDate.tr(),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  to != null ? _formatDate(to) : '-',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showQRDialog(BuildContext context, String qrData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code, size: 48, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                'QR Kod',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        qrData,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.blue),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: qrData));
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(Words.qrCodeCopied.tr()),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(Words.close.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => DateFormat('dd.MM.yyyy').format(date);

  String _formatDateTime(DateTime date) =>
      DateFormat('dd.MM.yyyy HH:mm').format(date);
}
