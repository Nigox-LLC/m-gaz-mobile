import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/api/working_with_consumers_api/consumer_relations_api.dart';
import '../../../../core/common/words.dart';
import '../../../../core/extension/message_extension.dart';
import '../../../../core/mocdata/map_select_item.dart';
import '../../../../core/models/global/global_model.dart';
import '../../../../core/models/working_with_consumers_document/consumer_file_models.dart';
import '../../../../core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../../../features/actions/presentation/pages/eghu/presentation/pages/eghu_indicator_upload_page.dart';
import '../../../../features/actions/presentation/pages/eghu/presentation/pages/eghu_reset.dart';
import '../../../../features/actions/presentation/pages/eghu/presentation/pages/eghu_take_off.dart';
import '../../../../features/actions/presentation/pages/eghu/presentation/widgets/create/eghu_action_bottom_sheets.dart';
import '../../../../global_bloc/global_bloc.dart';
import '../../../../global_bloc/global_event.dart';
import '../../../../global_bloc/global_state.dart';
import '../bloc/consumer_detail_bloc.dart';
import '../bloc/consumer_detail_state.dart';
import '../widget/consumer_upload_widgets.dart';

class ConsumerRelationsDetailScreen extends StatelessWidget {
  final int documentId;
  final ConsumerRelationsApi? api;

  const ConsumerRelationsDetailScreen({
    super.key,
    required this.documentId,
    this.api,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ConsumerDetailBloc(api: api)..add(ConsumerDetailFetched(documentId)),
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
  bool _lookupsRequested = false;
  bool _allowPop = false;
  bool _exitAfterSave = false;

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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: BlocConsumer<ConsumerDetailBloc, ConsumerDetailState>(
              listenWhen: (p, c) =>
                  p.saveStatus != c.saveStatus || p.status != c.status,
              listener: (context, state) {
                if (state.status == ConsumerDetailStatus.loaded) {
                  _requestLookups(state.draftDocument ?? state.document);
                }
                if (state.saveStatus == ConsumerDetailSaveStatus.success) {
                  showToast(
                    context,
                    Words.eghuCreateSuccess.tr(),
                    backgroundColor: const Color(0xFF17B26A),
                  );
                  if (_exitAfterSave) {
                    _exitAfterSave = false;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _popRoute(true);
                    });
                  }
                } else if (state.saveStatus ==
                    ConsumerDetailSaveStatus.failure) {
                  _exitAfterSave = false;
                  showToast(
                    context,
                    state.saveError ?? Words.errorOccurred.tr(),
                  );
                }
              },
              builder: (context, state) {
                return PopScope(
                  canPop: _allowPop || (!state.canSave && !state.isSaving),
                  onPopInvokedWithResult: (didPop, result) {
                    if (didPop) return;
                    _attemptExit(state);
                  },
                  child: Column(
                    children: [
                      _Header(onBack: () => _attemptExit(state)),
                      Expanded(child: _buildBody(state)),
                      if (state.status == ConsumerDetailStatus.loaded)
                        _SaveBar(
                          enabled: state.canSave,
                          loading: state.isSaving,
                          onTap: () => context.read<ConsumerDetailBloc>().add(
                            const ConsumerDetailSaved(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _attemptExit(ConsumerDetailState state) async {
    if (state.isSaving) return;

    if (!state.canSave) {
      _popRoute();
      return;
    }

    final action = await showModalBottomSheet<ConsumerUnsavedChangesAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ConsumerUnsavedChangesSheet(),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case ConsumerUnsavedChangesAction.discard:
        _popRoute(false);
        break;
      case ConsumerUnsavedChangesAction.save:
        _exitAfterSave = true;
        context.read<ConsumerDetailBloc>().add(const ConsumerDetailSaved());
        break;
    }
  }

  void _popRoute([Object? result]) {
    if (!mounted) return;
    setState(() => _allowPop = true);
    Navigator.of(context).pop(result);
  }

  void _requestLookups(WorkingWithConsumersDetailModel? document) {
    if (_lookupsRequested) return;
    try {
      final bloc = context.read<GlobalBloc>();
      bloc.add(EgxuFormInitialDataRequested());
      final regionId = document?.region?.id;
      final districtId = document?.district?.id;
      if (regionId != null && districtId != null) {
        bloc.add(
          GetGasNetworksEvent(regionId: regionId, districtId: districtId),
        );
      }
      _lookupsRequested = true;
    } catch (_) {
      _lookupsRequested = true;
    }
  }

  Widget _buildBody(ConsumerDetailState state) {
    switch (state.status) {
      case ConsumerDetailStatus.loading:
      case ConsumerDetailStatus.initial:
        return const Center(child: CircularProgressIndicator());
      case ConsumerDetailStatus.fail:
        return _ErrorState(message: state.errorMessage, onRetry: _retry);
      case ConsumerDetailStatus.loaded:
        final doc = state.draftDocument ?? state.document;
        if (doc == null) {
          return _ErrorState(message: null, onRetry: _retry);
        }
        return _buildContent(state, doc);
    }
  }

  Widget _buildContent(
    ConsumerDetailState state,
    WorkingWithConsumersDetailModel doc,
  ) {
    final egxuList = doc.egxuList ?? const <ConsumersEgxuItem>[];
    final companyInfo = egxuList.isNotEmpty ? egxuList.first.companyInfo : null;
    final globalState = _globalStateOrNull();

    return RefreshIndicator(
      onRefresh: () async => _retry(),
      color: ConsumerDetailColors.primary,
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _DocumentCard(
            state: state,
            document: doc,
            companyInfo: companyInfo,
            onDetails: companyInfo == null
                ? null
                : () => context.read<ConsumerDetailBloc>().add(
                    const ConsumerDetailCompanyToggled(),
                  ),
          ),
          if (state.companyInfoExpanded && companyInfo != null) ...[
            const SizedBox(height: 8),
            _CompanyInfoEditor(
              info: companyInfo,
              globalState: globalState,
              onChanged: (info) => context.read<ConsumerDetailBloc>().add(
                ConsumerDetailCompanyChanged(info),
              ),
              onSelectGlobal: _selectGlobal,
              onSelectText: _selectText,
            ),
          ],
          const SizedBox(height: 12),
          _FacialRow(facial: doc.facial),
          const SizedBox(height: 12),
          for (final item in egxuList) ...[
            _EgxuCard(
              item: item,
              state: state,
              globalState: globalState,
              expanded:
                  item.id != null && state.expandedEgxuIds.contains(item.id),
              onToggle: item.id == null
                  ? null
                  : () => context.read<ConsumerDetailBloc>().add(
                      ConsumerDetailEgxuToggled(item.id!),
                    ),
              onRelationChanged: (relation) {
                final id = item.id;
                if (id == null) return;
                context.read<ConsumerDetailBloc>().add(
                  ConsumerDetailEgxuRelationChanged(
                    egxuId: id,
                    relation: relation,
                  ),
                );
              },
              onItemChanged: (item) => context.read<ConsumerDetailBloc>().add(
                ConsumerDetailEgxuItemChanged(item),
              ),
              onAddCert: item.id == null
                  ? null
                  : () => _pickFile(
                      ConsumerFileSlot.certificate,
                      egxuId: item.id,
                    ),
              onRemoveCert: (file) => context.read<ConsumerDetailBloc>().add(
                ConsumerDetailFileRemoved(
                  slot: ConsumerFileSlot.certificate,
                  egxuId: item.id,
                  file: file,
                ),
              ),
              onViewFile: _viewFile,
              onAction: _openEghuAction,
              onSelectGlobal: _selectGlobal,
              onSelectItem: _selectItem,
            ),
            const SizedBox(height: 12),
          ],
          ConsumerUploadSection(
            title: Words.technicalDocuments.tr(),
            sectionKey: 'technical',
            helpText: Words.uploadSectionHelp.tr(),
            helpKey: const Key('consumer-upload-help-technical'),
            files: state.technicalAll,
            onAdd: () => _pickFile(ConsumerFileSlot.technical),
            onRemove: (file) => context.read<ConsumerDetailBloc>().add(
              ConsumerDetailFileRemoved(
                slot: ConsumerFileSlot.technical,
                file: file,
              ),
            ),
            onView: _viewFile,
          ),
          const SizedBox(height: 12),
          ConsumerUploadSection(
            title: Words.contract.tr(),
            sectionKey: 'contract',
            helpText: Words.uploadSectionHelp.tr(),
            helpKey: const Key('consumer-upload-help-contract'),
            files: state.contractsAll,
            onAdd: () => _pickFile(ConsumerFileSlot.contract),
            onRemove: (file) => context.read<ConsumerDetailBloc>().add(
              ConsumerDetailFileRemoved(
                slot: ConsumerFileSlot.contract,
                file: file,
              ),
            ),
            onView: _viewFile,
          ),
        ],
      ),
    );
  }

  GlobalState? _globalStateOrNull() {
    try {
      return context.watch<GlobalBloc>().state;
    } catch (_) {
      return null;
    }
  }

  Future<GlobalModel?> _selectGlobal({
    required String title,
    required List<GlobalModel> items,
    required int? selectedId,
  }) {
    return showModalBottomSheet<GlobalModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectionSheet<GlobalModel>(
        title: title,
        items: items,
        selected: (item) => item.id == selectedId,
        label: (item) => item.name ?? item.fio ?? '-',
      ),
    );
  }

  Future<String?> _selectText({
    required String title,
    required List<String> items,
    required String? selected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectionSheet<String>(
        title: title,
        items: items,
        selected: (item) => item == selected,
        label: (item) => item,
      ),
    );
  }

  Future<SelectItem?> _selectItem({
    required String title,
    required List<SelectItem> items,
    required String? selectedCode,
  }) {
    return showModalBottomSheet<SelectItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectionSheet<SelectItem>(
        title: title,
        items: items,
        selected: (item) => item.code == selectedCode,
        label: (item) => item.label,
      ),
    );
  }

  void _openEghuAction(_EghuActionKind kind) {
    final page = switch (kind) {
      _EghuActionKind.reset => const EghuResetPage(),
      _EghuActionKind.detach => const EghuTakeOffPage(),
      _EghuActionKind.indicator => const EghuIndicatorUploadPage(),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _pickFile(ConsumerFileSlot slot, {int? egxuId}) async {
    final bloc = context.read<ConsumerDetailBloc>();
    final source = await showModalBottomSheet<EghuAttachmentSource>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EghuAttachmentSourceSheet(),
    );
    if (source == null) return;

    try {
      final file = source == EghuAttachmentSource.camera
          ? await _pickFromCamera()
          : await _pickFromDevice();
      if (file == null) return;

      bloc.add(ConsumerDetailFileAdded(slot: slot, egxuId: egxuId, file: file));
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

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          IconButton(
            key: const Key('consumer-detail-back-button'),
            constraints: const BoxConstraints.tightFor(width: 24, height: 24),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: 28,
              color: ConsumerDetailColors.textStrong,
            ),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              Words.documentDetails.tr(),
              textAlign: TextAlign.center,
              style: consumerText(
                fontSize: 17,
                lineHeight: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1D2E),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.state,
    required this.document,
    required this.companyInfo,
    required this.onDetails,
  });

  final ConsumerDetailState state;
  final WorkingWithConsumersDetailModel document;
  final ConsumersCompanyInfo? companyInfo;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    return _FigmaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SoftHeader(
            icon: Icons.description_outlined,
            title: '${Words.document.tr()} #${document.id ?? '-'}',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: ConsumerDetailColors.textSub,
                ),
                const SizedBox(width: 4),
                Text(
                  AppDateFormatter.dateFromString(document.datetime),
                  style: consumerText(
                    fontSize: 13,
                    lineHeight: 20,
                    color: ConsumerDetailColors.textSub,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _InfoText(label: Words.region.tr(), value: document.region?.name),
          _InfoText(label: Words.district.tr(), value: document.district?.name),
          _InfoText(label: Words.employee.tr(), value: document.employee?.fio),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _InfoText(
                  label: Words.consumer.tr(),
                  value: document.consumers?.name,
                  bottom: 0,
                ),
              ),
              if (onDetails != null)
                _SmallButton(
                  label: Words.detailsButton.tr(),
                  onTap: onDetails!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompanyInfoEditor extends StatelessWidget {
  const _CompanyInfoEditor({
    required this.info,
    required this.globalState,
    required this.onChanged,
    required this.onSelectGlobal,
    required this.onSelectText,
  });

  final ConsumersCompanyInfo info;
  final GlobalState? globalState;
  final ValueChanged<ConsumersCompanyInfo> onChanged;
  final Future<GlobalModel?> Function({
    required String title,
    required List<GlobalModel> items,
    required int? selectedId,
  })
  onSelectGlobal;
  final Future<String?> Function({
    required String title,
    required List<String> items,
    required String? selected,
  })
  onSelectText;

  @override
  Widget build(BuildContext context) {
    return _FigmaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SoftHeader(
            icon: Icons.apartment_rounded,
            title: Words.enterpriseInfo.tr(),
            trailing: _StatusChip(
              active: info.isActive ?? false,
              verified: true,
            ),
          ),
          const SizedBox(height: 12),
          _EditField(
            label: Words.accountNumber.tr(),
            value: info.accountNumber,
            bold: true,
            onChanged: (v) => onChanged(info.copyWith(accountNumber: v)),
          ),
          _EditField(
            label: Words.contractNumber.tr(),
            value: info.contractNumber,
            bold: true,
            onChanged: (v) => onChanged(info.copyWith(contractNumber: v)),
          ),
          _EditField(
            label: Words.directorName.tr(),
            value: info.companyDirector,
            bold: true,
            onChanged: (v) => onChanged(info.copyWith(companyDirector: v)),
          ),
          _SelectorField(
            label: Words.ministry.tr(),
            value: info.ministry?.name,
            bold: true,
            onTap: () async {
              final selected = await onSelectGlobal(
                title: Words.ministry.tr(),
                items: globalState?.ministries ?? const [],
                selectedId: info.ministryId ?? info.ministry?.id,
              );
              if (selected == null) return;
              onChanged(
                info.copyWith(
                  ministry: ConsumersLookup(
                    id: selected.id,
                    name: selected.name ?? selected.fio,
                  ),
                  ministryId: selected.id,
                ),
              );
            },
          ),
          _DateField(
            label: Words.contractStart.tr(),
            value: AppDateFormatter.dateFromString(info.contractDate),
            onChanged: (v) => onChanged(info.copyWith(contractDate: v)),
          ),
          _DateField(
            label: Words.contractEnd.tr(),
            value: AppDateFormatter.dateFromString(info.contractEndDate),
            onChanged: (v) => onChanged(info.copyWith(contractEndDate: v)),
          ),
          _EditField(
            label: Words.companyStir.tr(),
            value: info.companyTin,
            bold: true,
            onChanged: (v) => onChanged(info.copyWith(companyTin: v)),
          ),
          _EditField(
            label: Words.phoneNumber.tr(),
            value: info.phone,
            bold: true,
            keyboardType: TextInputType.phone,
            onChanged: (v) => onChanged(info.copyWith(phone: v)),
          ),
          _EditField(
            label: Words.email.tr(),
            value: info.email,
            bold: true,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => onChanged(info.copyWith(email: v)),
          ),
          _EditField(
            label: Words.address.tr(),
            value: info.address,
            bold: true,
            onChanged: (v) => onChanged(info.copyWith(address: v)),
          ),
          _EditField(
            label: Words.type.tr(),
            value: info.typeConsumers,
            bold: true,
            onChanged: (v) => onChanged(info.copyWith(typeConsumers: v)),
          ),
          _SelectorField(
            label: Words.season.tr(),
            value: info.season,
            bold: true,
            onTap: () async {
              final selected = await onSelectText(
                title: Words.season.tr(),
                items: _seasonOptions(),
                selected: info.season,
              );
              if (selected != null) {
                onChanged(info.copyWith(season: selected));
              }
            },
          ),
          _SelectorField(
            label: Words.status.tr(),
            value: (info.isActive ?? false)
                ? Words.active.tr()
                : Words.inactive.tr(),
            bold: true,
            bottom: 0,
            onTap: () async {
              final selected = await onSelectText(
                title: Words.status.tr(),
                items: [Words.active.tr(), Words.inactive.tr()],
                selected: (info.isActive ?? false)
                    ? Words.active.tr()
                    : Words.inactive.tr(),
              );
              if (selected != null) {
                onChanged(
                  info.copyWith(isActive: selected == Words.active.tr()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FacialRow extends StatelessWidget {
  const _FacialRow({required this.facial});

  final String? facial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: ConsumerDetailColors.field,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _IconBox(icon: Icons.menu_book_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Words.facialLabel.tr(),
                  style: consumerText(fontSize: 15, lineHeight: 24),
                ),
                const SizedBox(height: 2),
                Text(
                  facial?.isNotEmpty == true ? facial! : '-',
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
}

class _EgxuCard extends StatelessWidget {
  const _EgxuCard({
    required this.item,
    required this.state,
    required this.globalState,
    required this.expanded,
    required this.onToggle,
    required this.onRelationChanged,
    required this.onItemChanged,
    required this.onAddCert,
    required this.onRemoveCert,
    required this.onViewFile,
    required this.onAction,
    required this.onSelectGlobal,
    required this.onSelectItem,
  });

  final ConsumersEgxuItem item;
  final ConsumerDetailState state;
  final GlobalState? globalState;
  final bool expanded;
  final VoidCallback? onToggle;
  final ValueChanged<ConsumerRelationEgxu> onRelationChanged;
  final ValueChanged<ConsumersEgxuItem> onItemChanged;
  final VoidCallback? onAddCert;
  final ValueChanged<ConsumerUploadFile> onRemoveCert;
  final ValueChanged<ConsumerUploadFile> onViewFile;
  final ValueChanged<_EghuActionKind> onAction;
  final Future<GlobalModel?> Function({
    required String title,
    required List<GlobalModel> items,
    required int? selectedId,
  })
  onSelectGlobal;
  final Future<SelectItem?> Function({
    required String title,
    required List<SelectItem> items,
    required String? selectedCode,
  })
  onSelectItem;

  @override
  Widget build(BuildContext context) {
    final egxuId = item.id;
    final active = item.isActive ?? false;
    final relation = item.consumerRelationEgxu ?? ConsumerRelationEgxu();
    final certs = egxuId == null
        ? const <ConsumerUploadFile>[]
        : state.certificatesFor(egxuId);

    return _FigmaCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onToggle,
            child: _EgxuHeader(item: item, active: active, expanded: expanded),
          ),
          if (expanded) ...[
            const SizedBox(height: 8),
            const _DashedDivider(),
            const SizedBox(height: 8),
            _EgxuRelationEditor(
              item: item,
              relation: relation,
              globalState: globalState,
              onChanged: onRelationChanged,
              onItemChanged: onItemChanged,
              onSelectGlobal: onSelectGlobal,
              onSelectItem: onSelectItem,
            ),
            const SizedBox(height: 12),
            ConsumerUploadSection(
              title: Words.eghuCertificate.tr(),
              sectionKey: 'cert-$egxuId',
              helpText: Words.uploadSectionHelp.tr(),
              helpKey: Key('consumer-upload-help-cert-$egxuId'),
              files: certs,
              onAdd: onAddCert ?? () {},
              onRemove: onRemoveCert,
              onView: onViewFile,
            ),
            const SizedBox(height: 12),
            _EghuActionChip(
              title: Words.actionEghuReinstall.tr(),
              onTap: () => onAction(_EghuActionKind.reset),
            ),
            const SizedBox(height: 8),
            _EghuActionChip(
              title: Words.actionEghuDetach.tr(),
              onTap: () => onAction(_EghuActionKind.detach),
            ),
            const SizedBox(height: 8),
            _EghuActionChip(
              title: Words.actionEghuIndicatorUpload.tr(),
              onTap: () => onAction(_EghuActionKind.indicator),
            ),
          ],
        ],
      ),
    );
  }
}

class _EgxuHeader extends StatelessWidget {
  const _EgxuHeader({
    required this.item,
    required this.active,
    required this.expanded,
  });

  final ConsumersEgxuItem item;
  final bool active;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final factoryLines = _factoryLines(item);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: expanded ? ConsumerDetailColors.field : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _IconBox(
            icon: Icons.description_outlined,
            size: 48,
            radius: 12,
            iconSize: 24,
            color: active ? const Color(0xFFE3F7EC) : const Color(0xFFFEF3F2),
            iconColor: active
                ? const Color(0xFF1FC16B)
                : const Color(0xFFF04438),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EGXU #${item.id ?? '-'}',
                  style: consumerText(
                    fontSize: 15,
                    lineHeight: 24,
                    fontWeight: FontWeight.w800,
                    color: ConsumerDetailColors.textStrong,
                  ),
                ),
                if (factoryLines.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  for (final line in factoryLines)
                    Text(
                      line,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: consumerText(
                        fontSize: 11,
                        lineHeight: 16,
                        color: ConsumerDetailColors.textStrong,
                        letterSpacing: 0.4,
                      ),
                    ),
                ],
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (item.egxuType?.name != null)
                      _Chip(
                        label: item.egxuType!.name!,
                        color: ConsumerDetailColors.textStrong,
                        bg: ConsumerDetailColors.soft,
                      ),
                    _StatusChip(active: active),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            expanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 24,
            color: ConsumerDetailColors.textStrong,
          ),
        ],
      ),
    );
  }
}

class _EgxuRelationEditor extends StatelessWidget {
  const _EgxuRelationEditor({
    required this.item,
    required this.relation,
    required this.globalState,
    required this.onChanged,
    required this.onItemChanged,
    required this.onSelectGlobal,
    required this.onSelectItem,
  });

  final ConsumersEgxuItem item;
  final ConsumerRelationEgxu relation;
  final GlobalState? globalState;
  final ValueChanged<ConsumerRelationEgxu> onChanged;
  final ValueChanged<ConsumersEgxuItem> onItemChanged;
  final Future<GlobalModel?> Function({
    required String title,
    required List<GlobalModel> items,
    required int? selectedId,
  })
  onSelectGlobal;
  final Future<SelectItem?> Function({
    required String title,
    required List<SelectItem> items,
    required String? selectedCode,
  })
  onSelectItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NumberField(
          label: Words.extraGasUsage.tr(),
          value: relation.additionalGas,
          onChanged: (v) => onChanged(relation.copyWith(additionalGas: v)),
        ),
        _NumberField(
          label: Words.violationGasUsage.tr(),
          value: relation.violationGas,
          onChanged: (v) => onChanged(relation.copyWith(violationGas: v)),
        ),
        _NumberField(
          label: Words.additionalResidue.tr(),
          value: relation.additionalBalance,
          onChanged: (v) => onChanged(relation.copyWith(additionalBalance: v)),
        ),
        _NumberField(
          label: Words.monthStartIndicator.tr(),
          value: relation.monthStartReading,
          onChanged: (v) => onChanged(relation.copyWith(monthStartReading: v)),
        ),
        _NumberField(
          label: Words.monthEndIndicator.tr(),
          value: relation.monthEndReading,
          onChanged: (v) => onChanged(relation.copyWith(monthEndReading: v)),
        ),
        _NumberField(
          label: Words.indicatorDifference.tr(),
          value: relation.readingDifference,
          onChanged: (v) => onChanged(relation.copyWith(readingDifference: v)),
        ),
        _NumberField(
          label: Words.totalGasUsage.tr(),
          value: relation.totalGas,
          onChanged: (v) => onChanged(relation.copyWith(totalGas: v)),
        ),
        _SelectorField(
          label: Words.gtpExist.tr(),
          value: _boolLabel(relation.grpExists),
          onTap: () async {
            final selected = await onSelectItem(
              title: Words.gtpExist.tr(),
              items: _yesNoItems(),
              selectedCode: relation.grpExists == null
                  ? null
                  : relation.grpExists!
                  ? 'true'
                  : 'false',
            );
            if (selected != null) {
              onChanged(relation.copyWith(grpExists: selected.code == 'true'));
            }
          },
        ),
        _NumberField(
          label: Words.gtpLoss.tr(),
          value: relation.grpLoss,
          onChanged: (v) => onChanged(relation.copyWith(grpLoss: v)),
        ),
        _SelectorField(
          label: Words.status.tr(),
          value: (item.isActive ?? false)
              ? Words.active.tr()
              : Words.inactive.tr(),
          onTap: () async {
            final selected = await onSelectItem(
              title: Words.status.tr(),
              items: _activeStatusItems(),
              selectedCode: (item.isActive ?? false) ? 'active' : 'inactive',
            );
            if (selected != null) {
              onItemChanged(item.copyWith(isActive: selected.code == 'active'));
            }
          },
        ),
        _SelectorField(
          label: Words.meterStatus.tr(),
          value: relation.counterStatus,
          onTap: () async {
            final selected = await onSelectItem(
              title: Words.meterStatus.tr(),
              items: _counterStatusItems(),
              selectedCode: relation.counterStatus,
            );
            if (selected != null) {
              onChanged(relation.copyWith(counterStatus: selected.code));
            }
          },
        ),
        _SelectorField(
          label: Words.activityType.tr(),
          value: relation.typeOfActivity,
          onTap: () async {
            final selected = await onSelectGlobal(
              title: Words.activityType.tr(),
              items: globalState?.activityTypes ?? const [],
              selectedId: relation.typeOfActivityId,
            );
            if (selected != null) {
              onChanged(
                relation.copyWith(
                  typeOfActivity: selected.name ?? selected.fio,
                  typeOfActivityId: selected.id,
                ),
              );
            }
          },
        ),
        _SelectorField(
          label: Words.gasNetworkName.tr(),
          value: relation.gasNetworks,
          onTap: () async {
            final selected = await onSelectGlobal(
              title: Words.gasNetworkName.tr(),
              items: globalState?.gasNetworks ?? const [],
              selectedId: relation.gasNetworksId,
            );
            if (selected != null) {
              onChanged(
                relation.copyWith(
                  gasNetworks: selected.name ?? selected.fio,
                  gasNetworksId: selected.id,
                ),
              );
            }
          },
        ),
        _SelectorField(
          label: Words.eghuConnectionPoint.tr(),
          value: relation.egxuConnectionPoint,
          onTap: () async {
            final selected = await onSelectGlobal(
              title: Words.eghuConnectionPoint.tr(),
              items: globalState?.connectionPoints ?? const [],
              selectedId: relation.egxuConnectionPointId,
            );
            if (selected != null) {
              onChanged(
                relation.copyWith(
                  egxuConnectionPoint: selected.name ?? selected.fio,
                  egxuConnectionPointId: selected.id,
                ),
              );
            }
          },
        ),
        _EditField(
          label: Words.ghuId.tr(),
          value: relation.ghuIdNumber?.toString(),
          keyboardType: TextInputType.number,
          onChanged: (v) =>
              onChanged(relation.copyWith(ghuIdNumber: int.tryParse(v.trim()))),
        ),
        _SelectorField(
          label: Words.moveGtpAfterEghu.tr(),
          value: _moveGrpLabel(relation.movGrpAfterEgxu),
          onTap: () async {
            final selected = await onSelectItem(
              title: Words.moveGtpAfterEghu.tr(),
              items: _moveGrpItems(),
              selectedCode: relation.movGrpAfterEgxu,
            );
            if (selected != null) {
              onChanged(relation.copyWith(movGrpAfterEgxu: selected.code));
            }
          },
        ),
        _EditField(
          label: Words.violationReason.tr(),
          value: relation.reasonsForViolations,
          minLines: 1,
          maxLines: 3,
          bottom: 0,
          onChanged: (v) =>
              onChanged(relation.copyWith(reasonsForViolations: v)),
        ),
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.paddingOf(context).bottom + 10,
      ),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: enabled && !loading ? onTap : null,
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
              fontSize: 17,
              lineHeight: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _FigmaCard extends StatelessWidget {
  const _FigmaCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ConsumerDetailColors.stroke),
      ),
      child: child,
    );
  }
}

class _SoftHeader extends StatelessWidget {
  const _SoftHeader({required this.icon, required this.title, this.trailing});

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: ConsumerDetailColors.field,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _IconBox(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: consumerText(
                fontSize: 15,
                lineHeight: 24,
                fontWeight: FontWeight.w800,
                color: ConsumerDetailColors.textStrong,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    this.size = 40,
    this.radius = 8,
    this.iconSize = 20,
    this.color = ConsumerDetailColors.soft,
    this.iconColor = ConsumerDetailColors.textStrong,
  });

  final IconData icon;
  final double size;
  final double radius;
  final double iconSize;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, size: iconSize, color: iconColor),
    );
  }
}

class _InfoText extends StatelessWidget {
  const _InfoText({required this.label, required this.value, this.bottom = 8});

  final String label;
  final String? value;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: consumerText(
              fontSize: 11,
              lineHeight: 16,
              color: ConsumerDetailColors.textSub,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value?.trim().isNotEmpty == true ? value! : '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: consumerText(
              fontSize: 13,
              lineHeight: 20,
              fontWeight: FontWeight.w800,
              color: ConsumerDetailColors.textStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ConsumerDetailColors.soft,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: consumerText(
              fontSize: 13,
              lineHeight: 20,
              color: const Color(0xFF1A1D2E),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.keyboardType,
    this.suffix,
    this.trailingIcon,
    this.bold = false,
    this.readOnly = false,
    this.onTap,
    this.bottom = 6,
    this.minLines,
    this.maxLines = 1,
  });

  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final String? suffix;
  final IconData? trailingIcon;
  final bool bold;
  final bool readOnly;
  final VoidCallback? onTap;
  final double bottom;
  final int? minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: consumerText(
              fontSize: 11,
              lineHeight: 16,
              color: ConsumerDetailColors.textSub,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            key: readOnly ? ValueKey('$label-$value') : null,
            initialValue: value?.trim().isNotEmpty == true ? value : '',
            onChanged: onChanged,
            onTap: onTap,
            readOnly: readOnly,
            keyboardType: keyboardType,
            minLines: minLines,
            maxLines: maxLines,
            style: consumerText(
              fontSize: 13,
              lineHeight: 20,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: ConsumerDetailColors.textStrong,
            ),
            decoration: InputDecoration(
              hintText: '-',
              hintStyle: consumerText(
                fontSize: 13,
                lineHeight: 20,
                color: ConsumerDetailColors.textSub,
              ),
              suffixText: suffix,
              suffixStyle: consumerText(
                fontSize: 13,
                lineHeight: 20,
                color: ConsumerDetailColors.textSub,
              ),
              suffixIcon: trailingIcon == null
                  ? null
                  : Icon(
                      trailingIcon,
                      size: 20,
                      color: ConsumerDetailColors.textSub,
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: _inputBorder(),
              enabledBorder: _inputBorder(),
              focusedBorder: _inputBorder(ConsumerDetailColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _EditField(
      label: label,
      value: (value ?? 0).toStringAsFixed(2),
      suffix: 'm³',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (v) => onChanged(double.tryParse(v.replaceAll(',', '.'))),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _EditField(
      label: label,
      value: value,
      bold: true,
      readOnly: true,
      trailingIcon: Icons.calendar_today_rounded,
      onTap: () async {
        final initial = _parseDate(value) ?? DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(AppDateFormatter.date(picked));
        }
      },
      onChanged: (_) {},
    );
  }
}

class _SelectorField extends StatelessWidget {
  const _SelectorField({
    required this.label,
    required this.value,
    required this.onTap,
    this.bold = false,
    this.bottom = 6,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool bold;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return _EditField(
      label: label,
      value: value,
      bold: bold,
      readOnly: true,
      trailingIcon: Icons.keyboard_arrow_down_rounded,
      bottom: bottom,
      onTap: onTap,
      onChanged: (_) {},
    );
  }
}

class _EghuActionChip extends StatelessWidget {
  const _EghuActionChip({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ConsumerDetailColors.soft,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              const SizedBox(width: 12),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.speed_rounded,
                  size: 18,
                  color: ConsumerDetailColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: consumerText(
                    fontSize: 13,
                    lineHeight: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 24),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active, this.verified = false});

  final bool active;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return _Chip(
      label: active ? Words.active.tr() : Words.inactive.tr(),
      color: Colors.white,
      bg: active
          ? (verified ? const Color(0xFF47C2FF) : const Color(0xFF1FC16B))
          : const Color(0xFFF04438),
      icon: verified ? null : Icons.sell_outlined,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.bg,
    this.icon,
  });

  final String label;
  final Color color;
  final Color bg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: consumerText(
              fontSize: 11,
              lineHeight: 16,
              fontWeight: FontWeight.w500,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedLinePainter(),
      child: const SizedBox(height: 1, width: double.infinity),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE1E1E1)
      ..strokeWidth = 1;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 6, 0), paint);
      x += 10;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SelectionSheet<T> extends StatefulWidget {
  const _SelectionSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.label,
  });

  final String title;
  final List<T> items;
  final bool Function(T item) selected;
  final String Function(T item) label;

  @override
  State<_SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<_SelectionSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where(
          (item) =>
              widget.label(item).toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 390,
            maxHeight: MediaQuery.sizeOf(context).height * 0.75,
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.paddingOf(context).bottom + 12,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 39,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1E1E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: consumerText(
                  fontSize: 17,
                  lineHeight: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                style: consumerText(fontSize: 13, lineHeight: 20),
                decoration: InputDecoration(
                  hintText: Words.search.tr().replaceAll('...', ''),
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: ConsumerDetailColors.field,
                  border: _inputBorder(),
                  enabledBorder: _inputBorder(),
                  focusedBorder: _inputBorder(ConsumerDetailColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text(Words.noInformationFound.tr()))
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isSelected = widget.selected(item);
                          return Material(
                            color: isSelected
                                ? ConsumerDetailColors.primary.withValues(
                                    alpha: 0.1,
                                  )
                                : ConsumerDetailColors.field,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.of(context).pop(item),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.label(item),
                                        style: consumerText(
                                          fontSize: 13,
                                          lineHeight: 20,
                                          color: isSelected
                                              ? ConsumerDetailColors.primary
                                              : ConsumerDetailColors.textStrong,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: ConsumerDetailColors.primary,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(Words.retry.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

enum _EghuActionKind { reset, detach, indicator }

OutlineInputBorder _inputBorder([Color color = ConsumerDetailColors.stroke]) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );
}

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty || value == '-') return null;
  final iso = DateTime.tryParse(value);
  if (iso != null) return iso;
  final parts = value.split('.');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}

String _boolLabel(bool? value) {
  if (value == null) return '-';
  return value ? Words.yes.tr() : Words.no.tr();
}

List<String> _factoryLines(ConsumersEgxuItem item) {
  final one = item.oneFactory?.trim();
  final two = item.twoFactory?.trim();
  return [
    if (one != null && one.isNotEmpty) '${Words.factoryOne.tr()}: $one',
    if (two != null && two.isNotEmpty) '${Words.factoryTwo.tr()}: $two',
  ];
}

String _moveGrpLabel(String? code) {
  return _moveGrpItems()
          .where((item) => item.code == code)
          .map((item) => item.label)
          .firstOrNull ??
      code ??
      '-';
}

List<String> _seasonOptions() => ['Bahor', 'Yoz', 'Kuz', 'Qish'];

List<SelectItem> _yesNoItems() => [
  SelectItem(code: 'true', label: Words.yes.tr()),
  SelectItem(code: 'false', label: Words.no.tr()),
];

List<SelectItem> _counterStatusItems() => [
  SelectItem(code: 'Installed', label: Words.installed.tr()),
  SelectItem(
    code: 'TemporarilyDisabled',
    label: Words.temporarilyDisabled.tr(),
  ),
  SelectItem(code: 'Untied', label: Words.untied.tr()),
  SelectItem(code: 'New', label: Words.newItem.tr()),
];

List<SelectItem> _activeStatusItems() => [
  SelectItem(code: 'active', label: Words.active.tr()),
  SelectItem(code: 'inactive', label: Words.inactive.tr()),
];

List<SelectItem> _moveGrpItems() => [
  SelectItem(code: 'BEFORE_EGHU', label: Words.beforeEghu.tr()),
  SelectItem(code: 'AFTER_EGHU', label: Words.afterEghu.tr()),
];
