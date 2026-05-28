import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../data/models/nutrition_rules_data.dart'; 
import '../data/models/nutrition_rules.dart';
import '../data/models/meal.dart';

class AppProvider extends ChangeNotifier {
  // --- AUTH & INITIALIZATION INDICATORS ---
  bool isLoggedIn = false;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // --- UI PREFERENCES ---
  Color accentColor = const Color(0xFF1E8234);
  bool isDarkMode = false;
  bool isAdmin = false;

  // --- USER PROFILE FIELDS ---
  String userName = "User";
  String userAvatar = "U";
  String email = "";
  String gender = "Male";
  int age = 22;
  double height = 170.0;
  double weight = 65.0;
  String activityLevel = "Moderate";
  String goal = "weight_loss";

  // --- DAILY TRACKING (MACROS) ---
  int dailyCaloriesGoal = 2000;
  int consumedCalories = 0;
  int consumedProtein = 0;
  int consumedCarbs = 0;
  int consumedFat = 0;

  // --- MEAL LOG DATA ---
  List<Map<String, dynamic>> todayMeals = [];
  Map<String, Meal> generatedPlan = {};

  // --- DIETARY FILTERS & ALLERGIES ---
  bool isVegetarian = false;
  bool isVegan = false;
  bool isGlutenFree = false;
  bool isDairyFree = false;
  bool isNutFree = false;
  bool isLowCarb = false;
  List<String> allergies = [];

  // --- PROGRESS TRACKING TARGETS ---
  double currentWeight = 65.0;
  double targetWeight = 60.0;
  List<WeightEntry> weightHistory = [];
  int totalMealsLogged = 0;
  int streakDays = 0;

  String get firestoreDateKey {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
  
  // --- METRIC RULE SEGMENT MATCHING PARSER ---

  NutritionRule? get matchingRule {
    try {
      final normalizedGoal = goal.toLowerCase().split('_')[0];
      return rules.firstWhere((rule) =>
        rule.gender.toLowerCase() == gender.toLowerCase() &&
        age >= rule.minAge && age <= rule.maxAge &&
        rule.goal.toLowerCase().contains(normalizedGoal) &&
        rule.activityLevel.toLowerCase() == activityLevel.toLowerCase()
      );
    } catch (e) {
      debugPrint("⚠️ No exact nutrition rule match found, processing fallback.");
      try {
        return rules.firstWhere((r) => r.gender.toLowerCase() == gender.toLowerCase());
      } catch (_) {
        return rules.isNotEmpty ? rules.first : null;
      }
    }
  }

  List<Meal> get recommendedBreakfast => matchingRule?.breakfast ?? [];
  List<Meal> get recommendedLunch => matchingRule?.lunch ?? [];
  List<Meal> get recommendedDinner => matchingRule?.dinner ?? [];
  List<Meal> get recommendedSnacks => matchingRule?.snacks ?? [];

  // --- STORAGE SYNCHRONIZATION FROM FIRESTORE ---

  /// Reads account documents and health parameters from Firestore
  Future<void> loadUserDataAndProfiles(String uid) async {
    try {
      // 1. Fetch user account data
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data() as Map<String, dynamic>;
        userName = userData['fullName'] ?? "User";
        email = userData['email'] ?? "";
        userAvatar = userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : "U";
      }

      // 2. Fetch specific physical baseline profile parameters
      DocumentSnapshot profileDoc = await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(uid)
          .get();

      if (profileDoc.exists && profileDoc.data() != null) {
        final pData = profileDoc.data() as Map<String, dynamic>;
        
        gender = pData['gender'] ?? "Male";
        age = pData['age'] ?? 22;
        height = (pData['height'] as num?)?.toDouble() ?? 170.0;
        weight = (pData['weight'] as num?)?.toDouble() ?? 65.0;
        currentWeight = (pData['current_weight'] as num?)?.toDouble() ?? weight;
        targetWeight = (pData['target_weight'] as num?)?.toDouble() ?? 60.0;
        activityLevel = pData['activity_level'] ?? "Moderate";
        goal = pData['goal'] ?? "weight_loss";

        // Macro counters tracking allocations
        consumedCalories = pData['consumedCalories'] ?? 0;
        consumedProtein = pData['consumedProtein'] ?? 0;
        consumedCarbs = pData['consumedCarbs'] ?? 0;
        consumedFat = pData['consumedFat'] ?? 0;
        totalMealsLogged = pData['totalMealsLogged'] ?? 0;
        streakDays = pData['streakDays'] ?? 0;

        // Dietary profiles
        isVegetarian = pData['isVegetarian'] ?? false;
        isVegan = pData['isVegan'] ?? false;
        isGlutenFree = pData['isGlutenFree'] ?? false;
        isDairyFree = pData['isDairyFree'] ?? false;
        isNutFree = pData['isNutFree'] ?? false;
        isLowCarb = pData['isLowCarb'] ?? false;
        allergies = List<String>.from(pData['allergies'] ?? []);

        // Safely extract meal arrays
        if (pData['todayMeals'] != null) {
          todayMeals = (pData['todayMeals'] as List)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        } else {
          todayMeals = [];
        }

        // Validate if logs belong to a previous calendar day
        String lastSavedDate = pData['lastSavedDate'] ?? "";
        if (lastSavedDate.isNotEmpty && lastSavedDate != firestoreDateKey) {
          await checkAndResetDailyCounters(uid);
        }
      }

      dailyCaloriesGoal = calculateDailyCalories();
      isLoggedIn = true;
      _isInitialized = true;
      
      notifyListeners();
      debugPrint("🔥 AppProvider memory initialization completed safely for UID: $uid");
    } catch (e) {
      debugPrint("❌ Database read extraction failure: $e");
      rethrow;
    }
  }

  /// Automatically clears active tracking pools when passing past midnight lines
  Future<void> checkAndResetDailyCounters(String uid) async {
    todayMeals.clear();
    consumedCalories = 0;
    consumedProtein = 0;
    consumedCarbs = 0;
    consumedFat = 0;

    await FirebaseFirestore.instance.collection('user_profiles').doc(uid).update({
      'consumedCalories': 0,
      'consumedProtein': 0,
      'consumedCarbs': 0,
      'consumedFat': 0,
      'todayMeals': [],
      'lastSavedDate': firestoreDateKey,
    });
    debugPrint("🔄 Calendar date change detected. Micro tracking pools rolled over into zero baseline values.");
  }

  // --- AUTHENTICATION STATE WRITERS ---

  String capitalizeEmailName(String email) {
    if (email.trim().isEmpty) return "User";
    String namePart = email.trim().split('@')[0];
    if (namePart.isEmpty) return "User";
    return namePart[0].toUpperCase() + namePart.substring(1);
  }

  Future<void> login(String emailAddress, String name) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await loadUserDataAndProfiles(currentUser.uid);
    } else {
      email = emailAddress;
      userName = name.trim().isEmpty ? capitalizeEmailName(email) : name.trim();
      userAvatar = userName.isNotEmpty ? userName[0].toUpperCase() : "U";
      isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    isLoggedIn = false;
    _isInitialized = false;
    userName = "User";
    userAvatar = "U";
    email = "";
    todayMeals.clear();
    notifyListeners();
  }

  // --- CORE TRANSACTIONAL LOGGING WRITERS ---

  Future<void> logMeal({
    required String name,
    required String type,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    final now = DateTime.now();
    final String timeStampString = 
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final newMeal = {
      'id': now.millisecondsSinceEpoch.toString(),
      'name': name,
      'type': type,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'time': timeStampString
    };

    // Update internal memory states immediately for fast UI feedback
    todayMeals.add(newMeal);
    consumedCalories += calories;
    consumedProtein += protein;
    consumedCarbs += carbs;
    consumedFat += fat;
    totalMealsLogged++;

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDocRef = FirebaseFirestore.instance.collection('user_profiles').doc(currentUser.uid);

      // Sync data changes directly to primary account reference maps
      await userDocRef.update({
        'consumedCalories': consumedCalories,
        'consumedProtein': consumedProtein,
        'consumedCarbs': consumedCarbs,
        'consumedFat': consumedFat,
        'totalMealsLogged': totalMealsLogged,
        'todayMeals': todayMeals,
        'lastSavedDate': firestoreDateKey,
      });

      // Commit a mirrored historical log node down structural timelines
      await userDocRef.collection('meal_history').doc(firestoreDateKey).set({
        'date': firestoreDateKey,
        'totalCalories': consumedCalories,
        'totalProtein': consumedProtein,  // Aggregation baseline
        'totalCarbs': consumedCarbs,      // Aggregation baseline
        'totalFat': consumedFat,          // Aggregation baseline
        'meals': todayMeals,
      }, SetOptions(merge: true));
    }
    
    notifyListeners();
  }

  Future<void> updateUserInfo({
    String? name, String? gender, int? age, 
    double? height, double? weight, String? goal, String? activityLevel, double? currentWeight, double? targetWeight
  }) async {
    if (name != null && name.trim().isNotEmpty) { 
      userName = name.trim(); 
      userAvatar = userName.isNotEmpty ? userName[0].toUpperCase() : "U";
    }
    if (gender != null) this.gender = gender;
    if (age != null) this.age = age;
    if (height != null) this.height = height;
    if (weight != null) {
      this.weight = weight;
      currentWeight = weight;
    }
    if (goal != null) this.goal = goal;
    if (activityLevel != null) this.activityLevel = activityLevel;
    if (currentWeight != null) this.currentWeight = currentWeight;
    if (targetWeight != null) this.targetWeight = targetWeight;

    dailyCaloriesGoal = calculateDailyCalories();

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if (name != null) {
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
          'fullName': userName,
        });
      }
      
      await FirebaseFirestore.instance.collection('user_profiles').doc(currentUser.uid).update({
        'gender': this.gender,
        'age': this.age,
        'height': this.height,
        'weight': this.weight,
        'current_weight': currentWeight,
        'goal': this.goal,
        'activity_level': this.activityLevel,
      });
    }

    notifyListeners();
  }
  /// Records a new current weight update without shifting the starting baseline anchor
  Future<void> logCurrentWeightCheckIn(double newWeight) async {
    currentWeight = newWeight;
    
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(currentUser.uid)
          .update({
        'current_weight': currentWeight, // Modifies ONLY the active tracker pointer
      });
    }
    
    notifyListeners();
    debugPrint("📉 Weight check-in updated in Firestore: $currentWeight kg");
  }
  Future<void> updateDietarySettings({
    bool? vegetarian, bool? vegan, bool? glutenFree,
    bool? dairyFree, bool? nutFree, bool? lowCarb
  }) async {
    if (vegetarian != null) isVegetarian = vegetarian;
    if (vegan != null) isVegan = vegan;
    if (glutenFree != null) isGlutenFree = glutenFree;
    if (dairyFree != null) isDairyFree = dairyFree;
    if (nutFree != null) isNutFree = nutFree;
    if (lowCarb != null) isLowCarb = lowCarb;
    
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('user_profiles').doc(currentUser.uid).update({
        'isVegetarian': isVegetarian,
        'isVegan': isVegan,
        'isGlutenFree': isGlutenFree,
        'isDairyFree': isDairyFree,
        'isNutFree': isNutFree,
        'isLowCarb': isLowCarb,
      });
    }
    notifyListeners();
  }

  Future<void> addAllergy(String allergy) async {
    if (!allergies.contains(allergy)) {
      allergies.add(allergy);
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('user_profiles').doc(currentUser.uid).update({
          'allergies': allergies,
        });
      }
      notifyListeners();
    }
  }

  Future<void> removeAllergy(String allergy) async {
    if (allergies.contains(allergy)) {
      allergies.remove(allergy);
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('user_profiles').doc(currentUser.uid).update({
          'allergies': allergies,
        });
      }
      notifyListeners();
    }
  }

  Future<void> updateProgressGoals({double? newTargetWeight, int? newStreakDays}) async {
    if (newTargetWeight != null) targetWeight = newTargetWeight;
    if (newStreakDays != null) streakDays = newStreakDays;
    
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('user_profiles').doc(currentUser.uid).update({
        'target_weight': targetWeight,
        'streakDays': streakDays,
      });
    }
    notifyListeners();
  }

  Future<void> resetToday() async {
    todayMeals.clear();
    consumedCalories = 0;
    consumedProtein = 0;
    consumedCarbs = 0;
    consumedFat = 0;

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('user_profiles').doc(currentUser.uid).update({
        'consumedCalories': 0,
        'consumedProtein': 0,
        'consumedCarbs': 0,
        'consumedFat': 0,
        'todayMeals': [],
      });
    }
    notifyListeners();
  }

  // --- HEALTH & NUTRITION EQUATIONS ---

  int calculateDailyCalories() {
    double bmr;
    // Mifflin-St Jeor Equation
    if (gender == "Male") {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    double multiplier = 1.55; 
    final normActivity = activityLevel.toLowerCase();
    if (normActivity == "low" || normActivity == "sedentary") {
      multiplier = 1.2;
    } else if (normActivity == "moderate" || normActivity == "light") {
      multiplier = 1.55;
    } else if (normActivity == "high" || normActivity == "active" || normActivity == "very active") {
      multiplier = 1.9;
    }

    double maintenanceCalories = bmr * multiplier;

    // Apply caloric offset buffers based on user goals
    if (goal.toLowerCase().contains("loss")) {
      return (maintenanceCalories - 450).round().clamp(1200, 5000); 
    } else if (goal.toLowerCase().contains("gain")) {
      return (maintenanceCalories + 400).round();
    }
    
    return maintenanceCalories.round();
  }

  // --- ADD THESE DYNAMIC MACRO TARGET GETTERS ---

  /// Calculates target protein goal in grams (30% of daily caloric intake)
  int get dailyProteinGoal {
    return ((dailyCaloriesGoal * 0.30) / 4).round();
  }

  /// Calculates target carbohydrate goal in grams (40% of daily caloric intake)
  int get dailyCarbsGoal {
    return ((dailyCaloriesGoal * 0.40) / 4).round();
  }

  /// Calculates target fat goal in grams (30% of daily caloric intake)
  int get dailyFatGoal {
    return ((dailyCaloriesGoal * 0.30) / 9).round();
  }
  
  void generateRandomPlan() {
    final rule = matchingRule;
    if (rule == null || rule.breakfast.isEmpty || rule.lunch.isEmpty || rule.dinner.isEmpty) return;

    final random = Random();
    generatedPlan = {
      "Breakfast": rule.breakfast[random.nextInt(rule.breakfast.length)],
      "Lunch": rule.lunch[random.nextInt(rule.lunch.length)],
      "Dinner": rule.dinner[random.nextInt(rule.dinner.length)],
      "Snack": rule.snacks.isNotEmpty ? rule.snacks[random.nextInt(rule.snacks.length)] : rule.dinner[0],
    };
    notifyListeners();
  }

  double getWeightProgress() {
    double initial = weight;
    double current = currentWeight;
    double target = targetWeight;
    double totalDistance = (initial - target).abs();
    double remainingDistance = (current - target).abs();
    if (totalDistance == 0) return 1.0;
    return (1.0 - (remainingDistance / totalDistance)).clamp(0.0, 1.0);
  }

  int getCalorieRemaining() => (dailyCaloriesGoal - consumedCalories).clamp(0, dailyCaloriesGoal);

  double getMacroPercentage(int value, int total) => total == 0 ? 0 : (value / total * 100).clamp(0, 100);

  String get currentDate {
    DateTime now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  void changeAccentColor(Color color) {
    accentColor = color;
    notifyListeners();
  }

  void toggleAdminMode() {
    isAdmin = !isAdmin;
    notifyListeners();
  }

  // --- 📊 ANALYTICS WEEKLY METHOD REPORT (MOVED INSIDE THE CLASS BODY) ---

  /// Fetches summarized macro totals for the last 7 days for chart rendering
  Future<List<Map<String, dynamic>>> fetchWeeklyNutrientReport() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    List<Map<String, dynamic>> weeklyData = [];
    final now = DateTime.now();

    try {
      // Generate date keys for the last 7 days chronologically (oldest to today)
      List<String> last7DaysKeys = List.generate(7, (index) {
        final day = now.subtract(Duration(days: 6 - index));
        return "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
      });

      // Fetch all 7 documents from the sub-collection in parallel
      final futures = last7DaysKeys.map((dateKey) {
        return FirebaseFirestore.instance
            .collection('user_profiles')
            .doc(currentUser.uid)
            .collection('meal_history')
            .doc(dateKey)
            .get();
      }).toList();

      final snapshots = await Future.wait(futures);

      for (int i = 0; i < snapshots.length; i++) {
        final doc = snapshots[i];
        final dateKey = last7DaysKeys[i];
        final dayLabel = _getDayLabel(dateKey);

        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          
          weeklyData.add({
            'day': dayLabel,
            'calories': data['totalCalories'] ?? 0,
            'protein': data['totalProtein'] ?? 0,
            'carbs': data['totalCarbs'] ?? 0,
            'fat': data['totalFat'] ?? 0,
          });
        } else {
          // If no data exists for that day yet, return a clean empty baseline
          weeklyData.add({
            'day': dayLabel, 'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0,
          });
        }
      }
      return weeklyData;
    } catch (e) {
      debugPrint("❌ Error compiling weekly nutrient analytics: $e");
      return [];
    }
  }

  /// Converts a YYYY-MM-DD string into a clean day abbreviation (e.g., "Mon")
  String _getDayLabel(String dateKey) {
    try {
      final parsedDate = DateTime.parse(dateKey);
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[parsedDate.weekday - 1];
    } catch (_) {
      return "--";
    }
  }
} // <--- AppProvider class cleanly ends here now!

// --- POJO TRANSLATION DATA CLASSES ---

class WeightEntry {
  final DateTime date;
  final double weight;
  WeightEntry({required this.date, required this.weight});

  Map<String, dynamic> toJson() => {'date': date.toIso8601String(), 'weight': weight};
  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
    date: DateTime.parse(json['date']),
    weight: (json['weight'] as num).toDouble(),
  );
}