import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/core/api/global/global_api.dart';
import 'package:m_gaz/core/models/global/global_model.dart';
import 'package:m_gaz/di.dart';
import 'package:m_gaz/global_widget/global_dropdown.dart';

import '../../../../../../../core/common/words.dart';
import '../widgets/create/eghu_action_bottom_sheets.dart';
import '../widgets/create/eghu_action_form_fields.dart';
import '../widgets/eghu_calendar_dialog.dart';
import 'eghu_removal_stamps_page.dart';

class EghuRemovalDatePage extends StatefulWidget {
  const EghuRemovalDatePage({super.key, this.preselection, this.globalApi});

  final EghuActionPreselection? preselection;
  final GlobalApi? globalApi;

  @override
  State<EghuRemovalDatePage> createState() => _EghuRemovalDatePageState();
}

class _EghuRemovalDatePageState extends State<EghuRemovalDatePage> {
  late DateTime _dateTime;
  late final Future<List<GlobalModel>> _activityTypes;
  GlobalModel? _selectedActivityType;

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
    _activityTypes = _loadActivityTypes(
      widget.globalApi ?? di.get<GlobalApi>(),
    );
  }

  Future<List<GlobalModel>> _loadActivityTypes(GlobalApi api) async {
    final activityTypes = await api.getActivityTypes();
    final currentRelation = widget.preselection?.eghu.consumerRelationEgxu;
    final currentId = currentRelation?.typeOfActivityId;
    final currentName = _normalizeActivityName(
      currentRelation?.typeOfActivity ?? '',
    );

    for (final activityType in activityTypes) {
      final activityName = _normalizeActivityName(
        activityType.name ?? activityType.fio ?? '',
      );
      if ((currentId != null && activityType.id == currentId) ||
          (currentName.isNotEmpty && activityName == currentName)) {
        _selectedActivityType = activityType;
        break;
      }
    }
    return activityTypes;
  }

  String _normalizeActivityName(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[’‘ʻ]'), "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.preselection;
    final detail = selection?.detail;
    final eghu = selection?.eghu;
    final canContinue = selection != null && eghu?.id != null;

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
                        _ReadOnlyField(
                          label: Words.consumer.tr(),
                          value: selection?.consumer.consumers,
                        ),
                        const SizedBox(height: 12),
                        _ReadOnlyField(
                          label: Words.eghu.tr(),
                          value: eghu == null ? null : eghuTitle(eghu),
                        ),
                        const SizedBox(height: 12),
                        _ReadOnlyField(
                          label: Words.region.tr(),
                          value: detail?.region?.name,
                        ),
                        const SizedBox(height: 12),
                        _ReadOnlyField(
                          label: Words.district.tr(),
                          value: detail?.district?.name,
                        ),
                        const SizedBox(height: 12),
                        _ActivityTypeField(
                          label: Words.activityType.tr(),
                          activityTypesFuture: _activityTypes,
                          selectedActivityType: _selectedActivityType,
                          onChanged: (value) {
                            setState(() => _selectedActivityType = value);
                          },
                        ),
                        if (!canContinue) ...[
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
                    if (!canContinue) return;
                    final saved = await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => EghuRemovalStampsPage(
                          preselection: selection,
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
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = value?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: eghuText(fontSize: 11, lineHeight: 16)),
        const SizedBox(height: 4),
        Container(
          height: 44,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: EghuActionCreateColors.soft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: EghuActionCreateColors.stroke),
          ),
          child: Text(
            text?.isNotEmpty == true ? text! : '-',
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
      ],
    );
  }
}

class _ActivityTypeField extends StatelessWidget {
  const _ActivityTypeField({
    required this.label,
    required this.activityTypesFuture,
    required this.selectedActivityType,
    required this.onChanged,
  });

  final String label;
  final Future<List<GlobalModel>> activityTypesFuture;
  final GlobalModel? selectedActivityType;
  final ValueChanged<GlobalModel> onChanged;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GlobalModel>>(
      future: activityTypesFuture,
      builder: (context, snapshot) {
        return GenericSelectableField<GlobalModel>(
          title: label,
          items: snapshot.data ?? const [],
          selectedItem: selectedActivityType,
          hintText: snapshot.hasError
              ? Words.errorOccurred.tr()
              : snapshot.connectionState == ConnectionState.waiting
              ? Words.loading.tr()
              : Words.select.tr(),
          getTitle: (item) => item.name ?? item.fio ?? '-',
          isEqual: (a, b) => a.id == b.id,
          onChanged: onChanged,
        );
      },
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
                border: Border.all(color: EghuActionCreateColors.primary),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(value),
                      style: eghuText(fontSize: 13, lineHeight: 20),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: EghuActionCreateColors.primary,
                  ),
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
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(Words.next.tr()),
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
