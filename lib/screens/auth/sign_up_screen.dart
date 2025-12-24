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
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Doctor Specific Controllers
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  String? _selectedSpecialty;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  final List<String> _specialties = [
    'Cardiologists', 'Orthopedic', 'Dermatologists', 
    'Nephrologists', 'General Medicine', 'Nutrition & Dietetics', 'Psychiatry'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    // পাসওয়ার্ড ম্যাচ চেক
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }

    // ডাক্তার হলে লাইসেন্স চেক (ব্যাকএন্ড রিকোয়ারমেন্ট অনুযায়ী)
    if (widget.userType == 'Doctor' && _licenseController.text.isEmpty) {
      _showSnackBar('Medical license number is required', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // ব্যাকএন্ডের Key গুলোর সাথে মিল রেখে ডাটা পাঠানো হচ্ছে
      final result = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text, // ব্যাকএন্ডে এটি রিসিভ করা হচ্ছে
        userType: widget.userType, // এটি নিচে 'role' হিসেবে পাঠাতে হবে
        medicalLicenseNumber: widget.userType == 'Doctor' ? _licenseController.text.trim() : null,
        specialty: widget.userType == 'Doctor' ? _selectedSpecialty : null,
        experienceYears: widget.userType == 'Doctor' ? _experienceController.text.trim() : null,
      );

      setState(() => _isLoading = false);
      if (result['success'] == true) {
        _showSnackBar('Registration Successful!', isError: false);
        Navigator.pop(context); 
      } else {
        _showSnackBar(result['message'] ?? 'Registration failed', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    bool isDoctor = widget.userType == 'Doctor';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0, 
        backgroundColor: Colors.white, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        )
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/icon.png', 
                  height: 200, 
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
              
              Center(
                child: Column(
                  children: [
                    Text(
                      'Create ${widget.userType} Account', 
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please Signup to your Account', 
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              const Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B3267))),
              const SizedBox(height: 8),
              CustomTextField(hintText: "Enter your full name", controller: _nameController),

              const SizedBox(height: 15),
              const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B3267))),
              const SizedBox(height: 8),
              CustomTextField(hintText: "you@gmail.com", controller: _emailController, keyboardType: TextInputType.emailAddress),

              if (isDoctor) ...[
                const SizedBox(height: 15),
                const Text("Medical License Number", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B3267))),
                const SizedBox(height: 8),
                CustomTextField(hintText: "Enter License Number", controller: _licenseController),

                const SizedBox(height: 15),
                const Text("Medical Specialty*", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B3267))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300), 
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedSpecialty,
                      hint: const Text("Add your specialty"),
                      items: _specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _selectedSpecialty = v),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                const Text("How many years of experience?", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B3267))),
                const SizedBox(height: 8),
                CustomTextField(hintText: "05 Years", controller: _experienceController),
              ],

              const SizedBox(height: 15),
              const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B3267))),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: "****************", 
                controller: _passwordController, 
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 15),
              const Text("Confirm Password", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B3267))),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: "****************", 
                controller: _confirmPasswordController, 
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),

              const SizedBox(height: 30),
              _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : CustomButton(
                    text: "Create Account", 
                    onPressed: _handleSignUp,
                  ),
              
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sign In', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1664CD))
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}