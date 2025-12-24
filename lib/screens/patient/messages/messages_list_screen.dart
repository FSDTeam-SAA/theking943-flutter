import 'package:flutter/material.dart';
import 'package:docmobi/screens/patient/messages/chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  // এই ফাংশনটি আপনাকে হোম স্ক্রিনে নিয়ে যাবে
  void _goBackToHome(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // সাধারণ ব্যাক করার জন্য
    } else {
      // যদি সরাসরি এই পেজে আসেন, তবে রুট ক্লিয়ার করে হোমে যাবে
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // সিস্টেম ব্যাক বাটন আমরা নিজে হ্যান্ডেল করব
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBackToHome(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => _goBackToHome(context), // Appbar এর ব্যাক বাটন
          ),
          title: const Text(
            "Doctor’s Messages",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell( // GestureDetector এর বদলে InkWell দিলে ক্লিক ইফেক্ট পাওয়া যায়
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatDetailScreen(
                        doctorName: "Dr. Joynal Abedin",
                      ),
                    ),
                  );
                },
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
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 56,
                          width: 56,
                          color: Colors.grey[300], // ইমেজ লোড না হলে কালার দেখাবে
                          child: Image.asset(
                            "assets/images/doctor1.png",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                               const Icon(Icons.person), // ইমেজ না থাকলে আইকন
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dr. Joynal Abedin",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B2C49),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Hi, how can I help you",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        "10:30am",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}