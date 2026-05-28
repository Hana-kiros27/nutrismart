import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final Color brandGreen = const Color(0xFF1E8234);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Smooth pulse animation for the logo
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_animationController);
    _animationController.repeat(reverse: true);

    // Run the conditional Firebase state verification check loop
    _checkUserAuthenticationSession();
  }

  /// Evaluates authentication state tokens to choose the matching route destination
  Future<void> _checkUserAuthenticationSession() async {
    // 1. Let the beautiful pulse animation render for at least 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;

    try {
      // 2. Intercept the active state user entity container from Firebase Auth
      final User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        debugPrint("🔐 Session match found for UID: ${firebaseUser.uid}. Hydrating memory maps...");
        
        // 3. Hydrate provider cache with custom user profile document files before jumping screens
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        await appProvider.loadUserDataAndProfiles(firebaseUser.uid);

        if (mounted) {
          // Send recognized users straight to the application layout canvas dashboard
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        debugPrint("🔓 No pre-existing authorization tokens caught. Routing straight to onboarding.");
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/landing');
        }
      }
    } catch (e) {
      debugPrint("❌ Failure handling splash runtime channel route checks: $e");
      // Fallback safe escape route default handle to prevent black screen lockouts
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandGreen,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.eco_rounded,
                size: 110,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                "NutriSmart",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your Personal Nutrition Companion",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}