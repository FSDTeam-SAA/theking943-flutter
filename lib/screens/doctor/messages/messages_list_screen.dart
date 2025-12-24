import 'package:flutter/material.dart';
import 'package:docmobi/screens/doctor/messages/chat_screen.dart';
import 'package:docmobi/screens/doctor/home/doctor_home_screen.dart';

class DoctorMessagesScreen extends StatefulWidget {
  const DoctorMessagesScreen({super.key});

  @override
  State<DoctorMessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<DoctorMessagesScreen> {
  String selectedTab = "Doctors";

  final List<Map<String, String>> doctorChats = List.generate(8, (index) => {
        "name": "Dr. Joynal Abedin",
        "message": "Hi, how can I help you",
        "time": "5:40 am",
        "image": "assets/images/doctor1.png"
      });

  final List<Map<String, String>> patientChats = [
    {
      "name": "Patient Name Example",
      "message": "I need an appointment",
      "time": "9:00 am",
      "image": "assets/images/doctor1.png"
    },
  ];

  // ব্যাক বাটন হ্যান্ডলার
  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // যদি stack-এ আর কোনো পেজ না থাকে, তবে Home এ পাঠিয়ে দিবে।
      // pushReplacement এর বদলে pushAndRemoveUntil ব্যবহার করা নিরাপদ যাতে আগের সব রুট ক্লিয়ার হয়
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentChats = selectedTab == "Doctors" ? doctorChats : patientChats;

    // WillPopScope এর বদলে নতুন PopScope ব্যবহার করা হয়েছে (Flutter 3.12+)
    return PopScope(
      canPop: false, // ম্যানুয়ালি হ্যান্ডেল করার জন্য false
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => _handleBack(context),
          ),
          title: const Text(
            "Messages",
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            // Tab Selection Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F0FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTabButton("Doctors"),
                    _buildTabButton("Patient"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Chat List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: currentChats.length,
                itemBuilder: (context, index) {
                  return _buildChatItem(currentChats[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title) {
    final isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = title),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E61D4) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF1B2C49),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatItem(Map<String, String> chat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell( // GestureDetector এর বদলে InkWell দিলে ক্লিক ইফেক্ট সুন্দর হয়
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorChatDetailScreen(doctorName: chat["name"]!),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  chat["image"]!,
                  height: 56,
                  width: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.account_circle, size: 56), // ইমেজ না থাকলে আইকন দেখাবে
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat["name"]!,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2C49),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat["message"]!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                chat["time"]!,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}