import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../../core/api/working_with_consumers_api/consumer_relations_api.dart';
import '../../../../../../../core/common/words.dart';
import '../../../../../../../core/extension/message_extension.dart';
import '../../../../../../../core/models/global/global_model.dart';
import '../../../../../../../core/models/working_with_consumers_document/working_with_consumers_list.dart';
import '../../../../../../../di.dart';
import '../../../../../../../features/auth/presentation/bloc/login_bloc.dart';
import '../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../data/models/eghu_action_attachment.dart';
import '../../../../../data/models/eghu_removal_detail.dart';
import '../../../../../domain/entities/action_menu_item.dart';
import '../bloc/eghu_action_create_bloc/eghu_action_create_bloc.dart';
import '../widgets/create/eghu_action_bottom_sheets.dart';
import '../widgets/create/eghu_action_form_fields.dart';
import '../widgets/create/eghu_action_upload_widgets.dart';
import '../widgets/create/eghu_create_header.dart';
import '../widgets/eghu_calendar_dialog.dart';

class EghuActionCreatePage extends StatefulWidget {
  const EghuActionCreatePage({
    super.key,
    required this.actionType,
    this.api,
    this.detailApi,
    this.detail,
    this.consumerApi,
    this.consumerSource,
    this.bloc,
    this.preselection,
  });

  final ActionMenuType actionType;
  final EghuActionSubmitApi? api;
  final EghuActionDetailApi? detailApi;
  final EghuRemovalDetail? detail;
  final ConsumerRelationsApi? consumerApi;
  final EghuActionConsumerSource? consumerSource;
  final EghuActionCreateBloc? bloc;
  final EghuActionPreselection? preselection;

  @override
  State<EghuActionCreatePage> createState() => _EghuActionCreatePageState();
}

class _EghuActionCreatePageState extends State<EghuActionCreatePage> {
  final _imagePicker = ImagePicker();
  EghuActionCreateBloc? _bloc;
  EghuActionConsumerSource? _consumerSource;
  EghuStampPlaceSource? _placeSource;
  bool _profileLoadRequested = false;
  bool _preselectionApplied = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _consumerSource ??=
        widget.consumerSource ??
        ConsumerRelationsEghuSource(
          widget.consumerApi ?? di.get<ConsumerRelationsApi>(),
        );
    _placeSource ??= defaultStampPlaceSource();

    final profile = _readLoginState(context);
    _bloc ??=
        widget.bloc ??
        EghuActionCreateBloc(
          actionType: widget.actionType,
          api: widget.api ?? di.get<EghuActionApi>(),
          detailApi:
              widget.detailApi ??
              (widget.detail != null ? di.get<EghuActionApi>() : null),
          detail: widget.detail,
          employeeId: profile?.user?.employeeId,
          employeeName: profile?.user?.username,
          regionId: profile?.user?.regionId,
          districtId: profile?.user?.districtId,
        );

    if (profile?.user == null) {
      _requestProfileLoad(context);
    } else {
      _syncProfile(profile!);
    }

    _applyPreselection();
  }

  void _applyPreselection() {
    final preselection = widget.preselection;
    if (_preselectionApplied || preselection == null || widget.detail != null) {
      return;
    }
    _preselectionApplied = true;
    _bloc!
      ..add(EghuActionConsumerSelected(preselection.consumer))
      ..add(
        EghuActionEghuSelected(
          preselection.eghu,
          consumerDetail: preselection.detail,
        ),
      );
  }

  @override
  void dispose() {
    if (widget.bloc == null) _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocProvider.value(
      value: _bloc!,
      child: BlocConsumer<EghuActionCreateBloc, EghuActionCreateState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: _onSubmitStateChanged,
        builder: (context, state) {
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
                              EghuCreateHeader(
                                title: _title,
                                helpText: Words.eghuCreateHelpTooltip.tr(),
                                helpButtonKey: const Key(
                                  'eghu-create-help-button',
                                ),
                                helpTooltipKey: const Key(
                                  'eghu-create-help-tooltip',
                                ),
                              ),
                              const SizedBox(height: 24),
                              EghuSelectorField(
                                label: Words.consumer.tr(),
                                value: state.selectedConsumer == null
                                    ? Words.selectConsumer.tr()
                                    : state.selectedConsumer!.consumers,
                                placeholder: state.selectedConsumer == null,
                                onTap: () => _selectConsumer(context, state),
                              ),
                              const SizedBox(height: 12),
                              EghuSelectorField(
                                label: Words.eghu.tr(),
                                value: state.selectedEghu == null
                                    ? Words.selectEghu.tr()
                                    : eghuTitle(state.selectedEghu!),
                                placeholder: state.selectedEghu == null,
                                onTap: () => _selectEghu(context, state),
                              ),
                              const SizedBox(height: 16),
                              EghuUploadSection(
                                slot: EghuActionAttachmentSlot.act,
                                attachments: state.actFiles,
                                showHelp: true,
                                uploaderName: state.employeeName,
                                onAdd: () => _pickAttachment(
                                  context,
                                  EghuActionAttachmentSlot.act,
                                ),
                                onRemoveAt: (index) =>
                                    context.read<EghuActionCreateBloc>().add(
                                      EghuActionAttachmentRemovedAt(
                                        slot: EghuActionAttachmentSlot.act,
                                        index: index,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 16),
                              EghuStampSection(
                                stamps: state.stamps,
                                employeeName: state.employeeName,
                                showInstallationPlace: true,
                                onAdd: () => context
                                    .read<EghuActionCreateBloc>()
                                    .add(const EghuActionStampAdded()),
                                onNumberChanged: (localId, value) =>
                                    context.read<EghuActionCreateBloc>().add(
                                      EghuActionStampNumberChanged(
                                        value,
                                        localId: localId,
                                      ),
                                    ),
                                onDateChanged: (localId, value) =>
                                    context.read<EghuActionCreateBloc>().add(
                                      EghuActionStampDateChanged(
                                        value,
                                        localId: localId,
                                      ),
                                    ),
                                onSelectPlace: (localId) =>
                                    _selectStampPlace(context, state, localId),
                                onPlaceCleared: (localId) => context
                                    .read<EghuActionCreateBloc>()
                                    .add(EghuActionStampPlaceCleared(localId)),
                                onRemoveUnsaved: (localId) => context
                                    .read<EghuActionCreateBloc>()
                                    .add(EghuActionStampRemoved(localId)),
                              ),
                              const SizedBox(height: 16),
                              EghuUploadSection(
                                slot: EghuActionAttachmentSlot.comparison,
                                attachments: state.comparisonFiles,
                                showHelp: true,
                                uploaderName: state.employeeName,
                                onAdd: () => _pickAttachment(
                                  context,
                                  EghuActionAttachmentSlot.comparison,
                                ),
                                onRemoveAt: (index) =>
                                    context.read<EghuActionCreateBloc>().add(
                                      EghuActionAttachmentRemovedAt(
                                        slot: EghuActionAttachmentSlot.comparison,
                                        index: index,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      EghuSubmitBar(
                        enabled: state.canSubmit,
                        loading:
                            state.status == EghuActionSubmitStatus.submitting,
                        onTap: () => context.read<EghuActionCreateBloc>().add(
                          const EghuActionSubmitted(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    return _withLoginProfileListener(content);
  }

  String get _title => switch (widget.actionType) {
    ActionMenuType.reinstall => Words.actionEghuReinstall.tr(),
    ActionMenuType.detach => Words.actionEghuDetach.tr(),
    ActionMenuType.indicatorUpload => Words.actionEghuIndicatorUpload.tr(),
  };

  LoginState? _readLoginState(BuildContext context) {
    try {
      return context.read<LoginBloc>().state;
    } catch (_) {
      return null;
    }
  }

  void _requestProfileLoad(BuildContext context) {
    if (_profileLoadRequested) return;

    try {
      context.read<LoginBloc>().add(const LoadUserProfile());
      _profileLoadRequested = true;
    } catch (_) {
      // EGHU page tests can inject the create bloc without an auth provider.
    }
  }

  Widget _withLoginProfileListener(Widget child) {
    try {
      final loginBloc = context.read<LoginBloc>();
      return BlocListener<LoginBloc, LoginState>(
        bloc: loginBloc,
        listenWhen: (previous, current) =>
            previous.user != current.user && current.user != null,
        listener: (context, state) => _syncProfile(state),
        child: child,
      );
    } catch (_) {
      return child;
    }
  }

  void _syncProfile(LoginState state) {
    final user = state.user;
    if (user == null) return;

    _bloc?.add(
      EghuActionProfileChanged(
        employeeId: user.employeeId,
        employeeName: user.username,
        regionId: user.regionId,
        districtId: user.districtId,
      ),
    );
  }

  void _onSubmitStateChanged(
    BuildContext context,
    EghuActionCreateState state,
  ) {
    if (state.status == EghuActionSubmitStatus.success) {
      showToast(
        context,
        Words.eghuCreateSuccess.tr(),
        backgroundColor: const Color(0xFF17B26A),
      );
      Navigator.of(context).maybePop(true);
      return;
    }

    if (state.status == EghuActionSubmitStatus.failure) {
      showToast(context, _localizedErrorMessage(state.errorMessage));
    }
  }

  String _localizedErrorMessage(String message) {
    for (final word in Words.values) {
      if (word.name == message) return word.tr();
    }
    return message;
  }

  Future<void> _selectConsumer(
    BuildContext context,
    EghuActionCreateState state,
  ) async {
    final selected = await showModalBottomSheet<WorkingWithConsumersList>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EghuConsumerPickerSheet(
        source: _consumerSource!,
        selected: state.selectedConsumer,
      ),
    );

    if (!context.mounted || selected == null) return;
    context.read<EghuActionCreateBloc>().add(
      EghuActionConsumerSelected(selected),
    );
  }

  Future<void> _selectEghu(
    BuildContext context,
    EghuActionCreateState state,
  ) async {
    final consumer = state.selectedConsumer;
    if (consumer == null) {
      showToast(
        context,
        Words.selectConsumerFirst.tr(),
        backgroundColor: Colors.orange,
      );
      return;
    }

    final selected = await showModalBottomSheet<EghuDeviceSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EghuDevicePickerSheet(
        source: _consumerSource!,
        consumer: consumer,
        selected: state.selectedEghu,
      ),
    );

    if (!context.mounted || selected == null) return;
    context.read<EghuActionCreateBloc>().add(
      EghuActionEghuSelected(selected.item, consumerDetail: selected.detail),
    );
  }

  Future<void> _selectStampPlace(
    BuildContext context,
    EghuActionCreateState state,
    String localId,
  ) async {
    final stamp = state.stamps
        .where((item) => item.localId == localId)
        .firstOrNull;

    final selected = await showModalBottomSheet<GlobalModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EghuStampPlacePickerSheet(
        source: _placeSource!,
        selectedId: stamp?.installationPlaceId,
      ),
    );

    if (!context.mounted || selected?.id == null) return;
    context.read<EghuActionCreateBloc>().add(
      EghuActionStampPlaceChanged(
        localId: localId,
        placeId: selected!.id!,
        placeName: selected.name ?? '',
      ),
    );
  }

  Future<void> _pickAttachment(
    BuildContext context,
    EghuActionAttachmentSlot slot,
  ) async {
    final source = await showModalBottomSheet<EghuAttachmentSource>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EghuAttachmentSourceSheet(),
    );

    if (!context.mounted || source == null) return;

    try {
      final List<EghuActionAttachment> attachments;
      if (source == EghuAttachmentSource.camera) {
        final image = await _pickFromCamera();
        attachments = image == null ? const [] : [image];
      } else {
        attachments = await _pickFromDevice();
      }
      if (!context.mounted || attachments.isEmpty) return;

      final bloc = context.read<EghuActionCreateBloc>();
      for (final attachment in attachments) {
        bloc.add(EghuActionAttachmentAdded(slot: slot, file: attachment));
      }
    } catch (e) {
      if (!context.mounted) return;
      showToast(
        context,
        '${Words.filePickFailed.tr()}: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  Future<EghuActionAttachment?> _pickFromCamera() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image == null) return null;

    return EghuActionAttachment(
      path: image.path,
      name: _fileName(image.path),
      sizeBytes: await image.length(),
      isImage: true,
      sourceLabel: Words.openCamera.tr(),
      createdAt: DateTime.now(),
    );
  }

  Future<List<EghuActionAttachment>> _pickFromDevice() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const [
        'jpg',
        'jpeg',
        'png',
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
      ],
      withData: false,
    );
    if (result == null) return const [];

    final attachments = <EghuActionAttachment>[];
    for (final file in result.files) {
      final path = file.path;
      if (path == null) continue;
      attachments.add(
        EghuActionAttachment(
          path: path,
          name: file.name,
          sizeBytes: file.size == 0 ? await File(path).length() : file.size,
          isImage: _isImage(path),
          sourceLabel: Words.uploadFromPhone.tr(),
          createdAt: DateTime.now(),
        ),
      );
    }
    return attachments;
  }

  String _fileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.split('/').last;
  }

  bool _isImage(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');
  }
}

class _EghuStampTimeDialog extends StatefulWidget {
  const _EghuStampTimeDialog({
    required this.selectedDate,
    required this.initialTime,
    required this.now,
  });

  final DateTime selectedDate;
  final TimeOfDay initialTime;
  final DateTime now;

  @override
  State<_EghuStampTimeDialog> createState() => _EghuStampTimeDialogState();
}

class _EghuStampTimeDialogState extends State<_EghuStampTimeDialog> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    final clamped = _clampTimeForDate(
      widget.initialTime,
      selectedDate: widget.selectedDate,
      now: widget.now,
    );
    _hour = clamped.hour;
    _minute = clamped.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        key: const Key('eghu-stamp-time-dialog'),
        width: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E6F2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 11,
              offset: Offset(0, 11),
            ),
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 15,
              offset: Offset(0, 25),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Words.chooseTime.tr(),
              style: GoogleFonts.manrope(
                fontSize: 17,
                height: 28 / 17,
                fontWeight: FontWeight.w500,
                color: EghuActionCreateColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_twoDigits(_hour)}:${_twoDigits(_minute)}',
              key: const Key('eghu-selected-time-label'),
              style: GoogleFonts.manrope(
                fontSize: 28,
                height: 36 / 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF314692),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TimeColumn(
                    title: Words.hour.tr(),
                    itemCount: 24,
                    selectedValue: _hour,
                    itemKeyPrefix: 'eghu-time-hour',
                    isEnabled: _isHourEnabled,
                    onSelected: (value) {
                      setState(() {
                        _hour = value;
                        if (!_isMinuteEnabled(_minute)) {
                          _minute = _maxMinuteForHour(_hour);
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeColumn(
                    title: Words.minute.tr(),
                    itemCount: 60,
                    selectedValue: _minute,
                    itemKeyPrefix: 'eghu-time-minute',
                    isEnabled: _isMinuteEnabled,
                    onSelected: (value) => setState(() => _minute = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                key: const Key('eghu-time-confirm'),
                onPressed: () => Navigator.of(
                  context,
                ).pop(TimeOfDay(hour: _hour, minute: _minute)),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: EghuActionCreateColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  Words.select.tr(),
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    height: 24 / 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isHourEnabled(int hour) {
    if (!_isSameDate(widget.selectedDate, widget.now)) return true;
    return hour <= widget.now.hour;
  }

  bool _isMinuteEnabled(int minute) {
    if (!_isSameDate(widget.selectedDate, widget.now)) return true;
    if (_hour < widget.now.hour) return true;
    if (_hour > widget.now.hour) return false;
    return minute <= widget.now.minute;
  }

  int _maxMinuteForHour(int hour) {
    if (!_isSameDate(widget.selectedDate, widget.now)) return 59;
    if (hour < widget.now.hour) return 59;
    if (hour == widget.now.hour) return widget.now.minute;
    return 0;
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.title,
    required this.itemCount,
    required this.selectedValue,
    required this.itemKeyPrefix,
    required this.isEnabled,
    required this.onSelected,
  });

  final String title;
  final int itemCount;
  final int selectedValue;
  final String itemKeyPrefix;
  final bool Function(int value) isEnabled;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: _calendarTextStyle(
            13,
            const Color(0xFFD9D9D9),
            lineHeight: 20,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: EghuActionCreateColors.field,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: EghuActionCreateColors.stroke),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(itemCount, (index) {
                final enabled = isEnabled(index);
                final selected = index == selectedValue;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  child: InkWell(
                    key: Key('$itemKeyPrefix-${_twoDigits(index)}'),
                    borderRadius: BorderRadius.circular(8),
                    onTap: enabled ? () => onSelected(index) : null,
                    child: Container(
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? EghuActionCreateColors.primary
                            : enabled
                            ? Colors.transparent
                            : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _twoDigits(index),
                        style: _calendarTextStyle(
                          15,
                          selected
                              ? Colors.white
                              : enabled
                              ? EghuActionCreateColors.text
                              : const Color(0xFFD9D9D9),
                          lineHeight: 24,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

TextStyle _calendarTextStyle(
  double fontSize,
  Color color, {
  required double lineHeight,
}) {
  return GoogleFonts.manrope(
    fontSize: fontSize,
    height: lineHeight / fontSize,
    fontWeight: FontWeight.w500,
    color: color,
  );
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _clampDate(
  DateTime value, {
  required DateTime min,
  required DateTime max,
}) {
  if (value.isBefore(min)) return min;
  if (value.isAfter(max)) return max;
  return value;
}

TimeOfDay _initialStampTimeForDate({
  required DateTime selectedDate,
  required DateTime? currentStampDateTime,
  required DateTime now,
}) {
  final time =
      currentStampDateTime != null &&
          _isSameDate(currentStampDateTime, selectedDate)
      ? TimeOfDay.fromDateTime(currentStampDateTime)
      : TimeOfDay.fromDateTime(now);
  return _clampTimeForDate(time, selectedDate: selectedDate, now: now);
}

TimeOfDay _clampTimeForDate(
  TimeOfDay time, {
  required DateTime selectedDate,
  required DateTime now,
}) {
  if (!_isSameDate(selectedDate, now)) return time;
  final nowTime = TimeOfDay.fromDateTime(now);
  return _isTimeAfter(time, nowTime) ? nowTime : time;
}

bool _isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _isTimeAfter(TimeOfDay value, TimeOfDay limit) {
  if (value.hour != limit.hour) return value.hour > limit.hour;
  return value.minute > limit.minute;
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

Future<DateTime?> pickEghuStampDateTime(
  BuildContext context, {
  DateTime? currentStampDateTime,
}) async {
  final now = DateTime.now();
  final today = _dateOnly(now);
  final initialDate = _clampDate(
    _dateOnly(currentStampDateTime ?? now),
    min: DateTime(2020),
    max: today,
  );

  final date = await pickEghuDate(
    context,
    initialDate: initialDate,
    firstDate: DateTime(2020),
    lastDate: today,
    dialogKey: const Key('eghu-stamp-calendar-dialog'),
  );
  if (!context.mounted || date == null) return null;

  final initialTime = _initialStampTimeForDate(
    selectedDate: date,
    currentStampDateTime: currentStampDateTime,
    now: now,
  );
  final time = await showDialog<TimeOfDay>(
    context: context,
    builder: (_) => _EghuStampTimeDialog(
      selectedDate: date,
      initialTime: initialTime,
      now: now,
    ),
  );
  if (!context.mounted || time == null) return null;

  final latestNow = DateTime.now();
  if (_isSameDate(date, latestNow) &&
      _isTimeAfter(time, TimeOfDay.fromDateTime(latestNow))) {
    return null;
  }

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
