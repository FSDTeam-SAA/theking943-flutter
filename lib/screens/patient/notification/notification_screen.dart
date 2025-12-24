import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // স্বচ্ছ থেকে সাদা করা হয়েছে স্পষ্টতার জন্য
        elevation: 0,
        centerTitle: true,
        // --- ব্যাক বাটন ফিক্স করা হয়েছে ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B3267)),
          onPressed: () {
            Navigator.pop(context); // এটি আপনাকে আগের পেজে ফিরিয়ে নিয়ে যাবে
          },
        ),
        title: const Text(
          "Notification",
          style: TextStyle(
            color: Color(0xFF0B3267), 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          const Text(
            "New",
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2C49),
            ),
          ),
          const SizedBox(height: 15),
          _buildNotifyCard(
            "Appointment Confirmed",
            "Your appointment with Dr. Joynal Abedin is confirmed for tomorrow at 10:30 AM",
            "2 hours ago",
            Colors.green,
            Icons.event_available,
          ),
          _buildNotifyCard(
            "Appointment Reminder",
            "You have an appointment with Dr. Karim Mansouri in 1 hour",
            "30 minutes ago",
            Colors.orange,
            Icons.notifications_none,
          ),
          _buildNotifyCard(
            "New Message",
            "Dr. Leila Kaddour sent you a message about your treatment",
            "2 hours ago",
            Colors.blue,
            Icons.chat_bubble_outline,
          ),
          _buildNotifyCard(
            "Appointment Cancel",
            "Your appointment with Dr. Joynal Abedin has been cancelled as the doctor is unavailable.",
            "2 hours ago",
            Colors.red, // Cancel এর জন্য Red বেশি উপযোগী
            Icons.event_busy,
          ),
          const SizedBox(height: 20),
          const Text(
            "Earlier",
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2C49),
            ),
          ),
          const SizedBox(height: 15),
          _buildNotifyCard(
            "Appointment Confirmed",
            "Your appointment with Dr. Joynal Abedin is confirmed for yesterday at 10:30 AM",
            "1 day ago",
            Colors.green,
            Icons.event_available,
          ),
        ],
      ),
    );
  }

  Widget _buildNotifyCard(
    String title,
    String desc,
    String time,
    Color iconColor,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.03)), // হালকা বর্ডার যোগ করা হয়েছে
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2C49),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7), 
                    fontSize: 13,
                    height: 1.4, // লাইন হাইট বাড়ানো হয়েছে পড়ার সুবিধার জন্য
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}