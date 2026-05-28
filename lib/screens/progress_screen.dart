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

    // Calculate weight metrics safely
    double weightProgress = appProvider.getWeightProgress();
    double remainingDistance = (appProvider.currentWeight - appProvider.targetWeight).abs();
    double lostWeight = (appProvider.weight - appProvider.currentWeight).abs();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text(
          'Your Progress',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: WEIGHT PROGRESS CARD ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weight Journey',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(weightProgress * 100).toStringAsFixed(0)}% Done',
                            style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildWeightStatColumn('Starting', '${appProvider.weight} kg'),
                        _buildWeightStatColumn('Current', '${appProvider.currentWeight} kg', isHighlight: true),
                        _buildWeightStatColumn('Target', '${appProvider.targetWeight} kg'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: weightProgress,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      appProvider.currentWeight <= appProvider.targetWeight && appProvider.goal.contains('loss')
                          ? '🎉 Goal reached! Phenomenal job!'
                          : '🔥 You have changed ${lostWeight.toStringAsFixed(1)} kg! Only ${remainingDistance.toStringAsFixed(1)} kg left to reach your goal.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- SECTION 2: ENGAGEMENT & STREAK STATS ---
            Text(
              'Activity Milestones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMilestoneCard(
                    context,
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange,
                    title: 'Current Streak',
                    value: '${appProvider.streakDays} Days',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMilestoneCard(
                    context,
                    icon: Icons.restaurant,
                    iconColor: Colors.blue,
                    title: 'Total Logged',
                    value: '${appProvider.totalMealsLogged} Meals',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- SECTION 3: WEEKLY NUTRIENT SUMMARY GRAPH ---
            Text(
              'Weekly Nutrient Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: appProvider.fetchWeeklyNutrientReport(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _cachedReportData.isEmpty) {
                  return const Card(
                    child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                  );
                }
                if (snapshot.hasData) {
                  _cachedReportData = snapshot.data!;
                }
                if (_cachedReportData.isEmpty) {
                  return const Card(
                    child: SizedBox(height: 100, child: Center(child: Text("No weekly metrics compiled yet."))),
                  );
                }

                // Find highest calorie value to scale the graph elements safely
                int maxCalorieValue = _cachedReportData.map((d) => (d['calories'] as num).toInt()).reduce(max);
                if (maxCalorieValue < appProvider.dailyCaloriesGoal) {
                  maxCalorieValue = appProvider.dailyCaloriesGoal;
                }

                return Column(
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildGraphLegendItem("Calorie", accentColor),
                                _buildGraphLegendItem("Protein", Colors.red),
                                _buildGraphLegendItem("Carbs", Colors.orange),
                                _buildGraphLegendItem("Fat", Colors.amber),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // --- BAR GRAPH ROW ---
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

                                  double calFactor = maxCalorieValue > 0 ? (cals / maxCalorieValue) : 0.0;
                                  double protFactor = (prot / 150.0);
                                  double carbFactor = (carb / 300.0);
                                  double fatFactor = (fats / 100.0);

                                  return Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _showMetricLabelDialog(context, dayData, appProvider),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                _buildGroupedMiniBar(calFactor, cals > appProvider.dailyCaloriesGoal ? Colors.redAccent : accentColor),
                                                _buildGroupedMiniBar(protFactor, Colors.red),
                                                _buildGroupedMiniBar(carbFactor, Colors.orange),
                                                _buildGroupedMiniBar(fatFactor, Colors.amber),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            dayData['day'],
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const Divider(height: 24),
                            Text(
                              "💡 Tap on any day's bar group above to view absolute numerical label metrics!",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- SECTION 4: DATA TABLE & EXPORT ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Metric Logs Table',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                        ),
                        TextButton.icon(
                          onPressed: () => _exportNutritionDataAsCSV(context, _cachedReportData),
                          icon: const Icon(Icons.explicit_outlined, size: 18, color: Colors.green),
                          label: const Text("Export CSV", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 22,
                            headingRowHeight: 40,
                            dataRowMaxHeight: 40,
                            dataRowMinHeight: 30,
                            columns: const [
                              DataColumn(label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Cal (kcal)', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Prot (g)', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Carb (g)', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Fat (g)', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _cachedReportData.map((dayData) {
                              return DataRow(cells: [
                                DataCell(Text(dayData['day'], style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text('${dayData['calories']}')),
                                DataCell(Text('${(dayData['protein'] as num).toStringAsFixed(0)}g')),
                                DataCell(Text('${(dayData['carbs'] as num).toStringAsFixed(0)}g')),
                                DataCell(Text('${(dayData['fat'] as num).toStringAsFixed(0)}g')),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDER HELPERS ---

  Widget _buildGroupedMiniBar(double heightFactor, Color barColor) {
    return Expanded(
      child: FractionallySizedBox(
        heightFactor: heightFactor.clamp(0.03, 1.0),
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            color: barColor.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ),
      ),
    );
  }

  Widget _buildGraphLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
      ],
    );
  }

  Widget _buildWeightStatColumn(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: isHighlight ? 19 : 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMilestoneCard(BuildContext context, {required IconData icon, required Color iconColor, required String title, required String value}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- INTERACTION & LOGIC LAYERS ---

  void _showMetricLabelDialog(BuildContext context, Map<String, dynamic> data, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('📊 ${data['day']} Balanced Breakdown', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogMetricRow('Calories total', '${data['calories']} / ${provider.dailyCaloriesGoal} kcal', provider.accentColor),
            _buildDialogMetricRow('Protein baseline', '${(data['protein'] as num).toStringAsFixed(1)} g', Colors.red),
            _buildDialogMetricRow('Carbohydrates', '${(data['carbs'] as num).toStringAsFixed(1)} g', Colors.orange),
            _buildDialogMetricRow('Lipids / Fats', '${(data['fat'] as num).toStringAsFixed(1)} g', Colors.amber),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Dismiss', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildDialogMetricRow(String label, String value, Color theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: theme, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // Generates and prints/saves tabular matrix data natively into a system console / snackbar channel 
  void _exportNutritionDataAsCSV(BuildContext context, List<Map<String, dynamic>> dataset) {
    StringBuffer csvBuffer = StringBuffer();
    csvBuffer.writeln("Day,Calories(kcal),Protein(g),Carbs(g),Fat(g)");
    
    for (var row in dataset) {
      csvBuffer.writeln("${row['day']},${row['calories']},${row['protein']},${row['carbs']},${row['fat']}");
    }

    // Since file-system write access requires native target configuration hooks ('path_provider' & 'share_plus'),
    // we convert the buffer into an actionable exportable string stream ready to pipe safely.
    debugPrint("=== EXPORTED NUTRISMART NUTRIENT SHEET MAPPED ===");
    debugPrint(csvBuffer.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("CSV matrix copied to developer debugger logs! Ready to save to device storage."),
        backgroundColor: Theme.of(context).primaryColor,
        action: SnackBarAction(
          label: "VIEW TEXT", 
          textColor: Colors.white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Raw Excel CSV Output String"),
                content: SingleChildScrollView(child: SelectionArea(child: Text(csvBuffer.toString()))),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))],
              ),
            );
          }
        ),
      ),
    );
  }
}