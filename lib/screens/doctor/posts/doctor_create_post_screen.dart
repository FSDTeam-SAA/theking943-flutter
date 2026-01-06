import 'dart:io';
import 'package:docmobi/screens/doctor/reels/doctor_reels_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:docmobi/services/api_service.dart';


class DoctorCreatePostScreen extends StatefulWidget {
  const DoctorCreatePostScreen({super.key});

  @override
  State<DoctorCreatePostScreen> createState() => _DoctorCreatePostScreenState();
}

class _DoctorCreatePostScreenState extends State<DoctorCreatePostScreen> {
  final TextEditingController _postController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedMediaList = [];
  String _postType = 'normal'; // 'normal', 'photo', 'video', 'reels'
  bool _isUploading = false;

  Future<void> _pickMedia(String type) async {
    if (type == 'Photo') {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedMediaList = images;
          _postType = 'photo';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${images.length} photos selected')),
        );
      }
    } else if (type == 'Video') {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _selectedMediaList = [video];
          _postType = 'video';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video selected: ${video.name}')),
        );
      }
    } else if (type == 'Reels') {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _selectedMediaList = [video];
          _postType = 'reels';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reels video selected: ${video.name}')),
        );
      }
    }
  }

  Future<void> _handlePost() async {
    String text = _postController.text.trim();

    if (text.isEmpty && _selectedMediaList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some text or media to post')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      Map<String, dynamic> result;

      if (_postType == 'reels') {
        // Upload as Reel
        if (_selectedMediaList.isEmpty) {
          throw Exception('Please select a video for reels');
        }

        result = await ApiService.createReel(
          videoFile: File(_selectedMediaList.first.path),
          caption: text.isNotEmpty ? text : null,
          visibility: 'public',
        );

        if (!mounted) return;

        setState(() {
          _isUploading = false;
        });

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reel uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to Reels Screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DoctorReelsScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to upload reel'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Upload as Regular Post
        List<File>? mediaFiles;
        if (_selectedMediaList.isNotEmpty) {
          mediaFiles = _selectedMediaList.map((xFile) => File(xFile.path)).toList();
        }

        result = await ApiService.createPost(
          content: text,
          mediaFiles: mediaFiles,
          visibility: 'public',
        );

        if (!mounted) return;

        setState(() {
          _isUploading = false;
        });

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post shared successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Go back to previous screen
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to create post'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMediaList.removeAt(index);
      if (_selectedMediaList.isEmpty) {
        _postType = 'normal';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: _isUploading ? null : _handlePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D53C1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 25),
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Post',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      AssetImage('assets/images/doctor_booking.png'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dr. Joynal Abedin',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _buildSmallDropdown(Icons.public, 'Public'),
                        const SizedBox(width: 8),
                        _buildSmallDropdown(Icons.add, 'Album'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _postController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "What's on your mind?.......",
                hintStyle: TextStyle(fontSize: 20, color: Colors.black54),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 20),
            ),
            
            // Display selected media
            if (_selectedMediaList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: _postType == 'photo' && _selectedMediaList.length > 1
                    ? _buildMultiplePhotosPreview()
                    : _buildSingleMediaPreview(),
              ),

            const SizedBox(height: 100),
            
            // Media Selection Grid
            Row(
              children: [
                Expanded(
                    child: InkWell(
                        onTap: () => _pickMedia('Photo'),
                        child: _buildMediaCard(Icons.image_outlined, 'Photo'))),
                const SizedBox(width: 15),
                Expanded(
                    child: InkWell(
                        onTap: () => _pickMedia('Video'),
                        child:
                            _buildMediaCard(Icons.videocam_outlined, 'Video'))),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                    child: InkWell(
                        onTap: () => _pickMedia('Reels'),
                        child: _buildMediaCard(
                            Icons.play_circle_outline, 'Reels'))),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleMediaPreview() {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey[200],
          ),
          child: _postType == 'video' || _postType == 'reels'
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam, size: 50),
                      SizedBox(height: 10),
                      Text('Video Selected'),
                    ],
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    File(_selectedMediaList.first.path),
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () => _removeMedia(0),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiplePhotosPreview() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedMediaList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_selectedMediaList[index].path),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: GestureDetector(
                    onTap: () => _removeMedia(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmallDropdown(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: const Color(0xFFE8EEF9),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.black87),
          const SizedBox(width: 4),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const Icon(Icons.keyboard_arrow_down, size: 16),
        ],
      ),
    );
  }

  Widget _buildMediaCard(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 30, color: Colors.black87),
              const Icon(Icons.add, size: 20, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}