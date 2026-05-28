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
    // Fire generation cleanly on initialization mount safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _generateDynamicMealPlan();
      }
    });
  }

  Future<void> _generateDynamicMealPlan() async {
    // Prevent double invocation if a routine operation is actively pending
    if (_isLoading) return;

    // Safely update state without interrupting parent frame tree layout
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      // Explicitly recalculate rules up front to capture latest configuration updates
      if (provider.matchingRule != null) {
        final NutritionRule ruleData = provider.matchingRule!;
        
        int breakfastCals = ruleData.breakfast.isNotEmpty ? ruleData.breakfast.first.calories : 450;
        int lunchCals = ruleData.lunch.isNotEmpty ? ruleData.lunch.first.calories : 650;
        int dinnerCals = ruleData.dinner.isNotEmpty ? ruleData.dinner.first.calories : 550;
        int snackCals = ruleData.snacks.isNotEmpty ? ruleData.snacks.first.calories : 200;

        _targetCalorieGoal = breakfastCals + lunchCals + dinnerCals + snackCals;
      } else {
        _targetCalorieGoal = 2000; 
      }

      // Fetch fresh catalog data from Firestore collection context
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('foods').get();
      final allFoods = snapshot.docs;

      if (allFoods.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      Map<String, Meal> temporaryPlan = {};
      final Map<String, double> mealSplits = {
        "Breakfast": 0.30,
        "Lunch": 0.35,
        "Dinner": 0.25,
        "Snack": 0.10,
      };

      // Matrix optimization loop tracking closest calorie profile delta matches
      for (var entry in mealSplits.entries) {
        String category = entry.key;
        double splitPercentage = entry.value;
        int idealTargetKcal = (_targetCalorieGoal * splitPercentage).round();

        final categoryFoods = allFoods.where((doc) {
          final cat = (doc['category'] ?? '').toString().toLowerCase();
          return cat == category.toLowerCase();
        }).toList();

        final targetPool = categoryFoods.isNotEmpty ? categoryFoods : allFoods;

        // Shuffle target item lists if user hits "Regenerate" to prevent getting the exact same top element
        final List<QueryDocumentSnapshot> mutablePool = List.from(targetPool)..shuffle();
        var bestMatchingDoc = mutablePool.first;
        num minimalCalorieDelta = double.infinity;

        for (var doc in mutablePool) {
          final foodCal = (doc['calories'] ?? 0) as num;
          num currentDelta = (foodCal - idealTargetKcal).abs();
          if (currentDelta < minimalCalorieDelta) {
            minimalCalorieDelta = currentDelta;
            bestMatchingDoc = doc;
          }
        }

        temporaryPlan[category] = Meal.fromFirestore(
          bestMatchingDoc.data() as Map<String, dynamic>,
          fallbackType: category,
        );
      }

      // Check mounted flag before committing UI changes over asynchronous contexts
      if (mounted) {
        setState(() {
          _generatedPlan = temporaryPlan;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error optimization loop failed completely: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final rule = provider.matchingRule;
    final accentColor = provider.accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text("NutriSmart", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              // Safe ternary evaluation preventing sequential multi-taps
              onPressed: _isLoading ? null : _generateDynamicMealPlan,
              icon: _isLoading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.refresh, size: 18),
              label: Text(_isLoading ? "Optimizing..." : "Regenerate"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E8234),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          )
        ],
      ),
      body: rule == null 
        ? _buildNoRuleState() 
        : _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E8234)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Meal Plan", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accentColor)),
                  Text(provider.currentDate, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 16),
                  
                  _buildTodayChip(const Color(0xFF1E8234)),
                  const SizedBox(height: 24),

                  _buildMacroSummary(),
                  const SizedBox(height: 24),

                  _buildMealDetailCard(context, "Breakfast", "7:00–9:00 AM", "🌅", provider),
                  _buildMealDetailCard(context, "Lunch", "12:00–2:00 PM", "☀️", provider),
                  _buildMealDetailCard(context, "Dinner", "6:00–8:00 PM", "🌙", provider),
                  _buildMealDetailCard(context, "Snack", "Anytime", "🍎", provider),
                ],
              ),
            ),
    );
  }

  // --- UI RENDERING COMPONENTS ---

  Widget _buildTodayChip(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text("Target Allocation: $_targetCalorieGoal kcal", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMacroSummary() {
    int totalKcal = 0;
    int totalP = 0;
    int totalC = 0;
    int totalF = 0;

    _generatedPlan.forEach((key, meal) {
      totalKcal += meal.calories;
      totalP += meal.protein;
      totalC += meal.carbs;
      totalF += meal.fat;
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Plan Metrics Matrix:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text("$totalKcal / $_targetCalorieGoal kcal", 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E8234))),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroItem("$totalKcal", "kcal", const Color(0xFF1E8234)),
              _buildMacroItem("${totalP}g", "Protein", Colors.blue),
              _buildMacroItem("${totalC}g", "Carbs", Colors.orange),
              _buildMacroItem("${totalF}g", "Fat", Colors.pink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealDetailCard(BuildContext context, String title, String time, String icon, AppProvider provider) {
    final Meal? displayMeal = _generatedPlan[title];

    if (displayMeal == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF1E8234).withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                  child: Text(icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      Text(time, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                    ],
                  ),
                ),
                Text("${displayMeal.calories}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E8234))),
                const Text(" kcal", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Divider(height: 1),
          
          _buildFoodItem(displayMeal),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () async {
                await provider.logMeal(
                  name: displayMeal.name,
                  type: title,
                  calories: displayMeal.calories,
                  protein: displayMeal.protein,
                  carbs: displayMeal.carbs,
                  fat: displayMeal.fat,
                );
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${displayMeal.name} tracked to profile history"),
                      backgroundColor: const Color(0xFF1E8234),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text("Accept & Log $title"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                foregroundColor: const Color(0xFF1E8234),
                side: const BorderSide(color: Color(0xFF1E8234)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(Meal meal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.radio_button_checked, size: 12, color: Color(0xFF1E8234)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Text("P: ${meal.protein}g  •  C: ${meal.carbs}g  •  F: ${meal.fat}g", 
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildNoRuleState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
          "No validation rules found for calculation processing. Please ensure weight and energy profiles are established.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
      ),
    );
  }
}