import 'package:flutter/material.dart';
import 'package:docmobi/models/appointment_model.dart';
import 'package:docmobi/screens/patient/appointments/appointment_detail_screen.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> {
  bool isUpcoming = true;

  final List<Appointment> upcomingAppointments = [
    Appointment(
      id: '1',
      doctorName: 'Dr. Jaynor Abedin',
      doctorImage: 'assets/images/doctor_booking.png',
      specialty: 'Pediatric Surgery',
      date: 'Nov.03,2025',
      time: '10:30 am',
      status: 'upcoming',
      appointmentType: 'Physical',
    ),
    Appointment(
      id: '2',
      doctorName: 'Dr. Jaynor Abedin',
      doctorImage: 'assets/images/doctor_booking.png',
      specialty: 'Pediatric Surgery',
      date: 'Nov.03,2025',
      time: '10:30 am',
      status: 'upcoming',
      appointmentType: 'Video',
    ),
    Appointment(
      id: '3',
      doctorName: 'Dr. Jaynor Abedin',
      doctorImage: 'assets/images/doctor_booking.png',
      specialty: 'Pediatric Surgery',
      date: 'Nov.03,2025',
      time: '10:30 am',
      status: 'upcoming',
      appointmentType: 'Video',
    ),
  ];

  final List<Appointment> completedAppointments = [
    Appointment(
      id: '4',
      doctorName: 'Dr. Jaynor Abedin',
      doctorImage: 'assets/images/doctor_booking.png',
      specialty: 'Pediatric Surgery',
      date: 'Nov.03,2025',
      time: '10:30 am',
      status: 'completed',
      appointmentType: 'Physical',
    ),
    Appointment(
      id: '5',
      doctorName: 'Dr. Jaynor Abedin',
      doctorImage: 'assets/images/doctor_booking.png',
      specialty: 'Pediatric Surgery',
      date: 'Nov.03,2025',
      time: '10:30 am',
      status: 'completed',
      appointmentType: 'Physical',
    ),
    Appointment(
      id: '6',
      doctorName: 'Dr. Jaynor Abedin',
      doctorImage: 'assets/images/doctor_booking.png',
      specialty: 'Pediatric Surgery',
      date: 'Nov.03,2025',
      time: '10:30 am',
      status: 'completed',
      appointmentType: 'Physical',
    ),
    Appointment(
      id: '7',
      doctorName: 'Dr. Jaynor Abedin',
      doctorImage: 'assets/images/doctor_booking.png',
      specialty: 'Pediatric Surgery',
      date: 'Nov.03,2025',
      time: '10:30 am',
      status: 'completed',
      appointmentType: 'Physical',
    ),
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
          'My Appointment',
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
                        isUpcoming = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isUpcoming ? const Color(0xFF4A7BF7) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isUpcoming ? const Color(0xFF4A7BF7) : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Text(
                        'Up Coming(02)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isUpcoming ? Colors.white : const Color(0xFF666666),
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
                        isUpcoming = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isUpcoming ? const Color(0xFF4A7BF7) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: !isUpcoming ? const Color(0xFF4A7BF7) : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Text(
                        'Completed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !isUpcoming ? Colors.white : const Color(0xFF666666),
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
              isUpcoming ? upcomingAppointments : completedAppointments,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
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

  Widget _buildAppointmentCard(Appointment appointment) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentDetailScreen(appointment: appointment),
          ),
        );
      },
      child: Container(
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
                // Doctor Image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/doctor_booking.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.specialty,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: appointment.status == 'completed'
                        ? const Color(0xFFD4F4DD)
                        : const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    appointment.status == 'completed' ? 'Completed' : 'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: appointment.status == 'completed'
                          ? const Color(0xFF27AE60)
                          : const Color(0xFFFFA726),
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
                  appointment.date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time_outlined, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  appointment.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  appointment.appointmentType == 'Video'
                      ? Icons.videocam_outlined
                      : Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  appointment.appointmentType,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            if (appointment.status == 'upcoming') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Reschedule
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4A7BF7), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Reschedule',
                        style: TextStyle(
                          color: Color(0xFF4A7BF7),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showCancelDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC304C),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Cancel Appointment',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'No',
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
                const SnackBar(
                  content: Text('Appointment cancelled successfully'),
                  backgroundColor: Color(0xFFE74C3C),
                ),
              );
            },
            child: const Text(
              'Yes',
              style: TextStyle(
                color: Color(0xFFE74C3C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}