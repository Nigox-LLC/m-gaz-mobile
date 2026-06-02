import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/common/words.dart';
import '../../../../core/extension/message_extension.dart';
import '../../../../core/models/working_with_consumers_document/consumer_file_models.dart';
import '../../../../core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../bloc/consumer_detail_bloc.dart';
import '../bloc/consumer_detail_state.dart';
import '../widget/consumer_upload_widgets.dart';

class ConsumerRelationsDetailScreen extends StatelessWidget {
  final int documentId;

  const ConsumerRelationsDetailScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ConsumerDetailBloc()..add(ConsumerDetailFetched(documentId)),
      child: _ConsumerDetailView(documentId: documentId),
    );
  }
}

class _ConsumerDetailView extends StatefulWidget {
  const _ConsumerDetailView({required this.documentId});

  final int documentId;

  @override
  State<_ConsumerDetailView> createState() => _ConsumerDetailViewState();
}

class _ConsumerDetailViewState extends State<_ConsumerDetailView> {
  final _imagePicker = ImagePicker();

  void _retry() {
    context.read<ConsumerDetailBloc>().add(
      ConsumerDetailFetched(widget.documentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConsumerDetailColors.page,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<ConsumerDetailBloc, ConsumerDetailState>(
          listenWhen: (p, c) => p.saveStatus != c.saveStatus,
          listener: (context, state) {
            if (state.saveStatus == ConsumerDetailSaveStatus.success) {
              showToast(
                context,
                Words.eghuCreateSuccess.tr(),
                backgroundColor: const Color(0xFF17B26A),
              );
            } else if (state.saveStatus == ConsumerDetailSaveStatus.failure) {
              showToast(
                context,
                state.saveError ?? Words.errorOccurred.tr(),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildBody(state)),
                if (state.status == ConsumerDetailStatus.loaded)
                  _buildSaveBar(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: ConsumerDetailColors.textStrong,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              Words.documentDetails.tr(),
              textAlign: TextAlign.center,
              style: consumerText(
                fontSize: 17,
                lineHeight: 28,
                fontWeight: FontWeight.w800,
                color: ConsumerDetailColors.textStrong,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildBody(ConsumerDetailState state) {
    switch (state.status) {
      case ConsumerDetailStatus.loading:
      case ConsumerDetailStatus.initial:
        return const Center(child: CircularProgressIndicator());
      case ConsumerDetailStatus.fail:
        return _buildError(state.errorMessage);
      case ConsumerDetailStatus.loaded:
        final doc = state.document;
        if (doc == null) return _buildError(null);
        return _buildContent(context, state, doc);
    }
  }

  Widget _buildError(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFF04438),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? Words.errorOccurred.tr(),
              textAlign: TextAlign.center,
              style: consumerText(
                fontSize: 14,
                lineHeight: 20,
                color: ConsumerDetailColors.textSub,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(Words.retry.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: ConsumerDetailColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
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

  Widget _buildContent(
    BuildContext context,
    ConsumerDetailState state,
    WorkingWithConsumersDetailModel doc,
  ) {
    final egxuList = doc.egxuList ?? const <ConsumersEgxuItem>[];
    final companyInfo = egxuList.isNotEmpty ? egxuList.first.companyInfo : null;

    return RefreshIndicator(
      onRefresh: () async => _retry(),
      color: ConsumerDetailColors.primary,
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          _buildDocumentCard(context, state, doc, companyInfo),
          if (state.companyInfoExpanded && companyInfo != null) ...[
            const SizedBox(height: 12),
            _buildCompanyInfoCard(companyInfo),
          ],
          const SizedBox(height: 12),
          _buildFacialCard(doc),
          const SizedBox(height: 16),
          for (var i = 0; i < egxuList.length; i++) ...[
            _buildEgxuCard(context, state, egxuList[i], expanded: i == 0),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          _buildCard(
            child: ConsumerUploadSection(
              title: Words.technicalDocuments.tr(),
              sectionKey: 'technical',
              files: state.technicalAll,
              onAdd: () => _pickFile(ConsumerFileSlot.technical),
              onRemove: (file) => context.read<ConsumerDetailBloc>().add(
                ConsumerDetailFileRemoved(
                  slot: ConsumerFileSlot.technical,
                  file: file,
                ),
              ),
              onView: (file) => _viewFile(file),
            ),
          ),
          const SizedBox(height: 12),
          _buildCard(
            child: ConsumerUploadSection(
              title: Words.contract.tr(),
              sectionKey: 'contract',
              files: state.contractsAll,
              onAdd: () => _pickFile(ConsumerFileSlot.contract),
              onRemove: (file) => context.read<ConsumerDetailBloc>().add(
                ConsumerDetailFileRemoved(
                  slot: ConsumerFileSlot.contract,
                  file: file,
                ),
              ),
              onView: (file) => _viewFile(file),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DOCUMENT CARD ====================
  Widget _buildDocumentCard(
    BuildContext context,
    ConsumerDetailState state,
    WorkingWithConsumersDetailModel doc,
    ConsumersCompanyInfo? companyInfo,
  ) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ConsumerDetailColors.field,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: ConsumerDetailColors.textStrong,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${Words.document.tr()} #${doc.id ?? '-'}',
                  style: consumerText(
                    fontSize: 17,
                    lineHeight: 24,
                    fontWeight: FontWeight.w800,
                    color: ConsumerDetailColors.textStrong,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: ConsumerDetailColors.textSub,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppDateFormatter.dateFromString(doc.datetime),
                    style: consumerText(
                      fontSize: 13,
                      lineHeight: 20,
                      color: ConsumerDetailColors.textSub,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(Words.region.tr(), doc.region?.name),
          _infoRow(Words.district.tr(), doc.district?.name),
          _infoRow(Words.employee.tr(), doc.employee?.fio),
          _infoRowWithAction(
            Words.consumer.tr(),
            doc.consumers?.name,
            action: companyInfo == null
                ? null
                : _DetailsButton(
                    expanded: state.companyInfoExpanded,
                    onTap: () => context.read<ConsumerDetailBloc>().add(
                      const ConsumerDetailCompanyToggled(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: consumerText(
              fontSize: 11,
              lineHeight: 16,
              color: ConsumerDetailColors.textSub,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value != null && value.isNotEmpty ? value : '-',
            style: consumerText(
              fontSize: 15,
              lineHeight: 22,
              fontWeight: FontWeight.w700,
              color: ConsumerDetailColors.textStrong,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowWithAction(String label, String? value, {Widget? action}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _infoRow(label, value)),
        if (action != null) ...[const SizedBox(width: 8), action],
      ],
    );
  }

  // ==================== COMPANY INFO ====================
  Widget _buildCompanyInfoCard(ConsumersCompanyInfo info) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ConsumerDetailColors.field,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  size: 20,
                  color: ConsumerDetailColors.textStrong,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  Words.enterpriseInfo.tr(),
                  style: consumerText(
                    fontSize: 15,
                    lineHeight: 24,
                    fontWeight: FontWeight.w800,
                    color: ConsumerDetailColors.textStrong,
                  ),
                ),
              ),
              _StatusChip(active: info.isActive ?? false),
            ],
          ),
          const SizedBox(height: 16),
          _companyField(Words.accountNumber.tr(), info.accountNumber),
          _companyField(Words.contractNumber.tr(), info.contractNumber),
          _companyField(Words.directorName.tr(), info.companyDirector),
          _companyField(Words.ministry.tr(), info.ministry?.name),
          _companyField(
            Words.contractStart.tr(),
            AppDateFormatter.dateFromString(info.contractDate),
            icon: Icons.calendar_today_rounded,
          ),
          _companyField(
            Words.contractEnd.tr(),
            AppDateFormatter.dateFromString(info.contractEndDate),
            icon: Icons.calendar_today_rounded,
          ),
          _companyField(Words.companyStir.tr(), info.companyTin),
          _companyField(Words.phoneNumber.tr(), info.phone),
          _companyField(Words.email.tr(), info.email),
          _companyField(Words.address.tr(), info.address),
          _companyField(Words.type.tr(), info.typeConsumers),
          _companyField(Words.season.tr(), info.season, last: true),
        ],
      ),
    );
  }

  Widget _companyField(
    String label,
    String? value, {
    IconData? icon,
    bool last = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: consumerText(
              fontSize: 11,
              lineHeight: 16,
              color: ConsumerDetailColors.textSub,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: ConsumerDetailColors.field,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ConsumerDetailColors.stroke),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null && value.isNotEmpty ? value : '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: consumerText(
                      fontSize: 13,
                      lineHeight: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (icon != null)
                  Icon(icon, size: 18, color: ConsumerDetailColors.textSub),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FACIAL ====================
  Widget _buildFacialCard(WorkingWithConsumersDetailModel doc) {
    return _buildCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ConsumerDetailColors.field,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 20,
              color: ConsumerDetailColors.textStrong,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Words.facialLabel.tr(),
                  style: consumerText(
                    fontSize: 13,
                    lineHeight: 20,
                    fontWeight: FontWeight.w600,
                    color: ConsumerDetailColors.textStrong,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  doc.facial?.isNotEmpty == true ? doc.facial! : '-',
                  style: consumerText(
                    fontSize: 13,
                    lineHeight: 20,
                    color: ConsumerDetailColors.textSub,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EGHU CARD ====================
  Widget _buildEgxuCard(
    BuildContext context,
    ConsumerDetailState state,
    ConsumersEgxuItem item, {
    required bool expanded,
  }) {
    final egxuId = item.id;
    final isActive = item.isActive ?? false;
    final certs = egxuId != null
        ? state.certificatesFor(egxuId)
        : const <ConsumerUploadFile>[];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ConsumerDetailColors.stroke),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: expanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFECFDF3)
                  : const Color(0xFFFEF3F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.memory_rounded,
              size: 20,
              color: isActive
                  ? const Color(0xFF17B26A)
                  : const Color(0xFFF04438),
            ),
          ),
          title: Text(
            'EGXU #${egxuId ?? '-'}',
            style: consumerText(
              fontSize: 15,
              lineHeight: 24,
              fontWeight: FontWeight.w800,
              color: ConsumerDetailColors.textStrong,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${Words.factoryOne.tr()}: ${item.oneFactory ?? '-'}'
              '   ${Words.factoryTwo.tr()}: ${item.twoFactory ?? '-'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: consumerText(
                fontSize: 11,
                lineHeight: 16,
                color: ConsumerDetailColors.textSub,
              ),
            ),
          ),
          children: [
            Row(
              children: [
                if (item.egxuType?.name != null) ...[
                  _Chip(
                    label: item.egxuType!.name!,
                    color: ConsumerDetailColors.textSub,
                    bg: ConsumerDetailColors.field,
                  ),
                  const SizedBox(width: 8),
                ],
                _StatusChip(active: isActive),
              ],
            ),
            if (item.consumerRelationEgxu != null) ...[
              const SizedBox(height: 12),
              _buildGasMetrics(item.consumerRelationEgxu!),
            ],
            const SizedBox(height: 16),
            ConsumerUploadSection(
              title: Words.eghuCertificate.tr(),
              sectionKey: 'cert-$egxuId',
              files: certs,
              onAdd: egxuId == null
                  ? () {}
                  : () => _pickFile(
                      ConsumerFileSlot.certificate,
                      egxuId: egxuId,
                    ),
              onRemove: (file) => context.read<ConsumerDetailBloc>().add(
                ConsumerDetailFileRemoved(
                  slot: ConsumerFileSlot.certificate,
                  egxuId: egxuId,
                  file: file,
                ),
              ),
              onView: (file) => _viewFile(file),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGasMetrics(ConsumerRelationEgxu egxu) {
    final rows = <List<String>>[
      [Words.extraGasUsage.tr(), _m3(egxu.additionalGas)],
      [Words.violationGasUsage.tr(), _m3(egxu.violationGas)],
      [Words.monthStartIndicator.tr(), _m3(egxu.monthStartReading)],
      [Words.monthEndIndicator.tr(), _m3(egxu.monthEndReading)],
      [Words.indicatorDifference.tr(), _m3(egxu.readingDifference)],
      [Words.totalGasUsage.tr(), _m3(egxu.totalGas)],
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: ConsumerDetailColors.field,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ConsumerDetailColors.stroke),
      ),
      child: Column(
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row[0],
                      style: consumerText(
                        fontSize: 13,
                        lineHeight: 18,
                        color: ConsumerDetailColors.textSub,
                      ),
                    ),
                  ),
                  Text(
                    row[1],
                    style: consumerText(
                      fontSize: 13,
                      lineHeight: 18,
                      fontWeight: FontWeight.w700,
                      color: ConsumerDetailColors.textStrong,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _m3(double? value) => '${value?.toStringAsFixed(2) ?? '0.00'} m³';

  // ==================== SAVE BAR ====================
  Widget _buildSaveBar(BuildContext context, ConsumerDetailState state) {
    final enabled = state.canSave;
    final loading = state.isSaving;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.paddingOf(context).bottom + 8,
      ),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: enabled && !loading
              ? () => context.read<ConsumerDetailBloc>().add(
                  const ConsumerDetailSaved(),
                )
              : null,
          icon: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded, size: 20),
          label: Text(Words.save.tr()),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: ConsumerDetailColors.primary,
            disabledBackgroundColor: const Color(0xFFF4F4F4),
            disabledForegroundColor: ConsumerDetailColors.textSub,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: consumerText(
              fontSize: 16,
              lineHeight: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== SHARED CARD ====================
  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ConsumerDetailColors.stroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ==================== FILE PICK ====================
  Future<void> _pickFile(ConsumerFileSlot slot, {int? egxuId}) async {
    final bloc = context.read<ConsumerDetailBloc>();
    final source = await showModalBottomSheet<ConsumerPickSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const ConsumerSourceSheet(),
    );
    if (source == null) return;

    try {
      final file = source == ConsumerPickSource.camera
          ? await _pickFromCamera()
          : await _pickFromDevice();
      if (file == null) return;

      bloc.add(
        ConsumerDetailFileAdded(slot: slot, egxuId: egxuId, file: file),
      );
    } catch (e) {
      if (!mounted) return;
      showToast(
        context,
        '${Words.filePickFailed.tr()}: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  Future<ConsumerUploadFile?> _pickFromCamera() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image == null) return null;
    return ConsumerUploadFile.local(
      path: image.path,
      name: _fileName(image.path),
      sizeBytes: await image.length(),
    );
  }

  Future<ConsumerUploadFile?> _pickFromDevice() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      withData: false,
    );
    final file = result?.files.single;
    final path = file?.path;
    if (file == null || path == null) return null;
    return ConsumerUploadFile.local(
      path: path,
      name: file.name,
      sizeBytes: file.size == 0 ? await File(path).length() : file.size,
    );
  }

  String _fileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.split('/').last;
  }

  // ==================== FILE VIEW ====================
  Future<void> _viewFile(ConsumerUploadFile file) async {
    HapticFeedback.selectionClick();
    if (file.isImage && file.viewSource != null) {
      _showFullScreenImage(
        file.isRemote
            ? NetworkImage(file.remoteUrl!)
            : FileImage(File(file.localPath!)) as ImageProvider,
      );
      return;
    }
    if (file.isRemote && file.remoteUrl != null) {
      final uri = Uri.tryParse(file.remoteUrl!);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _showFullScreenImage(ImageProvider provider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Container(
              color: Colors.black.withValues(alpha: 0.92),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: PhotoView(
                  imageProvider: provider,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      Words.imageLoadFailed.tr(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 48,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SMALL WIDGETS ====================
class _DetailsButton extends StatelessWidget {
  const _DetailsButton({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ConsumerDetailColors.field,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Words.detailsButton.tr(),
                style: consumerText(
                  fontSize: 13,
                  lineHeight: 18,
                  fontWeight: FontWeight.w600,
                  color: ConsumerDetailColors.textStrong,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: ConsumerDetailColors.textSub,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return _Chip(
      label: active ? Words.active.tr() : Words.inactive.tr(),
      color: Colors.white,
      bg: active ? const Color(0xFF17B26A) : const Color(0xFFF04438),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, required this.bg});

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: consumerText(
          fontSize: 11,
          lineHeight: 16,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
