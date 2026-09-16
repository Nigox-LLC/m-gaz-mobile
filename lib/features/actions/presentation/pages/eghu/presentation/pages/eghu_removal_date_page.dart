import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/core/api/global/global_api.dart';
import 'package:m_gaz/core/api/working_with_consumers_api/consumer_relations_api.dart';
import 'package:m_gaz/core/models/global/global_model.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import 'package:m_gaz/di.dart';

import '../../../../../../../core/common/words.dart';
import '../widgets/create/eghu_action_bottom_sheets.dart';
import '../widgets/create/eghu_action_form_fields.dart';
import '../widgets/eghu_calendar_dialog.dart';
import 'eghu_removal_page_widgets.dart';
import 'eghu_removal_stamps_page.dart';

class EghuRemovalDatePage extends StatefulWidget {
  const EghuRemovalDatePage({
    super.key,
    this.preselection,
    this.globalApi,
    // Kept for source compatibility with the old selectable form.
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
    try {
      final items = await api.getActivityTypes();
      _selectedActivityType = _findActivityType(
        items,
        widget.preselection?.eghu.consumerRelationEgxu,
      );
      if (mounted) setState(() {});
      return items;
    } catch (_) {
      return const [];
    }
  }

  GlobalModel? _findActivityType(
    List<GlobalModel> items,
    ConsumerRelationEgxu? relation,
  ) {
    if (items.isEmpty) return null;
    final relationId = relation?.typeOfActivityId;
    if (relationId != null) {
      for (final item in items) {
        if (item.id == relationId) return item;
      }
    }

    final relationName = _normalize(relation?.typeOfActivity ?? '');
    if (relationName.isNotEmpty) {
      for (final item in items) {
        if (_normalize(item.name ?? item.fio ?? '') == relationName) {
          return item;
        }
      }
    }

    // The backend sometimes returns a null activity on the consumer relation.
    return items.first;
  }

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[’‘ʻ]'), "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String _activityName() {
    final activity = _selectedActivityType;
    if (activity != null) return activity.name ?? activity.fio ?? '-';
    return widget.preselection?.eghu.consumerRelationEgxu?.typeOfActivity ??
        '-';
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.preselection;
    final detail = selection?.detail;
    final consumer = selection?.consumer;
    final eghu = selection?.eghu;
    final canContinue = eghu?.id != null;

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
                        EghuRemovalField(
                          label: Words.region.tr(),
                          value: detail?.region?.name ?? consumer?.region,
                          trailing: EghuRemovalFieldTrailing.close,
                        ),
                        const SizedBox(height: 12),
                        EghuRemovalField(
                          label: Words.district.tr(),
                          value: detail?.district?.name ?? consumer?.district,
                          trailing: EghuRemovalFieldTrailing.chevron,
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<List<GlobalModel>>(
                          future: _activityTypes,
                          builder: (context, snapshot) => EghuRemovalField(
                            label: Words.activityType.tr(),
                            value: _activityName(),
                            placeholder:
                                snapshot.connectionState ==
                                    ConnectionState.waiting
                                ? Words.loading.tr()
                                : Words.select.tr(),
                            trailing: EghuRemovalFieldTrailing.chevron,
                          ),
                        ),
                        const SizedBox(height: 12),
                        EghuRemovalField(
                          label: Words.documentTypeLabel.tr(),
                          value: Words.consumerDocumentType.tr(),
                          trailing: EghuRemovalFieldTrailing.close,
                        ),
                        const SizedBox(height: 12),
                        EghuRemovalField(
                          label: Words.selectConsumer.tr(),
                          value: consumer?.consumers,
                          trailing: EghuRemovalFieldTrailing.close,
                        ),
                        if (selection == null) ...[
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
                EghuRemovalNextBar(
                  enabled: canContinue,
                  onTap: () async {
                    if (!canContinue || selection == null) return;
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

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap});

  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return EghuRemovalField(
      key: const Key('eghu-removal-date-field'),
      label: Words.date.tr(),
      value: DateFormat('dd.MM.yyyy HH:mm').format(value),
      trailing: EghuRemovalFieldTrailing.close,
      onTap: onTap,
    );
  }
}
