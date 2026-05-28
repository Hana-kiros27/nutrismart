import './nutrition_rules.dart';
import 'meal.dart';

final List<NutritionRule> rules = [
  NutritionRule(
    gender: "female",
    minAge: 18,
    maxAge: 20,
    minWeight: 45,
    maxWeight: 60,
    minHeight: 1.50,
    maxHeight: 1.60,
    activityLevel: "Moderate",
    goal: "weight_loss",

    breakfast: [
      Meal(name: "Oatmeal with banana", type: "Breakfast", calories: 320, protein: 10, carbs: 58, fat: 5),
      Meal(name: "Boiled eggs + toast", type: "Breakfast", calories: 280, protein: 18, carbs: 26, fat: 12),
      Meal(name: "Greek yogurt + berries", type: "Breakfast", calories: 250, protein: 15, carbs: 32, fat: 4),
    ],

    lunch: [
      Meal(name: "Grilled chicken salad", type: "Lunch", calories: 450, protein: 35, carbs: 18, fat: 26),
      Meal(name: "Brown rice + vegetables", type: "Lunch", calories: 420, protein: 12, carbs: 74, fat: 8),
      Meal(name: "Tuna sandwich", type: "Lunch", calories: 380, protein: 25, carbs: 38, fat: 14),
    ],

    dinner: [
      Meal(name: "Grilled fish + salad", type: "Dinner", calories: 400, protein: 30, carbs: 12, fat: 24),
      Meal(name: "Vegetable soup + chicken", type: "Dinner", calories: 350, protein: 28, carbs: 30, fat: 12),
      Meal(name: "Egg omelette + vegetables", type: "Dinner", calories: 300, protein: 22, carbs: 10, fat: 18),
    ],

    snacks: [
      Meal(name: "Apple", type: "Snack", calories: 80, protein: 0, carbs: 22, fat: 0),
      Meal(name: "Low-fat yogurt", type: "Snack", calories: 120, protein: 8, carbs: 16, fat: 2),
      Meal(name: "Almonds", type: "Snack", calories: 150, protein: 6, carbs: 5, fat: 13),
    ],
  ),

  NutritionRule(
    gender: "female",
    minAge: 21,
    maxAge: 30,
    minWeight: 50,
    maxWeight: 70,
    minHeight: 1.55,
    maxHeight: 1.70,
    activityLevel: "Low",
    goal: "maintenance",

    breakfast: [
      Meal(name: "Avocado toast", type: "Breakfast", calories: 350, protein: 12, carbs: 36, fat: 18),
      Meal(name: "Oatmeal + milk", type: "Breakfast", calories: 300, protein: 10, carbs: 48, fat: 7),
      Meal(name: "Egg sandwich", type: "Breakfast", calories: 330, protein: 18, carbs: 30, fat: 15),
    ],

    lunch: [
      Meal(name: "Chicken rice bowl", type: "Lunch", calories: 520, protein: 40, carbs: 58, fat: 14),
      Meal(name: "Pasta with vegetables", type: "Lunch", calories: 480, protein: 15, carbs: 76, fat: 12),
      Meal(name: "Lentil soup", type: "Lunch", calories: 400, protein: 18, carbs: 54, fat: 10),
    ],

    dinner: [
      Meal(name: "Grilled chicken + veggies", type: "Dinner", calories: 450, protein: 38, carbs: 20, fat: 22),
      Meal(name: "Fish + quinoa", type: "Dinner", calories: 430, protein: 32, carbs: 44, fat: 14),
      Meal(name: "Vegetable stir fry", type: "Dinner", calories: 380, protein: 14, carbs: 48, fat: 14),
    ],

    snacks: [
      Meal(name: "Banana", type: "Snack", calories: 100, protein: 1, carbs: 26, fat: 0),
      Meal(name: "Peanut butter toast", type: "Snack", calories: 180, protein: 6, carbs: 22, fat: 8),
      Meal(name: "Yogurt cup", type: "Snack", calories: 130, protein: 9, carbs: 18, fat: 3),
    ],
  ),

  NutritionRule(
    gender: "male",
    minAge: 18,
    maxAge: 25,
    minWeight: 60,
    maxWeight: 80,
    minHeight: 1.65,
    maxHeight: 1.85,
    activityLevel: "High",
    goal: "weight_gain",

    breakfast: [
      Meal(name: "Eggs + bread + milk", type: "Breakfast", calories: 600, protein: 30, carbs: 62, fat: 24),
      Meal(name: "Oats + peanut butter", type: "Breakfast", calories: 650, protein: 25, carbs: 75, fat: 28),
      Meal(name: "Protein smoothie", type: "Breakfast", calories: 500, protein: 35, carbs: 55, fat: 15),
    ],

    lunch: [
      Meal(name: "Beef rice bowl", type: "Lunch", calories: 750, protein: 45, carbs: 82, fat: 26),
      Meal(name: "Chicken pasta", type: "Lunch", calories: 700, protein: 40, carbs: 85, fat: 22),
      Meal(name: "Burger + potatoes", type: "Lunch", calories: 800, protein: 38, carbs: 90, fat: 32),
    ],

    dinner: [
      Meal(name: "Steak + rice", type: "Dinner", calories: 780, protein: 50, carbs: 80, fat: 28),
      Meal(name: "Chicken pasta", type: "Dinner", calories: 720, protein: 42, carbs: 85, fat: 24),
      Meal(name: "Fish + potatoes", type: "Dinner", calories: 650, protein: 40, carbs: 70, fat: 22),
    ],

    snacks: [
      Meal(name: "Protein bar", type: "Snack", calories: 250, protein: 20, carbs: 28, fat: 6),
      Meal(name: "Milk + banana", type: "Snack", calories: 300, protein: 12, carbs: 44, fat: 8),
      Meal(name: "Peanuts", type: "Snack", calories: 200, protein: 10, carbs: 6, fat: 16),
    ],
  ),
];