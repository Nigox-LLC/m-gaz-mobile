import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:m_gaz/core/api/working_with_consumers_api/consumer_relations_api.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_list.dart';
import 'package:m_gaz/di.dart';
import 'package:m_gaz/features/actions/data/datasources/eghu_action_api.dart';
import 'package:m_gaz/features/actions/data/models/eghu_removal_flow.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/widgets/create/eghu_action_bottom_sheets.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/widgets/create/eghu_action_form_fields.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/widgets/eghu_calendar_dialog.dart';
import 'package:m_gaz/global_bloc/global_bloc.dart';
import 'package:m_gaz/global_bloc/global_event.dart';
import 'package:m_gaz/global_bloc/global_state.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

class EghuReinstallationCreatePage extends StatefulWidget {
  const EghuReinstallationCreatePage({
    super.key,
    this.api,
    this.consumerApi,
    this.consumerSource,
    this.preselection,
  });

  final EghuReinstallationApi? api;
  final ConsumerRelationsApi? consumerApi;
  final EghuActionConsumerSource? consumerSource;
  final EghuActionPreselection? preselection;

  @override
  State<EghuReinstallationCreatePage> createState() =>
      _EghuReinstallationCreatePageState();
}

class _EghuReinstallationCreatePageState
    extends State<EghuReinstallationCreatePage> {
  final _documentNumber = TextEditingController();
  final _oneFactory = TextEditingController();
  final _twoFactory = TextEditingController();

  EghuReinstallationApi? _api;
  EghuActionConsumerSource? _consumerSource;
  WorkingWithConsumersList? _consumer;
  WorkingWithConsumersDetailModel? _detail;
  ConsumersEgxuItem? _eghu;
  EghuTargetInfo? _targetInfo;
  List<_PendingRemoval> _removals = const [];
  List<_TypeOption> _types = const [];
  _PendingRemoval? _removal;
  _TypeOption? _type;
  String _removalReason = 'other_type_or_factory';
  DateTime _datetime = DateTime.now();
  int _step = 0;
  bool _loading = false;
  bool _submitting = false;
  bool _success = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final preselection = widget.preselection;
    _consumer = preselection?.consumer;
    _detail = preselection?.detail;
    _eghu = preselection?.eghu;
    _datetime =
        DateTime.tryParse(preselection?.detail.datetime ?? '') ??
        DateTime.now();
    _oneFactory.text = _eghu?.oneFactory ?? '';
    _twoFactory.text = _eghu?.twoFactory ?? '';
    _type = _eghu?.egxuType?.id == null
        ? null
        : _TypeOption(
            id: _eghu!.egxuType!.id!,
            name: _eghu!.egxuType!.name ?? 'EGHU',
          );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _api = widget.api ?? di.get<EghuActionApi>();
    _consumerSource =
        widget.consumerSource ??
        ConsumerRelationsEghuSource(
          widget.consumerApi ?? di.get<ConsumerRelationsApi>(),
        );
    try {
      final global = context.read<GlobalBloc>();
      if (!global.state.isEgxuTypesLoaded) {
        global.add(EgxuTypesRequested());
      }
      _syncTypes(global.state);
    } catch (_) {}
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTargetInfo());
  }

  @override
  void dispose() {
    _documentNumber.dispose();
    _oneFactory.dispose();
    _twoFactory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: EghuActionCreateColors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: PopScope(
              canPop: _step == 0 && !_submitting,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop && !_submitting) _back();
              },
              child: Column(
                children: [
                  _header(),
                  if (_loading)
                    const LinearProgressIndicator(
                      minHeight: 2,
                      color: EghuActionCreateColors.primary,
                    ),
                  Expanded(child: _success ? _successBody() : _body()),
                  _success ? _successBottomBar() : _bottomBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return _withGlobalListener(content);
  }

  Widget _withGlobalListener(Widget child) {
    try {
      return BlocListener<GlobalBloc, GlobalState>(
        listenWhen: (p, c) => p.egxuTypes != c.egxuTypes,
        listener: (_, state) => _syncTypes(state),
        child: child,
      );
    } catch (_) {
      return child;
    }
  }

  void _syncTypes(GlobalState state) {
    final options = state.egxuTypes
        .map((item) => _TypeOption(id: item.id, name: item.name))
        .toList();
    final selected = _type;
    if (selected != null && !options.any((item) => item.id == selected.id)) {
      options.insert(0, selected);
    }
    if (!mounted) {
      _types = options;
      return;
    }
    setState(() => _types = options);
  }

  Future<void> _loadTargetInfo() async {
    final consumerId = _consumer?.id;
    if (consumerId == null || _api == null) return;
    setState(() => _loading = true);
    try {
      final info = await _api!.getTargetInfo(
        documentType: 'consumer',
        documentId: consumerId,
      );
      if (!mounted) return;
      final removals = info.pendingRemovals
          .map(_PendingRemoval.fromJson)
          .where((item) => item.id != null)
          .toList();
      final selected =
          _removal ??
          _firstMatchingRemoval(removals, _eghu?.id) ??
          (removals.isEmpty ? null : removals.first);
      setState(() {
        _targetInfo = info;
        _removals = removals;
        _removal = selected;
        _loading = false;
      });
      if (selected != null) _applyRemoval(selected);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _toast(error.toString().replaceAll('Exception: ', ''));
    }
  }

  _PendingRemoval? _firstMatchingRemoval(
    List<_PendingRemoval> items,
    int? eghuId,
  ) {
    if (eghuId == null) return null;
    for (final item in items) {
      if (item.eghuId == eghuId) return item;
    }
    return null;
  }

  Widget _header() {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: Row(
          children: [
            GestureDetector(
              key: const Key('eghu-reinstallation-back'),
              onTap: _back,
              child: AppTools.svg(AppTools.backIcon, width: 24, height: 24),
            ),
            Expanded(
              child: Text(
                'EGHU qayta oʻrnatish',
                textAlign: TextAlign.center,
                style: eghuText(
                  fontSize: 17,
                  lineHeight: 28,
                  fontWeight: FontWeight.w800,
                  color: EghuActionCreateColors.textStrong,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  content: Text(
                    'Qayta o‘rnatish uchun avval EGHU yechib olingan hujjatni tanlang.',
                    style: eghuText(fontSize: 13, lineHeight: 20),
                  ),
                ),
              ),
              child: AppTools.svg(AppTools.help, width: 24, height: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: switch (_step) {
        0 => _linkedDocumentStep(),
        1 => _generalInfoStep(),
        _ => _installedEghuStep(),
      },
    );
  }

  Widget _linkedDocumentStep() {
    final removal = _removal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _selectorField(
          label: 'Yechib olingan hujjat',
          value: removal?.displayNumber ?? 'Yechib olingan hujjatni tanlang',
          placeholder: removal == null,
          clearable: removal != null,
          onTap: _selectRemoval,
          onClear: () => setState(() => _removal = null),
        ),
        if (removal != null) ...[
          const SizedBox(height: 12),
          _infoCard(removal),
        ],
      ],
    );
  }

  Widget _infoCard(_PendingRemoval removal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: EghuActionCreateColors.field,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hujjatdan olingan maʼlumotlar',
            style: eghuText(
              fontSize: 11,
              lineHeight: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _infoRow('Isteʼmolchi', _consumerName, bold: true),
          _infoRow('Yechib olingan EGHU', _eghuName, bold: true),
          _infoRow('Yechib olingan sana', _date(removal.datetime), bold: true),
          _infoRow('Olib tashlash sababi', removal.reasonDisplay, bold: true),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: eghuText(fontSize: 11, lineHeight: 16)),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: eghuText(
              fontSize: 13,
              lineHeight: 20,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: EghuActionCreateColors.textStrong,
            ),
          ),
        ],
      ),
    );
  }

  Widget _generalInfoStep() {
    return Column(
      children: [
        _selectorField(
          label: 'Sana',
          value: DateFormat('dd.MM.yyyy HH:mm').format(_datetime.toLocal()),
          clearable: true,
          onTap: _pickDate,
        ),
        const SizedBox(height: 12),
        _selectorField(label: 'Viloyat', value: _regionName, onTap: null),
        const SizedBox(height: 12),
        _selectorField(label: 'Tuman', value: _districtName, onTap: null),
        const SizedBox(height: 12),
        _selectorField(
          label: 'Faoliyat turi',
          value: _activityName,
          onTap: null,
        ),
        const SizedBox(height: 12),
        _selectorField(label: 'Hujjat turi', value: 'Isteʼmolchi', onTap: null),
        const SizedBox(height: 12),
        _selectorField(
          label: 'Isteʼmolchini tanlang',
          value: _consumerName,
          placeholder: _consumer == null,
          onTap: _selectConsumer,
        ),
      ],
    );
  }

  Widget _installedEghuStep() {
    return Column(
      children: [
        _selectorField(
          label: 'Olib tashlash holati',
          value: _reasonLabel(_removalReason),
          onTap: _selectReason,
        ),
        const SizedBox(height: 12),
        _textField('Hujjat nomer', _documentNumber),
        const SizedBox(height: 12),
        _selectorField(
          label: 'Oʻrnatilgan EGHU turi',
          value: _type?.name ?? 'EGHU turini tanlang',
          placeholder: _type == null,
          onTap: _selectType,
        ),
        const SizedBox(height: 12),
        _textField('1-zavod raqami', _oneFactory),
        const SizedBox(height: 12),
        _textField('2-zavod raqami', _twoFactory),
      ],
    );
  }

  Widget _selectorField({
    required String label,
    required String value,
    bool placeholder = false,
    bool clearable = false,
    VoidCallback? onTap,
    VoidCallback? onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: eghuText(fontSize: 11, lineHeight: 16, letterSpacing: 0.4),
        ),
        const SizedBox(height: 4),
        Material(
          color: EghuActionCreateColors.field,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
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
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: eghuText(
                        fontSize: 13,
                        lineHeight: 20,
                        color: placeholder
                            ? EghuActionCreateColors.textSub
                            : EghuActionCreateColors.text,
                      ),
                    ),
                  ),
                  if (clearable && onClear != null)
                    GestureDetector(
                      onTap: onClear,
                      child: const Icon(Icons.close_rounded, size: 20),
                    )
                  else
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: EghuActionCreateColors.text,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: eghuText(fontSize: 11, lineHeight: 16, letterSpacing: 0.4),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: TextField(
            controller: controller,
            style: eghuText(fontSize: 13, lineHeight: 20),
            decoration: InputDecoration(
              filled: true,
              fillColor: EghuActionCreateColors.field,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: controller.clear,
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
              border: _border(),
              enabledBorder: _border(),
              focusedBorder: _border(EghuActionCreateColors.primary),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border([Color color = EghuActionCreateColors.stroke]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
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
      child: _step < 2
          ? _button(
              key: const Key('eghu-reinstallation-continue'),
              label: 'Davom etish',
              color: EghuActionCreateColors.primary,
              onTap: _continue,
            )
          : Row(
              children: [
                Expanded(
                  child: _button(
                    key: const Key('eghu-reinstallation-save'),
                    label: 'Saqlash',
                    color: const Color(0xFF3F57B3),
                    onTap: () => _submit(confirm: false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _button(
                    key: const Key('eghu-reinstallation-confirm'),
                    label: 'Tasdiqlash',
                    color: const Color(0xFF3FB343),
                    onTap: () => _submit(confirm: true),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _button({
    required Key key,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        key: key,
        onPressed: _submitting ? null : onTap,
        icon: const Icon(Icons.check_rounded, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          disabledBackgroundColor: EghuActionCreateColors.soft,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: eghuText(
            fontSize: 17,
            lineHeight: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _successBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEDF9F1),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF00A63C),
                size: 36,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'EGHU oʻrnatildi',
              textAlign: TextAlign.center,
              style: eghuText(
                fontSize: 17,
                lineHeight: 28,
                fontWeight: FontWeight.w800,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_removal?.displayNumber ?? 'Hujjat'} hujjati roʻyxatga olindi. '
              '${_oneFactory.text.trim().isEmpty ? 'EGHU' : _oneFactory.text.trim()} '
              'obyektga o‘rnatilgan deb qayd etildi.',
              textAlign: TextAlign.center,
              style: eghuText(fontSize: 13, lineHeight: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _successBottomBar() {
    return Container(
      color: EghuActionCreateColors.white,
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.paddingOf(context).bottom + 8,
      ),
      child: _button(
        key: const Key('eghu-reinstallation-return'),
        label: 'Roʻyxatga qaytish',
        color: EghuActionCreateColors.primary,
        onTap: () => Navigator.of(context).pop(true),
      ),
    );
  }

  void _back() {
    if (_submitting) return;
    if (_step == 0) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _step--);
    }
  }

  void _continue() {
    if (_step == 0 && _removal == null) {
      _toast('Yechib olingan hujjatni tanlang');
      return;
    }
    if (_step == 1 && _consumer?.id == null) {
      _toast('Isteʼmolchini tanlang');
      return;
    }
    setState(() => _step++);
  }

  Future<void> _selectRemoval() async {
    if (_removals.isEmpty && _consumer == null) {
      await _selectConsumer();
    }
    if (!mounted) return;
    if (_removals.isEmpty) {
      _toast('Qayta o‘rnatish uchun yechib olingan hujjat topilmadi');
      return;
    }
    final selected = await showDialog<_PendingRemoval>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => _ChoiceDialog<_PendingRemoval>(
        title: 'Yechib olingan hujjatni tanlang',
        hint: 'Hujjat, isteʼmolchi yoki EGHU raqami',
        items: _removals,
        titleOf: (item) => item.displayNumber,
        subtitleOf: (item) =>
            '$_consumerName, $_eghuName, ${_date(item.datetime)}',
        initiallySelected: _removal,
      ),
    );
    if (!mounted || selected == null) return;
    _applyRemoval(selected);
  }

  void _applyRemoval(_PendingRemoval removal) {
    setState(() {
      _removal = removal;
      _removalReason = removal.reason;
      _datetime = removal.datetime ?? _datetime;
      final target = _targetInfo?.egxus
          .where((item) => item.id == removal.eghuId)
          .firstOrNull;
      if (target != null && _eghu == null) {
        _oneFactory.text = target.oneFactory ?? '';
        _twoFactory.text = target.twoFactory ?? '';
      }
    });
  }

  Future<void> _selectConsumer() async {
    final selected = await showModalBottomSheet<WorkingWithConsumersList>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EghuConsumerPickerSheet(
        source: _consumerSource!,
        selected: _consumer,
      ),
    );
    if (!mounted || selected == null) return;
    try {
      final detail = await _consumerSource!.getDocumentById(selected.id);
      if (!mounted) return;
      setState(() {
        _consumer = selected;
        _detail = detail;
        _eghu = detail.egxuList?.firstOrNull;
        _removal = null;
        _removals = const [];
        _oneFactory.text = _eghu?.oneFactory ?? '';
        _twoFactory.text = _eghu?.twoFactory ?? '';
      });
      await _loadTargetInfo();
    } catch (error) {
      if (mounted) _toast(error.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _pickDate() async {
    final value = await pickEghuStampDateTime(
      context,
      currentStampDateTime: _datetime,
    );
    if (mounted && value != null) setState(() => _datetime = value);
  }

  Future<void> _selectReason() async {
    final options = const [
      _ReasonOption('other_type_or_factory', 'Boshqa EGHU bilan almashtirish'),
      _ReasonOption(
        'for_certificate_replacement',
        'Sertifikat yangilash uchun',
      ),
      _ReasonOption('for_repair', 'Taʼmirlash uchun'),
    ];
    final selected = await showDialog<_ReasonOption>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => _ChoiceDialog<_ReasonOption>(
        title: 'Olib tashlash holati',
        hint: 'Sababni qidiring',
        items: options,
        titleOf: (item) => item.label,
        subtitleOf: (_) => '',
        initiallySelected: options
            .where((item) => item.code == _removalReason)
            .firstOrNull,
      ),
    );
    if (mounted && selected != null) {
      setState(() => _removalReason = selected.code);
    }
  }

  Future<void> _selectType() async {
    if (_types.isEmpty) {
      _toast('EGHU turlari yuklanmoqda');
      return;
    }
    final selected = await showDialog<_TypeOption>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => _ChoiceDialog<_TypeOption>(
        title: 'Oʻrnatilgan EGHU turini tanlang',
        hint: 'EGHU turi nomi',
        items: _types,
        titleOf: (item) => item.name,
        subtitleOf: (_) => '',
        initiallySelected: _type,
      ),
    );
    if (mounted && selected != null) setState(() => _type = selected);
  }

  Future<void> _submit({required bool confirm}) async {
    if (_removal?.id == null || _consumer?.id == null || _type?.id == null) {
      _toast('Majburiy maydonlarni to‘ldiring');
      return;
    }
    if (_oneFactory.text.trim().isEmpty) {
      _toast('1-zavod raqamini kiriting');
      return;
    }
    final accepted = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => _ActionDialog(
        confirm: confirm,
        documentNumber: _documentNumber.text.trim(),
      ),
    );
    if (!mounted || accepted != true) return;
    setState(() => _submitting = true);
    try {
      await _api!.createReinstallation(
        EghuReinstallationRequest(
          removalId: _removal!.id!,
          datetime: _datetime,
          consumerDocumentId: _consumer!.id,
          installedEghuTypeId: _type!.id,
          regionId: _detail?.region?.id ?? _targetInfo?.regionId,
          districtId: _detail?.district?.id ?? _targetInfo?.districtId,
          typeOfActivityId: _eghu?.consumerRelationEgxu?.typeOfActivityId,
          removalReason: _removalReason,
          documentNumber: _documentNumber.text,
          oneFactory: _oneFactory.text,
          twoFactory: _twoFactory.text,
          employeeId: _detail?.employee?.id,
        ),
      );
      if (!mounted) return;
      if (confirm) {
        setState(() {
          _success = true;
          _submitting = false;
        });
      } else {
        _toast('Hujjat saqlandi');
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _toast(error.toString().replaceAll('Exception: ', ''));
    }
  }

  String get _consumerName {
    final name = _consumer?.consumers.trim();
    if (name?.isNotEmpty == true) return name!;
    return _targetInfo?.targetName ?? 'Isteʼmolchini tanlang';
  }

  String get _eghuName {
    final values = <String>[
      if (_eghu?.egxuType?.name?.trim().isNotEmpty == true)
        _eghu!.egxuType!.name!,
      if (_eghu?.oneFactory?.trim().isNotEmpty == true) _eghu!.oneFactory!,
    ];
    return values.isEmpty ? 'EGHU' : values.join(', ');
  }

  String get _regionName =>
      _detail?.region?.name ?? _targetInfo?.regionName ?? '-';

  String get _districtName =>
      _detail?.district?.name ?? _targetInfo?.districtName ?? '-';

  String get _activityName =>
      _eghu?.consumerRelationEgxu?.typeOfActivity ?? 'Gaz taʼminoti';

  String _date(DateTime? value) =>
      value == null ? '-' : DateFormat('dd.MM.yyyy').format(value.toLocal());

  String _reasonLabel(String code) => switch (code) {
    'for_certificate_replacement' => 'Sertifikat yangilash uchun',
    'for_repair' => 'Taʼmirlash uchun',
    _ => 'Boshqa EGHU bilan almashtirish',
  };

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TypeOption {
  const _TypeOption({required this.id, required this.name});

  final int id;
  final String name;
}

class _ReasonOption {
  const _ReasonOption(this.code, this.label);

  final String code;
  final String label;
}

class _PendingRemoval {
  const _PendingRemoval({
    required this.id,
    required this.documentNumber,
    required this.datetime,
    required this.eghuId,
    required this.reason,
    required this.reasonDisplay,
  });

  final int? id;
  final String documentNumber;
  final DateTime? datetime;
  final int? eghuId;
  final String reason;
  final String reasonDisplay;

  String get displayNumber =>
      documentNumber.isEmpty ? 'Hujjat' : documentNumber;

  factory _PendingRemoval.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final item =
        rawItems is List && rawItems.isNotEmpty && rawItems.first is Map
        ? Map<String, dynamic>.from(rawItems.first as Map)
        : const <String, dynamic>{};
    final reason = (item['removal_reason'] ?? '').toString();
    return _PendingRemoval(
      id: _asInt(json['removal_id'] ?? json['id']),
      documentNumber: (json['document_number'] ?? '').toString(),
      datetime: DateTime.tryParse((json['datetime'] ?? '').toString()),
      eghuId: _asInt(item['egxu_id'] ?? item['egxu']),
      reason: reason.isEmpty ? 'other_type_or_factory' : reason,
      reasonDisplay: (item['removal_reason_display'] ?? '').toString(),
    );
  }
}

int? _asInt(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

class _ChoiceDialog<T> extends StatefulWidget {
  const _ChoiceDialog({
    required this.title,
    required this.hint,
    required this.items,
    required this.titleOf,
    required this.subtitleOf,
    this.initiallySelected,
  });

  final String title;
  final String hint;
  final List<T> items;
  final String Function(T item) titleOf;
  final String Function(T item) subtitleOf;
  final T? initiallySelected;

  @override
  State<_ChoiceDialog<T>> createState() => _ChoiceDialogState<T>();
}

class _ChoiceDialogState<T> extends State<_ChoiceDialog<T>> {
  final _search = TextEditingController();
  T? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initiallySelected;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final items = widget.items
        .where(
          (item) => '${widget.titleOf(item)} ${widget.subtitleOf(item)}'
              .toLowerCase()
              .contains(query),
        )
        .toList();
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 574),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: EghuActionCreateColors.white,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: eghuText(
                fontSize: 17,
                lineHeight: 28,
                fontWeight: FontWeight.w800,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 44,
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                style: eghuText(fontSize: 13, lineHeight: 20),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: eghuText(
                    fontSize: 13,
                    lineHeight: 20,
                    color: EghuActionCreateColors.textSub,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: EghuActionCreateColors.textSub,
                  ),
                  filled: true,
                  fillColor: EghuActionCreateColors.soft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 2),
                itemBuilder: (_, index) {
                  final item = items[index];
                  final selected = item == _selected;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _selected = item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? EghuActionCreateColors.field
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.titleOf(item),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: eghuText(
                                    fontSize: 13,
                                    lineHeight: 20,
                                    fontWeight: selected
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: EghuActionCreateColors.textStrong,
                                  ),
                                ),
                                if (widget.subtitleOf(item).isNotEmpty)
                                  Text(
                                    widget.subtitleOf(item),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: eghuText(
                                      fontSize: 11,
                                      lineHeight: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: EghuActionCreateColors.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _dialogButton(
                    label: 'Bekor qilish',
                    background: EghuActionCreateColors.soft,
                    foreground: EghuActionCreateColors.textStrong,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dialogButton(
                    label: 'Tanlash',
                    background: EghuActionCreateColors.primary,
                    foreground: Colors.white,
                    onTap: _selected == null
                        ? null
                        : () => Navigator.of(context).pop(_selected),
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

class _ActionDialog extends StatelessWidget {
  const _ActionDialog({required this.confirm, required this.documentNumber});

  final bool confirm;
  final String documentNumber;

  @override
  Widget build(BuildContext context) {
    final description = confirm
        ? 'Tasdiqlangandan keyin hujjat tahrirlanmaydi. EGHU oʻrnatilgan deb qayd etiladi va bogʻlangan yechib olish akti yopiladi.'
        : (documentNumber.isEmpty
              ? 'Hujjat qoralama sifatida saqlanadi. Keyinroq davom ettirishingiz mumkin.'
              : '$documentNumber hujjati qoralama sifatida saqlanadi. Keyinroq davom ettirishingiz mumkin.');
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: EghuActionCreateColors.white,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              confirm ? 'Hujjatni tasdiqlaysizmi?' : 'Hujjatni saqlaysizmi?',
              style: eghuText(
                fontSize: 17,
                lineHeight: 28,
                fontWeight: FontWeight.w800,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
            const SizedBox(height: 8),
            Text(description, style: eghuText(fontSize: 13, lineHeight: 20)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _dialogButton(
                    label: 'Bekor qilish',
                    background: EghuActionCreateColors.soft,
                    foreground: EghuActionCreateColors.textStrong,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dialogButton(
                    label: confirm ? 'Tasdiqlash' : 'Saqlash',
                    background: confirm
                        ? const Color(0xFF3FB343)
                        : const Color(0xFF3F57B3),
                    foreground: Colors.white,
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

Widget _dialogButton({
  required String label,
  required Color background,
  required Color foreground,
  required VoidCallback? onTap,
}) {
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
          Icon(
            onTap == null ? Icons.check_rounded : Icons.check_rounded,
            size: 18,
            color: foreground,
          ),
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
