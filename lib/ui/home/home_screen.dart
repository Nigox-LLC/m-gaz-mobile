import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_gaz/ui/home/measurement_devices/measurement_devices_screen.dart';
import 'package:m_gaz/ui/home/profile/profile_screen.dart';
import 'dart:ui';
import 'package:m_gaz/ui/home/tasks/task_screen.dart';
import 'package:m_gaz/ui/home/working_with_consumers/consumer_relations_screen.dart';
import '../../core/common/words.dart';
import 'main/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialIndex});

  final int? initialIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  final List<BottomNavItemModel> _navItems = [
    BottomNavItemModel(
      title: Words.main,
      icon: Icons.home_rounded,
      screen: const DashboardPage(),
    ),
    BottomNavItemModel(
      title: Words.tasks,
      icon: Icons.task_outlined,
      screen: TaskListScreen(),
    ),
    BottomNavItemModel(
      title: Words.consumer,
      icon: Icons.people,
      screen: const ConsumerRelationsScreen(),
    ),
    BottomNavItemModel(
      title: Words.device,
      icon: Icons.devices,
      screen: const MeasurementDevicesScreen(),
    ),
    BottomNavItemModel(
      title: Words.profile,
      icon: Icons.person,
      screen: const ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        // Bottom navigation uchun shaffof
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      extendBody: true, // Bottom nav ni orqa fon bilan cho'zish
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _navItems[_currentIndex].screen,
      ),

      // 🎨 Glassmorphism Bottom Navigation Bar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7), // 70% shaffof
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9), // Oq chegara
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effekti
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                // BottomNav rangi shaffof
                elevation: 0,
                selectedItemColor: const Color(0xFF2563EB),
                unselectedItemColor: Colors.black54,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                items: _navItems.map((item) => _buildNavItem(item)).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(BottomNavItemModel item) {
    final isSelected = _navItems.indexOf(item) == _currentIndex;

    return BottomNavigationBarItem(
      icon: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? _scaleAnimation.value : 1.0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF2563EB).withValues(alpha: 0.15)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    item.icon,
                    size: isSelected ? 28 : 24,
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : Colors.black54,
                  ),
                ),
                if (item.badgeCount != null && item.badgeCount! > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 2,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        item.badgeCount!.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      label: item.title.tr(),
    );
  }
}

class BottomNavItemModel {
  final Words title;
  final IconData icon;
  final Widget screen;
  final int? badgeCount;

  const BottomNavItemModel({
    required this.title,
    required this.icon,
    required this.screen,
    this.badgeCount,
  });
}
