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
    // Optional: read provider here if you want to use provider.accentColor for your navigation seed
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _currentIndex,
        // Tint the navigation bar according to user color choices dynamically
        indicatorColor: provider.accentColor.withOpacity(0.2),
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_rounded, size: 36, color: provider.accentColor),
            label: 'Log',
          ),
          const NavigationDestination(
            icon: Icon(Icons.trending_up_rounded),
            label: 'Progress',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}