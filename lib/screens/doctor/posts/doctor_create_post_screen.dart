import 'package:flutter/material.dart';

class DoctorCreatePostScreen extends StatefulWidget {
  const DoctorCreatePostScreen({super.key});

  @override
  State<DoctorCreatePostScreen> createState() => _DoctorCreatePostScreenState();
}

class _DoctorCreatePostScreenState extends State<DoctorCreatePostScreen> {
  final TextEditingController _postController = TextEditingController();
  bool _showDoctorInfo = true;

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
          'Create Post',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              if (_postController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please write something to post'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post created successfully'),
                  backgroundColor: Color(0xFF27AE60),
                ),
              );
              _postController.clear();
              Navigator.pop(context);
            },
            child: const Text(
              'Share',
              style: TextStyle(
                color: Color(0xFF1664CD),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info Card
            if (_showDoctorInfo)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5EEFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/images/doctor_booking.png'),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. Jaynor Abedin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B3267),
                            ),
                          ),
                          Text(
                            'Pediatric Surgery',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        setState(() {
                          _showDoctorInfo = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            // Post Input
            const Text(
              'What\'s on your mind?......',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0B3267),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _postController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Share health tips, medical advice, or updates...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1664CD)),
                ),
                contentPadding: const EdgeInsets.all(15),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Media Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMediaOption(Icons.photo_library, 'Photo', Colors.green),
                _buildMediaOption(Icons.videocam, 'Video', Colors.red),
                _buildMediaOption(Icons.attach_file, 'File', Colors.blue),
              ],
            ),
            const SizedBox(height: 30),
            // Tips Section
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF4A90E2).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: const Color(0xFF4A90E2)),
                      const SizedBox(width: 10),
                      const Text(
                        'Tips for Creating Engaging Posts',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B3267),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTip('Share health tips and medical advice'),
                  _buildTip('Post educational content about your specialty'),
                  _buildTip('Share success stories (with patient consent)'),
                  _buildTip('Answer common health questions'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label picker coming soon'),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14, color: Colors.grey)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}
