import '../data/models/profile.dart';
import '../data/models/nutrition_rules_data.dart';
import '../data/models/meal.dart';
import 'dart:math';

class RecommendationService {

  static Map<String, Meal>? getMeal(Profile profile) {

    for (var rule in rules) {

      if (profile.gender == rule.gender &&
          profile.age >= rule.minAge &&
          profile.age <= rule.maxAge &&
          profile.weight >= rule.minWeight &&
          profile.weight <= rule.maxWeight &&
          profile.height >= rule.minHeight &&
          profile.height <= rule.maxHeight &&
          profile.activityLevel == rule.activityLevel &&
          profile.goal == rule.goal) {

        final rand = Random();

        return {
          "breakfast": rule.breakfast[rand.nextInt(rule.breakfast.length)],
          "lunch": rule.lunch[rand.nextInt(rule.lunch.length)],
          "dinner": rule.dinner[rand.nextInt(rule.dinner.length)],
          "snack": rule.snacks[rand.nextInt(rule.snacks.length)],
        };
      }
    }

    return null;
  }
}