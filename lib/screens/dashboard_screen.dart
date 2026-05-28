import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'dart:math';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    // 🎨 DYNAMIC THEMING: Pulling the color schema directly from your global provider state
    final Color brandGreen = provider.accentColor;
    
    final List<String> dailyTips = [
      "Did you know? People with your profile often benefit from adding a mid-morning snack to boost energy!",
      "Pro tip: Staying hydrated can often reduce 'false' hunger signals between meals.",
      "Eating protein-rich breakfasts can help stabilize your blood sugar throughout the day.",
      "Consider a light walk after dinner to help with digestion and sleep quality.",
      "Consistency is key! Try to eat your meals at the same time every day."
    ];
    
    // Using remember mechanics or clean lookups to hold onto a tip during basic UI refreshes
    final String randomTip = dailyTips[Random().nextInt(dailyTips.length)];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text(
          "NutriSmart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No notifications yet')),
              );
            },
            icon: const Icon(Icons.notifications_none),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: brandGreen,
              radius: 18,
              child: Text(
                provider.userAvatar.isNotEmpty ? provider.userAvatar : "A",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Greeting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // Uses clean fallback handling logic in case name split returns empty maps
                      "Hey there, ${provider.userName.isNotEmpty ? provider.userName.split(' ').first : 'User'} 👋",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Today is ${provider.currentDate}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Calorie Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [brandGreen.withOpacity(0.9), brandGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: brandGreen.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Today's Calories",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "${provider.consumedCalories}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                " / ${provider.dailyCaloriesGoal}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Remaining: ${provider.getCalorieRemaining()} kcal",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: provider.dailyCaloriesGoal > 0 
                          ? (provider.consumedCalories / provider.dailyCaloriesGoal).clamp(0.0, 1.0) 
                          : 0.0,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Macros Breakdown
            const Text(
              "Macronutrients",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMacroCard(
                  label: "Protein",
                  value: provider.consumedProtein,
                  // 🚀 FIXED: Dynamic targets parsed directly through your biological formula engines
                  goal: provider.dailyProteinGoal,
                  color: Colors.red,
                  unit: "g",
                ),
                const SizedBox(width: 12),
                _buildMacroCard(
                  label: "Carbs",
                  value: provider.consumedCarbs,
                  goal: provider.dailyCarbsGoal,
                  color: Colors.orange,
                  unit: "g",
                ),
                const SizedBox(width: 12),
                _buildMacroCard(
                  label: "Fat",
                  value: provider.consumedFat,
                  goal: provider.dailyFatGoal,
                  color: Colors.amber,
                  unit: "g",
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Today's Meals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Meals",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${provider.todayMeals.length}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: brandGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.todayMeals.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_outlined,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No meals logged yet",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Start by adding a meal to track your nutrition",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: provider.todayMeals.map((meal) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: brandGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.fastfood_rounded,
                            color: brandGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal['name'] ?? 'Unknown Item',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${meal['calories']} kcal • ${meal['time'] ?? '--:--'}",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${meal['calories']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: brandGreen,
          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // Daily Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outlined,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      randomTip,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCard({
    required String label,
    required int value,
    required int goal,
    required Color color,
    required String unit,
  }) {
    // Check avoids potential division-by-zero crashes if target parameters haven't computed yet
    double percentage = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$value$unit",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 4,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "$goal$unit goal",
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}