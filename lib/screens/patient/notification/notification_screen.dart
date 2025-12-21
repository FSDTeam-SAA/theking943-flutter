import 'package:flutter/material.dart';
import 'package:docmobi/models/notification_model.dart';
import 'package:docmobi/widgets/notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<NotificationModel> newNotifications = [
    NotificationModel(
      id: '1',
      title: 'Appointment Confirmed',
      message: 'Your appointment with Dr. Jaynor Abedin is confirmed for tomorrow at 9:00 AM',
      time: '3 hours ago',
      type: 'appointment',
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      title: 'Appointment Reminder',
      message: 'You have an appointment with Dr. Karem Alennsoy in 1hour',
      time: '5 minutes ago',
      type: 'reminder',
      isRead: false,
    ),
    NotificationModel(
      id: '3',
      title: 'New Message',
      message: 'Dr. Lena Kozlow sent you a message about your treatment',
      time: '1 hour ago',
      type: 'message',
      isRead: false,
    ),
  ];

  final List<NotificationModel> earlierNotifications = [
    NotificationModel(
      id: '4',
      title: 'Appointment Confirmed',
      message: 'Your appointment with Dr. Jaynor Abedin is confirmed for tomorrow at 9:00 AM',
      time: '2 days ago',
      type: 'appointment',
      isRead: true,
    ),
    NotificationModel(
      id: '5',
      title: 'Appointment Reminder',
      message: 'You have an appointment with Dr. Karem Alennsoy in 1hour',
      time: '3 minutes ago',
      type: 'reminder',
      isRead: true,
    ),
    NotificationModel(
      id: '6',
      title: 'New Message',
      message: 'Dr. Lena Kozlow sent you a message about your treatment',
      time: '1 hour ago',
      type: 'message',
      isRead: true,
    ),
    NotificationModel(
      id: '7',
      title: 'Appointment Cancel',
      message: 'Your appointment with Dr. Jaynor Abedin has been cancelled by the doctor is unexpected',
      time: '5 hours ago',
      type: 'appointment',
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          'Notification',
          style: TextStyle(
            color: Color(0xFF0B3267),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1664CD),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1664CD),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'New'),
            Tab(text: 'Earlier'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // New Notifications
          ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: newNotifications.length,
            itemBuilder: (context, index) {
              return NotificationCard(notification: newNotifications[index]);
            },
          ),
          // Earlier Notifications
          ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: earlierNotifications.length,
            itemBuilder: (context, index) {
              return NotificationCard(notification: earlierNotifications[index]);
            },
          ),
        ],
      ),
    );
  }
}