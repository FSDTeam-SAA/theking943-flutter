import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'The King');
  final TextEditingController _emailController = TextEditingController(text: 'example@gmail.com');
  final TextEditingController _phoneController = TextEditingController(text: 'Phone Number');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B3267)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Personal Info',
          style: TextStyle(
            color: Color(0xFF0B3267),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Picture
            Stack(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/images/doctor_profile.png'),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0B3267), Color(0xFF1664CD)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap to Change your Picture',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            // Profile Picture Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Profile Picture',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B3267),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Name Field
            _buildInfoField(
              icon: Icons.person_outline,
              controller: _nameController,
              label: 'The King',
            ),
            const SizedBox(height: 20),
            // Email Field
            _buildInfoField(
              icon: Icons.email_outlined,
              controller: _emailController,
              label: 'example@gmail.com',
            ),
            const SizedBox(height: 20),
            // Phone Field
            _buildInfoField(
              icon: Icons.phone_outlined,
              controller: _phoneController,
              label: 'Phone Number',
            ),
            const SizedBox(height: 20),
            // Change Password
            _buildInfoField(
              icon: Icons.lock_outline,
              controller: _passwordController,
              label: 'Change Password',
              isPassword: true,
            ),
            const SizedBox(height: 20),
            // Address Field
            _buildInfoField(
              icon: Icons.location_on_outlined,
              controller: _addressController,
              label: 'Address',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    TextEditingController? controller,
    required String label,
    bool isPassword = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1664CD)),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.edit, size: 20, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}