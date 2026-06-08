import 'dart:async';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/features/profile/presentation/pages/profile_page.dart';

import '../../../core/common/words.dart';
import '../../../core/enums/task_status_enum.dart';
import '../../../core/models/task/task_analysis.dart';
import '../../../core/utils/colors.dart';
import '../tasks/bloc/task_bloc.dart';
import '../tasks/bloc/task_event.dart';
import '../tasks/bloc/task_state.dart';

@visibleForTesting
class DashboardDateRange {
  const DashboardDateRange({required this.dateFrom, required this.dateTo});

  final DateTime dateFrom;
  final DateTime dateTo;
}

@visibleForTesting
DateTime dashboardSubtractMonths(DateTime date, int months) {
  final targetMonth = date.month - months;
  final targetYear = date.year + ((targetMonth - 1) ~/ 12);
  final normalizedMonth = ((targetMonth - 1) % 12) + 1;
  final lastDay = DateUtils.getDaysInMonth(targetYear, normalizedMonth);
  final day = date.day > lastDay ? lastDay : date.day;
  return DateTime(targetYear, normalizedMonth, day);
}

enum _DashboardPeriod { oneDay, oneMonth, threeMonths, sixMonths, custom }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.nowProvider, this.calendarBuilder});

  @visibleForTesting
  final DateTime Function()? nowProvider;

  @visibleForTesting
  final Widget Function(DashboardDateRange initialRange)? calendarBuilder;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double xOffset = 0, yOffset = 0, scaleFactor = 1;
  bool isDrawerOpen = false;
  _DashboardPeriod _period = _DashboardPeriod.oneMonth;
  late DashboardDateRange _selectedRange;
  late DateTime _analysisTime;

  DateTime get _today => DateUtils.dateOnly(widget.nowProvider?.call() ?? DateTime.now());

  @override
  void initState() {
    super.initState();
    _selectedRange = _rangeFor(_DashboardPeriod.oneMonth);
    _analysisTime = widget.nowProvider?.call() ?? DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TaskBloc>().add(TaskProfileLoad());
    });
    _loadAnalysis();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.dark),
    );
  }

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
      xOffset = isDrawerOpen ? 260 : 0;
      yOffset = isDrawerOpen ? 120 : 0;
      scaleFactor = isDrawerOpen ? 0.8 : 1;
    });
  }

  DashboardDateRange _rangeFor(_DashboardPeriod period) {
    final to = _today;
    return switch (period) {
      _DashboardPeriod.oneDay => DashboardDateRange(dateFrom: to, dateTo: to),
      _DashboardPeriod.oneMonth => DashboardDateRange(dateFrom: dashboardSubtractMonths(to, 1), dateTo: to),
      _DashboardPeriod.threeMonths => DashboardDateRange(dateFrom: dashboardSubtractMonths(to, 3), dateTo: to),
      _DashboardPeriod.sixMonths => DashboardDateRange(dateFrom: dashboardSubtractMonths(to, 6), dateTo: to),
      _DashboardPeriod.custom => _selectedRange,
    };
  }

  void _loadAnalysis() {
    _analysisTime = widget.nowProvider?.call() ?? DateTime.now();
    context.read<TaskBloc>().add(TaskAnalysisLoad(dateFrom: _selectedRange.dateFrom, dateTo: _selectedRange.dateTo));
  }

  void _selectPreset(_DashboardPeriod period) {
    setState(() {
      _period = period;
      _selectedRange = _rangeFor(period);
    });
    _loadAnalysis();
  }

  Future<void> _openCalendar() async {
    final range = await showDialog<DashboardDateRange>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.08),
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        alignment: Alignment.center,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: widget.calendarBuilder?.call(_selectedRange) ?? _DashboardRangeCalendar(initialRange: _selectedRange),
      ),
    );
    if (range == null || !mounted) return;

    setState(() {
      _period = _DashboardPeriod.custom;
      _selectedRange = range;
    });
    _loadAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // const CustomDrawer(),
            GestureDetector(
              onTap: () => isDrawerOpen ? toggleDrawer() : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                transform: Matrix4.translationValues(xOffset, yOffset, 0)..scaleByDouble(scaleFactor, scaleFactor, scaleFactor, 1),
                decoration: BoxDecoration(
                  color: _DashboardColors.background,
                  borderRadius: isDrawerOpen ? BorderRadius.circular(30) : BorderRadius.zero,
                  boxShadow: isDrawerOpen
                      ? [BoxShadow(color: AppColors.c181D27.withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 20))]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: isDrawerOpen ? BorderRadius.circular(30) : BorderRadius.zero,
                  child: Scaffold(
                    backgroundColor: _DashboardColors.background,
                    body: SafeArea(
                      bottom: false,
                      child: RefreshIndicator(
                        color: _DashboardColors.textStrong,
                        onRefresh: () async => _loadAnalysis(),
                        child: BlocBuilder<TaskBloc, TaskState>(
                          builder: (context, state) {
                            return ListView(
                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                              children: [
                                _DashboardUserHeader(profileUsername: state.profileUsername),
                                const SizedBox(height: 32),
                                _DashboardAiCard(state: state, analysisTime: _analysisTime),
                                const SizedBox(height: 20),
                                _PeriodSelector(selectedPeriod: _period, onSelect: _selectPreset, onOpenCalendar: _openCalendar),
                                const SizedBox(height: 20),
                                _TaskBarChartCard(analysis: state.taskAnalysis, selectedRange: _selectedRange),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardColors {
  const _DashboardColors._();

  static const background = Color(0xFFFCFCFC);
  static const cardSoft = Color(0xFFF9F9F9);
  static const chartSoft = Color(0xFFF0F0F0);
  static const stroke = Color(0xFFE8E8E8);
  static const textStrong = Color(0xFF202020);
  static const textSub = Color(0xFFBBBBBB);
  static const avatar = Color(0xFF8A8A8A);
  static const accentBlue = Color(0xFF3F57B3);
  static const accentOrange = Color(0xFFED9121);
  static const accentPurple = Color(0xFF8A008A);
  static const calendarAccent = Color(0xFFF76B15);
  static const success = Color(0xFF1FC16B);
  static const successLight = Color(0xFFC2F5DA);
  static const rangeMiddle = Color(0xFFE0E0E0);
  static const weekend = Color(0xFFDD4C1E);
}

TextStyle _manrope({
  required double size,
  required FontWeight weight,
  required double height,
  Color color = _DashboardColors.textStrong,
  double letterSpacing = 0,
}) {
  return GoogleFonts.manrope(fontSize: size, fontWeight: weight, height: height / size, color: color, letterSpacing: letterSpacing);
}

class _DashboardUserHeader extends StatelessWidget {
  const _DashboardUserHeader({required this.profileUsername});

  final String? profileUsername;

  @override
  Widget build(BuildContext context) {
    final profileName = profileUsername?.trim();
    final displayName = (profileName == null || profileName.isEmpty) ? Words.fallbackUser.tr() : profileName;
    final initial = displayName.characters.first.toUpperCase();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage())),
      child: Row(
        key: const Key('dashboard-user-header'),
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: _DashboardColors.avatar, shape: BoxShape.circle),
            child: Text(
              initial,
              style: _manrope(size: 17, weight: FontWeight.w800, height: 28, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _manrope(size: 13, weight: FontWeight.w800, height: 20),
              ),
              Text(
                Words.employee.tr(),
                style: _manrope(size: 11, weight: FontWeight.w500, height: 16, color: _DashboardColors.textSub, letterSpacing: 0.4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardAiCard extends StatelessWidget {
  const _DashboardAiCard({required this.state, required this.analysisTime});

  final TaskState state;
  final DateTime analysisTime;

  @override
  Widget build(BuildContext context) {
    final analysis = state.taskAnalysis;
    final isLoading = state.status == TaskLoadStatus.loading;
    final analyzedCount = analysis?.allTask ?? 0;

    return Container(
      key: const Key('dashboard-ai-card'),
      height: 148,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DashboardColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DashboardColors.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 20, color: Color(0xFF3438FF)),
                    const SizedBox(width: 8),
                    Text(Words.aiAnalysis.tr(), style: _manrope(size: 13, weight: FontWeight.w800, height: 20)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  Words.autoAnalysis.tr(),
                  style: _manrope(size: 11, weight: FontWeight.w500, height: 16, color: _DashboardColors.textSub, letterSpacing: 0.4),
                ),
                const Spacer(),
                Row(
                  children: [
                    isLoading
                        ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline, color: _DashboardColors.success, size: 16),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isLoading ? Words.aiAnalyzing.tr() : Words.aiAnalysisCompleted.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _manrope(size: 13, weight: FontWeight.w800, height: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.work_outline, color: Color(0xFF959595), size: 16),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$analyzedCount ${Words.tasksAnalyzed.tr()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _manrope(size: 13, weight: FontWeight.w500, height: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: _DashboardColors.chartSoft, borderRadius: BorderRadius.circular(13)),
                  child: Text(
                    '${Words.analysisTime.tr()}: ${DateFormat('HH:mm').format(analysisTime)}',
                    style: _manrope(size: 8, weight: FontWeight.w500, height: 12, color: _DashboardColors.textSub),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _DashboardColors.cardSoft,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE1E1E1), width: .5),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 72,
                height: 20,
                decoration: BoxDecoration(color: _DashboardColors.successLight, borderRadius: BorderRadius.circular(27)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: _DashboardColors.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(Words.aiActive.tr(), style: _manrope(size: 8, weight: FontWeight.w600, height: 12, letterSpacing: 0.4)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selectedPeriod, required this.onSelect, required this.onOpenCalendar});

  final _DashboardPeriod selectedPeriod;
  final ValueChanged<_DashboardPeriod> onSelect;
  final VoidCallback onOpenCalendar;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('dashboard-period-selector'),
      children: [
        Expanded(
          child: Text(
            Words.selectPeriod.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _manrope(size: 13, weight: FontWeight.w500, height: 20),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 32,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: _DashboardColors.chartSoft, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              _PeriodButton(
                key: const Key('dashboard-period-1-day'),
                label: Words.oneDay.tr(),
                selected: selectedPeriod == _DashboardPeriod.oneDay,
                onTap: () => onSelect(_DashboardPeriod.oneDay),
              ),
              _PeriodButton(
                key: const Key('dashboard-period-1-month'),
                label: Words.oneMonth.tr(),
                selected: selectedPeriod == _DashboardPeriod.oneMonth,
                onTap: () => onSelect(_DashboardPeriod.oneMonth),
              ),
              _PeriodButton(
                key: const Key('dashboard-period-3-months'),
                label: Words.threeMonths.tr(),
                selected: selectedPeriod == _DashboardPeriod.threeMonths,
                onTap: () => onSelect(_DashboardPeriod.threeMonths),
              ),
              _PeriodButton(
                key: const Key('dashboard-period-6-months'),
                label: Words.sixMonths.tr(),
                selected: selectedPeriod == _DashboardPeriod.sixMonths,
                onTap: () => onSelect(_DashboardPeriod.sixMonths),
              ),
              InkWell(
                key: const Key('dashboard-calendar-button'),
                onTap: onOpenCalendar,
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: selectedPeriod == _DashboardPeriod.custom ? _DashboardColors.textStrong : _DashboardColors.textSub,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 24,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: selected ? _DashboardColors.background : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Text(
          label,
          style: _manrope(
            size: 11,
            weight: FontWeight.w800,
            height: 16,
            color: selected ? _DashboardColors.textStrong : _DashboardColors.textSub,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _TaskBarChartCard extends StatelessWidget {
  const _TaskBarChartCard({required this.analysis, required this.selectedRange});

  final TaskAnalysisModel? analysis;
  final DashboardDateRange selectedRange;

  @override
  Widget build(BuildContext context) {
    final items = [
      _ChartBarData(status: TaskStatus.completed, value: analysis?.doneTask ?? 0, color: _DashboardColors.accentBlue),
      _ChartBarData(status: TaskStatus.pending, value: analysis?.notDoneTask ?? 0, color: _DashboardColors.accentOrange),
      _ChartBarData(status: TaskStatus.overdue, value: analysis?.expiredTask ?? 0, color: _DashboardColors.accentPurple),
    ];
    final maxValue = items.map((item) => item.value).fold<int>(0, (max, value) => value > max ? value : max);
    final tooltipItem = items.reduce((max, item) => item.value > max.value ? item : max);

    return Container(
      key: const Key('dashboard-task-chart-card'),
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _DashboardColors.chartSoft, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              Text(Words.dashboardTasks.tr(), style: _manrope(size: 16, weight: FontWeight.w700, height: 24)),
              const Spacer(),
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _DashboardColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _DashboardColors.stroke),
                ),
                child: Row(
                  children: [
                    Text(_rangeLabel(context, selectedRange), style: _manrope(size: 13, weight: FontWeight.w500, height: 20)),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: items.map((item) {
                    return _TaskBar(
                      item: item,
                      maxValue: maxValue,
                      chartHeight: constraints.maxHeight,
                      showTooltip: identical(item, tooltipItem) && item.value > 0,
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.map((item) => _ChartLegend(label: item.label, color: item.color)).toList(),
          ),
        ],
      ),
    );
  }
}

String _rangeLabel(BuildContext context, DashboardDateRange range) {
  final from = DateUtils.dateOnly(range.dateFrom);
  final to = DateUtils.dateOnly(range.dateTo);
  final sameMonth = from.year == to.year && from.month == to.month;
  final isOneMonthPreset = from == dashboardSubtractMonths(to, 1);

  if (sameMonth || isOneMonthPreset) {
    return _monthLabel(context, to);
  }

  final fromLabel = from.year == to.year ? _monthLabel(context, from) : _monthYearLabel(context, from);
  return '$fromLabel-${_monthYearLabel(context, to, includeYear: from.year != to.year)}';
}

String _monthLabel(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final value = DateFormat.MMM(locale).format(date);
  return _capitalizeLabel(value);
}

String _monthYearLabel(BuildContext context, DateTime date, {bool includeYear = true}) {
  final month = _monthLabel(context, date);
  return includeYear ? '$month ${date.year}' : month;
}

String _capitalizeLabel(String value) {
  return value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}

class _ChartBarData {
  const _ChartBarData({required this.status, required this.value, required this.color});

  final TaskStatus status;
  final int value;
  final Color color;

  String get label => status.localizedName;
}

class _TaskBar extends StatelessWidget {
  const _TaskBar({required this.item, required this.maxValue, required this.chartHeight, required this.showTooltip});

  final _ChartBarData item;
  final int maxValue;
  final double chartHeight;
  final bool showTooltip;

  @override
  Widget build(BuildContext context) {
    final normalized = maxValue == 0 ? 0.0 : item.value / maxValue;
    final minHeight = item.value == 0 ? 0.0 : 32.0;
    final availableHeight = chartHeight - 36;
    final height = item.value == 0 ? 0.0 : (availableHeight * normalized).clamp(minHeight, availableHeight);

    return SizedBox(
      width: 72,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 56,
            height: height,
            decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(12)),
          ),
          if (showTooltip)
            Positioned(
              bottom: height + 10,
              child: Container(
                key: const Key('dashboard-chart-tooltip'),
                width: 56,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(80)),
                child: Text(
                  item.value.toString(),
                  style: _manrope(size: 15, weight: FontWeight.w500, height: 24, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _manrope(size: 13, weight: FontWeight.w500, height: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardRangeCalendar extends StatefulWidget {
  const _DashboardRangeCalendar({required this.initialRange});

  final DashboardDateRange initialRange;

  @override
  State<_DashboardRangeCalendar> createState() => _DashboardRangeCalendarState();
}

class _DashboardRangeCalendarState extends State<_DashboardRangeCalendar> {
  late List<DateTime?> _dates;

  @override
  void initState() {
    super.initState();
    _dates = [widget.initialRange.dateFrom, widget.initialRange.dateTo];
  }

  @override
  Widget build(BuildContext context) {
    final dayStyle = _manrope(size: 15, weight: FontWeight.w500, height: 24);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final calendarWidth = screenWidth.clamp(280.0, 320.0);

    return Container(
      key: const Key('dashboard-range-calendar'),
      width: calendarWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E6F2)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 3)),
          BoxShadow(color: Color(0x0A000000), blurRadius: 11, offset: Offset(0, 11)),
          BoxShadow(color: Color(0x08000000), blurRadius: 15, offset: Offset(0, 25)),
        ],
      ),
      child: CalendarDatePicker2(
        value: _dates,
        onValueChanged: (dates) {
          setState(() => _dates = dates);
          final start = dates.isNotEmpty ? dates.first : null;
          final end = dates.length > 1 ? dates[1] : null;
          if (start == null || end == null) return;

          final range = start.isBefore(end) ? DashboardDateRange(dateFrom: start, dateTo: end) : DashboardDateRange(dateFrom: end, dateTo: start);
          final navigator = Navigator.of(context);
          unawaited(
            Future<void>.delayed(const Duration(milliseconds: 120), () {
              if (mounted) navigator.pop(range);
            }),
          );
        },
        config: CalendarDatePicker2Config(
          calendarType: CalendarDatePicker2Type.range,
          rangeBidirectional: true,
          firstDayOfWeek: 1,
          dynamicCalendarRows: false,
          dayMaxWidth: 36,
          controlsHeight: 28,
          centerAlignModePicker: true,
          hideMonthPickerDividers: true,
          hideYearPickerDividers: true,
          modePickersGap: 6,
          selectedDayHighlightColor: _DashboardColors.calendarAccent,
          selectedDayTextStyle: dayStyle.copyWith(color: Colors.white),
          selectedRangeDayTextStyle: dayStyle,
          selectedRangeHighlightColor: _DashboardColors.rangeMiddle,
          dayTextStyle: dayStyle,
          todayTextStyle: dayStyle,
          weekdayLabelTextStyle: _manrope(size: 13, weight: FontWeight.w500, height: 20, color: const Color(0xFFD9D9D9)),
          weekdayLabels: const ['ВС', 'ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ'],
          lastMonthIcon: const Icon(Icons.chevron_left, size: 16),
          nextMonthIcon: const Icon(Icons.chevron_right, size: 16),
          modePickerBuilder: ({required monthDate, required viewMode, isMonthPicker}) {
            return _CalendarHeaderTitle(monthDate: monthDate, isMonthPicker: isMonthPicker == true);
          },
          dayTextStylePredicate: ({required date}) {
            if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
              return dayStyle.copyWith(color: _DashboardColors.weekend);
            }
            return null;
          },
          dayBuilder: ({required date, decoration, isDisabled, isSelected, isToday, textStyle}) {
            final style = textStyle ?? dayStyle;
            return Container(
              alignment: Alignment.center,
              decoration: isSelected == true ? BoxDecoration(color: _DashboardColors.calendarAccent, borderRadius: BorderRadius.circular(8)) : null,
              child: Text('${date.day}', style: style),
            );
          },
          selectedRangeHighlightBuilder: ({required dayToBuild, required isStartDate, required isEndDate}) {
            if (isStartDate || isEndDate) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: _DashboardColors.rangeMiddle, borderRadius: BorderRadius.circular(8)),
            );
          },
        ),
      ),
    );
  }
}

class _CalendarHeaderTitle extends StatelessWidget {
  const _CalendarHeaderTitle({required this.monthDate, required this.isMonthPicker});

  final DateTime monthDate;
  final bool isMonthPicker;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final month = DateFormat.MMMM(locale).format(monthDate);
    final monthLabel = month.isEmpty ? month : '${month[0].toUpperCase()}${month.substring(1)}';

    final text = isMonthPicker ? monthLabel : '${monthDate.year}';
    final color = isMonthPicker ? _DashboardColors.textStrong : _DashboardColors.calendarAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _manrope(size: 17, weight: FontWeight.w500, height: 28, color: color),
        ),
      ),
    );
  }
}
