import 'package:flutter/material.dart';
import 'package:docmobi/models/doctor_model.dart';
import 'package:docmobi/widgets/doctor_card.dart';

class SearchDoctorScreen extends StatefulWidget {
  const SearchDoctorScreen({super.key});

  @override
  State<SearchDoctorScreen> createState() => _SearchDoctorScreenState();
}

class _SearchDoctorScreenState extends State<SearchDoctorScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Doctor> searchResults = [];
  bool isSearching = false;

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

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchResults = allDoctors
          .where((doctor) =>
              doctor.name.toLowerCase().contains(query.toLowerCase()) ||
              doctor.specialty.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

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
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _performSearch,
          decoration: const InputDecoration(
            hintText: 'Search doctors...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: isSearching
          ? searchResults.isEmpty
              ? const Center(
                  child: Text(
                    'No doctors found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    return DoctorCard(
                      doctor: searchResults[index],
                      onTap: () {
                        // Navigate to doctor detail
                      },
                    );
                  },
                )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'Search for doctors',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
    );
  }
}