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
  double height = 170.0;
  double weight = 65.0;
  double targetWeight = 60.0; 
  
  String activityLevel = "Moderate";
  String goal = "weight_loss"; 

  final Color brandGreen = const Color(0xFF1E8234);

  final List<String> activityLevels = [
    "Sedentary", "Light", "Moderate", "Active", "Very Active"
  ];

  final Map<String, String> goalOptions = {
    "weight_loss": "Weight Loss",
    "maintenance": "Maintenance",
    "weight_gain": "Weight Gain",
  };

  // --- SUBMISSION DISPATCH LOOP ---

  void _handleFinishSetup(AppProvider provider) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 1. Fetch the authentic current logged-in user UID from Firebase Auth
        final User? currentUser = FirebaseAuth.instance.currentUser;
        
        if (currentUser == null) {
          throw Exception("No authorized session detected.");
        }

        final String uid = currentUser.uid;
        final double calculatedTarget = goal == "maintenance" ? weight : targetWeight;

        // 2. Perform a network update operation on the pre-existing user_profiles document path
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

        // 3. Sync memory data states inside AppProvider to run your rule matrix
        await provider.loadUserDataAndProfiles(uid);
        provider.generateRandomPlan();

        if (mounted) {
          setState(() => _isLoading = false);
          
          // Clear routing stack straight to success configuration milestone layout
          Navigator.pushReplacementNamed(context, '/congra');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Profile setup complete! Daily Goal: ${provider.dailyCaloriesGoal} kcal"),
              backgroundColor: brandGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update health metrics. Check your internet connection."),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // --- VIEW INTERFACE COMPILER ---

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Complete Your Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, ${provider.userName}! 👋",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: brandGreen),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Let's personalize your metabolic vitality parameters to optimize your meal mapping schedules.",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Gender Form Block Segment
                const Text("Gender", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildGenderOption("Male", Icons.male),
                    const SizedBox(width: 16),
                    _buildGenderOption("Female", Icons.female),
                  ],
                ),
                const SizedBox(height: 24),

                // Age Input Row Form Element
                _buildNumberField(
                  label: "Age (years)",
                  placeholderValue: age,
                  onChanged: (val) => setState(() => age = val),
                ),
                const SizedBox(height: 24),

                // Physical Scale Space Dimension Inputs Row Configuration
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberField(
                        label: "Height (cm)",
                        placeholderValue: height.toInt(),
                        onChanged: (val) => setState(() => height = val.toDouble()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildNumberField(
                        label: "Weight (kg)",
                        placeholderValue: weight.toInt(),
                        onChanged: (val) => setState(() => weight = val.toDouble()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Activity Index Menu Dropdown Selection Component Row
                const Text("Activity Level", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: activityLevel,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: brandGreen, width: 2), borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: activityLevels.map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (value) => setState(() => activityLevel = value!),
                ),
                const SizedBox(height: 24),

                // Target Fitness Objective Primary Categorization Component List
                const Text("Fitness Goal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: goal,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: brandGreen, width: 2), borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: goalOptions.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      goal = value!;
                      if (goal == "maintenance") {
                        targetWeight = weight;
                      }
                    });
                  },
                ),
                
                // Adaptive Dynamic Weight Goal Targets Selector Field Element
                if (goal != "maintenance") ...[
                  const SizedBox(height: 24),
                  _buildNumberField(
                    label: "Target Goal Weight (kg)",
                    placeholderValue: targetWeight.toInt(),
                    onChanged: (val) => setState(() => targetWeight = val.toDouble()),
                  ),
                ],

                const SizedBox(height: 40),

                // Final Operational Action Transaction Submission Control Row
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : () => _handleFinishSetup(provider),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Finish Setup & Start", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- COMPONENT LEVEL METRIC SUBSYSTEM WIDGET HELPERS ---

  Widget _buildGenderOption(String text, IconData icon) {
    bool isSelected = gender == text;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? brandGreen.withOpacity(0.08) : Colors.grey[50],
            border: Border.all(color: isSelected ? brandGreen : Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? brandGreen : Colors.grey, size: 32),
              const SizedBox(height: 8),
              Text(
                text, 
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? brandGreen : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int placeholderValue,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey(label), 
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 16),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Please provide a valid metric measure entry.";
            }
            if (double.tryParse(value) == null) {
              return "Numeric characters only.";
            }
            return null;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: brandGreen, width: 2), borderRadius: BorderRadius.circular(12)),
            hintText: "Current value: $placeholderValue",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
          ),
          onChanged: (val) {
            if (val.isNotEmpty) {
              final parsed = int.tryParse(val);
              if (parsed != null) onChanged(parsed);
            }
          },
        ),
      ],
    );
  }
}