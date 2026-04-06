import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import 'package:m_gaz/global_widget/global_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
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
    extends State<ConsumerRelationsDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  void _loadDocument() {
    context.read<ConsumerRelationsBloc>().add(
      ConsumerRelationsDocumentFetched(widget.documentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomGlobalAppBar(
        title: 'Hujjat Tafsilotlari',
        centerTitle: true,
      ),
      body: BlocBuilder<ConsumerRelationsBloc, ConsumerRelationsState>(
        builder: (context, state) {
          switch (state.status) {
            case ConsumerRelationsStatus.loading:
              return _buildLoading();
            case ConsumerRelationsStatus.fail:
              return _buildErrorView(context, state.errorMessage);
            case ConsumerRelationsStatus.success:
              final document = state.selectedDocument;
              if (document == null) return _buildEmptyView();
              return _buildDocumentContent(context, document);
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.c1570EF,
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
                fontWeight: FontWeight.bold,
                color: Colors.red.shade400,
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
                backgroundColor: AppColors.c1570EF,
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
            Words.fileNotFound.tr(),
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

  Widget _buildDocumentContent(
      BuildContext context,
      WorkingWithConsumersDetailModel doc,
      ) {
    return RefreshIndicator(
      onRefresh: () async => _loadDocument(),
      color: AppColors.c1570EF,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainInfoCard(doc),
            const SizedBox(height: 20),
            _buildSectionHeader('EGXU Elementlari'),
            const SizedBox(height: 12),
            _buildEgxuList(doc.egxuList ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfoCard(WorkingWithConsumersDetailModel doc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1570EF.withValues(alpha: 0.1),
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
                  color: AppColors.c1570EF.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description,
                  color: AppColors.c1570EF,
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
                      doc.datetime != null ? _formatDate(doc.datetime!) : "-",
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
            value: doc.region?.name ?? "",
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.location_city,
            label: Words.district.tr(),
            value: doc.district?.name ?? "",
            color: Colors.blue.shade700,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.person,
            label: Words.employee.tr(),
            value: doc.employee?.fio ?? "",
            color: Colors.purple.shade700,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.people,
            label: Words.consumer.tr(),
            value: doc.consumers?.name ?? "",
            color: Colors.teal.shade700,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.badge,
            label: 'FACIAL',
            value: doc.facial ?? "",
            color: Colors.orange.shade700,
          ),
          if (doc.excelId != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.table_view,
              label: 'Excel ID',
              value: doc.excelId.toString(),
              color: Colors.orange.shade700,
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
        color: AppColors.c1570EF.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.c1570EF.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.list_alt, color: AppColors.c1570EF),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.c1570EF,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEgxuList(List<ConsumersEgxuItem> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildEgxuCard(item);
      },
    );
  }

  Widget _buildEgxuCard(ConsumersEgxuItem item) {
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
        leading: _buildStatusIcon(item.isActive ?? false),
        title: Text(
          'EGXU #${item.id}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _buildStatusChip(item.isActive ?? false),
        ),
        children: [
          // Consumer Relation EGXU ma'lumotlari
          if (item.consumerRelationEgxu != null) ...[
            _buildSubSection('Gaz Ma\'lumotlari', Icons.gas_meter),
            _buildConsumerRelationEgxuInfo(item.consumerRelationEgxu!),
            const SizedBox(height: 16),
          ],
          // Gas Equipment List
          if (item.gasEquipmentList?.isNotEmpty ?? false) ...[
            _buildSubSection(
              'Gaz Jihozlari (${item.gasEquipmentList!.length})',
              Icons.build,
            ),
            _buildGasEquipmentList(item.gasEquipmentList!),
            const SizedBox(height: 16),
          ],
          // Company Info
          if (item.companyInfo != null) ...[
            _buildSubSection('Korxona Ma\'lumotlari', Icons.business),
            _buildCompanyInfo(item.companyInfo!),
            const SizedBox(height: 16),
          ],
          // Real Devices
          if (item.real?.isNotEmpty ?? false) ...[
            _buildSubSection(
              'Hisoblagichlar (${item.real!.length})',
              Icons.devices,
            ),
            _buildRealDevicesList(item.real!),
            const SizedBox(height: 16),
          ],
          // Indicator Images
          if (item.indicatorImages?.isNotEmpty ?? false) ...[
            _buildSubSection(
              'Ko\'rsatkich Rasmlari (${item.indicatorImages!.length})',
              Icons.image,
            ),
            _buildIndicatorImages(item.indicatorImages!),
            const SizedBox(height: 16),
          ],
          // EGXU Type
          if (item.egxuType != null) ...[
            _buildSubSection('EGXU Turi', Icons.category),
            _buildEgxuType(item.egxuType!),
            const SizedBox(height: 16),
          ],
          // Dates
          if (item.fromDate != null || item.toDate != null) ...[
            _buildSubSection('Amal qilish muddati', Icons.date_range),
            _buildDateRange(item.fromDate, item.toDate),
          ],
          // Factory info
          if (item.oneFactory != null || item.twoFactory != null) ...[
            const SizedBox(height: 16),
            _buildSubSection('Zavod Ma\'lumotlari', Icons.factory),
            _buildFactoryInfo(item.oneFactory, item.twoFactory),
          ],
        ],
      ),
    );
  }

  // Modelga mos: ConsumerRelationEgxu faqat 4 ta fieldga ega
  Widget _buildConsumerRelationEgxuInfo(ConsumerRelationEgxu egxu) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.numbers,
            label: 'ID',
            value: egxu.id?.toString() ?? '-',
            color: Colors.orange.shade700,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.add_circle,
            label: 'Qoʻshimcha gaz',
            value: egxu.additionalGas?.toString() ?? '-',
            color: Colors.orange.shade700,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.warning,
            label: 'Qoidabuzarlik',
            value: egxu.violationGas?.toString() ?? '-',
            color: Colors.orange.shade700,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.toggle_on,
            label: 'Status',
            value: egxu.isActive == true ? 'Faol' : 'Nofaol',
            color: egxu.isActive == true ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ],
      ),
    );
  }

  // Modelga mos: ConsumersGasEquipmentItem faqat id va quantity
  Widget _buildGasEquipmentList(List<ConsumersGasEquipmentItem> equipment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        children: equipment.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.build_circle,
                  size: 20,
                  color: Colors.purple.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Jihoz ID: ${item.id}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Miqdor: ${item.quantity}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Modelga mos: ConsumersCompanyInfo faqat 4 ta field
  Widget _buildCompanyInfo(ConsumersCompanyInfo info) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.numbers,
            label: 'ID',
            value: info.id?.toString() ?? '-',
            color: Colors.blue.shade700,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.account_balance,
            label: 'Hisob raqami',
            value: info.accountNumber ?? '-',
            color: Colors.blue.shade700,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.confirmation_number,
            label: 'Shartnoma',
            value: info.contractNumber ?? '-',
            color: Colors.blue.shade700,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.person,
            label: 'Direktor',
            value: info.companyDirector ?? '-',
            color: Colors.blue.shade700,
          ),
        ],
      ),
    );
  }

  // Modelga mos: ConsumersRealItem faqat id va realNumber
  Widget _buildRealDevicesList(List<ConsumersRealItem> items) {
    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.gas_meter,
                color: Colors.green.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${item.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.realNumber ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Modelga mos: ConsumersIndicatorImage
  Widget _buildIndicatorImages(List<ConsumersIndicatorImage> images) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: images.map((img) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: img.image != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              img.image!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
          )
              : const Icon(Icons.image_not_supported),
        );
      }).toList(),
    );
  }

  // Modelga mos: ConsumersEgxuType
  Widget _buildEgxuType(ConsumersEgxuType type) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.category, color: Colors.teal.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${type.id}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  type.name ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactoryInfo(String? oneFactory, String? twoFactory) {
    return Row(
      children: [
        if (oneFactory != null)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.looks_one, color: Colors.indigo.shade700),
                  const SizedBox(height: 4),
                  Text(
                    'Birinchisi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    oneFactory,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (oneFactory != null && twoFactory != null) const SizedBox(width: 12),
        if (twoFactory != null)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.looks_two, color: Colors.indigo.shade700),
                  const SizedBox(height: 4),
                  Text(
                    'Ikkinchisi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    twoFactory,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade700,
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
        isActive ? 'FAOL' : 'NOFAOL',
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
          Icon(icon, size: 20, color: AppColors.c1570EF),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.c1570EF,
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
                style: const TextStyle(color: Colors.black87, fontSize: 14),
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

  Widget _buildDateRange(String? from, String? to) {
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
                  'Boshlanish',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  from ?? '-',
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
                  'Tugash',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  to ?? '-',
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

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";

    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) return "-";

    return DateFormat('dd.MM.yyyy').format(parsedDate);
  }}