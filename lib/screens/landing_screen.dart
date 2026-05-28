import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // The primary brand green matching your splash screen
  final Color brandGreen = const Color(0xFF1E8234);

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Optimize your well-being\nthrough balanced nutrition.",
      "subtitle": "Personalized cellular health, automated wellness recipes, and weekly groceries optimized for peak vitality.",
      "image": "assets/nutrition_plate.jpg" 
    },
    {
      "title": "Track your personalized\nnutritional supplements.",
      "subtitle": "Manage your vital supplement routine and track your clean-eating meal plan delivery in real-time.",
      "image": "assets/smart_plate.jpg" 
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white background
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // App Branding Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.eco_rounded, color: brandGreen, size: 28),
                const SizedBox(width: 8),
                Text(
                  "NutriSmart",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: brandGreen,
                  ),
                ),
              ],
            ),
            
            // Sliding Carousel Section
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image Frame (Circular border structure from design)
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08), // Subtle dark shadow
                                spreadRadius: 4,                      // How far the shadow spreads
                                blurRadius: 16,                       // How soft/fuzzy the shadow looks
                                offset: const Offset(0, 8),           // Moves shadow down slightly (x: 0, y: 8)
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              _onboardingData[index]["image"]!,
                              fit: BoxFit.cover, // Scale image cleanly into circle bounds
                              errorBuilder: (context, error, stackTrace) {
                                // Graceful asset error recovery display frame
                                return Container(
                                  color: const Color.fromARGB(255, 188, 255, 190),
                                  child: const Icon(
                                    Icons.spa_rounded, 
                                    size: 80, 
                                    color: Color.fromARGB(255, 4, 98, 17)
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Dynamic Headline Text
                        Text(
                          _onboardingData[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: brandGreen,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Subtitle Text
                        Text(
                          _onboardingData[index]["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Navigation Elements Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                children: [
                  // Page Indicators (Dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? brandGreen : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Primary Interaction Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _onboardingData.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushNamed(context, '/signup');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(54),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage == _onboardingData.length - 1 ? "Get Started" : "Continue",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Secondary Sign In Link
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}