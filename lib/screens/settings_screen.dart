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
    // Dynamically fetch the modern app theme accent color
    final accentColor = provider.accentColor; 
    const baseDarkColor = Color(0xFF2C2C2C); // Modern charcoal base

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "NutriSmart",
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: baseDarkColor,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add notification screen navigation
            },
            icon: const Icon(Icons.notifications_none_rounded, color: baseDarkColor),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: accentColor.withOpacity(0.15),
              radius: 18,
              child: Text(
                provider.userAvatar.isNotEmpty ? provider.userAvatar : "U",
                style: TextStyle(
                  color: accentColor,
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TOP BODY ROW: TITLE & LOGOUT BUTTON ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Edit Profile",
                              style: TextStyle(
                                fontSize: 24, 
                                fontWeight: FontWeight.bold, 
                                color: baseDarkColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Update your biological metrics",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _handleLogout(context),
                          icon: const Icon(Icons.logout_rounded, size: 15),
                          label: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50]!,
                            foregroundColor: Colors.red[700]!,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- FORM CARD CONTAINER ---
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.tune_rounded, color: accentColor, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                "Body Metrics & Activity",
                                style: TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold, 
                                  color: baseDarkColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Gender Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: baseDarkColor, fontSize: 15),
                            decoration: _buildInputDecoration("Gender", Icons.wc_rounded, accentColor),
                            items: ["Male", "Female"]
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedGender = val),
                          ),
                          const SizedBox(height: 18),

                          // Age Field
                          TextFormField(
                            controller: _ageController,
                            style: const TextStyle(color: baseDarkColor, fontSize: 15),
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration("Age (years)", Icons.calendar_today_rounded, accentColor),
                            validator: (v) => v!.isEmpty ? "Age is required" : null,
                          ),
                          const SizedBox(height: 18),

                          // Height Field
                          TextFormField(
                            controller: _heightController,
                            style: const TextStyle(color: baseDarkColor, fontSize: 15),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _buildInputDecoration("Height (cm)", Icons.height_rounded, accentColor),
                            validator: (v) => v!.isEmpty ? "Height is required" : null,
                          ),
                          const SizedBox(height: 18),

                          // Current Weight Field
                          TextFormField(
                            controller: _weightController,
                            style: const TextStyle(color: baseDarkColor, fontSize: 15),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _buildInputDecoration("Current Weight (kg)", Icons.fitness_center_rounded, accentColor),
                            validator: (v) => v!.isEmpty ? "Current weight is required" : null,
                          ),
                          const SizedBox(height: 18),

                          // Target Weight Field
                          TextFormField(
                            controller: _targetWeightController,
                            style: const TextStyle(color: baseDarkColor, fontSize: 15),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _buildInputDecoration("Target Weight (kg)", Icons.outlined_flag_rounded, accentColor),
                            validator: (v) => v!.isEmpty ? "Target weight is required" : null,
                          ),
                          const SizedBox(height: 18),

                          // Activity Level Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedActivity,
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: baseDarkColor, fontSize: 15),
                            decoration: _buildInputDecoration("Activity Level", Icons.bolt_rounded, accentColor),
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
            
            // Modern Bottom Button Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton.icon(
                  onPressed: () => _saveProfileData(provider),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: const Text(
                    "Save Changes", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.3),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REWORKED MODERN INPUT FIELD DECORATION ---
  InputDecoration _buildInputDecoration(String label, IconData icon, Color activeThemeColor) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: activeThemeColor.withOpacity(0.8), size: 20),
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFFAFAFB),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: activeThemeColor, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red[300]!, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
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
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text("Profile metrics updated successfully!", style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: provider.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to logout from NutriSmart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
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