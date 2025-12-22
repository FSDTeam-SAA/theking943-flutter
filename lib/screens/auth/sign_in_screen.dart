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
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        final userData = result['data'];
        final userRole = userData?['user']?['role']?.toString().toLowerCase();
        final userName = userData?['user']?['fullName'] ?? 'User';

        if (userRole == widget.userType.toLowerCase()) {
          _showSnackBar('Welcome back, $userName!', isError: false);
          await Future.delayed(const Duration(milliseconds: 1000));
          if (!mounted) return;

          if (userRole == 'patient') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const PatientMainNavigation()),
              (route) => false,
            );
          } else if (userRole == 'doctor') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DoctorMainNavigation()),
              (route) => false,
            );
          }
        } else {
          await _authService.logout();
          _showSnackBar(
            'This account is registered as a ${_capitalize(userRole ?? "user")}. Please use the correct login type.',
            isError: true,
          );
        }
      } else {
        _showSnackBar(result['message'] ?? 'Login failed', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Connection Error: Check if server is running', isError: true);
    }
  }

  String _capitalize(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Logo (200x200 as requested)
                Center(
                  child: Image.asset(
                    'assets/images/icon.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.medical_services, size: 100, color: Color(0xFF1664CD)),
                  ),
                ),

                const SizedBox(height: 20),

                /// Welcome Text (Centered like screenshot)
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Welcome back',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0B3267)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please Login to your Account as ${widget.userType}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// Email Field
                const Text("Email Address", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0B3267))),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: 'you@gmail.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1664CD)),
                ),

                const SizedBox(height: 20),

                /// Password Field
                const Text("Password", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0B3267))),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: '****************',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1664CD)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),

                const SizedBox(height: 10),

                /// Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                    child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF1664CD), fontWeight: FontWeight.w600)),
                  ),
                ),

                const SizedBox(height: 20),

                /// Sign In Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: 'Sign in',
                        onPressed: _handleSignIn,
                      ),

                const SizedBox(height: 30),

                /// Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(userType: widget.userType),
                          ),
                        );
                      },
                      child: const Text(
                        'Signup',
                        style: TextStyle(color: Color(0xFF1664CD), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
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