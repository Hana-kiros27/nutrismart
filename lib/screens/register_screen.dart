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

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String fullName = _nameController.text.trim();

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final String uid = userCredential.user!.uid;
        final WriteBatch batch = FirebaseFirestore.instance.batch();

        final DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final DocumentReference profileRef = FirebaseFirestore.instance.collection('user_profiles').doc(uid);

        batch.set(userRef, {
          'uid': uid,
          'fullName': fullName,
          'email': email.toLowerCase(),
          'createdAt': FieldValue.serverTimestamp(),
        });

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

        await batch.commit();

        if (mounted) {
          setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
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
  backgroundColor: const Color(0xFFEFEFEF),
  resizeToAvoidBottomInset: true,

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
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Fill in your details to get started 🚀",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),

        // FLOATING CARD
        Transform.translate(
          offset: const Offset(0, -55),

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

                    // FULL NAME
                    TextFormField(
                      controller: _nameController,
                      validator: _validateName,
                      textCapitalization: TextCapitalization.words,

                      decoration: _buildInputDecoration(
                        hintText: "Full Name",
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          color: brandGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
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
                          Icons.lock_outline_rounded,
                          color: brandGreen,
                        ),

                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),

                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // REGISTER BUTTON
                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _handleRegister,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30),
                          ),

                          elevation: 0,
                        ),

                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // LOGIN LINK
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        const Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/login',
                            );
                          },

                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: brandGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "By creating an account, you agree to our\nTerms and Data Policy",
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        height: 1.4,
                      ),
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