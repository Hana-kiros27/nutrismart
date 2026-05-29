import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'dart:math';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    final Color brandGreen = provider.accentColor;

    final List<String> dailyTips = [
      "Did you know? People with your profile often benefit from adding a mid-morning snack to boost energy!",
      "Pro tip: Staying hydrated can reduce false hunger signals.",
      "Eating protein-rich breakfasts can stabilize blood sugar.",
      "A short walk after dinner can improve digestion and sleep.",
      "Consistency matters more than perfection.",
    ];

    final String randomTip = dailyTips[Random().nextInt(dailyTips.length)];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ================= TOP SECTION =================
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),

                child: Column(
                  children: [
                    // TOP ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Hello 👋",

                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              provider.userName.isNotEmpty
                                  ? provider.userName.split(' ').first
                                  : "User",

                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Today: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            // NOTIFICATION
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,

                                borderRadius: BorderRadius.circular(14),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),

                                    blurRadius: 10,

                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),

                              child: IconButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No notifications yet'),
                                    ),
                                  );
                                },

                                icon: Icon(
                                  Icons.notifications_none_rounded,

                                  color: Colors.grey[700],
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // AVATAR
                            CircleAvatar(
                              radius: 22,

                              backgroundColor: brandGreen,

                              child: Text(
                                provider.userAvatar.isNotEmpty
                                    ? provider.userAvatar
                                    : "A",

                                style: const TextStyle(
                                  color: Colors.white,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ================= CALORIE CARD =================
                    Container(
                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(
                        color: brandGreen,

                        borderRadius: BorderRadius.circular(28),

                        boxShadow: [
                          BoxShadow(
                            color: brandGreen.withOpacity(0.22),

                            blurRadius: 20,

                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  const Text(
                                    "Calories",

                                    style: TextStyle(
                                      color: Colors.white70,

                                      fontSize: 13,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,

                                    children: [
                                      Text(
                                        "${provider.consumedCalories}",

                                        style: const TextStyle(
                                          color: Colors.white,

                                          fontSize: 30,

                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 6,
                                          bottom: 4,
                                        ),

                                        child: Text(
                                          "/ ${provider.dailyCaloriesGoal}",

                                          style: const TextStyle(
                                            color: Colors.white70,

                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "${provider.getCalorieRemaining()} kcal left",

                                    style: const TextStyle(
                                      color: Colors.white,

                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              Container(
                                padding: const EdgeInsets.all(14),

                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),

                                  borderRadius: BorderRadius.circular(18),
                                ),

                                child: const Icon(
                                  Icons.local_fire_department,

                                  color: Colors.white,

                                  size: 30,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),

                            child: LinearProgressIndicator(
                              value: provider.dailyCaloriesGoal > 0
                                  ? (provider.consumedCalories /
                                            provider.dailyCaloriesGoal)
                                        .clamp(0.0, 1.0)
                                  : 0.0,

                              minHeight: 8,

                              backgroundColor: Colors.white24,

                              valueColor: const AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ================= CONTENT =================
              Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ================= QUICK STATS =================
                    Row(
                      children: [
                        _buildQuickStat(
                          icon: Icons.fitness_center,
                          title: "Protein",
                          value: "${provider.consumedProtein}g",
                          color: Colors.red,
                        ),

                        const SizedBox(width: 12),

                        _buildQuickStat(
                          icon: Icons.bakery_dining,
                          title: "Carbs",
                          value: "${provider.consumedCarbs}g",
                          color: Colors.orange,
                        ),

                        const SizedBox(width: 12),

                        _buildQuickStat(
                          icon: Icons.opacity,
                          title: "Fat",
                          value: "${provider.consumedFat}g",
                          color: Colors.amber,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ================= SECTION TITLE =================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          "Today's Meals",

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),

                          decoration: BoxDecoration(
                            color: brandGreen.withOpacity(0.1),

                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: Text(
                            "${provider.todayMeals.length}",

                            style: TextStyle(
                              color: brandGreen,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ================= EMPTY STATE =================
                    if (provider.todayMeals.isEmpty)
                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.all(24),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(24),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),

                              blurRadius: 12,

                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),

                              decoration: BoxDecoration(
                                color: brandGreen.withOpacity(0.08),

                                shape: BoxShape.circle,
                              ),

                              child: Icon(
                                Icons.restaurant_menu_rounded,

                                size: 34,

                                color: brandGreen,
                              ),
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              "No meals logged yet",

                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Start tracking your meals to monitor your nutrition journey.",

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: Colors.grey[600],

                                height: 1.5,

                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    // ================= MEALS =================
                    else
                      Column(
                        children: provider.todayMeals.map((meal) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),

                            padding: const EdgeInsets.all(14),

                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius: BorderRadius.circular(20),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),

                                  blurRadius: 10,

                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),

                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),

                                  decoration: BoxDecoration(
                                    color: brandGreen.withOpacity(0.1),

                                    borderRadius: BorderRadius.circular(14),
                                  ),

                                  child: Icon(
                                    Icons.fastfood_rounded,

                                    color: brandGreen,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        meal['name'] ?? 'Meal',

                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,

                                          fontSize: 15,
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      Text(
                                        "${meal['calories']} kcal • ${meal['time'] ?? '--:--'}",

                                        style: TextStyle(
                                          color: Colors.grey[600],

                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Text(
                                  "${meal['calories']}",

                                  style: TextStyle(
                                    color: brandGreen,

                                    fontWeight: FontWeight.bold,

                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 26),

                    // ================= DAILY TIP =================
                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.08),

                            Colors.cyan.withOpacity(0.05),
                          ],
                        ),

                        borderRadius: BorderRadius.circular(22),

                        border: Border.all(
                          color: Colors.blue.withOpacity(0.12),
                        ),
                      ),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),

                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.12),

                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: Icon(
                              Icons.lightbulb,

                              color: Colors.blue[700],

                              size: 22,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  "Daily Wellness Tip",

                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  randomTip,

                                  style: TextStyle(
                                    height: 1.5,

                                    color: Colors.grey[700],

                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),

              blurRadius: 10,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: color.withOpacity(0.12),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(icon, color: color, size: 20),
            ),

            const SizedBox(height: 10),

            Text(
              value,

              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,

              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
