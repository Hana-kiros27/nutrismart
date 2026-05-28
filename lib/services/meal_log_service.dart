class MealLogService {

  static List<Map<String, dynamic>> logs = [];

  static void addLog(Map<String, dynamic> meal) {
    logs.add(meal);
  }

}