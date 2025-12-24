import 'package:flutter/material.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  String selectedTab = "Confirmed"; // শুরুতে Confirmed ট্যাব সিলেক্ট করা থাকবে যাতে আপনি বাটন চেক করতে পারেন

  final List<Map<String, dynamic>> appointments = [
    {
      'name': 'Bessie Cooper',
      'date': 'Nov25,2025',
      'time': '10:30 am',
      'duration': '30min',
      'type': 'Physical', // এটার জন্য Mark as Completed দেখাবে
      'price': '20 DZD',
      'image': 'assets/images/doctor1.png',
    },
    {
      'name': 'Kristin Watson',
      'date': 'Nov25,2025',
      'time': '10:30 am',
      'duration': '30min',
      'type': 'Video', // এটার জন্য Start Session দেখাবে
      'price': '20 DZD',
      'image': 'assets/images/doctor2.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFF),
        elevation: 0,
        // --- ব্যাক বাটন ফিক্স ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // যদি মেমরিতে আগের স্ক্রিন থাকে তবে পপ করবে
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // যদি আপনি সরাসরি এই স্ক্রিন রান করেন, তবে এটি প্রিন্ট হবে
              debugPrint("No screen to go back to");
            }
          },
        ),
        title: const Text(
          'Appointment Management',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Manage your Video and physical\nConsultations",
              style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
            ),
          ),
          const SizedBox(height: 20),
          
          // --- Tab Bar ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabButton("Pending"),
                _buildTabButton("Confirmed"),
                _buildTabButton("Completed"),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider()),

          // Export PDF (Only for Completed)
          if (selectedTab == "Completed")
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 10),
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text("Export Pdf"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1664CD),
                    side: const BorderSide(color: Color(0xFF1664CD)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final data = appointments[index];
                
                if (selectedTab == "Pending") {
                  return _buildPendingCard(data);
                } else if (selectedTab == "Confirmed") {
                  return _buildConfirmedCard(data);
                } else {
                  return _buildCompletedCard(data);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    bool isSelected = selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1664CD) : const Color(0xFFE9F0FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF1B2C49),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPendingCard(Map<String, dynamic> data) {
    return _baseCardLayout(
      data: data,
      statusLabel: "Pending",
      statusColor: const Color(0xFFFAAD14),
      statusBg: const Color(0xFFFFF7E6),
      infoInBar: true,
      actions: Row(
        children: [
          Expanded(child: _actionBtn("Cancel", const Color(0xFFD93D57), Colors.white)),
          const SizedBox(width: 15),
          Expanded(child: _actionBtn("Accepted", const Color(0xFFC6F2D6), const Color(0xFF27AE60))),
        ],
      ),
    );
  }

  // --- ২. Confirmed কার্ডের ফিক্সড বাটন লজিক ---
  Widget _buildConfirmedCard(Map<String, dynamic> data) {
    return _baseCardLayout(
      data: data,
      statusLabel: null, 
      infoInBar: false,
      actions: Column(
        children: [
          Row(
            children: [
              Expanded(child: _actionBtn("Reschedule", const Color(0xFFE9F0FF), Colors.black87)),
              const SizedBox(width: 15),
              Expanded(child: _actionBtn("Cancel", const Color(0xFFD93D57), Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _actionBtn(
              // লজিক: ভিডিও হলে Start Session, ফিজিক্যাল হলে Mark as Completed
              data['type'] == "Video" ? "Start Session" : "Mark as Completed",
              const Color(0xFF0B3267),
              Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(Map<String, dynamic> data) {
    return _baseCardLayout(
      data: data,
      statusLabel: "Completed",
      statusColor: const Color(0xFF52C41A),
      statusBg: const Color(0xFFF6FFED),
      infoInBar: false,
      actions: const SizedBox.shrink(),
    );
  }

  Widget _baseCardLayout({
    required Map<String, dynamic> data,
    String? statusLabel,
    Color statusColor = Colors.grey,
    Color statusBg = Colors.transparent,
    required bool infoInBar,
    required Widget actions,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(data['image'], height: 60, width: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (!infoInBar) ...[
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 10,
                        runSpacing: 5,
                        children: [
                          _smallIconText(data['type'] == "Video" ? Icons.videocam_outlined : Icons.location_on_outlined, data['type']),
                          _smallIconText(Icons.calendar_today_outlined, data['date']),
                          _smallIconText(Icons.access_time, "${data['time']}(${data['duration']})"),
                          _smallIconText(Icons.payments_outlined, data['price']),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (statusLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                  child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 15),
          if (infoInBar) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFE9F1FF), borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _smallIconText(Icons.calendar_today_outlined, data['date']),
                  _smallIconText(Icons.access_time, data['time']),
                  _smallIconText(data['type'] == "Video" ? Icons.videocam_outlined : Icons.location_on_outlined, data['type']),
                  _smallIconText(Icons.payments_outlined, data['price']),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
          actions,
        ],
      ),
    );
  }

  Widget _smallIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
      ],
    );
  }

  Widget _actionBtn(String label, Color bg, Color txt) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label, style: TextStyle(color: txt, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}