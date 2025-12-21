import 'package:flutter/material.dart';

class DoctorPersonalInfoScreen extends StatefulWidget {
  const DoctorPersonalInfoScreen({super.key});

  @override
  State<DoctorPersonalInfoScreen> createState() => _DoctorPersonalInfoScreenState();
}

class _DoctorPersonalInfoScreenState extends State<DoctorPersonalInfoScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Dr. The King');
  final TextEditingController _emailController = TextEditingController(text: 'example@gmail.com');
  final TextEditingController _phoneController = TextEditingController(text: 'Phone Number');
  final TextEditingController _specialtyController = TextEditingController(text: 'Pediatric Surgery');
  final TextEditingController _degreeController = TextEditingController(text: 'MBBS, MD');
  final TextEditingController _experienceController = TextEditingController(text: '10 years');
  final TextEditingController _hospitalController = TextEditingController(text: 'Salem Hospital');
  final TextEditingController _addressController = TextEditingController(text: 'Keim - Germany');

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/doctor_booking.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Image picker coming soon'),
                          ),
                        );
                      },
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Tap to Change your Picture',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Profile Picture Section Title
            const Text(
              'Profile Picture',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3267),
              ),
            ),
            const SizedBox(height: 20),
            
            // Name Field
            _buildInfoField(
              icon: Icons.person_outline,
              controller: _nameController,
              label: 'Full Name',
            ),
            const SizedBox(height: 20),
            
            // Email Field
            _buildInfoField(
              icon: Icons.email_outlined,
              controller: _emailController,
              label: 'Email',
            ),
            const SizedBox(height: 20),
            
            // Phone Field
            _buildInfoField(
              icon: Icons.phone_outlined,
              controller: _phoneController,
              label: 'Phone Number',
            ),
            const SizedBox(height: 20),
            
            // Specialty Field
            _buildInfoField(
              icon: Icons.medical_services_outlined,
              controller: _specialtyController,
              label: 'Specialty',
            ),
            const SizedBox(height: 20),
            
            // Degree Field
            _buildInfoField(
              icon: Icons.school_outlined,
              controller: _degreeController,
              label: 'Degree',
            ),
            const SizedBox(height: 20),
            
            // Experience Field
            _buildInfoField(
              icon: Icons.work_outline,
              controller: _experienceController,
              label: 'Experience',
            ),
            const SizedBox(height: 20),
            
            // Hospital Field
            _buildInfoField(
              icon: Icons.local_hospital_outlined,
              controller: _hospitalController,
              label: 'Hospital',
            ),
            const SizedBox(height: 20),
            
            // Address Field
            _buildInfoField(
              icon: Icons.location_on_outlined,
              controller: _addressController,
              label: 'Address',
            ),
            const SizedBox(height: 30),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B3267), Color(0xFF1664CD)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully'),
                        backgroundColor: Color(0xFF27AE60),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required TextEditingController controller,
    required String label,
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
    _specialtyController.dispose();
    _degreeController.dispose();
    _experienceController.dispose();
    _hospitalController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
