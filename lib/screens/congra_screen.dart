// lib/screens/congra_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class CongraScreen extends StatelessWidget {
  const CongraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brandGreen = const Color(0xFF1E8234);
    // ✨ Extract the global user name safely inside stateless widgets
    final provider = Provider.of<AppProvider>(context);
    final String firstName = provider.userName.split(' ').first;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Central Success Graphic Element
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: brandGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 100,
                    color: brandGreen,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Personalized Dynamic Header
              Text(
                "Congratulations, $firstName!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: brandGreen,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Your personalized profile setup is complete. Your body metric parameters have been configured to maximize your metabolic vitality.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              // Primary Interaction Router
              ElevatedButton(
                onPressed: () {
                  // Push replacement guarantees they cannot backtrack into setup screens
                  Navigator.pushReplacementNamed(context, '/main');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Go to Dashboard",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}