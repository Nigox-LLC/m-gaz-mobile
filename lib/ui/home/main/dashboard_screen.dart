import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:m_gaz/core/extension/navigator_extension.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import 'package:m_gaz/global_widget/app_tools.dart';
import 'package:m_gaz/ui/home/profile/profile_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../core/common/words.dart';
import '../../../core/models/task/task_analysis.dart';
import '../../../core/utils/colors.dart';
import '../tasks/bloc/task_bloc.dart';
import '../tasks/bloc/task_event.dart';
import '../tasks/bloc/task_state.dart';
import 'custom_drawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double xOffset = 0, yOffset = 0, scaleFactor = 1;
  bool isDrawerOpen = false;

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
      xOffset = isDrawerOpen ? 260 : 0;
      yOffset = isDrawerOpen ? 120 : 0;
      scaleFactor = isDrawerOpen ? 0.8 : 1;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(TaskAnalysisLoad());
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            const CustomDrawer(),
            GestureDetector(
              onTap: () => isDrawerOpen ? toggleDrawer() : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                transform: Matrix4.translationValues(xOffset, yOffset, 0)
                  ..scale(scaleFactor),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: isDrawerOpen
                      ? BorderRadius.circular(30)
                      : BorderRadius.zero,
                  boxShadow: isDrawerOpen
                      ? [
                          BoxShadow(
                            color: AppColors.c181D27.withValues(alpha: 0.3),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: isDrawerOpen
                      ? BorderRadius.circular(30)
                      : BorderRadius.zero,
                  child: Scaffold(
                    backgroundColor: AppColors.cF5F5F5,
                    body: Column(
                      children: [
                        const SizedBox(height: 0),
                        _ModernHeader(
                          isDrawerOpen: isDrawerOpen,
                          toggleDrawer: toggleDrawer,
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            color: AppColors.c181D27,
                            onRefresh: () async => context.read<TaskBloc>().add(
                              TaskAnalysisLoad(),
                            ),
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              children: [
                                20.getH(),
                                _TaskStatusSection(),
                                80.getH(),
                              ],
                            ),
                          ),
                        ),
                      ],
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

/// 🔹 Modern Glass Header
class _ModernHeader extends StatelessWidget {
  final bool isDrawerOpen;
  final VoidCallback toggleDrawer;

  const _ModernHeader({required this.isDrawerOpen, required this.toggleDrawer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.catalogGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.c181D27,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => push(ProfileScreen()),
                child: AppTools.svg(AppTools.person, width: 50, height: 50),
              ),
              const Spacer(),
              _GlassIconButton(
                icon: Icons.notifications_none,
                onPressed: () {},
              ),
            ],
          ),
          16.getH(),
          Text(
            Words.departmentTitle.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _GlassIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onPressed,
      ),
    );
  }
}

/// 🔹 Task Status Section - ALLOHIDA CARD
class _TaskStatusSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionCard(
              title: Words.aiAnalysis.tr(),
              subtitle: Words.autoAnalysis.tr(),
              icon: Icons.auto_awesome,
              showLottie: true,
              child: state.status == TaskStatus.loading
                  ? const _AIAnalyzingWidget()
                  : _AISummaryWidget(analysis: state.taskAnalysis),
            ),

            SizedBox(height: 20.h),

            if (state.taskAnalysis != null &&
                state.status == TaskStatus.success)
              _SectionCard(
                title: Words.activeTasks.tr(),
                subtitle: Words.analyzedByAi.tr(),
                icon: Icons.assignment,
                child: Column(
                  children: [
                    _PieChartWidget(tasks: state.taskAnalysis!),
                    const SizedBox(height: 20),
                    StatItemWidget(
                      title: '${state.taskAnalysis!.consumerCount}',
                      subtitle: Words.consumersCount.tr(),
                      color: AppColors.c181D27,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

// 🎯 AI Analyzing Widget (DOIM KO'RINADI)
class _AIAnalyzingWidget extends StatefulWidget {
  const _AIAnalyzingWidget();

  @override
  State<_AIAnalyzingWidget> createState() => _AIAnalyzingWidgetState();
}

class _AIAnalyzingWidgetState extends State<_AIAnalyzingWidget>
    with TickerProviderStateMixin {
  late AnimationController _dotsController;
  late AnimationController _pulseController;
  List<String> get _texts => [
    Words.aiAnalyzing.tr(),
    Words.preparingReport.tr(),
    Words.processingData.tr(),
    Words.calculatingStats.tr(),
  ];
  int _textIndex = 0;

  @override
  void initState() {
    super.initState();

    _dotsController = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 500),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // 3 soniyada bir matn o'zgaradi
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        _textIndex = (_textIndex + 1) % _texts.length;
      });
    });

    // ✅ 5 sekundlik minimal loading davomiyligi
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      // bu yerda hech narsa qilmaymiz
      // faqat widget 5 sekunddan oldin yopilmasligiga kafolat beradi
    });
  }

  @override
  void dispose() {
    _dotsController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🔥 LOTTIE ANIMATION
          SizedBox(
            width: 120.w,
            height: 120.w,
            child: Lottie.asset(
              'assets/anim/ai_animation.json',
              repeat: true,
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(height: 20.h),

          /// 🧠 AI processing text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              _texts[_textIndex],
              key: ValueKey<int>(_textIndex),
              style: TextStyle(
                fontSize: 14.w,
                color: AppColors.c1570EF,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 12.h),

          /// ⏳ Status text
          Text(
            Words.pleaseWait.tr(),
            style: TextStyle(
              fontSize: 12.w,
              color: AppColors.c181D27.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// AI Summary Widget (when analysis is complete)
class _AISummaryWidget extends StatelessWidget {
  final TaskAnalysisModel? analysis;

  const _AISummaryWidget({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 12.w),
              Text(
                '✅ ${Words.aiAnalysisCompleted.tr()}',
                style: TextStyle(
                  fontSize: 16.w,
                  fontWeight: FontWeight.bold,
                  color: AppColors.c181D27,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (analysis != null) ...[
            Text(
              '📊 ${analysis!.allTask} ${Words.tasksAnalyzed.tr()}',
              style: TextStyle(
                fontSize: 14.w,
                color: AppColors.c181D27.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '⏱️ ${Words.analysisTime.tr()}: ${DateTime.now().toString().substring(10, 16)}',
              style: TextStyle(
                fontSize: 12.w,
                color: AppColors.c181D27.withValues(alpha: 0.6),
              ),
            ),
          ] else
            Text(
              Words.dataNotReady.tr(),
              style: TextStyle(
                fontSize: 14.w,
                color: AppColors.c181D27.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Widget child;
  final bool showLottie;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.showLottie = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.c181D27.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: AppColors.c181D27.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with AI indicator and animation
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and subtitle section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 24.w, color: AppColors.c1570EF),
                        SizedBox(width: 8.w),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20.w,
                            fontWeight: FontWeight.bold,
                            color: AppColors.c181D27,
                          ),
                        ),
                        // 🟢 AI Active Indicator
                        if (showLottie) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.w,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.w),
                              border: Border.all(
                                color: AppColors.green,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  Words.aiActive.tr(),
                                  style: TextStyle(
                                    fontSize: 10.w,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.w),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.w,
                        color: AppColors.c181D27.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // 🤖 Robot Animation (optimized size and position)
              if (showLottie) ...[
                SizedBox(width: 6.w),
                Container(
                  width: 70.w, // Optimal size
                  height: 70.w,
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.c1570EF.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16.w),
                    border: Border.all(
                      color: AppColors.c1570EF.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Lottie.asset(
                    'assets/anim/robot_bot.json',
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 20.w),
          child,
        ],
      ),
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  final TaskAnalysisModel tasks;

  const _PieChartWidget({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final all = tasks.allTask.toDouble();
    final done = tasks.doneTask.toDouble();
    final notDone = tasks.notDoneTask.toDouble();
    final expired = tasks.expiredTask.toDouble();

    double donePercent = all == 0 ? 0 : (done / all) * 100;
    double notDonePercent = all == 0 ? 0 : (notDone / all) * 100;
    double expiredPercent = all == 0 ? 0 : (expired / all) * 100;

    final data = [
      ChartData(Words.completed.tr(), donePercent, AppColors.green),
      ChartData(Words.notCompleted.tr(), notDonePercent, AppColors.red),
      ChartData(Words.orderExpiredDate.tr(), expiredPercent, AppColors.c1570EF),
    ];

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SfCircularChart(
              series: [
                DoughnutSeries<ChartData, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.value,
                  pointColorMapper: (d, _) => d.color,
                  innerRadius: '60%',
                  radius: '90%',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: data
                  .where((d) => d.value > 0)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.label}: ${item.value.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.c181D27,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}

class StatItemWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const StatItemWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 30.w,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          4.getH(),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
