import 'package:flutter/material.dart';
import 'package:docmobi/models/message_model.dart';
import 'package:docmobi/screens/patient/messages/chat_screen.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Message> messages = [
      Message(
        id: '1',
        doctorName: 'Dr. Jaynor Abedin',
        doctorImage: 'assets/images/doctor1.png',
        lastMessage: 'Thank you for your visit',
        time: '6:45am',
        isRead: false,
      ),
      Message(
        id: '2',
        doctorName: 'Dr. Jaynor Abedin',
        doctorImage: 'assets/images/doctor2.png',
        lastMessage: 'Your prescription is ready',
        time: '6:45am',
        isRead: true,
      ),
      Message(
        id: '3',
        doctorName: 'Dr. Jaynor Abedin',
        doctorImage: 'assets/images/doctor3.png',
        lastMessage: 'Please take your medicine',
        time: '6:45am',
        isRead: true,
      ),
      Message(
        id: '4',
        doctorName: 'Dr. Jaynor Abedin',
        doctorImage: 'assets/images/doctor4.png',
        lastMessage: 'See you next week',
        time: '6:45am',
        isRead: true,
      ),
      Message(
        id: '5',
        doctorName: 'Dr. Jaynor Abedin',
        doctorImage: 'assets/images/doctor5.png',
        lastMessage: 'How are you feeling today?',
        time: '6:45am',
        isRead: true,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE5EEFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Doctor\'s Messages',
          style: TextStyle(
            color: Color(0xFF0B3267),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return _buildMessageCard(context, messages[index]);
        },
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context, Message message) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              doctorName: message.doctorName,
              doctorImage: message.doctorImage,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(message.doctorImage),
                ),
                if (!message.isRead)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.doctorName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                      color: const Color(0xFF0B3267),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message.lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              message.time,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}