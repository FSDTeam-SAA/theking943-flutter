import 'package:flutter/material.dart';
import 'package:docmobi/models/doctor_model.dart';
import 'book_appointment_screen.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header: Image, Info and Close Button ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      doctor.image,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontSize: 26, // ছবির মতো বড় ফন্ট
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          doctor.specialty,
                          style: const TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.videocam_outlined, size: 20, color: Colors.black),
                            SizedBox(width: 5),
                            Text("Video Consultation", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 20, color: Colors.orange),
                            Text(
                              " ${doctor.rating}(120 reviews)",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.location_on, size: 20, color: Colors.black),
                            Text(" ${doctor.distance}", style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 35, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // --- Bio Section ---
              const Text(
                "Bio",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "${doctor.name} is a senior ${doctor.specialty} at  xyz Hospital over a years of Experiance...",
                style: const TextStyle(fontSize: 17, color: Colors.black, height: 1.3),
              ),

              const SizedBox(height: 30),

              // --- Specialty & Degree Section (এটাই মূল পরিবর্তন) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // দুইটিকে দুই পাশে ঠেলে দেবে
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // বাম পাশে Specialty
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Specialty",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildBulletItem(doctor.specialty),
                      _buildBulletItem("Medicine"),
                    ],
                  ),
                  // ডান পাশে Degree
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // টেক্সটগুলো ডানে শুরু হবে
                    children: [
                      const Text(
                        "Degree",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      // আপনার ইমেজ অনুযায়ী ডাটা এলাইনমেন্ট
                      ...doctor.degree.split(',').map((d) => _buildBulletItem(d.trim())).toList(),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // --- Fees & Visiting Hours ---
              Text(
                "Fees: 10.50\$",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Text(
                "Visiting Hours: Sun-Thu",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const Spacer(),

              // --- Book Now Button ---
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookAppointmentScreen(doctor: doctor),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D53C1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Book Now",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // একদম আপনার ইমেজের মতো ডট সহ লিস্ট আইটেম
  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("• ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
            text,
            style: const TextStyle(fontSize: 17, color: Colors.black),
          ),
        ],
      ),
    );
  }
}