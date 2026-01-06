import 'package:flutter/material.dart';
import 'package:docmobi/screens/doctor/navigation/doctor_main_navigation.dart';
import 'package:docmobi/services/api_service.dart';
import 'package:video_player/video_player.dart';

class DoctorReelsScreen extends StatefulWidget {
  const DoctorReelsScreen({super.key});

  @override
  State<DoctorReelsScreen> createState() => _DoctorReelsScreenState();
}

class _DoctorReelsScreenState extends State<DoctorReelsScreen> {
  List<Map<String, dynamic>> reelsList = [];
  bool isLoading = true;
  bool hasError = false;
  int currentPage = 1;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadReels();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !isLoading &&
        hasMore) {
      _loadMoreReels();
    }
  }

  Future<void> _loadReels() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await ApiService.getAllReels(page: 1, limit: 20);

      if (response['success'] == true) {
        final items = response['data']['items'] as List;
        final pagination = response['data']['pagination'];

        setState(() {
          reelsList = items.map((item) => item as Map<String, dynamic>).toList();
          currentPage = 1;
          hasMore = (pagination['page'] * pagination['limit']) < pagination['total'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reels: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreReels() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.getAllReels(page: currentPage + 1, limit: 20);

      if (response['success'] == true) {
        final items = response['data']['items'] as List;
        final pagination = response['data']['pagination'];

        setState(() {
          reelsList.addAll(items.map((item) => item as Map<String, dynamic>).toList());
          currentPage++;
          hasMore = (pagination['page'] * pagination['limit']) < pagination['total'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshReels() async {
    await _loadReels();
  }

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
                MaterialPageRoute(
                    builder: (context) => const DoctorMainNavigation()),
                (route) => false,
              );
            }
          },
        ),
        title: const Text(
          'Reels',
          style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
              fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReels,
        child: isLoading && reelsList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed to load reels'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _loadReels,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : reelsList.isEmpty
                    ? const Center(child: Text('No reels available'))
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          controller: _scrollController,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: reelsList.length + (hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == reelsList.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return _buildReelThumbnail(reelsList[index], index);
                          },
                        ),
                      ),
      ),
    );
  }

  Widget _buildReelThumbnail(Map<String, dynamic> reel, int index) {
    final thumbnailUrl = reel['thumbnail']?['url'];
    final videoUrl = reel['video']?['url'];
    final author = reel['author'];
    final doctorName = author?['fullName'] ?? 'Unknown Doctor';
    final caption = reel['caption'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReelsViewerScreen(
              reelsList: reelsList,
              initialIndex: index,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              thumbnailUrl != null
                  ? Image.network(thumbnailUrl, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, size: 50),
                      );
                    })
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.videocam, size: 50),
                    ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              const Center(
                  child: Icon(Icons.play_circle_outline,
                      color: Colors.white, size: 50)),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctorName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (caption.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(caption,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
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

  const ReelsViewerScreen(
      {super.key, required this.reelsList, required this.initialIndex});

  @override
  State<ReelsViewerScreen> createState() => _ReelsViewerScreenState();
}

class _ReelsViewerScreenState extends State<ReelsViewerScreen> {
  late PageController _pageController;
  late int currentPage;
  Map<int, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeVideoForPage(currentPage);
  }

  Future<void> _initializeVideoForPage(int index) async {
    if (_videoControllers.containsKey(index)) {
      _videoControllers[index]!.play();
      return;
    }

    final videoUrl = widget.reelsList[index]['video']?['url'];
    if (videoUrl == null) return;

    final controller = VideoPlayerController.network(videoUrl);
    _videoControllers[index] = controller;

    try {
      await controller.initialize();
      controller.setLooping(true);
      if (mounted && currentPage == index) {
        controller.play();
        setState(() {});
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  void _pauseAllExcept(int index) {
    _videoControllers.forEach((key, controller) {
      if (key != index) {
        controller.pause();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoControllers.forEach((_, controller) {
      controller.dispose();
    });
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
        onPageChanged: (index) {
          setState(() => currentPage = index);
          _pauseAllExcept(index);
          _initializeVideoForPage(index);
        },
        itemBuilder: (context, index) =>
            _buildReelPage(widget.reelsList[index], index),
      ),
    );
  }

  Widget _buildReelPage(Map<String, dynamic> reel, int index) {
    final author = reel['author'];
    final doctorName = author?['fullName'] ?? 'Unknown Doctor';
    final caption = reel['caption'] ?? '';
    final avatarUrl = author?['avatar']?['url'];
    final videoController = _videoControllers[index];

    return Stack(
      children: [
        // Video Player
        Center(
          child: videoController != null && videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: VideoPlayer(videoController),
                )
              : const CircularProgressIndicator(color: Colors.white),
        ),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
        ),
        // Back button
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
                    MaterialPageRoute(
                        builder: (context) => const DoctorMainNavigation()),
                    (route) => false,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
        // Actions
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              _buildActionButton(Icons.favorite_border, '${reel['likesCount'] ?? 0}', () {}),
              const SizedBox(height: 25),
              _buildActionButton(Icons.chat_bubble_outline, '234', () {}),
              const SizedBox(height: 25),
              _buildActionButton(Icons.share_outlined, 'Share', () {}),
              const SizedBox(height: 25),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
        // Doctor Info
        Positioned(
          left: 16,
          right: 80,
          bottom: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                          : null,
                    ),
                    child: avatarUrl == null
                        ? const Icon(Icons.person, color: Colors.white, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doctorName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              if (caption.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(caption,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ],
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
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 26)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}