import 'package:flutter/material.dart';

class DoctorPersonalInfoScreen extends StatefulWidget {
  const DoctorPersonalInfoScreen({super.key});

  @override
  State<DoctorPersonalInfoScreen> createState() => _DoctorPersonalInfoScreenState();
}

class _DoctorPersonalInfoScreenState extends State<DoctorPersonalInfoScreen> {

  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(text: 'Dr. The King');
  final TextEditingController _specialtyController = TextEditingController(text: 'Specialty');
  final TextEditingController _degreeController = TextEditingController(text: 'Degree');
  final TextEditingController _emailController = TextEditingController(text: 'example@gmail.com');
  final TextEditingController _addressController = TextEditingController(text: 'Keim - Germany');
  final TextEditingController _phoneController = TextEditingController(text: 'Phone Number');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // ডিজাইনের হালকা নীল ব্যাকগ্রাউন্ড
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2C49)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: const [
            Text(
              'Personal Info',
              style: TextStyle(
                color: Color(0xFF1B2C49),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Edit Your Profile',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- প্রোফাইল পিকচার সেকশন (কার্ড স্টাইল) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F0FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    'Profile Picture',
                    style: TextStyle(
                      color: Color(0xFF1B2C49),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/doctor_booking.png'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                            color: Color(0xFF1B2C49),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap to Change your Profile Picture',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- বায়ো সেকশন ---
            const Text(
              'Add Bio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2C49),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F0FF),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFB3CEFF)),
              ),
            child: TextField(
                controller: _bioController,
                maxLines: 3,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1B2C49)),
                decoration: const InputDecoration(
                  // এখানে টেক্সটটি হিন্ট হিসেবে দেওয়া হয়েছে
                  hintText: 'Dr. Joynal Abedin is a senior Podiatric surgery at xyz Hospital over a years of Experiance...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- ব্যক্তিগত তথ্যের তালিকা ---
            _buildInfoCard(icon: Icons.person_outline, controller: _nameController),
            _buildInfoCard(icon: Icons.person_search_outlined, controller: _specialtyController),
            _buildInfoCard(icon: Icons.school_outlined, controller: _degreeController),
            _buildInfoCard(icon: Icons.email_outlined, controller: _emailController),
            _buildInfoCard(icon: Icons.location_on_outlined, controller: _addressController),
            _buildInfoCard(icon: Icons.phone_outlined, controller: _phoneController),
            
            // পাসওয়ার্ড পরিবর্তনের অপশন হিসেবে একটি কাস্টম কার্ড
            _buildInfoCard(
              icon: Icons.lock_outline, 
              controller: TextEditingController(text: 'Change Password'),
            ),
            
            _buildInfoCard(icon: Icons.location_on_outlined, controller: _addressController),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ডিজাইন অনুযায়ী কার্ড স্টাইল ফিল্ড তৈরি করার মেথড
  Widget _buildInfoCard({required IconData icon, required TextEditingController controller}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1B2C49), size: 22),
        ),
        title: TextField(
          controller: controller,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1B2C49),
            fontWeight: FontWeight.w500,
          ),
          decoration: const InputDecoration(border: InputBorder.none),
        ),
        trailing: const Icon(
          Icons.edit_outlined,
          color: Color(0xFF1B2C49),
          size: 20,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialtyController.dispose();
    _degreeController.dispose();
    super.dispose();
  }
}