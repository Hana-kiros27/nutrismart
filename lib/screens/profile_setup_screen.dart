import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/app_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  String gender = "Male";
  int age = 22;
  double height = 170;
  double weight = 65;
  double targetWeight = 60;

  String activityLevel = "Moderate";
  String goal = "weight_loss";

  final Color brandGreen = const Color(0xFF1E8234);

  final List<String> activityLevels = [
    "Sedentary",
    "Light",
    "Moderate",
    "Active",
    "Very Active",
  ];

  final Map<String, String> goalOptions = {
    "weight_loss": "Weight Loss",
    "maintenance": "Maintenance",
    "weight_gain": "Weight Gain",
  };

  Future<void> _handleFinishSetup(AppProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("No user session");
      }

      final uid = currentUser.uid;

      final double calculatedTarget = goal == "maintenance"
          ? weight
          : targetWeight;

      await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(uid)
          .update({
            'age': age,
            'height': height,
            'weight': weight,
            'gender': gender,
            'activity_level': activityLevel,
            'goal': goal,
            'target_weight': calculatedTarget,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      await provider.loadUserDataAndProfiles(uid);

      provider.generateRandomPlan();

      if (mounted) {
        setState(() => _isLoading = false);

        Navigator.pushReplacementNamed(context, '/congra');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Profile completed • ${provider.dailyCaloriesGoal} kcal daily target",
            ),
            backgroundColor: brandGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save profile. Please try again."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ================= HEADER =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [brandGreen, brandGreen.withOpacity(0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: brandGreen.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome ${provider.userName} 👋",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "Set up your health profile to generate personalized meal plans and nutrition tracking.",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTopStat("Goal", goalOptions[goal] ?? ""),
                          _buildDivider(),
                          _buildTopStat("Weight", "${weight.toInt()} kg"),
                          _buildDivider(),
                          _buildTopStat("Activity", activityLevel),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ================= FORM =================
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildSectionCard(
                        title: "Personal Information",
                        icon: Icons.badge_outlined,
                        child: Column(
                          children: [
                            _buildGenderSelector(),

                            const SizedBox(height: 20),

                            _buildNumberField(
                              label: "Age",
                              suffix: "years",
                              initialValue: age.toString(),
                              onChanged: (val) {
                                age = int.tryParse(val) ?? age;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      _buildSectionCard(
                        title: "Body Measurements",
                        icon: Icons.monitor_weight_outlined,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildNumberField(
                                label: "Height",
                                suffix: "cm",
                                initialValue: height.toInt().toString(),
                                onChanged: (val) {
                                  height = double.tryParse(val) ?? height;
                                },
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: _buildNumberField(
                                label: "Weight",
                                suffix: "kg",
                                initialValue: weight.toInt().toString(),
                                onChanged: (val) {
                                  weight = double.tryParse(val) ?? weight;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      _buildSectionCard(
                        title: "Lifestyle",
                        icon: Icons.local_fire_department_outlined,
                        child: Column(
                          children: [
                            _buildDropdown(
                              label: "Activity Level",
                              value: activityLevel,
                              items: activityLevels,
                              onChanged: (val) {
                                setState(() {
                                  activityLevel = val!;
                                });
                              },
                            ),

                            const SizedBox(height: 18),

                            _buildDropdown(
                              label: "Fitness Goal",
                              value: goal,
                              items: goalOptions.keys.toList(),
                              customLabels: goalOptions,
                              onChanged: (val) {
                                setState(() {
                                  goal = val!;

                                  if (goal == "maintenance") {
                                    targetWeight = weight;
                                  }
                                });
                              },
                            ),

                            if (goal != "maintenance") ...[
                              const SizedBox(height: 18),

                              _buildNumberField(
                                label: "Target Weight",
                                suffix: "kg",
                                initialValue: targetWeight.toInt().toString(),
                                onChanged: (val) {
                                  targetWeight =
                                      double.tryParse(val) ?? targetWeight;
                                },
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _handleFinishSetup(provider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline),
                                    SizedBox(width: 10),
                                    Text(
                                      "Finish Setup",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TOP HEADER STATS =================

  Widget _buildTopStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withOpacity(0.2),
    );
  }

  // ================= SECTION CARD =================

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: brandGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: brandGreen, size: 20),
              ),

              const SizedBox(width: 12),

              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }

  // ================= GENDER SELECTOR =================

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(child: _buildGenderOption("Male", Icons.male_rounded)),

        const SizedBox(width: 14),

        Expanded(child: _buildGenderOption("Female", Icons.female_rounded)),
      ],
    );
  }

  Widget _buildGenderOption(String text, IconData icon) {
    final bool isSelected = gender == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          gender = text;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? brandGreen.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? brandGreen : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 34, color: isSelected ? brandGreen : Colors.grey),

            const SizedBox(height: 10),

            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? brandGreen : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= NUMBER FIELD =================

  Widget _buildNumberField({
    required String label,
    required String suffix,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),

        const SizedBox(height: 10),

        TextFormField(
          initialValue: initialValue,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Required";
            }

            if (double.tryParse(value) == null) {
              return "Invalid number";
            }

            return null;
          },
          onChanged: onChanged,
          decoration: InputDecoration(
            suffixText: suffix,
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: brandGreen, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ================= DROPDOWN =================

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    Map<String, String>? customLabels,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),

        const SizedBox(height: 10),

        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: brandGreen, width: 2),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(customLabels?[item] ?? item),
            );
          }).toList(),
        ),
      ],
    );
  }
}
