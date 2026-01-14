import 'package:docmobi/models/notification_model.dart';
import 'package:docmobi/providers/appointment_provider.dart';
import 'package:docmobi/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/upcoming_patient_card.dart';

class DoctorNotificationScreen extends StatefulWidget {
  const DoctorNotificationScreen({super.key});

  @override
  State<DoctorNotificationScreen> createState() =>
      _DoctorNotificationScreenState();
}

class _DoctorNotificationScreenState extends State<DoctorNotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B2C49),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B2C49),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2C49)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF1664CD)),
            tooltip: 'Mark all as read',
            onPressed: () {
              context.read<NotificationProvider>().markAllAsRead();
            },
          ),
        ],
      ),
      body: Consumer2<NotificationProvider, AppointmentProvider>(
        builder: (context, notifProvider, apptProvider, child) {
          final notifications = notifProvider.notifications;
          final unread = notifications.where((n) => !n.isRead).toList();
          final read = notifications.where((n) => n.isRead).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await apptProvider.fetchAppointments();
            },
            child: CustomScrollView(
              slivers: [
                // Upcoming Appointment Section for Doctor
                _buildUpcomingSection(apptProvider),

                // New Section
                if (unread.isNotEmpty) ...[
                  _buildSectionTitle("New"),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildDismissibleCard(unread[index]),
                        childCount: unread.length,
                      ),
                    ),
                  ),
                ],

                // Earlier Section
                if (read.isNotEmpty) ...[
                  _buildSectionTitle("Earlier"),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildDismissibleCard(read[index]),
                        childCount: read.length,
                      ),
                    ),
                  ),
                ],

                // Empty State
                if (notifications.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else if (unread.isEmpty && read.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  ),

                // Extra space at bottom
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2C49),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingSection(AppointmentProvider aptProvider) {
    final upcoming = aptProvider.upcomingAppointments;
    if (upcoming.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upcoming Patient",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2C49),
              ),
            ),
            const SizedBox(height: 15),
            UpcomingPatientCard(appointment: upcoming.first),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when a patient books or updates an appointment.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<NotificationProvider>().deleteNotification(
          notification.id,
        );
      },
      child: _buildNotificationCard(notification),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationProvider>().markAsRead(notification.id);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getNotificationColor(
                    notification.type,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2C49),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _personalizeMessage(notification),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _personalizeMessage(NotificationModel notification) {
    // Here we can further personalize the message if needed.
    // For now, we'll return the original message.
    return notification.message;
  }

  IconData _getNotificationIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('confirmed') || t.contains('accepted')) {
      return Icons.event_available;
    }
    if (t.contains('reminder')) return Icons.alarm;
    if (t.contains('message')) return Icons.chat_bubble_outline;
    if (t.contains('cancel')) return Icons.event_busy;
    return Icons.notifications_none;
  }

  Color _getNotificationColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('confirmed') || t.contains('accepted')) return Colors.green;
    if (t.contains('reminder')) return Colors.orange;
    if (t.contains('message')) return Colors.blue;
    if (t.contains('cancel')) return Colors.amber;
    return Colors.grey;
  }
}
