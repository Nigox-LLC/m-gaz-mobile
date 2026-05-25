import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/utils/locationService/location_service.dart';
import 'package:m_gaz/features/actions/presentation/pages/actions_screen.dart';
import 'package:m_gaz/global_widget/app_tools.dart';
import 'package:m_gaz/ui/home/main/dashboard_screen.dart';
import 'package:m_gaz/ui/home/measurement_devices/measurement_devices_screen.dart';
import 'package:m_gaz/ui/home/tasks/task_screen.dart';
import 'package:m_gaz/ui/home/working_with_consumers/consumer_relations_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialIndex});

  final int? initialIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _navHorizontalPadding = 20;
  static const double _navMaxWidth = 350;

  late int _currentIndex;

  final List<BottomNavItemModel> _navItems = [
    const BottomNavItemModel(
      title: Words.main,
      iconPath: AppTools.icNavBarMain,
      screen: DashboardPage(),
    ),
    BottomNavItemModel(
      title: Words.tasks,
      iconPath: AppTools.icNavBarTasks,
      screen: TaskListScreen(),
    ),
    const BottomNavItemModel(
      title: Words.consumer,
      iconPath: AppTools.icNavBarConsumer,
      screen: ConsumerRelationsScreen(),
    ),
    const BottomNavItemModel(
      title: Words.actions,
      iconPath: AppTools.icNavBarMovements,
      screen: ActionsScreen(),
    ),
    const BottomNavItemModel(
      title: Words.device,
      iconPath: AppTools.icNavBarDevice,
      screen: MeasurementDevicesScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = (widget.initialIndex ?? 0)
        .clamp(0, _navItems.length - 1)
        .toInt();
    _startDailyRouteTracking();
  }

  void _startDailyRouteTracking() {
    unawaited(
      DailyRouteLocationService().ensureStarted().catchError((
        Object error,
        StackTrace _,
      ) {
        debugPrint('DailyRoute ensureStarted error: $error');
        return false;
      }),
    );
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _navItems[_currentIndex].screen,
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          _navHorizontalPadding,
          0,
          _navHorizontalPadding,
          20,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _navMaxWidth),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        children: [
                          for (var index = 0; index < _navItems.length; index++)
                            Expanded(
                              child: _BottomNavItem(
                                item: _navItems[index],
                                isSelected: index == _currentIndex,
                                onTap: () => _onItemTapped(index),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  static const Color _selectedColor = Color(0xFF526ED3);
  static const Color _unselectedColor = Color(0xFF959595);

  final BottomNavItemModel item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _selectedColor : _unselectedColor;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.title.tr(),
      child: Material(
        color: isSelected ? const Color(0xFFF0F0F0) : Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppTools.svg(
                  item.iconPath,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
                const SizedBox(height: 4),
                Text(
                  item.title.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 14 / 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavItemModel {
  const BottomNavItemModel({
    required this.title,
    required this.iconPath,
    required this.screen,
  });

  final Words title;
  final String iconPath;
  final Widget screen;
}
