import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../../../core/common/words.dart';
import '../../../../../../../core/extension/message_extension.dart';
import '../../../../../../../di.dart';
import '../../../../../../../features/auth/presentation/bloc/login_bloc.dart';
import '../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../data/models/eghu_removal_flow.dart';
import '../widgets/create/eghu_action_bottom_sheets.dart';
import '../widgets/create/eghu_action_form_fields.dart';

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
  final _removedIds = <int?>{};
  int? _removingId;

  @override
  void initState() {
    super.initState();
    final api = widget.api ?? di.get<EghuActionApi>();
    final documentId =
        widget.preselection.detail.id ?? widget.preselection.consumer.id;
    _targetInfoFuture = widget.targetInfo != null
        ? Future<EghuTargetInfo>.value(widget.targetInfo!)
        : api.getTargetInfo(documentType: 'consumer', documentId: documentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EghuActionCreateColors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  _Header(title: Words.stamps.tr()),
                  const SizedBox(height: 20),
                  _Summary(preselection: widget.preselection),
                  const SizedBox(height: 20),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<EghuTargetInfo>(
      future: _targetInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorState(
            message: snapshot.error.toString().replaceAll('Exception: ', ''),
            onRetry: () => setState(() {
              final api = widget.api ?? di.get<EghuActionApi>();
              final id =
                  widget.preselection.detail.id ??
                  widget.preselection.consumer.id;
              _targetInfoFuture = api.getTargetInfo(
                documentType: 'consumer',
                documentId: id,
              );
            }),
          );
        }

        _egxu ??= _findEgxu(snapshot.data!);
        final stamps =
            _egxu?.reals
                .where((stamp) => !_removedIds.contains(stamp.id))
                .toList() ??
            const <EghuTargetInfoReal>[];
        if (stamps.isEmpty) {
          return Center(child: Text(Words.noStampsAdded.tr()));
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: stamps.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) => _StampCard(
            stamp: stamps[index],
            loading: _removingId == stamps[index].id,
            onRemove: () => _removeStamp(stamps[index]),
          ),
        );
      },
    );
  }

  EghuTargetInfoEgxu? _findEgxu(EghuTargetInfo info) {
    final selectedId = widget.preselection.eghu.id;
    for (final item in info.egxus) {
      if (item.id == selectedId) return item;
    }
    return info.egxus.isEmpty ? null : info.egxus.first;
  }

  Future<void> _removeStamp(EghuTargetInfoReal stamp) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => _RemoveStampDialog(stamp: stamp),
    );
    if (!mounted || confirmed != true || _egxu?.id == null) return;

    setState(() => _removingId = stamp.id);
    try {
      final profile = _profile();
      final detail = widget.preselection.detail;
      await (widget.api ?? di.get<EghuActionApi>()).removeStamp(
        EghuStampRemovalRequest(
          datetime: widget.removalDateTime,
          egxuId: _egxu!.id!,
          stamp: stamp,
          regionId: detail.region?.id ?? profile?.user?.regionId,
          districtId: detail.district?.id ?? profile?.user?.districtId,
          typeOfActivityId:
              widget.activityTypeId ??
              widget.preselection.eghu.consumerRelationEgxu?.typeOfActivityId,
          employeeId: profile?.user?.employeeId ?? detail.employee?.id,
          fullName: profile?.user?.username ?? detail.employee?.fio,
        ),
      );
      if (!mounted) return;
      setState(() {
        _removedIds.add(stamp.id);
        _removingId = null;
      });
      showToast(
        context,
        Words.sealRemoved.tr(),
        backgroundColor: const Color(0xFF17B26A),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _removingId = null);
      showToast(context, error.toString().replaceAll('Exception: ', ''));
    }
  }

  LoginState? _profile() {
    try {
      return context.read<LoginBloc>().state;
    } catch (_) {
      return null;
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: const Icon(Icons.chevron_left_rounded, size: 28),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: eghuText(
                fontSize: 17,
                lineHeight: 28,
                fontWeight: FontWeight.w800,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.preselection});

  final EghuActionPreselection preselection;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EghuActionCreateColors.field,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EghuActionCreateColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            preselection.consumer.consumers,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: eghuText(
              fontSize: 15,
              lineHeight: 24,
              fontWeight: FontWeight.w800,
              color: EghuActionCreateColors.textStrong,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            eghuTitle(preselection.eghu),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: eghuText(
              fontSize: 13,
              lineHeight: 20,
              color: EghuActionCreateColors.textSub,
            ),
          ),
        ],
      ),
    );
  }
}

class _StampCard extends StatelessWidget {
  const _StampCard({
    required this.stamp,
    required this.loading,
    required this.onRemove,
  });

  final EghuTargetInfoReal stamp;
  final bool loading;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EghuActionCreateColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stamp.number,
                  style: eghuText(
                    fontSize: 15,
                    lineHeight: 24,
                    fontWeight: FontWeight.w800,
                    color: EghuActionCreateColors.textStrong,
                  ),
                ),
              ),
              _StatusChip(status: stamp.status),
            ],
          ),
          const SizedBox(height: 8),
          if (stamp.installedDate != null)
            _DetailLine(
              label: Words.installedDate.tr(),
              value: DateFormat(
                'dd.MM.yyyy',
              ).format(stamp.installedDate!.toLocal()),
            ),
          if (stamp.sealLocation?.isNotEmpty == true)
            _DetailLine(
              label: Words.sealLocation.tr(),
              value: stamp.sealLocation!,
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              key: Key('eghu-remove-stamp-${stamp.id}'),
              onPressed: loading ? null : onRemove,
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.remove_circle_outline_rounded, size: 18),
              label: Text(Words.removeStamp.tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: EghuActionCreateColors.primary,
                side: const BorderSide(color: EghuActionCreateColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: eghuText(
                fontSize: 11,
                lineHeight: 16,
                color: EghuActionCreateColors.textSub,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: eghuText(fontSize: 12, lineHeight: 18)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final value = status?.trim();
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: eghuText(
          fontSize: 11,
          lineHeight: 16,
          color: const Color(0xFF16854B),
        ),
      ),
    );
  }
}

class _RemoveStampDialog extends StatelessWidget {
  const _RemoveStampDialog({required this.stamp});

  final EghuTargetInfoReal stamp;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Words.removeStamp.tr(),
              textAlign: TextAlign.center,
              style: eghuText(
                fontSize: 20,
                lineHeight: 28,
                fontWeight: FontWeight.w800,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stamp.number,
              textAlign: TextAlign.center,
              style: eghuText(
                fontSize: 15,
                lineHeight: 24,
                color: EghuActionCreateColors.textSub,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(Words.back.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: EghuActionCreateColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(Words.confirm.tr()),
                  ),
                ),
              ],
            ),
          ],
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(Words.retry.tr())),
        ],
      ),
    );
  }
}
