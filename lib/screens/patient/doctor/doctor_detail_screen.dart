import 'package:flutter/material.dart';
import 'package:docmobi/l10n/app_localizations.dart';
import 'package:docmobi/models/doctor_model.dart';
import 'package:docmobi/services/api_service.dart';
import 'package:docmobi/services/doctor_service.dart';
import 'package:docmobi/screens/patient/messages/patient_chat_screen.dart';
import 'book_appointment_screen.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  List<dynamic> _reviews = [];
  double _avgRating = 0.0;
  int _totalReviews = 0;
  Doctor? _fetchedDoctor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
    _loadDoctorReviews();
  }

  Future<void> _fetchDoctorDetails() async {
    try {
      final service = DoctorService();
      final response = await service.getDoctorById(widget.doctor.id);
      if (response['success'] == true && mounted) {
        setState(() {
          _fetchedDoctor = Doctor.fromJson(response['data']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('❌ Failed to fetch doctor details: $e');
    }
  }

  Future<void> _loadDoctorReviews() async {
    try {
      final response = await ApiService.get(
        '/api/v1/doctor-review/doctor/${widget.doctor.id}',
        requiresAuth: false,
      );

      if (response['success'] == true && response['data'] != null && mounted) {
        final data = response['data'];
        setState(() {
          _reviews = data['items'] ?? [];
          _avgRating = (data['summary']?['avgRating'] ?? 0.0).toDouble();
          _totalReviews = data['summary']?['totalReviews'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final doctor = _fetchedDoctor ?? widget.doctor; // Use fetched if available
    final bool hasVideoCall = doctor.isVideoCallAvailable;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Generic light grey background
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(context),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Header Profile
                    _buildDoctorProfileHeader(doctor, l10n, hasVideoCall),
                    
                    const SizedBox(height: 20),
                    
                    // Stats Row
                    _buildStatsRow(l10n, doctor),

                    const SizedBox(height: 24),

                    // Bio Section
                    _buildSectionTitle(l10n.bio),
                    const SizedBox(height: 8),
                    Text(
                      doctor.bio ?? "${doctor.fullName} is a senior ${doctor.specialty} with ${doctor.experience} years of experience.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info Cards (Specialty, Degree, Fees)
                    _buildInfoCards(l10n, doctor),

                    const SizedBox(height: 24),
                    
                    // Visiting Hours
                    _buildSectionTitle(l10n.visitingHours),
                    const SizedBox(height: 12),
                    _buildVisitingHoursCard(l10n, doctor),

                    const SizedBox(height: 30), // Bottom padding for scroll
                  ],
                ),
              ),
            ),
            
            // Bottom Action Bar
            _buildBottomActionBar(context, l10n, doctor),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Doctor Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildDoctorProfileHeader(Doctor doctor, AppLocalizations l10n, bool hasVideoCall) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Doctor Image with Shadow
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: doctor.image.startsWith('http')
                ? Image.network(
                    doctor.image,
                    height: 110,
                    width: 110,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    doctor.image,
                    height: 110,
                    width: 110,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(width: 20),
        // Doctor Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hasVideoCall 
                      ? const Color(0xFFE3F2FD) // Light Blue
                      : const Color(0xFFFFF3E0), // Light Orange
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasVideoCall ? l10n.videoAvailable : l10n.inPersonOnly,
                  style: TextStyle(
                    color: hasVideoCall ? const Color(0xFF1565C0) : const Color(0xFFE65100),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                doctor.fullName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                doctor.specialty,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      doctor.distance,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(AppLocalizations l10n, Doctor doctor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          icon: Icons.people,
          color: Colors.blueAccent,
          value: "500+", // Placeholder or real data if available
          label: "Patients",
        ),
        Container(width: 1, height: 40, color: Colors.grey[300]),
        _buildStatItem(
          icon: Icons.star,
          color: Colors.amber,
          value: _avgRating.toStringAsFixed(1),
          label: "Rating",
        ),
        Container(width: 1, height: 40, color: Colors.grey[300]),
        _buildStatItem(
          icon: Icons.reviews,
          color: Colors.purpleAccent,
          value: _totalReviews.toString(),
          label: "Reviews",
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoCards(AppLocalizations l10n, Doctor doctor) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            label: l10n.degree,
            value: "MBBS, MD", // Simplified for clean UI, typically valid
            icon: Icons.school,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildInfoCard(
            label: l10n.fees,
            value: "${doctor.fees?['amount'] ?? 500} ${l10n.dzd}",
            icon: Icons.monetization_on,
            color: const Color(0xFFEF5350),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitingHoursCard(AppLocalizations l10n, Doctor doctor) {
    String hoursText;
    if (doctor.weeklySchedule == null || doctor.weeklySchedule!.isEmpty) {
      hoursText = l10n.notSet;
    } else {
      List<String> activeDays = [];
      for (var schedule in doctor.weeklySchedule!) {
        if (schedule.isActive && schedule.slots.isNotEmpty) {
          activeDays.add(schedule.day.substring(0, 3));
        }
      }
      if (activeDays.isEmpty) {
        hoursText = l10n.notSet;
      } else if (activeDays.length <= 3) {
        hoursText = activeDays.join(', ');
      } else {
        hoursText = '${activeDays.first} - ${activeDays.last}';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1BEE7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_filled, color: Color(0xFF8E24AA)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hoursText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A148C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, AppLocalizations l10n, Doctor doctor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Message Button
          InkWell(
            onTap: () => _openChatWithDoctor(context),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF3F51B5),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Book Now Button
          Expanded(
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (doctor.id.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.invalidDoctor)),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookAppointmentScreen(doctor: doctor),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  l10n.bookNow,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openChatWithDoctor(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final doctorId = widget.doctor.id; // Corrected to use widget.doctor.id as starter

      if (doctorId.isEmpty) {
        if (mounted) navigator.pop();
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(l10n.doctorIdNotFound),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final result = await ApiService.createOrGetChat(userId: doctorId);

      if (mounted) navigator.pop();

      if (result['success'] == true) {
        final chatData = result['data'];
        final chatId = chatData['_id']?.toString();

        if (chatId == null || chatId.isEmpty) {
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(l10n.failedCreateChat),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final participants = chatData['participants'] as List?;
        String? doctorAvatar;

        if (participants != null) {
          final doctorParticipant = participants.firstWhere(
            (p) => p['_id'] == doctorId,
            orElse: () => null,
          );

          if (doctorParticipant != null) {
            doctorAvatar = doctorParticipant['avatar']?['url'];
          }
        }

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                chatId: chatId,
                doctorName: widget.doctor.fullName,
                doctorAvatar: doctorAvatar ??
                    (widget.doctor.image.startsWith('http')
                        ? widget.doctor.image
                        : null),
                doctorId: doctorId,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ??
                    l10n.failedOpenChat ??
                    'Failed to open chat',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        navigator.pop();
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
