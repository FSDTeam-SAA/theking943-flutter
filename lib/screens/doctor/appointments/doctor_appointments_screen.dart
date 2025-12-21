import 'package:flutter/material.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  bool isPending = true;

  final List<Map<String, dynamic>> pendingAppointments = [
    {
      'patientName': 'The King',
      'time': '10:00 AM - 10:30 AM',
      'date': 'Nov.03,2025',
      'type': 'Video Call',
      'image': 'assets/images/doctor1.png',
    },
    {
      'patientName': 'John Doe',
      'time': '11:00 AM - 11:30 AM',
      'date': 'Nov.03,2025',
      'type': 'Physical Visit',
      'image': 'assets/images/doctor2.png',
    },
    {
      'patientName': 'Jane Smith',
      'time': '02:00 PM - 02:30 PM',
      'date': 'Nov.04,2025',
      'type': 'Video Call',
      'image': 'assets/images/doctor3.png',
    },
  ];

  final List<Map<String, dynamic>> completedAppointments = [
    {
      'patientName': 'Alice Johnson',
      'time': '09:00 AM - 09:30 AM',
      'date': 'Oct.28,2025',
      'type': 'Physical Visit',
      'image': 'assets/images/profile.png',
    },
    {
      'patientName': 'Bob Wilson',
      'time': '10:00 AM - 10:30 AM',
      'date': 'Oct.27,2025',
      'type': 'Video Call',
      'image': 'assets/images/profile.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Appointments',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Tab Buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPending = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isPending ? const Color(0xFF4A7BF7) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPending ? const Color(0xFF4A7BF7) : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Text(
                        'Pending (${pendingAppointments.length})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isPending ? Colors.white : const Color(0xFF666666),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPending = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isPending ? const Color(0xFF4A7BF7) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: !isPending ? const Color(0xFF4A7BF7) : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Text(
                        'Completed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !isPending ? Colors.white : const Color(0xFF666666),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Appointments List
          Expanded(
            child: _buildAppointmentsList(
              isPending ? pendingAppointments : completedAppointments,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<Map<String, dynamic>> appointments) {
    if (appointments.isEmpty) {
      return const Center(
        child: Text(
          'No appointments found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(appointments[index]);
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Patient Image
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(appointment['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Patient Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['patientName'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment['type'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              if (isPending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFA726),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4F4DD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF27AE60),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Info Row
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                appointment['date'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time_outlined, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                appointment['time'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showConfirmDialog(context, 'Accept', appointment['patientName']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showConfirmDialog(context, 'Reject', appointment['patientName']);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCC304C), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        color: Color(0xFFCC304C),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, String action, String patientName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          '$action Appointment',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to $action appointment with $patientName?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF666666),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Appointment ${action.toLowerCase()}ed successfully'),
                  backgroundColor: action == 'Accept' ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                ),
              );
            },
            child: Text(
              action,
              style: TextStyle(
                color: action == 'Accept' ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}