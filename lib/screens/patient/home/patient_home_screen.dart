import 'package:flutter/material.dart';
import 'package:docmobi/models/doctor_model.dart';
import 'package:docmobi/widgets/doctor_card.dart';
import 'package:docmobi/screens/patient/home/see_all_doctors_screen.dart';
import 'package:docmobi/screens/patient/notification/notification_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showLocationDialog = true;


  final List<Doctor> nearbyDoctors = [
    Doctor(
      id: '1',
      name: 'Dr. Jaynor Abedin',
      specialty: 'Pediatric Surgery',
      hospital: 'Salemn Hospital',
      image: 'assets/images/doctor_booking.png',
      rating: 4.8,
      distance: '2.5km',
      experience: 10,
      degree: 'MBBS, MD',
      isAvailable: true,
    ),
    Doctor(
      id: '2',
      name: 'Dr. Jaynor Abedin',
      specialty: 'Pediatric Surgery',
      hospital: 'Salemn Hospital',
      image: 'assets/images/doctor_booking.png',
      rating: 4.8,
      distance: '3.1km',
      experience: 10,
      degree: 'MBBS, MD',
      isAvailable: true,
    ),
    Doctor(
      id: '3',
      name: 'Dr. Jaynor Abedin',
      specialty: 'Pediatric Surgery',
      hospital: 'Salemn Hospital',
      image: 'assets/images/doctor_booking.png',
      rating: 4.8,
      distance: '4.2km',
      experience: 10,
      degree: 'MBBS, MD',
      isAvailable: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: const Color(0xFFE5EEFF),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  color: const Color(0xFFE5EEFF),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage('assets/images/profile.png'),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'The king',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B3267),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 14, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(
                                      'Keim - Germany',
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, size: 28),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Search bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search Doctor...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                // Map and Doctors List
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Map
                        Container(
                          height: 200,
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  'assets/images/map.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Center(
                                child: Icon(
                                  Icons.location_on,
                                  size: 50,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Nearby Doctors
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Nearby Doctors',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B3267),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SeeAllDoctorsScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'See All',
                                  style: TextStyle(
                                    color: Color(0xFF1664CD),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Doctors List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: nearbyDoctors.length,
                          itemBuilder: (context, index) {
                            return DoctorCard(
                              doctor: nearbyDoctors[index],
                              onTap: () {
                                // Navigate to doctor detail
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Location Dialog
            if (_showLocationDialog)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(30),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 80,
                          color: Color(0xFF1664CD),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Allow Mapps to access this device\'s precise location?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B3267),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _showLocationDialog = false;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF1664CD)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  'Precise',
                                  style: TextStyle(
                                    color: Color(0xFF1664CD),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0B3267), Color(0xFF1664CD)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showLocationDialog = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text(
                                    'Approximate',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showLocationDialog = false;
                            });
                          },
                          child: const Text(
                            'While using the app',
                            style: TextStyle(
                              color: Color(0xFF1664CD),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showLocationDialog = false;
                            });
                          },
                          child: const Text(
                            'Only this time',
                            style: TextStyle(
                              color: Color(0xFF1664CD),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showLocationDialog = false;
                            });
                          },
                          child: const Text(
                            'Don\'t allow',
                            style: TextStyle(
                              color: Color(0xFF1664CD),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
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