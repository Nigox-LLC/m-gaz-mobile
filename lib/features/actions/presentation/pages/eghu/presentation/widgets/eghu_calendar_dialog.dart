import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'create/eghu_action_form_fields.dart';

Future<DateTime?> pickEghuDate(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  Key? dialogKey,
}) {
  final now = DateTime.now();
  final minDate = _dateOnly(firstDate ?? DateTime(2020));
  final maxDate = _dateOnly(lastDate ?? DateTime(now.year + 5, 12, 31));
  final selected = _clampDate(
    _dateOnly(initialDate ?? now),
    min: minDate,
    max: maxDate,
  );

  return showDialog<DateTime>(
    context: context,
    builder: (_) => EghuCalendarDialog(
      initialDate: selected,
      firstDate: minDate,
      lastDate: maxDate,
      dialogKey: dialogKey,
    ),
  );
}

class EghuCalendarDialog extends StatefulWidget {
  const EghuCalendarDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.dialogKey,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Key? dialogKey;

  @override
  State<EghuCalendarDialog> createState() => _EghuCalendarDialogState();
}

class _EghuCalendarDialogState extends State<EghuCalendarDialog> {
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
        key: widget.dialogKey,
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

bool _isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _isDateAfter(DateTime value, DateTime limit) =>
    _dateOnly(value).isAfter(_dateOnly(limit));

bool _isDateBefore(DateTime value, DateTime limit) =>
    _dateOnly(value).isBefore(_dateOnly(limit));

String _dateKey(DateTime day) =>
    '${day.year}-${_twoDigits(day.month)}-${_twoDigits(day.day)}';

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}
