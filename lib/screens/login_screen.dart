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

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        if (mounted) {
          final provider = Provider.of<AppProvider>(context, listen: false);
          await provider.loadUserDataAndProfiles(userCredential.user!.uid);
          
          setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    // Calculates safe explicit layout measurements dynamically based on the device context
    final double screenHeight = MediaQuery.of(context).size.height;
    final double bannerHeight = screenHeight * 0.32; 
    final double overlappingOffset = bannerHeight - 32; // Forces card to slice cleanly up into the banner border

    InputDecoration _buildInputDecoration({required String hintText, Widget? prefixIcon, Widget? suffixIcon}) {
      return InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF7F7F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: brandGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF), // Outer canvas background grey tint
      resizeToAvoidBottomInset: true, // Auto-scrolls form elements dynamically above the virtual keyboard
      body: SingleChildScrollView(
  child: Column(
    children: [
      // TOP GREEN HEADER
      Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          color: brandGreen,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(40),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome Back 👋",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Login to continue your wellness journey",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),

      // FLOATING FORM CARD
      Transform.translate(
        offset: const Offset(0, -50),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  // EMAIL
                  TextFormField(
                    controller: _emailController,
                    validator: _validateEmail,
                    decoration: _buildInputDecoration(
                      hintText: "Email Address",
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: brandGreen,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // PASSWORD
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    decoration: _buildInputDecoration(
                      hintText: "Password",
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: brandGreen,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text("Forgot Password?"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context,
                              '/signup');
                        },
                        child: Text(
                          "Register",
                          style: TextStyle(
                            color: brandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),
    );
  }
}