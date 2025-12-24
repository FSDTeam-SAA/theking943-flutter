import 'package:flutter/material.dart';
import 'package:docmobi/screens/patient/notification/notification_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // হালকা ব্যাকগ্রাউন্ড
      body: SafeArea(
        child: Column(
          children: [
            // --- Header (Same as Screenshot) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/images/doctor_booking.png'),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr.The king',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2C49),
                          ),
                        ),
                        Text(
                          'Podiatric Surgery',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  _buildHeaderIcon(Icons.search),
                  const SizedBox(width: 10),
                  _buildHeaderIcon(Icons.notifications_outlined, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                  }),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // --- Post Creation Box ---
                    _buildCreatePostBox(),

                    // --- Social Feed List ---
                    _buildSocialPost(
                      'Dr. Joynal Abedin',
                      '16h ago',
                      'A core principle of patient centered and compassionate care',
                      'assets/images/news.png', // আপনার ইমেজ পাথ
                      '792', '792', '12',
                    ),
                    _buildSocialPost(
                      'Dr. Joynal Abedin',
                      '16h ago',
                      'A core principle of patient centered and compassionate care',
                      'assets/images/news.png',
                      '792', '792', '12',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE9F1FF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF1B2C49), size: 24),
      ),
    );
  }

  Widget _buildCreatePostBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/doctor.png'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8FF),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    'Share your insights with follow doctors...',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPostAction(Icons.image_outlined, 'Photo', Colors.brown),
              _buildPostAction(Icons.videocam_outlined, 'Video', Colors.black87),
              _buildPostAction(Icons.play_circle_outline, 'Reels', Colors.black87),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF1664CD)),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Creat a Post', style: TextStyle(color: Color(0xFF1664CD), fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostAction(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSocialPost(String name, String time, String content, String image, String likes, String comments, String shares) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage('assets/images/doctor.png'),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(image, fit: BoxFit.cover, width: double.infinity, height: 200),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildStatChip(Icons.thumb_up_alt_outlined, likes),
              const SizedBox(width: 10),
              _buildStatChip(Icons.chat_bubble_outline, comments),
              const Spacer(),
              _buildStatChip(Icons.share_outlined, shares, isShare: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String count, {bool isShare = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1B2C49)),
          const SizedBox(width: 4),
          Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}