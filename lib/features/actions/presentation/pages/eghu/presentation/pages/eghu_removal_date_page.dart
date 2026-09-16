import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/core/api/global/global_api.dart';
import 'package:m_gaz/core/api/working_with_consumers_api/consumer_relations_api.dart';
import 'package:m_gaz/core/extension/message_extension.dart';
import 'package:m_gaz/core/models/global/global_model.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_list.dart';
import 'package:m_gaz/di.dart';

import '../../../../../../../core/common/words.dart';
import '../widgets/create/eghu_action_bottom_sheets.dart';
import '../widgets/create/eghu_action_form_fields.dart';
import '../widgets/eghu_calendar_dialog.dart';
import 'eghu_removal_stamps_page.dart';

class EghuRemovalDatePage extends StatefulWidget {
  const EghuRemovalDatePage({
    super.key,
    this.preselection,
    this.globalApi,
    this.consumerSource,
    this.consumerApi,
  });

  final EghuActionPreselection? preselection;
  final GlobalApi? globalApi;
  final EghuActionConsumerSource? consumerSource;
  final ConsumerRelationsApi? consumerApi;

  @override
  State<EghuRemovalDatePage> createState() => _EghuRemovalDatePageState();
}

class _EghuRemovalDatePageState extends State<EghuRemovalDatePage> {
  late DateTime _dateTime;
  late final Future<List<GlobalModel>> _activityTypes;
  late final EghuActionConsumerSource _consumerSource;
  WorkingWithConsumersList? _selectedConsumer;
  WorkingWithConsumersDetailModel? _selectedDetail;
  ConsumersEgxuItem? _selectedEghu;
  GlobalModel? _selectedActivityType;
  bool _consumerLoading = false;

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
    _selectedConsumer = widget.preselection?.consumer;
    _selectedDetail = widget.preselection?.detail;
    _selectedEghu = widget.preselection?.eghu;
    _consumerSource =
        widget.consumerSource ??
        ConsumerRelationsEghuSource(
          widget.consumerApi ?? di.get<ConsumerRelationsApi>(),
        );
    _activityTypes = _loadActivityTypes(
      widget.globalApi ?? di.get<GlobalApi>(),
    );
  }

  Future<List<GlobalModel>> _loadActivityTypes(GlobalApi api) async {
    final activityTypes = await api.getActivityTypes();
    _selectedActivityType = _findActivityType(
      activityTypes,
      _selectedEghu?.consumerRelationEgxu,
    );
    return activityTypes;
  }

  GlobalModel? _findActivityType(
    List<GlobalModel> activityTypes,
    ConsumerRelationEgxu? relation,
  ) {
    if (activityTypes.isEmpty) return null;

    if (relation?.typeOfActivityId != null) {
      for (final activityType in activityTypes) {
        if (activityType.id == relation!.typeOfActivityId) return activityType;
      }
    }

    final currentName = _normalizeActivityName(relation?.typeOfActivity ?? '');
    if (currentName.isNotEmpty) {
      for (final activityType in activityTypes) {
        if (_normalizeActivityName(
              activityType.name ?? activityType.fio ?? '',
            ) ==
            currentName) {
          return activityType;
        }
      }
    }

    return activityTypes.first;
  }

  String _normalizeActivityName(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[’‘ʻ]'), "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _selectConsumer() async {
    final selected = await showModalBottomSheet<WorkingWithConsumersList>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EghuConsumerPickerSheet(
        source: _consumerSource,
        selected: _selectedConsumer,
      ),
    );
    if (!mounted || selected == null || selected.id == _selectedConsumer?.id) {
      return;
    }

    setState(() {
      _selectedConsumer = selected;
      _selectedDetail = null;
      _selectedEghu = null;
      _selectedActivityType = null;
      _consumerLoading = true;
    });

    try {
      final detail = await _consumerSource.getDocumentById(selected.id);
      final eghu = _firstActiveEghu(detail.egxuList);
      final activityTypes = await _activityTypes;
      if (!mounted) return;
      setState(() {
        _selectedDetail = detail;
        _selectedEghu = eghu;
        _selectedActivityType = _findActivityType(
          activityTypes,
          eghu?.consumerRelationEgxu,
        );
        _consumerLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _consumerLoading = false);
      showToast(context, error.toString().replaceAll('Exception: ', ''));
    }
  }

  ConsumersEgxuItem? _firstActiveEghu(List<ConsumersEgxuItem>? egxus) {
    for (final eghu in egxus ?? const <ConsumersEgxuItem>[]) {
      if (eghu.id != null && eghu.isActive != false) return eghu;
    }
    return null;
  }

  void _clearConsumer() {
    setState(() {
      _selectedConsumer = null;
      _selectedDetail = null;
      _selectedEghu = null;
      _selectedActivityType = null;
    });
  }

  Future<void> _selectActivityType(List<GlobalModel> items) async {
    final selected = await showModalBottomSheet<GlobalModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActivityTypePickerSheet(
        items: items,
        selected: _selectedActivityType,
      ),
    );
    if (mounted && selected != null) {
      setState(() => _selectedActivityType = selected);
    }
  }

  EghuActionPreselection? _currentSelection() {
    final consumer = _selectedConsumer;
    final detail = _selectedDetail;
    final eghu = _selectedEghu;
    if (consumer == null || detail == null || eghu == null) return null;
    return EghuActionPreselection(
      consumer: consumer,
      detail: detail,
      eghu: eghu,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selection = _currentSelection();
    final detail = _selectedDetail;
    final consumer = _selectedConsumer;
    final canContinue = selection?.eghu.id != null && !_consumerLoading;

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
                        _PageHeader(title: Words.actionEghuDetach.tr()),
                        const SizedBox(height: 24),
                        _DateField(
                          value: _dateTime,
                          onTap: () async {
                            final selected = await pickEghuStampDateTime(
                              context,
                              currentStampDateTime: _dateTime,
                            );
                            if (selected != null && mounted) {
                              setState(() => _dateTime = selected);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _ChoiceField(
                          label: Words.selectConsumer.tr(),
                          value: consumer?.consumers,
                          onTap: _consumerLoading ? null : _selectConsumer,
                          onClear: consumer == null ? null : _clearConsumer,
                          showDropdownIcon: true,
                        ),
                        const SizedBox(height: 12),
                        _ChoiceField(
                          label: Words.region.tr(),
                          value: detail?.region?.name ?? consumer?.region,
                          showClearIcon: true,
                        ),
                        const SizedBox(height: 12),
                        _ChoiceField(
                          label: Words.district.tr(),
                          value: detail?.district?.name ?? consumer?.district,
                          showDropdownIcon: true,
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<List<GlobalModel>>(
                          future: _activityTypes,
                          builder: (context, snapshot) {
                            final items =
                                snapshot.data ?? const <GlobalModel>[];
                            return _ChoiceField(
                              label: Words.activityType.tr(),
                              value:
                                  _selectedActivityType?.name ??
                                  _selectedActivityType?.fio,
                              placeholder:
                                  snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? Words.loading.tr()
                                  : Words.select.tr(),
                              onTap: items.isEmpty
                                  ? null
                                  : () => _selectActivityType(items),
                              showDropdownIcon: true,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _ChoiceField(
                          label: Words.documentTypeLabel.tr(),
                          value: Words.consumerDocumentType.tr(),
                          showClearIcon: true,
                        ),
                        const SizedBox(height: 12),
                        if (consumer == null) ...[
                          const SizedBox(height: 12),
                          Text(
                            Words.selectConsumerFirst.tr(),
                            style: eghuText(
                              fontSize: 12,
                              lineHeight: 18,
                              color: EghuActionCreateColors.textSub,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                _NextBar(
                  enabled: canContinue,
                  onTap: () async {
                    final selected = selection;
                    if (!canContinue || selected == null) return;
                    final saved = await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => EghuRemovalStampsPage(
                          preselection: selected,
                          removalDateTime: _dateTime,
                          activityTypeId: _selectedActivityType?.id,
                        ),
                      ),
                    );
                    if (saved == true && context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title});

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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: eghuText(
                fontSize: 17,
                lineHeight: 28,
                fontWeight: FontWeight.w800,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
          ),
          const Icon(Icons.help_outline_rounded, size: 24),
        ],
      ),
    );
  }
}

class _ChoiceField extends StatelessWidget {
  const _ChoiceField({
    required this.label,
    this.value,
    this.placeholder = '-',
    this.onTap,
    this.onClear,
    this.showClearIcon = false,
    this.showDropdownIcon = false,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final bool showClearIcon;
  final bool showDropdownIcon;

  @override
  Widget build(BuildContext context) {
    final text = value?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: eghuText(fontSize: 11, lineHeight: 16)),
        const SizedBox(height: 4),
        Material(
          color: EghuActionCreateColors.field,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              height: 44,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EghuActionCreateColors.stroke),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text?.isNotEmpty == true ? text! : placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: eghuText(
                        fontSize: 13,
                        lineHeight: 20,
                        color: text?.isNotEmpty == true
                            ? EghuActionCreateColors.text
                            : EghuActionCreateColors.textSub,
                      ),
                    ),
                  ),
                  if (onClear != null || showClearIcon)
                    InkWell(
                      onTap: onClear,
                      borderRadius: BorderRadius.circular(10),
                      child: const Icon(Icons.close_rounded, size: 18),
                    )
                  else if (showDropdownIcon)
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityTypePickerSheet extends StatefulWidget {
  const _ActivityTypePickerSheet({required this.items, this.selected});

  final List<GlobalModel> items;
  final GlobalModel? selected;

  @override
  State<_ActivityTypePickerSheet> createState() =>
      _ActivityTypePickerSheetState();
}

class _ActivityTypePickerSheetState extends State<_ActivityTypePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final items = query.isEmpty
        ? widget.items
        : widget.items
              .where(
                (item) =>
                    (item.name ?? item.fio ?? '').toLowerCase().contains(query),
              )
              .toList();

    return Container(
      height: MediaQuery.sizeOf(context).height * .75,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: Words.search.tr(),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: EghuActionCreateColors.soft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = item.id == widget.selected?.id;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: selected
                      ? EghuActionCreateColors.primary.withValues(alpha: .1)
                      : EghuActionCreateColors.soft,
                  title: Text(item.name ?? item.fio ?? '-'),
                  trailing: selected
                      ? const Icon(
                          Icons.check_circle,
                          color: EghuActionCreateColors.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap});

  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Words.date.tr(), style: eghuText(fontSize: 11, lineHeight: 16)),
        const SizedBox(height: 4),
        Material(
          color: EghuActionCreateColors.field,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            key: const Key('eghu-removal-date-field'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EghuActionCreateColors.stroke),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(value),
                      style: eghuText(fontSize: 13, lineHeight: 20),
                    ),
                  ),
                  const Icon(Icons.close_rounded, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NextBar extends StatelessWidget {
  const _NextBar({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.paddingOf(context).bottom + 8,
      ),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton.icon(
          key: const Key('eghu-removal-next-button'),
          onPressed: enabled ? onTap : null,
          icon: const Icon(Icons.check_rounded),
          label: Text(Words.continueAction.tr()),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: EghuActionCreateColors.primary,
            disabledBackgroundColor: EghuActionCreateColors.soft,
            disabledForegroundColor: EghuActionCreateColors.textSub,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: eghuText(
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
