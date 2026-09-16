import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_gaz/core/api/global/global_api.dart';
import 'package:m_gaz/core/models/global/global_model.dart';
import 'package:m_gaz/di.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

import '../../../../../../../core/common/words.dart';
import '../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../data/models/eghu_removal_flow.dart';
import '../widgets/create/eghu_action_bottom_sheets.dart';
import '../widgets/create/eghu_action_form_fields.dart';
import 'eghu_removal_page_widgets.dart';
import 'eghu_removal_summary_page.dart';

class EghuRemovalDetailsPage extends StatefulWidget {
  const EghuRemovalDetailsPage({
    super.key,
    required this.preselection,
    required this.removalDateTime,
    required this.targetInfo,
    this.removedStampIds = const {},
    this.activityTypeId,
    this.api,
    this.globalApi,
  });

  final EghuActionPreselection preselection;
  final DateTime removalDateTime;
  final EghuTargetInfo targetInfo;
  final Set<int?> removedStampIds;
  final int? activityTypeId;
  final EghuRemovalFlowApi? api;
  final GlobalApi? globalApi;

  @override
  State<EghuRemovalDetailsPage> createState() => _EghuRemovalDetailsPageState();
}

class _EghuRemovalDetailsPageState extends State<EghuRemovalDetailsPage> {
  late final EghuTargetInfoEgxu? _egxu;
  late final Future<List<EghuTargetInfoGasEquipment>> _equipmentOptions;
  final _equipment = <_SelectedGasEquipment>[];
  final _selectedStamps = <EghuTargetInfoReal>[];
  String _removalReason = 'other_type_or_factory';
  String _gasUsageStatus = 'used';

  @override
  void initState() {
    super.initState();
    _egxu = _findEgxu(widget.targetInfo);
    _equipmentOptions = _loadEquipmentOptions();
  }

  @override
  void dispose() {
    for (final item in _equipment) {
      item.dispose();
    }
    super.dispose();
  }

  EghuTargetInfoEgxu? _findEgxu(EghuTargetInfo info) {
    final selectedId = widget.preselection.eghu.id;
    for (final item in info.egxus) {
      if (item.id == selectedId) return item;
    }
    return info.egxus.isEmpty ? null : info.egxus.first;
  }

  Future<List<EghuTargetInfoGasEquipment>> _loadEquipmentOptions() async {
    final fromTarget = _egxu?.gasEquipments ?? const [];
    if (fromTarget.isNotEmpty) return fromTarget;

    try {
      final response = await (widget.globalApi ?? di.get<GlobalApi>())
          .getGasEquipment(limit: 100);
      return response.results
          .map(
            (item) => EghuTargetInfoGasEquipment(
              id: item.id,
              name: item.name,
              hourlyGasConsumption: item.hourlyGasConsumption ?? 0,
            ),
          )
          .where((item) => item.id != null || item.name != null)
          .toList();
    } catch (_) {
      return const [];
    }
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
                        _buildReasons(),
                        const SizedBox(height: 12),
                        _buildUsageStatus(),
                        const SizedBox(height: 12),
                        if (_gasUsageStatus == 'used')
                          _buildEquipmentSection()
                        else
                          _buildStampSection(),
                      ],
                    ),
                  ),
                ),
                EghuRemovalNextBar(enabled: _canSubmit, onTap: _continue),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReasons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Olib tashlash holati'),
        const SizedBox(height: 8),
        _RemovalReasonOption(
          label: 'Boshqa EGHU bilan almashtirish',
          value: 'other_type_or_factory',
          groupValue: _removalReason,
          onChanged: _selectReason,
        ),
        const SizedBox(height: 8),
        _RemovalReasonOption(
          label: 'Sertifikat yangilash uchun',
          value: 'for_certificate_replacement',
          groupValue: _removalReason,
          onChanged: _selectReason,
        ),
        const SizedBox(height: 8),
        _RemovalReasonOption(
          label: 'Taʼmirlash uchun',
          value: 'for_repair',
          groupValue: _removalReason,
          onChanged: _selectReason,
        ),
      ],
    );
  }

  Widget _buildUsageStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _label('Gaz isteʼmol holati'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _UsageOption(
                label: 'Ish faoliyatida',
                value: 'used',
                selected: _gasUsageStatus == 'used',
                onTap: () => setState(() => _gasUsageStatus = 'used'),
              ),
              _UsageOption(
                label: 'Muhrlangan',
                value: 'tagged',
                selected: _gasUsageStatus == 'tagged',
                onTap: () => setState(() => _gasUsageStatus = 'tagged'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._equipment.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _EquipmentCard(
              index: entry.key + 1,
              item: entry.value,
              onSelect: () => _selectEquipment(entry.value),
              onHoursChanged: (_) => setState(() {}),
            ),
          ),
        ),
        EghuDashedAddButton(label: 'Gaz anjomi qoʻshish', onTap: _addEquipment),
        if (_equipment.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildTotal(),
        ],
      ],
    );
  }

  Widget _buildTotal() {
    final hours = _equipment.fold<double>(
      0,
      (sum, item) => sum + item.operatingHours,
    );
    final total = _equipment.fold<double>(
      0,
      (sum, item) => sum + item.totalConsumption,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _totalValue('Jami: ${_equipment.length} ta')),
          Expanded(child: _totalValue('${_format(hours, 0)} soat')),
          Expanded(child: _totalValue('${_format(total, 1)} m³')),
        ],
      ),
    );
  }

  Widget _totalValue(String value) {
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: eghuText(
        fontSize: 13,
        lineHeight: 20,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF3F57B3),
      ),
    );
  }

  Widget _buildStampSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._selectedStamps.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SelectedStampCard(index: entry.key + 1, stamp: entry.value),
          ),
        ),
        EghuDashedAddButton(label: 'Tamg’a qoʻshish', onTap: _addStamp),
      ],
    );
  }

  Text _label(String value) => Text(
    value,
    style: eghuText(
      fontSize: 11,
      lineHeight: 16,
      letterSpacing: 0.4,
      color: const Color(0xFF202020),
    ),
  );

  bool get _canSubmit {
    if (_egxu?.id == null) return false;
    if (_gasUsageStatus == 'used') {
      return _equipment.any((item) => item.operatingHours > 0);
    }
    return _selectedStamps.isNotEmpty;
  }

  void _selectReason(String value) {
    setState(() => _removalReason = value);
  }

  Future<void> _addEquipment() async {
    final selected = await showDialog<EghuTargetInfoGasEquipment>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => _EquipmentPickerDialog(
        options: _equipmentOptions,
        selectedIds: _equipment.map((item) => item.option.id).toSet(),
      ),
    );
    if (!mounted || selected == null || selected.id == null) return;
    if (_equipment.any((item) => item.option.id == selected.id)) return;
    final operatingHours = await showDialog<double>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => _UsageTimeDialog(option: selected),
    );
    if (!mounted || operatingHours == null) return;
    setState(
      () => _equipment.add(
        _SelectedGasEquipment(selected, operatingHours: operatingHours),
      ),
    );
  }

  Future<void> _selectEquipment(_SelectedGasEquipment current) async {
    final selected = await showDialog<EghuTargetInfoGasEquipment>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => _EquipmentPickerDialog(
        options: _equipmentOptions,
        selectedIds: {current.option.id},
      ),
    );
    if (!mounted || selected == null || selected.id == null) return;
    final duplicate = _equipment.any(
      (item) => item != current && item.option.id == selected.id,
    );
    if (duplicate) return;
    setState(() => current.option = selected);
  }

  Future<void> _addStamp() async {
    final selected = await showDialog<EghuTargetInfoReal>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => _StampAddDialog(globalApi: widget.globalApi),
    );
    if (!mounted || selected == null) return;
    setState(() => _selectedStamps.add(selected));
  }

  Future<void> _continue() async {
    if (!_canSubmit || _egxu?.id == null) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EghuRemovalSummaryPage(
          preselection: widget.preselection,
          removalDateTime: widget.removalDateTime,
          targetInfo: widget.targetInfo,
          removalReason: _removalReason,
          gasUsageStatus: _gasUsageStatus,
          replacementReason: _replacementReason,
          gasEquipments: _gasUsageStatus == 'used'
              ? _equipment
                    .where((item) => item.operatingHours > 0)
                    .map((item) => item.toRequest())
                    .toList()
              : const [],
          realNumbers: _gasUsageStatus == 'tagged'
              ? List.unmodifiable(_selectedStamps)
              : const [],
          activityTypeId: widget.activityTypeId,
          api: widget.api,
        ),
      ),
    );
    if (saved == true && mounted) Navigator.of(context).pop(true);
  }

  String get _replacementReason => switch (_removalReason) {
    'for_certificate_replacement' => 'Sertifikat yangilash uchun',
    'for_repair' => 'Taʼmirlash uchun',
    _ => 'Boshqa EGHU bilan almashtirish',
  };

  String _format(num value, int decimals) {
    final text = value.toStringAsFixed(decimals);
    return text.replaceAll('.', ',');
  }
}

class _SelectedGasEquipment {
  _SelectedGasEquipment(this.option, {double operatingHours = 0})
    : hoursController = TextEditingController(
        text: operatingHours > 0
            ? operatingHours.toStringAsFixed(2).replaceAll('.', ',')
            : '',
      );

  EghuTargetInfoGasEquipment option;
  final TextEditingController hoursController;

  double get operatingHours =>
      double.tryParse(hoursController.text.trim().replaceAll(',', '.')) ?? 0;

  double get totalConsumption =>
      option.hourlyGasConsumption * operatingHours * option.quantity;

  EghuRemovalGasEquipment toRequest() => EghuRemovalGasEquipment(
    id: option.id!,
    name: option.name ?? '-',
    hourlyGasConsumption: option.hourlyGasConsumption,
    operatingHours: operatingHours,
    quantity: option.quantity,
  );

  void dispose() => hoursController.dispose();
}

class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({
    required this.index,
    required this.item,
    required this.onSelect,
    required this.onHoursChanged,
  });

  final int index;
  final _SelectedGasEquipment item;
  final VoidCallback onSelect;
  final ValueChanged<String> onHoursChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: EghuActionCreateColors.field,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
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
                child: GestureDetector(
                  onTap: onSelect,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFCFC),
                      border: Border.all(color: EghuActionCreateColors.stroke),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.option.name ?? '-',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: eghuText(
                              fontSize: 13,
                              lineHeight: 20,
                              fontWeight: FontWeight.w800,
                              color: EghuActionCreateColors.textStrong,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ValueColumn(
                  label: 'Soatlik sarfi (A)',
                  value: '${_format(item.option.hourlyGasConsumption, 1)} m³',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HoursInput(
                  controller: item.hoursController,
                  onChanged: onHoursChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ValueColumn(
                  label: 'Summa (A × B)',
                  value: '${_format(item.totalConsumption, 1)} m³',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _format(num value, int decimals) =>
      value.toStringAsFixed(decimals).replaceAll('.', ',');
}

class _ValueColumn extends StatelessWidget {
  const _ValueColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: eghuText(fontSize: 11, lineHeight: 16),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: eghuText(
              fontSize: 13,
              lineHeight: 20,
              fontWeight: FontWeight.w800,
              color: EghuActionCreateColors.textStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoursInput extends StatelessWidget {
  const _HoursInput({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vaqti (B), soat', style: eghuText(fontSize: 11, lineHeight: 16)),
        const SizedBox(height: 4),
        SizedBox(
          height: 26,
          child: TextField(
            key: const Key('eghu-removal-operating-hours'),
            controller: controller,
            onChanged: onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
            textAlignVertical: TextAlignVertical.center,
            style: eghuText(
              fontSize: 13,
              lineHeight: 20,
              fontWeight: FontWeight.w800,
              color: EghuActionCreateColors.textStrong,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFCFCFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: EghuActionCreateColors.stroke),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: EghuActionCreateColors.stroke),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF3F57B3)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UsageTimeDialog extends StatefulWidget {
  const _UsageTimeDialog({required this.option});

  final EghuTargetInfoGasEquipment option;

  @override
  State<_UsageTimeDialog> createState() => _UsageTimeDialogState();
}

class _UsageTimeDialogState extends State<_UsageTimeDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  double get _hours =>
      double.tryParse(_controller.text.trim().replaceAll(',', '.')) ?? 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '90,00');
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _hours;
    final total = widget.option.hourlyGasConsumption * hours;
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
              'Ishlatilish vaqti',
              style: eghuText(
                fontSize: 17,
                lineHeight: 28,
                fontWeight: FontWeight.w800,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.option.name ?? 'Gaz anjomi'} uchun necha soat ishlatilgani',
              style: eghuText(fontSize: 13, lineHeight: 20),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 64,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: (_) => setState(() {}),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                textAlignVertical: TextAlignVertical.center,
                style: eghuText(
                  fontSize: 24,
                  lineHeight: 32,
                  fontWeight: FontWeight.w800,
                  color: EghuActionCreateColors.textStrong,
                ),
                decoration: InputDecoration(
                  suffixText: 'soat',
                  suffixStyle: eghuText(fontSize: 13, lineHeight: 20),
                  filled: true,
                  fillColor: const Color(0xFFFCFCFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF3F57B3),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFD0D5DD),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF3F57B3),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Soatlik sarfi ${_format(widget.option.hourlyGasConsumption, 1)} m³ × '
              '${_formatHours(hours)} soat = ${_format(total, 1)} m³',
              style: eghuText(fontSize: 11, lineHeight: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DialogAction(
                    label: Words.cancel.tr(),
                    background: const Color(0xFFF0F0F0),
                    foreground: EghuActionCreateColors.textStrong,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DialogAction(
                    label: Words.confirm.tr(),
                    background: const Color(0xFF3F57B3),
                    foreground: Colors.white,
                    onTap: hours > 0
                        ? () => Navigator.of(context).pop(hours)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _format(num value, int decimals) =>
      value.toStringAsFixed(decimals).replaceAll('.', ',');

  String _formatHours(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : _format(value, 2);
}

class _RemovalReasonOption extends StatelessWidget {
  const _RemovalReasonOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFCFCFC)
              : EghuActionCreateColors.field,
          border: selected
              ? Border.all(color: const Color(0xFF3F57B3), width: 1.5)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFFCFCFC),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF3F57B3)
                      : const Color(0xFFF0F0F0),
                  width: selected ? 5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: eghuText(
                  fontSize: 13,
                  lineHeight: 20,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected
                      ? EghuActionCreateColors.textStrong
                      : EghuActionCreateColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageOption extends StatelessWidget {
  const _UsageOption({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFCFCFC) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: eghuText(
              fontSize: 13,
              lineHeight: 20,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: EghuActionCreateColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedStampCard extends StatelessWidget {
  const _SelectedStampCard({required this.index, required this.stamp});

  final int index;
  final EghuTargetInfoReal stamp;

  @override
  Widget build(BuildContext context) {
    final defective = (stamp.status ?? '').toLowerCase().contains('shikast');
    final date = stamp.installedDate == null
        ? '-'
        : _date(stamp.installedDate!.toLocal());
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
              Text('$index', style: eghuText(fontSize: 11, lineHeight: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stamp.number,
                  style: eghuText(
                    fontSize: 13,
                    lineHeight: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: defective
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFEDF9F1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  defective ? 'Muhri shikastlangan' : 'Muhrlangan',
                  style: eghuText(
                    fontSize: 11,
                    lineHeight: 16,
                    fontWeight: FontWeight.w800,
                    color: defective
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(date, style: eghuText(fontSize: 11, lineHeight: 16)),
        ],
      ),
    );
  }

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
}

class _EquipmentPickerDialog extends StatefulWidget {
  const _EquipmentPickerDialog({
    required this.options,
    required this.selectedIds,
  });

  final Future<List<EghuTargetInfoGasEquipment>> options;
  final Set<int?> selectedIds;

  @override
  State<_EquipmentPickerDialog> createState() => _EquipmentPickerDialogState();
}

class _EquipmentPickerDialogState extends State<_EquipmentPickerDialog> {
  final _searchController = TextEditingController();
  String _query = '';
  EghuTargetInfoGasEquipment? _selected;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
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
        child: FutureBuilder<List<EghuTargetInfoGasEquipment>>(
          future: widget.options,
          builder: (context, snapshot) {
            final all = snapshot.data ?? const <EghuTargetInfoGasEquipment>[];
            final query = _query.trim().toLowerCase();
            final items = query.isEmpty
                ? all
                : all
                      .where(
                        (item) =>
                            (item.name ?? '').toLowerCase().contains(query),
                      )
                      .toList();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gaz anjomini tanlang',
                  style: eghuText(
                    fontSize: 17,
                    lineHeight: 28,
                    fontWeight: FontWeight.w800,
                    color: EghuActionCreateColors.textStrong,
                  ),
                ),
                const SizedBox(height: 14),
                _searchField(),
                const SizedBox(height: 14),
                if (snapshot.connectionState != ConnectionState.done)
                  const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (items.isEmpty)
                  const SizedBox(
                    height: 120,
                    child: Center(child: Text('Anjomlar topilmadi')),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 2),
                      itemBuilder: (_, index) => _equipmentOption(items[index]),
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: _DialogAction(
                        label: Words.cancel.tr(),
                        background: const Color(0xFFF0F0F0),
                        foreground: EghuActionCreateColors.textStrong,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DialogAction(
                        label: Words.select.tr(),
                        background: const Color(0xFF3F57B3),
                        foreground: Colors.white,
                        onTap: _selected == null
                            ? null
                            : () => Navigator.of(context).pop(_selected),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _searchField() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AppTools.svg(AppTools.icSearchIcon, width: 16, height: 16),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Anjom nomi',
                border: InputBorder.none,
                isDense: true,
                hintStyle: eghuText(
                  fontSize: 13,
                  lineHeight: 20,
                  color: const Color(0xFFBBBBBB),
                ),
              ),
              style: eghuText(fontSize: 13, lineHeight: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _equipmentOption(EghuTargetInfoGasEquipment option) {
    final selected =
        _selected?.id == option.id ||
        (_selected == null && widget.selectedIds.contains(option.id));
    return GestureDetector(
      onTap: () => setState(() => _selected = option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF2F2F2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              '${option.id ?? '-'}',
              style: eghuText(
                fontSize: 11,
                lineHeight: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name ?? '-',
                    style: eghuText(
                      fontSize: 13,
                      lineHeight: 20,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                      color: EghuActionCreateColors.textStrong,
                    ),
                  ),
                  Text(
                    '${_format(option.hourlyGasConsumption, 1)} m³/soat',
                    style: eghuText(fontSize: 11, lineHeight: 16),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_rounded,
                size: 16,
                color: Color(0xFF3F57B3),
              ),
          ],
        ),
      ),
    );
  }

  String _format(num value, int decimals) =>
      value.toStringAsFixed(decimals).replaceAll('.', ',');
}

class _StampAddDialog extends StatefulWidget {
  const _StampAddDialog({this.globalApi});

  final GlobalApi? globalApi;

  @override
  State<_StampAddDialog> createState() => _StampAddDialogState();
}

class _StampAddDialogState extends State<_StampAddDialog> {
  final _numberController = TextEditingController();
  GlobalModel? _location;

  bool get _canAdd =>
      _numberController.text.trim().isNotEmpty && _location?.name != null;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              'Tamg’a qo’shish',
              style: eghuText(
                fontSize: 17,
                lineHeight: 28,
                fontWeight: FontWeight.w800,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yangi tamg’a raqamini kiriting va joylashuvini tanlang.',
              style: eghuText(fontSize: 13, lineHeight: 20),
            ),
            const SizedBox(height: 14),
            _stampLabel('Tamg’a raqami'),
            const SizedBox(height: 4),
            _numberField(),
            const SizedBox(height: 12),
            _stampLabel('Joylashuvi'),
            const SizedBox(height: 4),
            _locationField(),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _DialogAction(
                    label: Words.cancel.tr(),
                    background: const Color(0xFFF0F0F0),
                    foreground: EghuActionCreateColors.textStrong,
                    icon: AppTools.svg(AppTools.x, width: 16, height: 16),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DialogAction(
                    label: Words.add.tr(),
                    background: const Color(0xFF3F57B3),
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
                    onTap: _canAdd
                        ? () => Navigator.of(context).pop(
                            EghuTargetInfoReal(
                              id: null,
                              number: _numberController.text.trim(),
                              status: 'Muhrlangan',
                              sealLocation: _location!.name,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stampLabel(String value) =>
      Text(value, style: eghuText(fontSize: 11, lineHeight: 16));

  Widget _numberField() {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _numberController,
        onChanged: (_) => setState(() {}),
        style: eghuText(
          fontSize: 13,
          lineHeight: 20,
          fontWeight: FontWeight.w800,
          color: EghuActionCreateColors.textStrong,
        ),
        decoration: InputDecoration(
          hintText: 'TM-441212',
          hintStyle: eghuText(
            fontSize: 13,
            lineHeight: 20,
            color: EghuActionCreateColors.textSub,
          ),
          filled: true,
          fillColor: const Color(0xFFF1F1F1),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF3F57B3)),
          ),
        ),
      ),
    );
  }

  Widget _locationField() {
    return GestureDetector(
      onTap: _selectLocation,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _location?.name ?? 'Joylashuvni tanlang',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: eghuText(
                  fontSize: 13,
                  lineHeight: 20,
                  fontWeight: FontWeight.w800,
                  color: _location == null
                      ? EghuActionCreateColors.textSub
                      : EghuActionCreateColors.textStrong,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: EghuActionCreateColors.textSub,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectLocation() async {
    final selected = await showDialog<GlobalModel>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => _LocationPickerDialog(
        globalApi: widget.globalApi,
        selectedId: _location?.id,
      ),
    );
    if (mounted && selected != null) setState(() => _location = selected);
  }
}

class _LocationPickerDialog extends StatefulWidget {
  const _LocationPickerDialog({this.globalApi, this.selectedId});

  final GlobalApi? globalApi;
  final int? selectedId;

  @override
  State<_LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<_LocationPickerDialog> {
  final _searchController = TextEditingController();
  late final Future<List<GlobalModel>> _places;
  String _query = '';
  GlobalModel? _selected;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() => _query = _searchController.text);
    });
    _places = _loadPlaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<GlobalModel>> _loadPlaces() async {
    final response = await (widget.globalApi ?? di.get<GlobalApi>())
        .getStampInstallationPlaces(limit: 100);
    return response.results
        .where((item) => item.name?.trim().isNotEmpty == true)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
        child: FutureBuilder<List<GlobalModel>>(
          future: _places,
          builder: (context, snapshot) {
            final all = snapshot.data ?? const <GlobalModel>[];
            final query = _query.trim().toLowerCase();
            final items = query.isEmpty
                ? all
                : all
                      .where(
                        (item) =>
                            (item.name ?? '').toLowerCase().contains(query),
                      )
                      .toList();
            final selected = _selected ?? _initialSelection(all);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Joylashuv',
                  style: eghuText(
                    fontSize: 17,
                    lineHeight: 28,
                    fontWeight: FontWeight.w800,
                    color: EghuActionCreateColors.textStrong,
                  ),
                ),
                const SizedBox(height: 14),
                _searchField(),
                const SizedBox(height: 14),
                SizedBox(height: 212, child: _list(snapshot, items, selected)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _DialogAction(
                        label: 'Orqaga',
                        background: const Color(0xFFF0F0F0),
                        foreground: EghuActionCreateColors.textStrong,
                        icon: const Icon(Icons.arrow_back_rounded, size: 16),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DialogAction(
                        label: Words.select.tr(),
                        background: const Color(0xFF3F57B3),
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
                        onTap: selected == null
                            ? null
                            : () => Navigator.of(context).pop(selected),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  GlobalModel? _initialSelection(List<GlobalModel> places) {
    if (places.isEmpty) return null;
    for (final item in places) {
      if (item.id == widget.selectedId) return item;
    }
    return places.first;
  }

  Widget _searchField() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AppTools.svg(AppTools.icSearchIcon, width: 16, height: 16),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Joylashuv nomi',
                hintStyle: eghuText(
                  fontSize: 13,
                  lineHeight: 20,
                  color: EghuActionCreateColors.textSub,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              style: eghuText(fontSize: 13, lineHeight: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(
    AsyncSnapshot<List<GlobalModel>> snapshot,
    List<GlobalModel> items,
    GlobalModel? selected,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError || items.isEmpty) {
      return Center(child: Text(Words.noInformationFound.tr()));
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        final isSelected = item.id == selected?.id;
        return GestureDetector(
          onTap: () => setState(() => _selected = item),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF1F1F1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  '${index + 1}',
                  style: eghuText(
                    fontSize: 11,
                    lineHeight: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.name ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: eghuText(
                      fontSize: 13,
                      lineHeight: 20,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: EghuActionCreateColors.textStrong,
                    ),
                  ),
                ),
                if (isSelected)
                  AppTools.svg(
                    AppTools.check,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF3F57B3),
                      BlendMode.srcIn,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DialogAction extends StatelessWidget {
  const _DialogAction({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: disabled ? const Color(0xFFE8E8E8) : background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 6)],
            Text(
              label,
              style: eghuText(
                fontSize: 13,
                lineHeight: 20,
                fontWeight: FontWeight.w800,
                color: disabled ? EghuActionCreateColors.textSub : foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
