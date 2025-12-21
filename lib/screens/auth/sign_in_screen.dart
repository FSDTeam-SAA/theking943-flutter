import 'package:flutter/material.dart';
import 'package:docmobi/screens/patient/navigation/patient_main_navigation.dart';
import 'package:docmobi/screens/doctor/navigation/doctor_main_navigation.dart';
import 'package:docmobi/screens/auth/sign_up_screen.dart';
import 'package:docmobi/screens/auth/forgot_password_screen.dart';
import 'package:docmobi/widgets/custom_button.dart';
import 'package:docmobi/widgets/custom_text_field.dart';
import 'package:docmobi/services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  final String userType;

  const SignInScreen({super.key, required this.userType});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  /// Load saved credentials if "Remember Me" was checked
  Future<void> _loadRememberedCredentials() async {
    // TODO: Implement SharedPreferences to load saved email
    // For now, this is a placeholder
  }

  /// Sign In Handler with Backend Integration
  void _handleSignIn() async {
    // Form validation check
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Basic validation
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Please enter email and password', isError: true);
      return;
    }

    // Email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _showSnackBar('Please enter a valid email address', isError: true);
      return;
    }

    // Show loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Call login API
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        // Get user data from response
        final userData = result['data'];
        final userRole = userData?['user']?['role']?.toString().toLowerCase();
        final userName = userData?['user']?['fullName'] ?? 'User';

        print('🔍 User Role: $userRole, Expected: ${widget.userType.toLowerCase()}');

        // ✅ Role verification - Check if login type matches user role
        if (userRole == widget.userType.toLowerCase()) {
          // Save credentials if "Remember Me" is checked
          if (_rememberMe) {
            await _saveCredentials();
          }

          _showSnackBar('Welcome back, $userName!', isError: false);

          // Wait for snackbar, then navigate
          await Future.delayed(const Duration(milliseconds: 1000));

          if (!mounted) return;

          // Navigate based on role
          if (userRole == 'patient') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PatientMainNavigation(),
              ),
            );
          } else if (userRole == 'doctor') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DoctorMainNavigation(),
              ),
            );
          }
        } else {
          // ❌ Wrong role - User trying to login with wrong account type
          await _authService.logout(); // Clear any saved data
          _showSnackBar(
            'This account is registered as a ${_capitalize(userRole ?? 'user')}. '
            'Please use the ${_capitalize(userRole ?? 'user')} login page.',
            isError: true,
          );
        }
      } else {
        // ❌ Login failed
        _showSnackBar(
          result['message'] ?? 'Invalid email or password. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('An unexpected error occurred. Please try again.', isError: true);
      print('❌ Login Error: $e');
    }
  }

  /// Save credentials for "Remember Me" feature
  Future<void> _saveCredentials() async {
    // TODO: Implement SharedPreferences to save email
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('remembered_email', _emailController.text.trim());
  }

  /// Helper function to capitalize first letter
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Helper function to show SnackBar
  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 4 : 2),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                /// Logo
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

                /// Welcome Text
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B3267),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Sign in to continue as ${widget.userType}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 40),

                /// Email Field
                CustomTextField(
                  hintText: 'Email Address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF1664CD),
                  ),
                ),

                const SizedBox(height: 20),

                /// Password Field
                CustomTextField(
                  hintText: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF1664CD),
                  ),
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

                const SizedBox(height: 15),

                /// Remember Me + Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: const Color(0xFF1664CD),
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                        const Text(
                          'Remember me',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF1664CD),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// Sign In Button with Loading State
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1664CD),
                        ),
                      )
                    : CustomButton(
                        text: 'Sign in',
                        onPressed: _handleSignIn,
                      ),

                const SizedBox(height: 20),

                /// Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(
                              userType: widget.userType,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign up',
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}