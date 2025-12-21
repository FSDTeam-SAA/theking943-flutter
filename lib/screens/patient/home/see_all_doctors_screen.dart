import 'package:flutter/material.dart';
import 'package:docmobi/models/doctor_model.dart';
import 'package:docmobi/widgets/doctor_card.dart';

class SeeAllDoctorsScreen extends StatefulWidget {
  const SeeAllDoctorsScreen({super.key});

  @override
  State<SeeAllDoctorsScreen> createState() => _SeeAllDoctorsScreenState();
}

class _SeeAllDoctorsScreenState extends State<SeeAllDoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Doctor> allDoctors = List.generate(
    10,
    (index) => Doctor(
      id: '$index',
      name: 'Dr. Jaynor Abedin',
      specialty: 'Pediatric Surgery',
      hospital: 'Salemn Hospital',
      image: 'assets/images/doctor_booking.png',
      rating: 4.8,
      distance: '${index + 2}.${index}km',
      experience: 10,
      degree: 'MBBS, MD',
      isAvailable: index % 2 == 0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: const Color(0xFFE5EEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5EEFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B3267)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Doctor\'s',
          style: TextStyle(
            color: Color(0xFF0B3267),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
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
          ),
          // Doctors List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: allDoctors.length,
              itemBuilder: (context, index) {
                return DoctorCard(
                  doctor: allDoctors[index],
                  onTap: () {
                    // Navigate to doctor detail
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}