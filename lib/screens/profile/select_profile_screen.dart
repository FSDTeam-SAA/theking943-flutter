import 'package:flutter/material.dart';
import 'package:docmobi/screens/auth/sign_in_screen.dart';
import 'package:docmobi/widgets/custom_button.dart';

class SelectProfileScreen extends StatefulWidget {
  const SelectProfileScreen({super.key});

  @override
  State<SelectProfileScreen> createState() => _SelectProfileScreenState();
}

class _SelectProfileScreenState extends State<SelectProfileScreen> {
  String? selectedProfile;

  // SnackBar দেখানোর জন্য এই মেথডটি যোগ করা হয়েছে
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'Select Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B3267),
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Patient Card
                  _buildProfileCard(
                    title: 'Patient',
                    imagePath: 'assets/images/patient.png',
                    isSelected: selectedProfile == 'Patient',
                    onTap: () => setState(() => selectedProfile = 'Patient'),
                  ),
                  // Doctor Card
                  _buildProfileCard(
                    title: 'Doctor',
                    imagePath: 'assets/images/doctor.png',
                    isSelected: selectedProfile == 'Doctor',
                    onTap: () => setState(() => selectedProfile = 'Doctor'),
                  ),
                ],
              ),
              const Spacer(),
              
              // Continue button
              CustomButton(
                text: 'Continue',
                onPressed: selectedProfile != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInScreen(userType: selectedProfile!),
                          ),
                        );
                      }
                    : () {
                        _showSnackBar('Please select a profile');
                      },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // কোড ক্লিন রাখার জন্য প্রোফাইল কার্ডের আলাদা উইজেট
  Widget _buildProfileCard({
    required String title,
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1664CD).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1664CD) : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 100,
              width: 100,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 80),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3267),
              ),
            ),
          ],
        ),
      ),
    );
  }
}