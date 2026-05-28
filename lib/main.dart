import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/main_screen.dart';
import 'screens/congra_screen.dart'; 
import 'food_data.dart'; // Imports your organized list of 20 categorized items
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🚀 AUTOMATIC ONE-TIME UPLOAD TRIGGER
  // Run the app once. As soon as it starts, look at your terminal.
  // Once it prints "SUCCESS", you can comment out or delete this line!
  // await uploadMy20Foods();

  runApp(const NutriSmartApp());
}

class NutriSmartApp extends StatelessWidget {
  const NutriSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // FIXED: Simply instantiate the clean AppProvider here without calling loadData().
      // Your SplashScreen or Login pipeline will handle triggering data hydration via UID.
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'NutriSmart',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF1E8234), 
          fontFamily: GoogleFonts.inter().fontFamily,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1E8234),
          ),
          cardTheme: const CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/landing': (context) => const LandingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const RegisterScreen(),
          '/profile-setup': (context) => const ProfileSetupScreen(),
          '/congra': (context) => const CongraScreen(), 
          '/main': (context) => const MainScreen(), 
        },
      ),
    );
  }
}

// 📦 THE BULK UPLOAD FUNCTION
Future<void> uploadMy20Foods() async {
  print('⏳ Starting database initialization...');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final WriteBatch batch = firestore.batch();
  final CollectionReference foodsCollection = firestore.collection('foods');

  for (var foodItem in nutritionPlannerFoods) {
    // Generates a clean new document with an Auto-ID inside your 'foods' collection
    DocumentReference newDocRef = foodsCollection.doc();
    batch.set(newDocRef, foodItem);
  }

  try {
    await batch.commit(); // Sends all 20 records to the cloud at the exact same time
    print('🚀 SUCCESS: All 20 categorized items are now live in your Firestore database!');
  } catch (error) {
    print('❌ UPLOAD FAILED: $error');
  }
}