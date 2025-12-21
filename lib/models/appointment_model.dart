class Appointment {
  final String id;
  final String doctorName;
  final String doctorImage;
  final String specialty;
  final String date;
  final String time;
  final String status; // 'upcoming', 'completed', 'cancelled'
  final String appointmentType; // 'Physical Visit' or 'Video Call'

  Appointment({
    required this.id,
    required this.doctorName,
    required this.doctorImage,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
    required this.appointmentType,
  });
}