import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import 'dart:math';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Map<String, dynamic>> _cachedReportData = [];

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final accentColor = appProvider.accentColor;

    double weightProgress = appProvider.getWeightProgress();
    double remainingDistance =
        (appProvider.currentWeight - appProvider.targetWeight).abs();

    double lostWeight = (appProvider.weight - appProvider.currentWeight).abs();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(34),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Your Progress",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF222222),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Track your nutrition journey",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            Icons.insights_rounded,
                            color: accentColor,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // WEIGHT CARD
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, accentColor.withOpacity(0.82)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Weight Journey",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${(weightProgress * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildWeightInfo(
                                "Start",
                                "${appProvider.weight} kg",
                              ),
                              _buildWeightInfo(
                                "Current",
                                "${appProvider.currentWeight} kg",
                                highlight: true,
                              ),
                              _buildWeightInfo(
                                "Target",
                                "${appProvider.targetWeight} kg",
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: weightProgress,
                              minHeight: 10,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            appProvider.currentWeight <= appProvider.targetWeight &&
                                    appProvider.goal.contains('loss')
                                ? '🎉 Goal reached! Amazing work!'
                                : '🔥 ${lostWeight.toStringAsFixed(1)} kg changed • ${remainingDistance.toStringAsFixed(1)} kg left',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ================= BODY =================
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ACTIVITY STATS
                    const Text(
                      "Activity Overview",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMilestoneCard(
                            icon: Icons.local_fire_department,
                            iconColor: Colors.orange,
                            title: "Current Streak",
                            value: "${appProvider.streakDays} Days",
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildMilestoneCard(
                            icon: Icons.restaurant,
                            iconColor: Colors.blue,
                            title: "Meals Logged",
                            value: "${appProvider.totalMealsLogged}",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // WEEKLY NUTRIENT SUMMARY CHANNELS & TABLES
                    const Text(
                      "Weekly Nutrient Summary",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: appProvider.fetchWeeklyNutrientReport(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting &&
                            _cachedReportData.isEmpty) {
                          return Container(
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: accentColor,
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasData) {
                          _cachedReportData = snapshot.data!;
                        }

                        if (_cachedReportData.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Center(
                              child: Text("No weekly metrics available yet."),
                            ),
                          );
                        }

                        int maxCalorieValue = _cachedReportData
                            .map((d) => (d['calories'] as num).toInt())
                            .reduce(max);

                        if (maxCalorieValue < appProvider.dailyCaloriesGoal) {
                          maxCalorieValue = appProvider.dailyCaloriesGoal;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // GRAPH CONTAINER
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(26),
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
                                  // LEGENDS
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildLegend("Calories", accentColor),
                                      _buildLegend("Protein", Colors.red),
                                      _buildLegend("Carbs", Colors.orange),
                                      _buildLegend("Fat", Colors.amber),
                                    ],
                                  ),
                                  const SizedBox(height: 28),

                                  // GRAPH RENDERING BLOCK
                                  SizedBox(
                                    height: 180,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: _cachedReportData.map((dayData) {
                                        final int cals = (dayData['calories'] as num?)?.toInt() ?? 0;
                                        final double prot = (dayData['protein'] as num?)?.toDouble() ?? 0.0;
                                        final double carb = (dayData['carbs'] as num?)?.toDouble() ?? 0.0;
                                        final double fats = (dayData['fat'] as num?)?.toDouble() ?? 0.0;

                                        double calFactor = maxCalorieValue > 0
                                            ? (cals / maxCalorieValue)
                                            : 0.0;

                                        return Expanded(
                                          child: GestureDetector(
                                            onTap: () => _showMetricLabelDialog(
                                              context,
                                              dayData,
                                              appProvider,
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      _buildGroupedMiniBar(
                                                        calFactor,
                                                        cals > appProvider.dailyCaloriesGoal
                                                            ? Colors.redAccent
                                                            : accentColor,
                                                      ),
                                                      _buildGroupedMiniBar(
                                                        prot / 150,
                                                        Colors.red,
                                                      ),
                                                      _buildGroupedMiniBar(
                                                        carb / 300,
                                                        Colors.orange,
                                                      ),
                                                      _buildGroupedMiniBar(
                                                        fats / 100,
                                                        Colors.amber,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  dayData['day'],
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    "Tap bars to view detailed metrics",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),

                            // TABLE NUTRITION LOGS HEADER
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Nutrition Logs",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _exportNutritionDataAsCSV(
                                    context,
                                    _cachedReportData,
                                  ),
                                  icon: Icon(
                                    Icons.download_rounded,
                                    size: 18,
                                    color: accentColor,
                                  ),
                                  label: Text(
                                    "Export",
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // ACTUAL REBUILT NUTRITION PROGRESS DATA TABLE
                            Container(
                              width: double.infinity,
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
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 22,
                                  headingTextStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  columns: const [
                                    DataColumn(label: Text('Day')),
                                    DataColumn(label: Text('Calories')),
                                    DataColumn(label: Text('Protein')),
                                    DataColumn(label: Text('Carbs')),
                                    DataColumn(label: Text('Fat')),
                                  ],
                                  rows: _cachedReportData.map((dayData) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(dayData['day'])),
                                        DataCell(Text('${dayData['calories']}')),
                                        DataCell(
                                          Text(
                                            '${(dayData['protein'] as num).toStringAsFixed(0)}g',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${(dayData['carbs'] as num).toStringAsFixed(0)}g',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${(dayData['fat'] as num).toStringAsFixed(0)}g',
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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

  // ================= HELPERS =================

  Widget _buildWeightInfo(
    String title,
    String value, {
    bool highlight = false,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: highlight ? 20 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildGroupedMiniBar(double heightFactor, Color barColor) {
    return Expanded(
      child: FractionallySizedBox(
        heightFactor: heightFactor.clamp(0.04, 1.0),
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= DIALOG =================

  void _showMetricLabelDialog(
    BuildContext context,
    Map<String, dynamic> data,
    AppProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          "${data['day']} Breakdown",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogMetricRow(
              'Calories',
              '${data['calories']} kcal',
              provider.accentColor,
            ),
            _buildDialogMetricRow(
              'Protein',
              '${(data['protein'] as num).toStringAsFixed(1)} g',
              Colors.red,
            ),
            _buildDialogMetricRow(
              'Carbs',
              '${(data['carbs'] as num).toStringAsFixed(1)} g',
              Colors.orange,
            ),
            _buildDialogMetricRow(
              'Fat',
              '${(data['fat'] as num).toStringAsFixed(1)} g',
              Colors.amber,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: provider.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogMetricRow(String label, String value, Color theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: theme, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ================= EXPORT =================

  void _exportNutritionDataAsCSV(
    BuildContext context,
    List<Map<String, dynamic>> dataset,
  ) {
    StringBuffer csvBuffer = StringBuffer();
    csvBuffer.writeln("Day,Calories(kcal),Protein(g),Carbs(g),Fat(g)");

    for (var row in dataset) {
      csvBuffer.writeln(
        "${row['day']},${row['calories']},${row['protein']},${row['carbs']},${row['fat']}",
      );
    }

    debugPrint(csvBuffer.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Nutrition report exported successfully!"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}