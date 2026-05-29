import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/app_provider.dart';
import '../data/models/meal.dart';
import '../data/models/nutrition_rules.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  bool _isLoading = false;

  Map<String, Meal> _generatedPlan = {};

  int _targetCalorieGoal = 2000;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _generateDynamicMealPlan();
      }
    });
  }

  Future<void> _generateDynamicMealPlan() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);

      int breakfastTarget = 450;
      int lunchTarget = 650;
      int dinnerTarget = 550;
      int snackTarget = 200;

      if (provider.matchingRule != null) {
        final NutritionRule rule = provider.matchingRule!;

        if (rule.breakfast.isNotEmpty) {
          breakfastTarget = rule.breakfast.first.calories;
        }

        if (rule.lunch.isNotEmpty) {
          lunchTarget = rule.lunch.first.calories;
        }

        if (rule.dinner.isNotEmpty) {
          dinnerTarget = rule.dinner.first.calories;
        }

        if (rule.snacks.isNotEmpty) {
          snackTarget = rule.snacks.first.calories;
        }
      }

      _targetCalorieGoal = provider.dailyCaloriesGoal;

      final snapshot = await FirebaseFirestore.instance
          .collection('foods')
          .get();

      final allFoods = snapshot.docs;

      if (allFoods.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Map<String, Meal> tempPlan = {};

      final Map<String, int> targets = {
        "Breakfast": breakfastTarget,
        "Lunch": lunchTarget,
        "Dinner": dinnerTarget,
        "Snack": snackTarget,
      };

      for (var entry in targets.entries) {
        final category = entry.key;
        final targetCalories = entry.value;

        final categoryFoods = allFoods.where((doc) {
          final cat = (doc['category'] ?? '').toString().toLowerCase();

          return cat.contains(category.toLowerCase());
        }).toList();

        final pool = categoryFoods.isNotEmpty ? categoryFoods : allFoods;

        List<QueryDocumentSnapshot> acceptable = pool.where((doc) {
          final cal = (doc['calories'] ?? 0) as num;

          return (cal - targetCalories).abs() <= 100;
        }).toList();

        QueryDocumentSnapshot selected;

        if (acceptable.isNotEmpty) {
          acceptable.shuffle();
          selected = acceptable.first;
        } else {
          pool.sort((a, b) {
            final calA = (a['calories'] ?? 0) as num;

            final calB = (b['calories'] ?? 0) as num;

            return (calA - targetCalories).abs().compareTo(
              (calB - targetCalories).abs(),
            );
          });

          selected = pool.first;
        }

        tempPlan[category] = Meal.fromFirestore(
          selected.data() as Map<String, dynamic>,
          fallbackType: category,
        );
      }

      if (mounted) {
        setState(() {
          _generatedPlan = tempPlan;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    final accentColor = provider.accentColor;

    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    _generatedPlan.forEach((key, meal) {
      totalCalories += meal.calories;
      totalProtein += meal.protein;
      totalCarbs += meal.carbs;
      totalFat += meal.fat;
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        title: const Text(
          "Meal Planner",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF2D2520),
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),

            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateDynamicMealPlan,

              icon: _isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),

              label: Text(_isLoading ? "Loading..." : "Regenerate"),

              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // HEADER CARD
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withOpacity(0.85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      borderRadius: BorderRadius.circular(24),

                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          provider.currentDate,

                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Your Personalized Plan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            _buildMacroColumn("$totalCalories", "Calories"),

                            _buildMacroColumn("${totalProtein}g", "Protein"),

                            _buildMacroColumn("${totalCarbs}g", "Carbs"),

                            _buildMacroColumn("${totalFat}g", "Fat"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TARGET CARD
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),

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
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.12),

                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: Icon(Icons.flag_rounded, color: accentColor),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                "Daily Goal",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "$_targetCalorieGoal kcal target for today",

                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // MEALS
                  _buildMealCard(
                    context,
                    "Breakfast",
                    "🌅",
                    "7:00 - 9:00 AM",
                    accentColor,
                    provider,
                  ),

                  _buildMealCard(
                    context,
                    "Lunch",
                    "☀️",
                    "12:00 - 2:00 PM",
                    accentColor,
                    provider,
                  ),

                  _buildMealCard(
                    context,
                    "Dinner",
                    "🌙",
                    "6:00 - 8:00 PM",
                    accentColor,
                    provider,
                  ),

                  _buildMealCard(
                    context,
                    "Snack",
                    "🍎",
                    "Anytime",
                    accentColor,
                    provider,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildMealCard(
    BuildContext context,
    String title,
    String emoji,
    String time,
    Color accentColor,
    AppProvider provider,
  ) {
    final meal = _generatedPlan[title];

    if (meal == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),

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
          Padding(
            padding: const EdgeInsets.all(16),

            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        time,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),

                Text(
                  "${meal.calories} kcal",

                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16),

            child: Row(
              children: [
                Container(
                  width: 65,
                  height: 65,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.fastfood,
                    size: 30,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        meal.name,

                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildNutrientChip("P ${meal.protein}g", Colors.red),

                          _buildNutrientChip("C ${meal.carbs}g", Colors.orange),

                          _buildNutrientChip("F ${meal.fat}g", Colors.amber),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

            child: SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () async {
                  await provider.logMeal(
                    name: meal.name,
                    type: title,
                    calories: meal.calories,
                    protein: meal.protein,
                    carbs: meal.carbs,
                    fat: meal.fat,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${meal.name} added successfully"),
                        backgroundColor: accentColor,
                      ),
                    );
                  }
                },

                icon: const Icon(Icons.add_rounded, size: 18),

                label: Text("Log $title"),

                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,

                  foregroundColor: Colors.white,

                  elevation: 0,

                  padding: const EdgeInsets.symmetric(vertical: 14),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        label,

        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMacroColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,

          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildNoRuleState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 60,
              color: Colors.grey[400],
            ),

            const SizedBox(height: 18),

            const Text(
              "No Nutrition Rules Found",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 10),

            Text(
              "Please complete your profile setup to generate a personalized meal plan.",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
