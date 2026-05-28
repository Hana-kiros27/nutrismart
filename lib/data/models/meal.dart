class Meal {
  final String name;
  final String type; // Made non-nullable for cleaner category matching
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  Meal({
    required this.name,
    required this.type,
    required this.calories,
    required this.protein,
    this.carbs = 0,
    this.fat = 0,
  });

  /// Factory mapper to cleanly instantiate a Meal directly from a Firestore document snapshot.
  /// This keeps your UI logic isolated, tidy, and defensive against missing backend fields.
  factory Meal.fromFirestore(Map<String, dynamic> data, {String? fallbackType}) {
    return Meal(
      name: data['name'] ?? 'Unknown Food',
      type: data['category'] ?? fallbackType ?? 'Snack',
      calories: ((data['calories'] ?? 0) as num).toInt(),
      protein: ((data['protein'] ?? 0) as num).toInt(),
      carbs: ((data['carbs'] ?? 0) as num).toInt(),
      fat: ((data['fat'] ?? 0) as num).toInt(),
    );
  }
}