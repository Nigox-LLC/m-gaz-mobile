import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../../core/common/words.dart';
import '../../../../../../../di.dart';
import '../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../data/models/eghu_removal_flow.dart';
import '../widgets/create/eghu_action_bottom_sheets.dart';
import '../widgets/create/eghu_action_form_fields.dart';
import 'eghu_removal_details_page.dart';
import 'eghu_removal_page_widgets.dart';

class EghuRemovalStampsPage extends StatefulWidget {
  const EghuRemovalStampsPage({
    super.key,
    required this.preselection,
    required this.removalDateTime,
    this.activityTypeId,
    this.api,
    this.targetInfo,
  });

  final EghuActionPreselection preselection;
  final DateTime removalDateTime;
  final int? activityTypeId;
  final EghuRemovalFlowApi? api;
  final EghuTargetInfo? targetInfo;

  @override
  State<EghuRemovalStampsPage> createState() => _EghuRemovalStampsPageState();
}

class _EghuRemovalStampsPageState extends State<EghuRemovalStampsPage> {
  late Future<EghuTargetInfo> _targetInfoFuture;
  EghuTargetInfoEgxu? _egxu;
  EghuTargetInfo? _loadedTargetInfo;

  @override
  void initState() {
    super.initState();
    final api = widget.api ?? di.get<EghuActionApi>();
    final documentId =
        widget.preselection.detail.id ?? widget.preselection.consumer.id;
    _targetInfoFuture = widget.targetInfo != null
        ? Future<EghuTargetInfo>.value(widget.targetInfo!)
        : api.getTargetInfo(documentType: 'consumer', documentId: documentId);
    _targetInfoFuture.then((info) {
      if (!mounted) return;
      setState(() {
        _loadedTargetInfo = info;
        _egxu = _findEgxu(info);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final canContinue =
        _egxu?.id != null ||
        (_loadedTargetInfo?.egxus.any(_isSelectable) ?? false);
    return Scaffold(
      backgroundColor: EghuActionCreateColors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: FutureBuilder<EghuTargetInfo>(
                      future: _targetInfoFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return Column(
                            children: [
                              EghuRemovalHeader(
                                title: Words.actionEghuDetach.tr(),
                              ),
                              const SizedBox(height: 32),
                              const CircularProgressIndicator(),
                            ],
                          );
                        }
                        if (snapshot.hasError) {
                          return Column(
                            children: [
                              EghuRemovalHeader(
                                title: Words.actionEghuDetach.tr(),
                              ),
                              const SizedBox(height: 32),
                              _ErrorState(
                                message: snapshot.error.toString().replaceAll(
                                  'Exception: ',
                                  '',
                                ),
                                onRetry: _retry,
                              ),
                            ],
                          );
                        }

                        final info = snapshot.data!;
                        final eghu = _egxu ?? _findEgxu(info);
                        return _buildContent(eghu);
                      },
                    ),
                  ),
                ),
                EghuRemovalNextBar(enabled: canContinue, onTap: _continue),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(EghuTargetInfoEgxu? eghu) {
    final selectedEghu = widget.preselection.eghu;
    final typeName = eghu?.typeName ?? selectedEghu.egxuType?.name ?? '-';
    final factoryNumber =
        eghu?.oneFactory ??
        eghu?.twoFactory ??
        selectedEghu.oneFactory ??
        selectedEghu.twoFactory ??
        '-';
    final stamps = (eghu?.reals ?? const <EghuTargetInfoReal>[])
        .where((stamp) => stamp.removeSeal != true)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EghuRemovalHeader(title: Words.actionEghuDetach.tr()),
        const SizedBox(height: 20),
        EghuRemovalField(
          label: 'Isteʼmolchiga tegishli boʻlgan EGHU turi',
          value: typeName,
          trailing: EghuRemovalFieldTrailing.close,
        ),
        const SizedBox(height: 12),
        EghuRemovalField(
          label: 'Isteʼmolchiga tegishli boʻlgan EGHU raqami',
          value: factoryNumber,
          trailing: EghuRemovalFieldTrailing.close,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Words.stamps.tr(),
              style: eghuText(
                fontSize: 13,
                lineHeight: 20,
                fontWeight: FontWeight.w800,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
            Text(
              '${stamps.length} ta',
              style: eghuText(
                fontSize: 11,
                lineHeight: 16,
                color: EghuActionCreateColors.textSub,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (stamps.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                Words.noStampsAdded.tr(),
                style: eghuText(
                  fontSize: 13,
                  lineHeight: 20,
                  color: EghuActionCreateColors.textSub,
                ),
              ),
            ),
          )
        else
          ...stamps.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _StampCard(index: entry.key + 1, stamp: entry.value),
            ),
          ),
      ],
    );
  }

  EghuTargetInfoEgxu? _findEgxu(EghuTargetInfo info) {
    final selectedId = widget.preselection.eghu.id;
    for (final item in info.egxus) {
      if (item.id == selectedId && _isSelectable(item)) return item;
    }
    for (final item in info.egxus) {
      if (_isSelectable(item)) return item;
    }
    return null;
  }

  bool _isSelectable(EghuTargetInfoEgxu item) => item.canBeRemoved;

  void _retry() {
    final api = widget.api ?? di.get<EghuActionApi>();
    final id = widget.preselection.detail.id ?? widget.preselection.consumer.id;
    setState(() {
      _egxu = null;
      _loadedTargetInfo = null;
      _targetInfoFuture = api.getTargetInfo(
        documentType: 'consumer',
        documentId: id,
      );
      _targetInfoFuture.then((info) {
        if (!mounted) return;
        setState(() {
          _loadedTargetInfo = info;
          _egxu = _findEgxu(info);
        });
      });
    });
  }

  Future<void> _continue() async {
    final info = _loadedTargetInfo;
    final eghu = _egxu ?? (info == null ? null : _findEgxu(info));
    if (eghu?.id == null || info == null) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EghuRemovalDetailsPage(
          preselection: widget.preselection,
          removalDateTime: widget.removalDateTime,
          activityTypeId: widget.activityTypeId,
          targetInfo: info,
          api: widget.api,
        ),
      ),
    );
    if (saved == true && mounted) Navigator.of(context).pop(true);
  }
}

class _StampCard extends StatelessWidget {
  const _StampCard({required this.index, required this.stamp});

  final int index;
  final EghuTargetInfoReal stamp;

  @override
  Widget build(BuildContext context) {
    final defective = _isDefective(stamp.status);
    final location =
        stamp.sealLocation ??
        stamp.installedLocation ??
        (stamp.installedDate == null
            ? '-'
            : DateFormat('dd.MM.yyyy').format(stamp.installedDate!.toLocal()));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: EghuActionCreateColors.field,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$index',
                style: eghuText(
                  fontSize: 11,
                  lineHeight: 16,
                  fontWeight: FontWeight.w800,
                  color: EghuActionCreateColors.text,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stamp.number,
                  style: eghuText(
                    fontSize: 13,
                    lineHeight: 20,
                    fontWeight: FontWeight.w800,
                    color: EghuActionCreateColors.textStrong,
                  ),
                ),
              ),
              _StatusChip(defective: defective),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: eghuText(fontSize: 11, lineHeight: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isDefective(String? status) {
    final normalized = status?.toLowerCase() ?? '';
    return normalized.contains('shikast') || normalized.contains('nosoz');
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.defective});

  final bool defective;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: defective ? const Color(0xFFFEF2F2) : const Color(0xFFEDF9F1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        defective ? 'Muhri shikastlangan' : 'Muhrlangan',
        style: eghuText(
          fontSize: 11,
          lineHeight: 16,
          fontWeight: FontWeight.w800,
          color: defective ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        TextButton(onPressed: onRetry, child: Text(Words.retry.tr())),
      ],
    );
  }
}
