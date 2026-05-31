import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../../../core/api/working_with_consumers_api/consumer_relations_api.dart';
import '../../../../../../../core/common/words.dart';
import '../../../../../../../core/extension/message_extension.dart';
import '../../../../../../../core/models/working_with_consumers_document/working_with_consumers_list.dart';
import '../../../../../../../di.dart';
import '../../../../../../../features/auth/presentation/bloc/login_bloc.dart';
import '../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../data/models/eghu_action_attachment.dart';
import '../../../../../domain/entities/action_menu_item.dart';
import '../bloc/eghu_action_create_bloc.dart';
import '../widgets/create/eghu_action_bottom_sheets.dart';
import '../widgets/create/eghu_action_form_fields.dart';
import '../widgets/create/eghu_action_upload_widgets.dart';

class EghuActionCreatePage extends StatefulWidget {
  const EghuActionCreatePage({
    super.key,
    required this.actionType,
    this.api,
    this.consumerApi,
    this.consumerSource,
    this.bloc,
  });

  final ActionMenuType actionType;
  final EghuActionSubmitApi? api;
  final ConsumerRelationsApi? consumerApi;
  final EghuActionConsumerSource? consumerSource;
  final EghuActionCreateBloc? bloc;

  @override
  State<EghuActionCreatePage> createState() => _EghuActionCreatePageState();
}

class _EghuActionCreatePageState extends State<EghuActionCreatePage> {
  final _stampController = TextEditingController();
  final _imagePicker = ImagePicker();
  EghuActionCreateBloc? _bloc;
  EghuActionConsumerSource? _consumerSource;
  bool _profileLoadRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _consumerSource ??=
        widget.consumerSource ??
        ConsumerRelationsEghuSource(
          widget.consumerApi ?? di.get<ConsumerRelationsApi>(),
        );

    final profile = _readLoginState(context);
    _bloc ??=
        widget.bloc ??
        EghuActionCreateBloc(
          actionType: widget.actionType,
          api: widget.api ?? di.get<EghuActionApi>(),
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
  }

  @override
  void dispose() {
    _stampController.dispose();
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
          if (_stampController.text != state.stampNumber) {
            _stampController.value = TextEditingValue(
              text: state.stampNumber,
              selection: TextSelection.collapsed(
                offset: state.stampNumber.length,
              ),
            );
          }

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
                              _CreateHeader(title: _title),
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
                                attachment: state.actFile,
                                showHelp: true,
                                uploaderName: state.employeeName,
                                onAdd: () => _pickAttachment(
                                  context,
                                  EghuActionAttachmentSlot.act,
                                ),
                                onRemove: () =>
                                    context.read<EghuActionCreateBloc>().add(
                                      const EghuActionAttachmentRemoved(
                                        EghuActionAttachmentSlot.act,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 16),
                              EghuStampSection(
                                controller: _stampController,
                                employeeName: state.employeeName,
                                selectedDate: state.stampDateTime,
                                onNumberChanged: (value) => context
                                    .read<EghuActionCreateBloc>()
                                    .add(EghuActionStampNumberChanged(value)),
                                onPickDate: () =>
                                    _pickStampDate(context, state),
                              ),
                              const SizedBox(height: 16),
                              EghuUploadSection(
                                slot: EghuActionAttachmentSlot.comparison,
                                attachment: state.comparisonFile,
                                showHelp: true,
                                uploaderName: state.employeeName,
                                onAdd: () => _pickAttachment(
                                  context,
                                  EghuActionAttachmentSlot.comparison,
                                ),
                                onRemove: () =>
                                    context.read<EghuActionCreateBloc>().add(
                                      const EghuActionAttachmentRemoved(
                                        EghuActionAttachmentSlot.comparison,
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
      final attachment = source == EghuAttachmentSource.camera
          ? await _pickFromCamera()
          : await _pickFromDevice();
      if (!context.mounted || attachment == null) return;

      context.read<EghuActionCreateBloc>().add(
        EghuActionAttachmentSet(slot: slot, file: attachment),
      );
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

  Future<EghuActionAttachment?> _pickFromDevice() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      withData: false,
    );
    final file = result?.files.single;
    final path = file?.path;
    if (file == null || path == null) return null;

    return EghuActionAttachment(
      path: path,
      name: file.name,
      sizeBytes: file.size == 0 ? await File(path).length() : file.size,
      isImage: _isImage(path),
      sourceLabel: Words.uploadFromPhone.tr(),
      createdAt: DateTime.now(),
    );
  }

  Future<void> _pickStampDate(
    BuildContext context,
    EghuActionCreateState state,
  ) async {
    final now = DateTime.now();
    final today = _dateOnly(now);
    final initialDate = _clampDate(
      _dateOnly(state.stampDateTime ?? now),
      min: DateTime(2020),
      max: today,
    );

    final date = await showDialog<DateTime>(
      context: context,
      builder: (_) => _EghuStampCalendarDialog(
        initialDate: initialDate,
        firstDate: DateTime(2020),
        lastDate: today,
      ),
    );
    if (!context.mounted || date == null) return;

    final initialTime = _initialStampTimeForDate(
      selectedDate: date,
      currentStampDateTime: state.stampDateTime,
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
    if (!context.mounted || time == null) return;

    final latestNow = DateTime.now();
    if (_isSameDate(date, latestNow) &&
        _isTimeAfter(time, TimeOfDay.fromDateTime(latestNow))) {
      showToast(context, Words.futureTimeInvalid.tr());
      return;
    }

    context.read<EghuActionCreateBloc>().add(
      EghuActionStampDateChanged(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      ),
    );
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

class _CreateHeader extends StatefulWidget {
  const _CreateHeader({required this.title});

  final String title;

  @override
  State<_CreateHeader> createState() => _CreateHeaderState();
}

class _CreateHeaderState extends State<_CreateHeader> {
  final LayerLink _helpLink = LayerLink();
  OverlayEntry? _tooltipEntry;

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  void _toggleTooltip() {
    if (_tooltipEntry != null) {
      _hideTooltip();
      return;
    }

    _tooltipEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: CompositedTransformFollower(
            link: _helpLink,
            showWhenUnlinked: false,
            offset: const Offset(-250, 32),
            child: const Align(
              alignment: Alignment.topLeft,
              widthFactor: 1,
              heightFactor: 1,
              child: _CreateHeaderHelpTooltip(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_tooltipEntry!);
  }

  void _hideTooltip() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.chevron_left_rounded),
            color: EghuActionCreateColors.textStrong,
            iconSize: 28,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 40),
          ),
          Expanded(
            child: Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 17,
                height: 28 / 17,
                fontWeight: FontWeight.w800,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
          ),
          CompositedTransformTarget(
            link: _helpLink,
            child: IconButton(
              key: const Key('eghu-create-help-button'),
              onPressed: _toggleTooltip,
              icon: const Icon(Icons.help_outline_rounded),
              color: EghuActionCreateColors.textStrong,
              iconSize: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 40),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateHeaderHelpTooltip extends StatelessWidget {
  const _CreateHeaderHelpTooltip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('eghu-create-help-tooltip'),
      width: 275,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -4,
            right: 2,
            child: Container(
              key: const Key('eghu-create-help-tooltip-dot'),
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.fromLTRB(12, 9, 13, 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 1.5,
                  offset: Offset(0, 1),
                ),
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 15,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              Words.eghuCreateHelpTooltip.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 11,
                height: 16 / 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EghuStampCalendarDialog extends StatefulWidget {
  const _EghuStampCalendarDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_EghuStampCalendarDialog> createState() =>
      _EghuStampCalendarDialogState();
}

class _EghuStampCalendarDialogState extends State<_EghuStampCalendarDialog> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        key: const Key('eghu-stamp-calendar-dialog'),
        width: 320,
        padding: const EdgeInsets.all(12),
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
            _EghuCalendarHeader(
              focusedDay: _focusedDay,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              locale: locale,
              onPrevious: _canGoPrevious
                  ? () => setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month - 1,
                      );
                    })
                  : null,
              onNext: _canGoNext
                  ? () => setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month + 1,
                      );
                    })
                  : null,
            ),
            const SizedBox(height: 12),
            TableCalendar<void>(
              locale: locale,
              firstDay: widget.firstDate,
              lastDay: widget.lastDate,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => _isSameDate(day, _selectedDay),
              enabledDayPredicate: (day) =>
                  !_isDateAfter(day, widget.lastDate) &&
                  !_isDateBefore(day, widget.firstDate),
              headerVisible: false,
              rowHeight: 36,
              daysOfWeekHeight: 36,
              availableGestures: AvailableGestures.horizontalSwipe,
              startingDayOfWeek: StartingDayOfWeek.monday,
              onPageChanged: (focusedDay) =>
                  setState(() => _focusedDay = focusedDay),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: _calendarTextStyle(
                  13,
                  const Color(0xFFD9D9D9),
                  lineHeight: 20,
                ),
                weekendStyle: _calendarTextStyle(
                  13,
                  const Color(0xFFD9D9D9),
                  lineHeight: 20,
                ),
              ),
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: true,
                markerDecoration: BoxDecoration(color: Colors.transparent),
              ),
              calendarBuilders: CalendarBuilders<void>(
                defaultBuilder: (context, day, focusedDay) =>
                    _EghuCalendarDayCell(
                      day: day,
                      onTap: () => _handleDaySelected(day, focusedDay),
                    ),
                todayBuilder: (context, day, focusedDay) =>
                    _EghuCalendarDayCell(
                      day: day,
                      isToday: true,
                      onTap: () => _handleDaySelected(day, focusedDay),
                    ),
                selectedBuilder: (context, day, focusedDay) =>
                    _EghuCalendarDayCell(
                      day: day,
                      isSelected: true,
                      onTap: () => _handleDaySelected(day, focusedDay),
                    ),
                disabledBuilder: (context, day, focusedDay) =>
                    _EghuCalendarDayCell(day: day, isDisabled: true),
                outsideBuilder: (context, day, focusedDay) {
                  final enabled =
                      !_isDateAfter(day, widget.lastDate) &&
                      !_isDateBefore(day, widget.firstDate);
                  return _EghuCalendarDayCell(
                    day: day,
                    isOutside: true,
                    onTap: enabled
                        ? () => _handleDaySelected(day, focusedDay)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canGoPrevious {
    final previous = DateTime(_focusedDay.year, _focusedDay.month - 1);
    final firstMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    return !previous.isBefore(firstMonth);
  }

  bool get _canGoNext {
    final next = DateTime(_focusedDay.year, _focusedDay.month + 1);
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);
    return !next.isAfter(lastMonth);
  }

  void _handleDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (_isDateAfter(selectedDay, widget.lastDate) ||
        _isDateBefore(selectedDay, widget.firstDate)) {
      return;
    }
    setState(() {
      _selectedDay = _dateOnly(selectedDay);
      _focusedDay = focusedDay;
    });
    Navigator.of(context).pop(_dateOnly(selectedDay));
  }
}

class _EghuCalendarHeader extends StatelessWidget {
  const _EghuCalendarHeader({
    required this.focusedDay,
    required this.firstDate,
    required this.lastDate,
    required this.locale,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime focusedDay;
  final DateTime firstDate;
  final DateTime lastDate;
  final String locale;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final month = DateFormat.MMMM(locale).format(focusedDay);

    return Row(
      children: [
        _CalendarNavButton(
          key: const Key('eghu-calendar-previous-month'),
          icon: Icons.chevron_left_rounded,
          onPressed: onPrevious,
        ),
        Expanded(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.manrope(
                fontSize: 17,
                height: 28 / 17,
                fontWeight: FontWeight.w500,
                color: EghuActionCreateColors.text,
              ),
              children: [
                TextSpan(text: '${_capitalize(month)} '),
                TextSpan(
                  text: '${focusedDay.year}',
                  style: const TextStyle(color: Color(0xFF314692)),
                ),
              ],
            ),
          ),
        ),
        _CalendarNavButton(
          key: const Key('eghu-calendar-next-month'),
          icon: Icons.chevron_right_rounded,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _CalendarNavButton extends StatelessWidget {
  const _CalendarNavButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 20,
        color: onPressed == null
            ? const Color(0xFFD9D9D9)
            : EghuActionCreateColors.text,
      ),
    );
  }
}

class _EghuCalendarDayCell extends StatelessWidget {
  const _EghuCalendarDayCell({
    required this.day,
    this.isSelected = false,
    this.isToday = false,
    this.isDisabled = false,
    this.isOutside = false,
    this.onTap,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;
  final bool isOutside;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
    final Color backgroundColor;
    final Color textColor;

    if (isSelected) {
      backgroundColor = EghuActionCreateColors.primary;
      textColor = Colors.white;
    } else if (isDisabled) {
      backgroundColor = Colors.transparent;
      textColor = const Color(0xFFD9D9D9);
    } else if (isToday) {
      backgroundColor = const Color(0xFFE0E0E0);
      textColor = EghuActionCreateColors.text;
    } else {
      backgroundColor = Colors.transparent;
      textColor = isWeekend || isOutside
          ? EghuActionCreateColors.primary
          : EghuActionCreateColors.text;
    }

    return GestureDetector(
      key: Key('eghu-calendar-day-${_dateKey(day)}'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: _calendarTextStyle(15, textColor, lineHeight: 24),
            ),
          ),
        ),
      ),
    );
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

bool _isDateAfter(DateTime value, DateTime limit) =>
    _dateOnly(value).isAfter(_dateOnly(limit));

bool _isDateBefore(DateTime value, DateTime limit) =>
    _dateOnly(value).isBefore(_dateOnly(limit));

bool _isTimeAfter(TimeOfDay value, TimeOfDay limit) {
  if (value.hour != limit.hour) return value.hour > limit.hour;
  return value.minute > limit.minute;
}

String _dateKey(DateTime day) =>
    '${day.year}-${_twoDigits(day.month)}-${_twoDigits(day.day)}';

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}
