import 'package:flutter/material.dart';
import 'package:m_gaz/di.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

import '../../../../../../../core/common/words.dart';
import '../../../../../../../core/extension/message_extension.dart';
import '../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../data/models/eghu_removal_flow.dart';
import '../widgets/create/eghu_action_bottom_sheets.dart';
import '../widgets/create/eghu_action_form_fields.dart';
import 'eghu_removal_page_widgets.dart';

class EghuRemovalSummaryPage extends StatefulWidget {
  const EghuRemovalSummaryPage({
    super.key,
    required this.preselection,
    required this.removalDateTime,
    required this.targetInfo,
    required this.removalReason,
    required this.gasUsageStatus,
    required this.replacementReason,
    required this.gasEquipments,
    required this.realNumbers,
    this.activityTypeId,
    this.api,
  });

  final EghuActionPreselection preselection;
  final DateTime removalDateTime;
  final EghuTargetInfo targetInfo;
  final String removalReason;
  final String gasUsageStatus;
  final String replacementReason;
  final List<EghuRemovalGasEquipment> gasEquipments;
  final List<EghuTargetInfoReal> realNumbers;
  final int? activityTypeId;
  final EghuRemovalFlowApi? api;

  @override
  State<EghuRemovalSummaryPage> createState() => _EghuRemovalSummaryPageState();
}

class _EghuRemovalSummaryPageState extends State<EghuRemovalSummaryPage> {
  final _documentNumberController = TextEditingController();
  bool _submitting = false;
  bool _documentNumberError = false;

  bool get _hasDocumentNumber =>
      _documentNumberController.text.trim().isNotEmpty;

  EghuTargetInfoEgxu? get _egxu {
    final selectedId = widget.preselection.eghu.id;
    for (final item in widget.targetInfo.egxus) {
      if (item.id == selectedId) return item;
    }
    return widget.targetInfo.egxus.isEmpty
        ? null
        : widget.targetInfo.egxus.first;
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    super.dispose();
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
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EghuRemovalHeader(title: Words.actionEghuDetach.tr()),
                        const SizedBox(height: 20),
                        _documentNumberField(),
                        const SizedBox(height: 16),
                        _summaryCard(),
                      ],
                    ),
                  ),
                ),
                _bottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _documentNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hujjat nomeri', style: eghuText(fontSize: 11, lineHeight: 16)),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: TextField(
            key: const Key('eghu-removal-document-number'),
            controller: _documentNumberController,
            onChanged: (_) => setState(() => _documentNumberError = false),
            textCapitalization: TextCapitalization.characters,
            style: eghuText(
              fontSize: 17,
              lineHeight: 24,
              color: EghuActionCreateColors.textStrong,
            ),
            decoration: InputDecoration(
              hintText: 'HJ-2026-0432',
              hintStyle: eghuText(
                fontSize: 17,
                lineHeight: 24,
                color: EghuActionCreateColors.textSub,
              ),
              suffixIcon: IconButton(
                tooltip: 'Tozalash',
                onPressed: () {
                  _documentNumberController.clear();
                  setState(() => _documentNumberError = false);
                },
                icon: AppTools.svg(AppTools.x, width: 18, height: 18),
              ),
              filled: true,
              fillColor: EghuActionCreateColors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: EghuActionCreateColors.stroke,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: EghuActionCreateColors.stroke,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: EghuActionCreateColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        if (_documentNumberError)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              'Hujjat nomeri kiritilishi shart',
              style: eghuText(
                fontSize: 11,
                lineHeight: 16,
                color: const Color(0xFFDC2626),
              ),
            ),
          ),
      ],
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EghuActionCreateColors.field,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hujjat xulosasi',
                  style: eghuText(
                    fontSize: 17,
                    lineHeight: 28,
                    fontWeight: FontWeight.w800,
                    color: EghuActionCreateColors.textStrong,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: EghuActionCreateColors.soft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Qoralama',
                  style: eghuText(
                    fontSize: 13,
                    lineHeight: 20,
                    fontWeight: FontWeight.w800,
                    color: EghuActionCreateColors.textStrong,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _summaryItem('Sana', _date(widget.removalDateTime.toLocal())),
          _summaryItem('Hudud', _regionDistrict),
          _summaryItem('Iste’molchi', _consumer),
          _summaryItem('EGHU', _egxuSummary),
          _summaryItem('Sabab', _reasonLabel),
          _summaryItem('Gaz iste’moli', _gasSummary),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: eghuText(fontSize: 13, lineHeight: 20)),
          const SizedBox(height: 2),
          Text(
            value,
            style: eghuText(
              fontSize: 17,
              lineHeight: 24,
              fontWeight: FontWeight.w800,
              color: EghuActionCreateColors.textStrong,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      color: EghuActionCreateColors.white,
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.paddingOf(context).bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: _bottomButton(
              key: const Key('eghu-removal-save-button'),
              label: Words.save.tr(),
              color: const Color(0xFF3F57B3),
              onTap: _save,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _bottomButton(
              key: const Key('eghu-removal-confirm-button'),
              label: Words.confirm.tr(),
              color: const Color(0xFF3FB343),
              onTap: _confirm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButton({
    required Key key,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        key: key,
        onPressed: _submitting ? null : onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          disabledBackgroundColor: EghuActionCreateColors.soft,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
          textStyle: eghuText(
            fontSize: 17,
            lineHeight: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTools.svg(
              AppTools.check,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_validateDocumentNumber()) return;
    final accepted = await _showActionDialog(confirm: false);
    if (!mounted || accepted != true) return;
    await _submit(confirm: false);
  }

  Future<void> _confirm() async {
    if (!_validateDocumentNumber()) return;
    final accepted = await _showActionDialog(confirm: true);
    if (!mounted || accepted != true) return;
    await _submit(confirm: true);
  }

  bool _validateDocumentNumber() {
    if (_hasDocumentNumber) return true;
    setState(() => _documentNumberError = true);
    return false;
  }

  Future<bool?> _showActionDialog({required bool confirm}) {
    return showDialog<bool>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => _RemovalDocumentActionDialog(
        confirm: confirm,
        documentNumber: _documentNumberController.text.trim(),
      ),
    );
  }

  Future<void> _submit({required bool confirm}) async {
    if (_submitting) return;
    final egxuId = _egxu?.id ?? widget.preselection.eghu.id;
    if (egxuId == null) return;

    setState(() => _submitting = true);
    try {
      final api = widget.api ?? di.get<EghuActionApi>();
      final documentId = await api.createRemoval(
        EghuStampRemovalRequest(
          datetime: widget.removalDateTime,
          documentId:
              widget.preselection.detail.id ?? widget.preselection.consumer.id,
          egxuId: egxuId,
          regionId: widget.preselection.detail.region?.id,
          districtId: widget.preselection.detail.district?.id,
          typeOfActivityId:
              widget.activityTypeId ??
              widget.preselection.eghu.consumerRelationEgxu?.typeOfActivityId,
          employeeId: widget.preselection.detail.employee?.id,
          fullName: widget.preselection.detail.employee?.fio,
          documentNumber: _documentNumberController.text.trim(),
          removalReason: widget.removalReason,
          gasUsageStatus: widget.gasUsageStatus,
          replacementReason: widget.replacementReason,
          gasEquipments: widget.gasEquipments,
          realNumbers: widget.realNumbers,
        ),
      );
      if (confirm) {
        await api.changeRemovalStatus(
          documentId: documentId,
          status: 'confirmed',
        );
      }
      if (!mounted) return;
      showToast(
        context,
        confirm ? 'Hujjat tasdiqlandi' : 'Hujjat saqlandi',
        backgroundColor: const Color(0xFF17B26A),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showToast(context, error.toString().replaceAll('Exception: ', ''));
    }
  }

  String get _regionDistrict {
    final values = [
      widget.preselection.detail.region?.name,
      widget.preselection.detail.district?.name,
    ].where((value) => value?.trim().isNotEmpty == true).join(', ');
    return values.isEmpty ? '-' : values;
  }

  String get _consumer {
    final values = <String>[
      if (widget.preselection.consumer.consumers.trim().isNotEmpty)
        widget.preselection.consumer.consumers,
      if (widget.preselection.consumer.facial.trim().isNotEmpty)
        widget.preselection.consumer.facial,
    ].join(', ');
    return values.isEmpty ? '-' : values;
  }

  String get _egxuSummary {
    final type =
        _egxu?.typeName ?? widget.preselection.eghu.egxuType?.name ?? '-';
    String? serial;
    for (final value in <String?>[
      _egxu?.oneFactory,
      _egxu?.twoFactory,
      widget.preselection.eghu.oneFactory,
      widget.preselection.eghu.twoFactory,
    ]) {
      if (value?.trim().isNotEmpty == true) {
        serial = value;
        break;
      }
    }
    return serial?.trim().isNotEmpty == true ? '$type, $serial' : type;
  }

  String get _reasonLabel => switch (widget.removalReason) {
    'for_certificate_replacement' => 'Sertifikat yangilash uchun',
    'for_repair' => 'Ta’mirlash uchun',
    _ => 'Boshqa EGHU bilan almashtirish',
  };

  String get _gasSummary {
    if (widget.gasEquipments.isEmpty) {
      return widget.realNumbers.isEmpty
          ? '-'
          : '${widget.realNumbers.length} ta tamg’a';
    }
    final total = widget.gasEquipments.fold<double>(
      0,
      (sum, item) =>
          sum + item.hourlyGasConsumption * item.operatingHours * item.quantity,
    );
    return '${widget.gasEquipments.length} ta anjom, ${_format(total, 1)} m³';
  }

  String _format(num value, int decimals) =>
      value.toStringAsFixed(decimals).replaceAll('.', ',');

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
}

class _RemovalDocumentActionDialog extends StatelessWidget {
  const _RemovalDocumentActionDialog({
    required this.confirm,
    required this.documentNumber,
  });

  final bool confirm;
  final String documentNumber;

  @override
  Widget build(BuildContext context) {
    final save = !confirm;
    final description = save
        ? (documentNumber.isEmpty
              ? 'Hujjat qoralama sifatida saqlanadi. Keyinroq davom '
                    'ettirishingiz mumkin.'
              : '$documentNumber hujjati qoralama sifatida saqlanadi. '
                    'Keyinroq davom ettirishingiz mumkin.')
        : 'Tasdiqlangandan keyin hujjat tahrirlanmaydi. EGHU yechib olingan deb '
              'qayd etiladi.';
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFC),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x38000000),
              blurRadius: 36,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              save ? 'Hujjatni saqlaysizmi?' : 'Hujjatni tasdiqlaysizmi?',
              style: eghuText(
                fontSize: 17,
                lineHeight: 28,
                fontWeight: FontWeight.w800,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
            const SizedBox(height: 8),
            Text(description, style: eghuText(fontSize: 13, lineHeight: 20)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SummaryDialogButton(
                    label: Words.cancel.tr(),
                    background: const Color(0xFFF0F0F0),
                    foreground: EghuActionCreateColors.textStrong,
                    icon: AppTools.svg(AppTools.x, width: 16, height: 16),
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryDialogButton(
                    label: confirm ? Words.confirm.tr() : Words.save.tr(),
                    background: confirm
                        ? const Color(0xFF3FB343)
                        : const Color(0xFF3F57B3),
                    foreground: Colors.white,
                    icon: AppTools.svg(
                      AppTools.check,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(true),
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

class _SummaryDialogButton extends StatelessWidget {
  const _SummaryDialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 6),
            Text(
              label,
              style: eghuText(
                fontSize: 13,
                lineHeight: 20,
                fontWeight: FontWeight.w800,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
