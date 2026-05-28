import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import '../providers/app_provider.dart';

class MealLogScreen extends StatefulWidget {
  const MealLogScreen({super.key});

  @override
  State<MealLogScreen> createState() => _MealLogScreenState();
}

class _MealLogScreenState extends State<MealLogScreen> {
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _calController = TextEditingController();
  final TextEditingController _proController = TextEditingController();
  final TextEditingController _carbController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();

  late Color accentColor;

  // State Variables
  String searchQuery = "";
  String selectedMealType = "All";
  bool isManualEntry = false;
  late String currentTip;

  final List<String> dailyTips = [
    "Did you know? People with your profile often benefit from adding a mid-morning snack to boost energy levels!",
    "Staying hydrated can help your body process nutrients more efficiently.",
    "Try to include a source of lean protein in every major meal.",
    "Fiber-rich vegetables like broccoli help keep you full for longer.",
    "Consistency is key! Logging your meals daily helps you reach your goals faster."
  ];

  @override
  void initState() {
    super.initState();
    currentTip = dailyTips[Random().nextInt(dailyTips.length)];
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _calController.dispose();
    _proController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    accentColor = provider.accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text(
          "NutriSmart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF1E8234),
              radius: 18,
              child: Text(
                provider.userAvatar.isNotEmpty ? provider.userAvatar : "A",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Log Meal", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accentColor),
            ),
            const SizedBox(height: 4),
            _buildDailyTip(),
            const SizedBox(height: 20),
            _buildSelectionCard("Select Meal Category", ["All", "Breakfast", "Lunch", "Dinner", "Snack"]),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildToggleButton("Database Foods", Icons.cloud_queue, !isManualEntry, () => setState(() => isManualEntry = false)),
                const SizedBox(width: 12),
                _buildToggleButton("Manual Entry", Icons.edit, isManualEntry, () => setState(() => isManualEntry = true)),
              ],
            ),
            const SizedBox(height: 20),
            isManualEntry ? _buildManualEntryForm(provider) : _buildFirestoreSearchList(provider),
          ],
        ),
      ),
    );
  }

  // ==================== DAILY TIP ====================
  Widget _buildDailyTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E8234).withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF1E8234).withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Daily Tip", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E8234))),
          const SizedBox(height: 4),
          Text(
            currentTip,
            style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ==================== FIRESTORE FOODS SECTION ====================
  Widget _buildFirestoreSearchList(AppProvider provider) {
    Query query = FirebaseFirestore.instance.collection('foods');
    
    if (selectedMealType != "All") {
      query = query.where('category', isEqualTo: selectedMealType.toLowerCase());
    }

    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
          decoration: InputDecoration(
            hintText: "Search items from your collection...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),

        StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: Color(0xFF1E8234)),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error fetching data: ${snapshot.error}"));
            }

            final docs = snapshot.data?.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>?;
              final name = (data != null && data['name'] != null) ? data['name'].toString().toLowerCase() : '';
              return name.contains(searchQuery);
            }).toList() ?? [];

            if (docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: Text("No matching foods found", style: TextStyle(color: Colors.grey))),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,          
                crossAxisSpacing: 14,       
                mainAxisSpacing: 14,
                childAspectRatio: 0.76,     
              ),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final food = doc.data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () => _showLoggingBottomSheet(context, food, provider),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                food['image'] ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.fastfood, color: Colors.grey, size: 36),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food['name'] ?? 'Unknown Food',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF2D2520),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${food['calories'] ?? 0} kcal",
                                    style: const TextStyle(
                                      color: Color(0xFF1E8234),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    "P: ${food['protein'] ?? 0}g",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ==================== QUANTITY BOTTOM SHEET ====================
  void _showLoggingBottomSheet(BuildContext context, Map<String, dynamic> food, AppProvider provider) {
    int localQuantity = 1;
    final targetLoggingType = selectedMealType == "All" ? "Lunch" : selectedMealType;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          food['image'] ?? '',
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 65,
                            height: 65,
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.fastfood, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food['name'] ?? 'Unnamed Item',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2520)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Macros per serving: P: ${food['protein'] ?? 0}g • C: ${food['carbs'] ?? 0}g • F: ${food['fat'] ?? 0}g",
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        "How many servings?",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D2520)),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setModalState(() => localQuantity > 1 ? localQuantity-- : null),
                        icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF1E8234)),
                      ),
                      Text("$localQuantity", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => setModalState(() => localQuantity++),
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1E8234)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final calValue = ((food['calories'] ?? 0) as num).toInt() * localQuantity;
                        final proValue = ((food['protein'] ?? 0) as num).toInt() * localQuantity;
                        final carbValue = ((food['carbs'] ?? 0) as num).toInt() * localQuantity;
                        final fatValue = ((food['fat'] ?? 0) as num).toInt() * localQuantity;

                        await provider.logMeal(
                          name: food['name'] ?? 'Unnamed',
                          type: targetLoggingType,
                          calories: calValue,
                          protein: proValue,
                          carbs: carbValue,
                          fat: fatValue,
                        );

                        if (context.mounted) {
                          Navigator.pop(context); 
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${food['name']} added to $targetLoggingType"),
                              backgroundColor: const Color(0xFF1E8234),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to log meal: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8234),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      "Log Food — ${( ((food['calories'] ?? 0) as num).toInt() * localQuantity )} kcal",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==================== MANUAL ENTRY ====================
  Widget _buildManualEntryForm(AppProvider provider) {
    final targetLoggingType = selectedMealType == "All" ? "Lunch" : selectedMealType;

    return Column(
      children: [
        _entryField("Food Name", "e.g. Scrambled Eggs", _nameController),
        Row(
          children: [
            Expanded(child: _entryField("Calories", "0", _calController, isNumber: true)),
            const SizedBox(width: 10),
            Expanded(child: _entryField("Protein (g)", "0", _proController, isNumber: true)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _entryField("Carbs (g)", "0", _carbController, isNumber: true)),
            const SizedBox(width: 10),
            Expanded(child: _entryField("Fat (g)", "0", _fatController, isNumber: true)),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter food name')),
              );
              return;
            }

            try {
              await provider.logMeal(
                name: name,
                type: targetLoggingType,
                calories: int.tryParse(_calController.text) ?? 0,
                protein: int.tryParse(_proController.text) ?? 0,
                carbs: int.tryParse(_carbController.text) ?? 0,
                fat: int.tryParse(_fatController.text) ?? 0,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$name added to $targetLoggingType"),
                    backgroundColor: const Color(0xFF1E8234),
                  ),
                );

                _nameController.clear();
                _calController.clear();
                _proController.clear();
                _carbController.clear();
                _fatController.clear();
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E8234),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Save Manual Entry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _entryField(String label, String hint, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildSelectionCard(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: 8,
            children: options.map((opt) => ChoiceChip(
              label: Text(opt),
              selected: selectedMealType == opt,
              selectedColor: const Color(0xFF1E8234).withOpacity(0.15),
              onSelected: (s) => setState(() {
                selectedMealType = opt;
              }),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String label, IconData icon, bool active, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: active ? Colors.white : Colors.grey),
        label: Text(label, style: TextStyle(color: active ? Colors.white : Colors.grey)),
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? const Color(0xFF1E8234) : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: active ? const Color(0xFF1E8234) : Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}