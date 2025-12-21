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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedProfile = 'Patient';
                      });
                    },
                    child: Container(
                      width: 150,
                      height: 200,
                      decoration: BoxDecoration(
                        color: selectedProfile == 'Patient' 
                            ? const Color(0xFF1664CD).withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selectedProfile == 'Patient'
                              ? const Color(0xFF1664CD)
                              : Colors.grey[300]!,
                          width: selectedProfile == 'Patient' ? 3 : 1,
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
                            'assets/images/patient.png',
                            height: 100,
                            width: 100,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Patient',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B3267),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Doctor Card
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedProfile = 'Doctor';
                      });
                    },
                    child: Container(
                      width: 150,
                      height: 200,
                      decoration: BoxDecoration(
                        color: selectedProfile == 'Doctor'
                            ? const Color(0xFF1664CD).withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selectedProfile == 'Doctor'
                              ? const Color(0xFF1664CD)
                              : Colors.grey[300]!,
                          width: selectedProfile == 'Doctor' ? 3 : 1,
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
                            'assets/images/doctor.png',
                            height: 100,
                            width: 100,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Doctor',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B3267),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a profile'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}