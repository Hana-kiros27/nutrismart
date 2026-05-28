import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _targetWeightController;
  
  String? _selectedGender;
  String? _selectedActivity;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _ageController = TextEditingController(text: provider.age.toString());
    _heightController = TextEditingController(text: provider.height.toString());
    _weightController = TextEditingController(text: provider.currentWeight.toString());
    _targetWeightController = TextEditingController(text: provider.targetWeight.toString());
    _selectedGender = provider.gender;
    _selectedActivity = provider.activityLevel;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      // App bar restored to match the original layout exactly
      appBar: AppBar(
        title: const Text(
          "NutriSmart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add notification screen navigation
            },
            icon: const Icon(Icons.notifications_none),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.green,
              radius: 18,
              child: Text(
                provider.userAvatar.isNotEmpty ? provider.userAvatar : "U",
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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TOP BODY ROW: TITLE & LOGOUT BUTTON ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF1B3922),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _handleLogout(context),
                          icon: const Icon(Icons.logout, size: 16, color: Colors.white),
                          label: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- FORM CARD ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Body Metrics & Activity",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1B3922)),
                          ),
                          const SizedBox(height: 20),

                          // Gender Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: _buildInputDecoration("Gender", Icons.wc),
                            items: ["Male", "Female"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (val) => setState(() => _selectedGender = val),
                          ),
                          const SizedBox(height: 16),

                          // Age Field
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration("Age (years)", Icons.calendar_today),
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 16),

                          // Height Field
                          TextFormField(
                            controller: _heightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _buildInputDecoration("Height (cm)", Icons.height),
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 16),

                          // Current Weight Field
                          TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _buildInputDecoration("Current Weight (kg)", Icons.fitness_center),
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 16),

                          // Target Weight Field
                          TextFormField(
                            controller: _targetWeightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _buildInputDecoration("Target Weight (kg)", Icons.flag_outlined),
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 16),

                          // Activity Level Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedActivity,
                            decoration: _buildInputDecoration("Activity Level", Icons.bolt),
                            items: ["Sedentary", "Low", "Light", "Moderate", "High", "Active", "Very Active"]
                                .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedActivity = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Save Changes Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ElevatedButton.icon(
                onPressed: () => _saveProfileData(provider),
                icon: const Icon(Icons.save_outlined),
                label: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green.shade700, size: 20),
      labelStyle: TextStyle(color: Colors.grey.shade700),
      filled: true,
      fillColor: const Color(0xFFFBFDFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 1.5),
      ),
    );
  }

  Future<void> _saveProfileData(AppProvider provider) async {
    if (_formKey.currentState!.validate()) {
      double? typedCurrentWeight = double.tryParse(_weightController.text);
      await provider.updateUserInfo(
        gender: _selectedGender,
        age: int.tryParse(_ageController.text),
        height: double.tryParse(_heightController.text),
        currentWeight: typedCurrentWeight,
        activityLevel: _selectedActivity,
      );

      double? target = double.tryParse(_targetWeightController.text);
      if (target != null) {
        await provider.updateProgressGoals(newTargetWeight: target);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile metrics updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _handleLogout(BuildContext context) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout from NutriSmart?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await provider.logout();
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (_) => const LoginScreen()), 
        (route) => false,
      );
    }
  }
}