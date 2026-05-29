import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Your signature premium green brand colors
  final Color brandGreen = const Color(0xFF1E8234);
  final Color brandGreenLight = const Color(
    0xFFE8F3EA,
  ); // Soft tint fallback background

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Optimize your well-being\nthrough balanced nutrition",
      "subtitle":
          "Personalized cellular health, automated wellness recipes, and weekly groceries optimized for peak vitality.",
      "image": "assets/nutrition_plate.jpg",
    },
    {
      "title": "Track your personalized\nutritional supplements",
      "subtitle":
          "Manage your vital supplement routine and track your clean-eating meal plan delivery in real-time.",
      "image": "assets/smart_plate.jpg",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Off-white modern surface
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // App Branding Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.eco_rounded, color: brandGreen, size: 26),
                const SizedBox(width: 8),
                Text(
                  "NutriSmart",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: brandGreen,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),

            // Sliding Carousel Section
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Spacer(), // Intelligently balances empty space top/bottom
                                  // Elevated Circular Image Frame with Ultra-Soft Drop Shadows
                                  Container(
                                    width: 260,
                                    height: 260,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          spreadRadius: 6,
                                          blurRadius: 24,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        _onboardingData[index]["image"]!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: brandGreenLight,
                                                child: Icon(
                                                  Icons.spa_rounded,
                                                  size: 90,
                                                  color: brandGreen,
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  // Premium Typography Headlines
                                  Text(
                                    _onboardingData[index]["title"]!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                      height: 1.25,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Subtitle Body Copy with safe layout limits
                                  Text(
                                    _onboardingData[index]["subtitle"]!,
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade600,
                                      height: 1.45,
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Navigation and Actions Area
            Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 24.0),
              child: Column(
                children: [
                  // Smooth Modern Carousel Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? brandGreen
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 28,
                  ), // Optimized slightly smaller space
                  // Primary Interaction Action Button (Pill Design)
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: brandGreen.withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
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
                        minimumSize: const Size.fromHeight(56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? "Get Started"
                            : "Continue",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Clean Secondary Action Pill Frame
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandGreen.withOpacity(0.07),
                      foregroundColor: brandGreen,
                      minimumSize: const Size.fromHeight(56),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                        color: brandGreen,
                        fontWeight: FontWeight.bold,
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
