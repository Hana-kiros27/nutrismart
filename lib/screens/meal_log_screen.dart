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
  final TextEditingController _searchController =
      TextEditingController();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _calController =
      TextEditingController();

  final TextEditingController _proController =
      TextEditingController();

  final TextEditingController _carbController =
      TextEditingController();

  final TextEditingController _fatController =
      TextEditingController();

  late Color accentColor;

  String searchQuery = "";
  String selectedMealType = "All";

  bool isManualEntry = false;

  late String currentTip;

  final List<String> dailyTips = [
    "Staying hydrated helps your body process nutrients better.",
    "Protein-rich meals help you stay full longer.",
    "Tracking meals daily improves nutrition consistency.",
    "Healthy eating is about balance, not restriction.",
    "Small healthy habits create long-term results.",
  ];

  @override
  void initState() {
    super.initState();

    currentTip =
        dailyTips[Random().nextInt(dailyTips.length)];
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
      backgroundColor: const Color(0xFFF4F7FB),

      body: SafeArea(
        child: Column(
          children: [

            // ================= HEADER =================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.fromLTRB(
                  22, 20, 22, 26),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          const Text(
                            "Meal Logger",

                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF222222),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Track your nutrition easily",

                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      Container(
                        padding: const EdgeInsets.all(3),

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor.withOpacity(0.2),
                          ),
                        ),

                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              accentColor.withOpacity(0.12),

                          child: Text(
                            provider.userAvatar.isNotEmpty
                                ? provider.userAvatar
                                : "A",

                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // SEARCH BAR

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),

                      borderRadius:
                          BorderRadius.circular(18),
                    ),

                    child: TextField(
                      controller: _searchController,

                      onChanged: (v) => setState(
                        () => searchQuery =
                            v.toLowerCase(),
                      ),

                      decoration: InputDecoration(
                        hintText: "Search foods...",

                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),

                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: accentColor,
                        ),

                        border: InputBorder.none,

                        contentPadding:
                            const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= BODY =================

            Expanded(
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),

                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // DAILY TIP

                    _buildDailyTip(),

                    const SizedBox(height: 20),

                    // FILTERS

                    _buildSelectionCard(
                      "Meal Type",
                      [
                        "All",
                        "Breakfast",
                        "Lunch",
                        "Dinner",
                        "Snack"
                      ],
                    ),

                    const SizedBox(height: 18),

                    // TOGGLE

                    Row(
                      children: [

                        _buildToggleButton(
                          "Food Database",
                          Icons.grid_view_rounded,
                          !isManualEntry,
                          () => setState(
                            () => isManualEntry = false,
                          ),
                        ),

                        const SizedBox(width: 12),

                        _buildToggleButton(
                          "Manual Entry",
                          Icons.edit_note_rounded,
                          isManualEntry,
                          () => setState(
                            () => isManualEntry = true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    isManualEntry
                        ? _buildManualEntryForm(
                            provider,
                          )
                        : _buildFirestoreSearchList(
                            provider,
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DAILY TIP =================

  Widget _buildDailyTip() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.12),
            accentColor.withOpacity(0.04),
          ],
        ),

        borderRadius: BorderRadius.circular(24),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: accentColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  "Daily Tip",

                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  currentTip,

                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= FIRESTORE LIST =================

  Widget _buildFirestoreSearchList(
      AppProvider provider) {
    Query query =
        FirebaseFirestore.instance.collection(
      'foods',
    );

    if (selectedMealType != "All") {
      query = query.where(
        'category',
        isEqualTo:
            selectedMealType.toLowerCase(),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final docs = snapshot.data?.docs.where((doc) {
              final data =
                  doc.data() as Map<String, dynamic>?;

              final name = data?['name']
                      ?.toString()
                      .toLowerCase() ??
                  '';

              return name.contains(searchQuery);
            }).toList() ??
            [];

        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(40),

            child: Center(
              child: Column(
                children: [

                  Icon(
                    Icons.search_off_rounded,
                    size: 55,
                    color: Colors.grey[400],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "No foods found",

                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),

          itemCount: docs.length,

          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),

          itemBuilder: (context, index) {
            final food =
                docs[index].data()
                    as Map<String, dynamic>;

            return GestureDetector(
              onTap: () =>
                  _showLoggingBottomSheet(
                context,
                food,
                provider,
              ),

              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // IMAGE

                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),

                        child: Image.network(
                          food['image'] ?? '',

                          width: double.infinity,
                          fit: BoxFit.cover,

                          errorBuilder:
                              (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[100],

                              child: Center(
                                child: Icon(
                                  Icons.fastfood_rounded,
                                  size: 42,
                                  color:
                                      Colors.grey[400],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.all(14),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            food['name'] ??
                                'Food Item',

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),

                                decoration:
                                    BoxDecoration(
                                  color: accentColor
                                      .withOpacity(
                                          0.1),

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              30),
                                ),

                                child: Text(
                                  "${food['calories'] ?? 0} kcal",

                                  style: TextStyle(
                                    color:
                                        accentColor,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),

                              Text(
                                "P ${food['protein'] ?? 0}g",

                                style: TextStyle(
                                  color:
                                      Colors.grey[600],
                                  fontSize: 11,
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
    );
  }

  // ================= MANUAL FORM =================

  Widget _buildManualEntryForm(
      AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(28),

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

          _entryField(
            "Food Name",
            "e.g Chicken Salad",
            _nameController,
          ),

          Row(
            children: [

              Expanded(
                child: _entryField(
                  "Calories",
                  "0",
                  _calController,
                  isNumber: true,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _entryField(
                  "Protein",
                  "0",
                  _proController,
                  isNumber: true,
                ),
              ),
            ],
          ),

          Row(
            children: [

              Expanded(
                child: _entryField(
                  "Carbs",
                  "0",
                  _carbController,
                  isNumber: true,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _entryField(
                  "Fat",
                  "0",
                  _fatController,
                  isNumber: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () async {
              final name =
                  _nameController.text.trim();

              if (name.isEmpty) return;

              await provider.logMeal(
                name: name,
                type: selectedMealType == "All"
                    ? "Lunch"
                    : selectedMealType,
                calories:
                    int.tryParse(
                          _calController.text,
                        ) ??
                        0,
                protein:
                    int.tryParse(
                          _proController.text,
                        ) ??
                        0,
                carbs:
                    int.tryParse(
                          _carbController.text,
                        ) ??
                        0,
                fat:
                    int.tryParse(
                          _fatController.text,
                        ) ??
                        0,
              );

              if (mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content:
                        Text("$name added successfully"),
                    backgroundColor: accentColor,
                  ),
                );
              }

              _nameController.clear();
              _calController.clear();
              _proController.clear();
              _carbController.clear();
              _fatController.clear();
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,

              minimumSize:
                  const Size(double.infinity, 54),

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),
            ),

            child: const Text(
              "Save Meal",

              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _entryField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: TextField(
        controller: controller,

        keyboardType: isNumber
            ? TextInputType.number
            : TextInputType.text,

        decoration: InputDecoration(
          labelText: label,
          hintText: hint,

          filled: true,
          fillColor: const Color(0xFFF6F8FB),

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(18),

            borderSide: BorderSide(
              color: accentColor,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  // ================= FILTER CHIPS =================

  Widget _buildSelectionCard(
      String title,
      List<String> options) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          title,

          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,

          children: options.map((opt) {
            final selected =
                selectedMealType == opt;

            return ChoiceChip(
              label: Text(opt),

              selected: selected,

              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.grey[700],

                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),

              backgroundColor: Colors.white,

              selectedColor: accentColor,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(30),
              ),

              side: BorderSide(
                color: selected
                    ? accentColor
                    : Colors.grey.shade200,
              ),

              onSelected: (_) {
                setState(() {
                  selectedMealType = opt;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ================= TOGGLE BUTTON =================

  Widget _buildToggleButton(
    String label,
    IconData icon,
    bool active,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,

        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 250),

          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),

          decoration: BoxDecoration(
            color:
                active ? accentColor : Colors.white,

            borderRadius:
                BorderRadius.circular(18),

            boxShadow: active
                ? [
                    BoxShadow(
                      color: accentColor
                          .withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Icon(
                icon,
                color: active
                    ? Colors.white
                    : Colors.grey[600],
                size: 20,
              ),

              const SizedBox(width: 8),

              Text(
                label,

                style: TextStyle(
                  color: active
                      ? Colors.white
                      : Colors.grey[700],

                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= BOTTOM SHEET =================

  void _showLoggingBottomSheet(
    BuildContext context,
    Map<String, dynamic> food,
    AppProvider provider,
  ) {
    int quantity = 1;

    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.transparent,

      isScrollControlled: true,

      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(34),
                ),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [

                  Container(
                    width: 55,
                    height: 5,

                    decoration: BoxDecoration(
                      color: Colors.grey[300],

                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 22),

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(22),

                    child: Image.network(
                      food['image'] ?? '',
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return Container(
                          height: 170,
                          color: Colors.grey[100],
                          child: Center(
                            child: Icon(
                              Icons.fastfood_rounded,
                              size: 55,
                              color: Colors.grey[400],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    food['name'] ?? 'Food',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${food['calories']} kcal • Protein ${food['protein']}g",

                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setModalState(
                              () => quantity--,
                            );
                          }
                        },
                        icon: Icon(
                          Icons.remove_circle_rounded,
                          color: accentColor,
                          size: 34,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Text(
                          "$quantity",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setModalState(
                            () => quantity++,
                          );
                        },
                        icon: Icon(
                          Icons.add_circle_rounded,
                          color: accentColor,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  ElevatedButton(
                    onPressed: () async {
                      await provider.logMeal(
                        name: food['name'] ?? '',
                        type: selectedMealType ==
                                "All"
                            ? "Lunch"
                            : selectedMealType,
                        calories:
                            ((food['calories'] ?? 0)
                                    as num)
                                .toInt() *
                                quantity,
                        protein:
                            ((food['protein'] ?? 0)
                                    as num)
                                .toInt() *
                                quantity,
                        carbs:
                            ((food['carbs'] ?? 0)
                                    as num)
                                .toInt() *
                                quantity,
                        fat:
                            ((food['fat'] ?? 0)
                                    as num)
                                .toInt() *
                                quantity,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              "${food['name']} logged successfully",
                            ),
                            backgroundColor:
                                accentColor,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      minimumSize:
                          const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      "Log ${(food['calories'] ?? 0) * quantity} kcal",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  SizedBox(
                    height:
                        MediaQuery.of(context)
                            .viewPadding
                            .bottom,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}