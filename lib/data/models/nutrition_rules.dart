import './meal.dart';
class NutritionRule {
  String gender;

  int minAge;
  int maxAge;

  double minWeight;
  double maxWeight;

  double minHeight;
  double maxHeight;

  String activityLevel;
  String goal;

  List<Meal> breakfast;
  List<Meal> lunch;
  List<Meal> dinner;
  List<Meal> snacks;

  NutritionRule({
    required this.gender,
    required this.minAge,
    required this.maxAge,
    required this.minWeight,
    required this.maxWeight,
    required this.minHeight,
    required this.maxHeight,
    required this.activityLevel,
    required this.goal,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
  });
}
