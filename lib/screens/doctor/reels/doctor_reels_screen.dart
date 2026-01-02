import 'package:flutter/material.dart';
import 'package:docmobi/screens/doctor/navigation/doctor_main_navigation.dart';

class DoctorReelsScreen extends StatefulWidget {
  const DoctorReelsScreen({super.key});

  @override
  State<DoctorReelsScreen> createState() => _DoctorReelsScreenState();
}

class _DoctorReelsScreenState extends State<DoctorReelsScreen> {
  final List<Map<String, dynamic>> reelsList = [
    {'thumbnail': 'assets/images/doctor1.png', 'doctorName': 'Dr. Jaynor Abedin', 'specialty': 'Pediatric Surgery'},
    {'thumbnail': 'assets/images/doctor2.png', 'doctorName': 'Dr. Sarah Johnson', 'specialty': 'Cardiologist'},
    {'thumbnail': 'assets/images/doctor3.png', 'doctorName': 'Dr. Michael Chen', 'specialty': 'Dermatologist'},
    {'thumbnail': 'assets/images/doctor4.png', 'doctorName': 'Dr. Emily White', 'specialty': 'Neurologist'},
    {'thumbnail': 'assets/images/doctor5.png', 'doctorName': 'Dr. David Brown', 'specialty': 'Orthopedic'},
    {'thumbnail': 'assets/images/doctor1.png', 'doctorName': 'Dr. Jaynor Abedin', 'specialty': 'Pediatric Surgery'},
    {'thumbnail': 'assets/images/doctor4.png', 'doctorName': 'Dr. Emily White', 'specialty': 'Neurologist'},
    {'thumbnail': 'assets/images/doctor2.png', 'doctorName': 'Dr. Sarah Johnson', 'specialty': 'Cardiologist'},
    {'thumbnail': 'assets/images/doctor3.png', 'doctorName': 'Dr. Michael Chen', 'specialty': 'Dermatologist'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () {
          
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DoctorMainNavigation()),
                (route) => false,
              );
            }
          },
        ),
        title: const Text(
          'Reels',
          style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: reelsList.length,
          itemBuilder: (context, index) {
            return _buildReelThumbnail(reelsList[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildReelThumbnail(Map<String, dynamic> reel, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReelsViewerScreen(reelsList: reelsList, initialIndex: index),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(reel['thumbnail'], fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              const Center(child: Icon(Icons.play_circle_outline, color: Colors.white, size: 50)),
              Positioned(
                left: 10, right: 10, bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reel['doctorName'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(reel['specialty'], style: const TextStyle(color: Colors.white, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReelsViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> reelsList;
  final int initialIndex;

  const ReelsViewerScreen({super.key, required this.reelsList, required this.initialIndex});

  @override
  State<ReelsViewerScreen> createState() => _ReelsViewerScreenState();
}

class _ReelsViewerScreenState extends State<ReelsViewerScreen> {
  late PageController _pageController;
  late int currentPage;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.reelsList.length,
        onPageChanged: (index) => setState(() => currentPage = index),
        itemBuilder: (context, index) => _buildReelPage(widget.reelsList[index]),
      ),
    );
  }

  Widget _buildReelPage(Map<String, dynamic> reel) {
    return Stack(
      children: [
        // Background
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/reelsviewdoctor.png'), fit: BoxFit.cover),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)]),
            ),
          ),
        ),
        // ফিক্সড ব্যাক বাটন
        Positioned(
          top: 50,
          left: 16,
          child: SafeArea(
            child: GestureDetector(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const DoctorMainNavigation()),
                    (route) => false,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
        // Actions
        Positioned(
          right: 12, bottom: 120,
          child: Column(
            children: [
              _buildActionButton(Icons.favorite_border, '1.2K', () {}),
              const SizedBox(height: 25),
              _buildActionButton(Icons.chat_bubble_outline, '234', () {}),
              const SizedBox(height: 25),
              _buildActionButton(Icons.share_outlined, 'Share', () {}),
              const SizedBox(height: 25),
              Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), image: DecorationImage(image: AssetImage(reel['thumbnail']), fit: BoxFit.cover))),
            ],
          ),
        ),
        // Doctor Info
        Positioned(
          left: 16, right: 80, bottom: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), image: DecorationImage(image: AssetImage(reel['thumbnail']), fit: BoxFit.cover))),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reel['doctorName'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(reel['specialty'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Health tips and medical advice 🩺\n#HealthTips #MedicalAdvice', style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 26)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}