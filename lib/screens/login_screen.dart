import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  final Color brandGreen = const Color(0xFF1E8234);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- INPUT VALIDATION CONTROLLERS ---

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

  // --- BACKEND AUTHENTICATION DISPATCHER ---

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      try {
        // 1. Submit email and password securely to Firebase Auth gatekeeper
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        // 2. Fetch user's corresponding user_profile document fields into the provider
        if (mounted) {
          final provider = Provider.of<AppProvider>(context, listen: false);
          
          // Pass the UID to load personal attributes and initialize the NutritionRules matching structure
          await provider.loadUserDataAndProfiles(userCredential.user!.uid);
          
          setState(() => _isLoading = false);
          
          // 3. Clear stack routing straight into main ecosystem space
          Navigator.pushReplacementNamed(context, '/main');
        }
      } on FirebaseAuthException catch (authError) {
        setState(() => _isLoading = false);
        String errorMessage = "Authentication failed.";

        if (authError.code == 'user-not-found') {
          errorMessage = "No profile exists under this email address.";
        } else if (authError.code == 'wrong-password') {
          errorMessage = "Incorrect security password key code.";
        } else if (authError.code == 'invalid-email') {
          errorMessage = "The email layout provided is malformed.";
        } else if (authError.code == 'user-disabled') {
          errorMessage = "This user profile account has been suspended.";
        }

        _showSnackBarError(errorMessage);
      } catch (e) {
        setState(() => _isLoading = false);
        _showSnackBarError("Network connection error. Failed syncing records.");
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

  // --- WIDGET STRUCTURE COMPILATION ---

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
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold,
                    color: brandGreen
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Sign in to your account",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Email Form Block Row
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

                // Password Form Block Row
                const Text("Password", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    hintText: "Your password",
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
                
                // Password Alternate Reset Auxiliary Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Password recovery links can be managed via Cloud Console configurations.'),
                          backgroundColor: brandGreen,
                        ),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Execution Submission Trigger
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
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
                    : const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),

                // Secondary Navigational Registration Alternative Link Segment Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}