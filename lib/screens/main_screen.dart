import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'dashboard_screen.dart';
import 'meal_plan_screen.dart';
import 'meal_log_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MealPlanScreen(),
    MealLogScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },

        child: Container(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),

      // FLOATING MODERN NAVIGATION BAR
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),

            child: NavigationBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,

              height: 78,

              selectedIndex: _currentIndex,

              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

              indicatorColor: provider.accentColor.withOpacity(0.15),

              animationDuration: const Duration(milliseconds: 500),

              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },

              destinations: [
                // HOME
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: Colors.grey.shade600),

                  selectedIcon: Icon(
                    Icons.home_rounded,
                    color: provider.accentColor,
                  ),

                  label: 'Home',
                ),

                // PLAN
                NavigationDestination(
                  icon: Icon(
                    Icons.restaurant_menu_outlined,
                    color: Colors.grey.shade600,
                  ),

                  selectedIcon: Icon(
                    Icons.restaurant_menu_rounded,
                    color: provider.accentColor,
                  ),

                  label: 'Plan',
                ),

                // CENTER ADD BUTTON
                NavigationDestination(
                  icon: Container(
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: provider.accentColor,
                      shape: BoxShape.circle,

                      boxShadow: [
                        BoxShadow(
                          color: provider.accentColor.withOpacity(0.35),

                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),

                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),

                  label: 'Log',
                ),

                // PROGRESS
                NavigationDestination(
                  icon: Icon(
                    Icons.trending_up_outlined,
                    color: Colors.grey.shade600,
                  ),

                  selectedIcon: Icon(
                    Icons.trending_up_rounded,
                    color: provider.accentColor,
                  ),

                  label: 'Progress',
                ),

                // SETTINGS
                NavigationDestination(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: Colors.grey.shade600,
                  ),

                  selectedIcon: Icon(
                    Icons.settings_rounded,
                    color: provider.accentColor,
                  ),

                  label: 'More',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
