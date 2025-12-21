import 'package:flutter/material.dart';
import 'package:docmobi/screens/patient/home/patient_home_screen.dart';
import 'package:docmobi/screens/patient/appointments/patient_appointments_screen.dart';
import 'package:docmobi/screens/patient/reels/doctor_reels_screen.dart';
import 'package:docmobi/screens/patient/messages/messages_list_screen.dart';
import 'package:docmobi/screens/patient/profile/patient_profile_screen.dart';

class PatientMainNavigation extends StatefulWidget {
  const PatientMainNavigation({super.key});

  @override
  State<PatientMainNavigation> createState() => _PatientMainNavigationState();
}

class _PatientMainNavigationState extends State<PatientMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    PatientHomeScreen(),
    PatientAppointmentsScreen(),
    DoctorReelsScreen(),
    MessagesListScreen(),
    PatientProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1664CD),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_fill),
              label: 'Reels',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
