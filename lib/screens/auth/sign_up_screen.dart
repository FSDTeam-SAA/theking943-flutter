import 'package:flutter/material.dart';
import 'package:docmobi/widgets/custom_button.dart';
import 'package:docmobi/widgets/custom_text_field.dart';
import 'package:docmobi/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  final String userType;

  const SignUpScreen({super.key, required this.userType});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  /// Signup handler - এখন সঠিকভাবে কাজ করবে
  void _handleSignUp() async {
    // Form validation check
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Basic validation
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }

    // Password match check
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }

    // Email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _showSnackBar('Please enter a valid email', isError: true);
      return;
    }

    // Password length check
    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', isError: true);
      return;
    }

    // Show loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Call register API
      final result = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: widget.userType,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        // ✅ Success - এখন Login page এ redirect করবে
        _showSnackBar(
          'Account created successfully! Please login.',
          isError: false,
        );

        // Wait for snackbar to show, then navigate to login
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          // Pop back to login screen
          Navigator.pop(context);
        }
      } else {
        // ❌ Error
        _showSnackBar(
          result['message'] ?? 'Registration failed. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('An unexpected error occurred', isError: true);
      print('❌ Signup Error: $e');
    }
  }

  /// Helper function to show SnackBar
  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B3267)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/icon.png',
                    height: 80,
                    width: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1664CD).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          size: 40,
                          color: Color(0xFF1664CD),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                
                // Create Account text
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B3267),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to get started as ${widget.userType}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Full Name field
                CustomTextField(
                  hintText: 'Full Name',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF1664CD)),
                ),
                const SizedBox(height: 20),
                
                // Email field
                CustomTextField(
                  hintText: 'Email Address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1664CD)),
                ),
                const SizedBox(height: 20),
                
                // Password field
                CustomTextField(
                  hintText: 'Password (min. 6 characters)',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1664CD)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                
                // Confirm Password field
                CustomTextField(
                  hintText: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1664CD)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),
                
                // Create Account button with loading state
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1664CD),
                        ),
                      )
                    : CustomButton(
                        text: 'Create Account',
                        onPressed: _handleSignUp,
                      ),
                const SizedBox(height: 20),
                
                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xFF1664CD),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}