import 'package:docmobi/screens/doctor/posts/doctor_create_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:docmobi/screens/patient/notification/notification_screen.dart';
import 'package:docmobi/services/api_service.dart';
import 'package:video_player/video_player.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.getAllPosts(page: 1, limit: 20);
      
      print('📥 Full Response: $result'); // Debug
      
      if (result['success'] == true) {
        // Backend returns: data.items (not data.posts)
        final posts = result['data']?['items'] ?? 
                     result['data']?['posts'] ?? 
                     result['posts'] ?? 
                     result['items'] ?? 
                     [];
        
        print('✅ Loaded ${posts.length} posts');
        print('📋 First post: ${posts.isNotEmpty ? posts[0] : "No posts"}');
        
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      } else {
        print('⚠️ Failed to load posts: ${result['message']}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DoctorCreatePostScreen(),
      ),
    );
    
    // Reload posts when coming back from create post screen
    if (result == true || result == null) {
      _loadPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  if (!_isSearching) ...[
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
                            'Dr.The king',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2C49),
                            ),
                          ),
                          Text(
                            'Podiatric Surgery',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F1FF),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Search posts...',
                            border: InputBorder.none,
                            icon: Icon(Icons.search, size: 20, color: Color(0xFF1B2C49)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  _buildHeaderIcon(
                    _isSearching ? Icons.close : Icons.search,
                    onTap: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) _searchController.clear();
                      });
                    },
                  ),
                  
                  if (!_isSearching) ...[
                    const SizedBox(width: 10),
                    _buildHeaderIcon(
                      Icons.notifications_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationScreen()),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadPosts,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _buildCreatePostBox(),
                            
                            if (_posts.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text(
                                  'No posts yet. Be the first to share!',
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _posts.length,
                                itemBuilder: (context, index) {
                                  final post = _posts[index];
                                  return _buildSocialPost(post);
                                },
                              ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFE9F1FF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF1B2C49), size: 24),
      ),
    );
  }

  Widget _buildCreatePostBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/doctor.png'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _navigateToCreatePost,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F8FF),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Text(
                      'Share your insights with follow doctors...',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPostAction(Icons.image_outlined, 'Photo', Colors.brown, _navigateToCreatePost),
              _buildPostAction(Icons.videocam_outlined, 'Video', Colors.redAccent, _navigateToCreatePost),
              _buildPostAction(Icons.play_circle_outline, 'Reels', Colors.blueAccent, _navigateToCreatePost),
              
              InkWell(
                onTap: _navigateToCreatePost,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1664CD)),
                  ),
                  child: const Text(
                    'Create a Post',
                    style: TextStyle(
                      color: Color(0xFF1664CD),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSocialPost(dynamic post) {
    final String name = post['user']?['name'] ?? 'Unknown User';
    final String timeAgo = _formatTimeAgo(post['created_at']);
    final String content = post['content'] ?? '';
    final List<dynamic> media = post['media'] ?? [];
    final String likes = post['likes_count']?.toString() ?? '0';
    final String comments = post['comments_count']?.toString() ?? '0';
    final String shares = post['shares_count']?.toString() ?? '0';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: post['user']?['profile_image'] != null
                    ? NetworkImage(post['user']['profile_image'])
                    : const AssetImage('assets/images/doctor.png') as ImageProvider,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
          ],
          
          // Display media (images or videos)
          if (media.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMediaSection(media),
          ],
          
          const SizedBox(height: 15),
          Row(
            children: [
              _buildStatChip(Icons.thumb_up_alt_outlined, likes),
              const SizedBox(width: 10),
              _buildStatChip(Icons.chat_bubble_outline, comments),
              const Spacer(),
              _buildStatChip(Icons.share_outlined, shares),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(List<dynamic> media) {
    if (media.length == 1) {
      final mediaItem = media[0];
      final String mediaType = mediaItem['type'] ?? 'image';
      final String mediaUrl = mediaItem['url'] ?? '';

      if (mediaType == 'video') {
        return _buildVideoPlayer(mediaUrl);
      } else {
        // Single Photo
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            mediaUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Failed to load image', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    } else {
      // Multiple Photos - Horizontal Scroll
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: media.length,
          itemBuilder: (context, index) {
            final mediaItem = media[index];
            final String mediaType = mediaItem['type'] ?? 'image';
            final String mediaUrl = mediaItem['url'] ?? '';
            
            // Check if it's video or image
            if (mediaType == 'video') {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 200,
                  child: _buildVideoPlayer(mediaUrl),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    mediaUrl,
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          },
        ),
      );
    }
  }

  Widget _buildVideoPlayer(String videoUrl) {
    return VideoPlayerWidget(videoUrl: videoUrl);
  }

  Widget _buildStatChip(IconData icon, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1B2C49)),
          const SizedBox(width: 4),
          Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    
    try {
      DateTime postTime = DateTime.parse(timestamp.toString());
      Duration difference = DateTime.now().difference(postTime);
      
      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}

// Separate Video Player Widget
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.network(widget.videoUrl);
    
    try {
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller),
              if (!_controller.value.isPlaying)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(15),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}