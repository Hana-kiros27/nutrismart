import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  final Color brandGreen = const Color(0xFF1E8234);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- FORM VALIDATION LABELS ---

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // --- BACKEND REGISTRATION LOGIC LOOP ---

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String fullName = _nameController.text.trim();

      try {
        // 1. Authenticate user registration through Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final String uid = userCredential.user!.uid;

        // 2. Initialize an atomic transaction write batch to update Firestore
        final WriteBatch batch = FirebaseFirestore.instance.batch();

        // Path pointer assignments using the user's authentic UID
        final DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final DocumentReference profileRef = FirebaseFirestore.instance.collection('user_profiles').doc(uid);

        // Core identity record payload setup
        batch.set(userRef, {
          'uid': uid,
          'fullName': fullName,
          'email': email.toLowerCase(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Blank initialization metadata profile payload structure
        // This sets up placeholders that the /profile-setup route will fill in
        batch.set(profileRef, {
          'uid': uid,
          'age': 0,
          'height': 0.0,
          'weight': 0.0,
          'gender': '',
          'activity_level': '',
          'goal': '',
          'target_weight': 0.0,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Safely dispatch the entire transactional block onto the database cloud
        await batch.commit();

        if (mounted) {
          setState(() => _isLoading = false);
          // Navigate to profile setup view so the user can complete their metrics setup
          Navigator.pushReplacementNamed(context, '/profile-setup');
        }
      } on FirebaseAuthException catch (authError) {
        setState(() => _isLoading = false);
        String errorMessage = "An unknown authentication error occurred.";
        
        if (authError.code == 'email-already-in-use') {
          errorMessage = "The email address is already registered.";
        } else if (authError.code == 'invalid-email') {
          errorMessage = "The email address layout is malformed.";
        } else if (authError.code == 'weak-password') {
          errorMessage = "The password security layer is too vulnerable.";
        }

        _showSnackBarError(errorMessage);
      } catch (e) {
        setState(() => _isLoading = false);
        _showSnackBarError("Database integration failed. Please check network connection.");
      }
    }
  }

  void _showSnackBarError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- UI TREE ASSEMBLY ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold,
                    color: brandGreen
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Create your account to get started",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Name Input Form Component Row
                const Text("Full Name", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  validator: _validateName,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: "Your full name",
                    prefixIcon: Icon(Icons.person_outline_rounded, color: brandGreen),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: brandGreen, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Email Input Form Component Row
                const Text("Email", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    hintText: "Your email",
                    prefixIcon: Icon(Icons.email_outlined, color: brandGreen),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: brandGreen, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Input Form Component Row
                const Text("Password", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    hintText: "At least 6 characters",
                    prefixIcon: Icon(Icons.lock_outline_rounded, color: brandGreen),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: brandGreen, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Register Submission Trigger Link Block
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Create Account", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),

                // Navigational Routing Alternate Alternative Label Segment
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Have an account? ", style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: Text(
                        "Sign In",
                        style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Text(
                  "By creating an account, you agree to our\nTerms and Data Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}