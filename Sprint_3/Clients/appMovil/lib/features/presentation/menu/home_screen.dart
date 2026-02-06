import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/screens/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:video_player/video_player.dart';

import 'package:exercici_disseny_responsiu_stateful/features/core/service_locator.dart';
import 'package:exercici_disseny_responsiu_stateful/features/core/session_service.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_videos.dart';

import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/widgets/submenu.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/widgets/video_carousel.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/widgets/videos_layout.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/search/search_screen.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/videoList/videoList_screen.dart';

import 'widgets/video_player_card.dart';
import 'widgets/video_controls.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Video? _selectedVideo;
  List<Video>? videos;

  late final GetVideos getVideos;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getVideos = ServiceLocator().getVideos;
    _loadVideos();
  }

/*
  @override
  void dispose() {
    _videoController?.dispose();
    _exitFullScreen();
    super.dispose();
  }*/

  // ---------------------------
  // DATA
  // ---------------------------

  Future<void> _loadVideos() async {
    try {
      final result = await getVideos();
      setState(() {
        videos = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // ---------------------------
  // VIDEO LOGIC (MISMA)
  // ---------------------------
/*
  Future<void> _initializeVideo(String video) async {
    final String baseUrl = ServiceLocator().getVideoUrl();
    final sessionService = SessionService(const FlutterSecureStorage());
    final token = await sessionService.getToken();

    await _videoController?.dispose();

    setState(() {
      _isVideoInitialized = false;
    });

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse("$baseUrl$video"),
      httpHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    try {
      await _videoController!.initialize();
      await _videoController!.setVolume(1.0);

      setState(() {
        _isVideoInitialized = true;
      });

      await _videoController!.play();

      _videoController!.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (_) {
      setState(() {
        _isVideoInitialized = false;
      });
    }
  }
*/

  Future<void> _onVideoTap(Video video) async {
    final sessionService = SessionService(const FlutterSecureStorage());
    final tokenData = await sessionService.getAccessTokenData();

    if (tokenData == null) return;

    final userLevel =
        int.tryParse(tokenData['subscription_level'].toString()) ?? 0;

    if (userLevel < (video.nivell ?? 0)) return;

    setState(() {
      _selectedVideo = video;
    });

/*
    if (video.videoURL.isNotEmpty) {
      _initializeVideo(video.videoURL);
    }*/

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(video: video),
      ),
    );
  }

  // ---------------------------
  // FULLSCREEN
  // ---------------------------
/*
  Future<void> _toggleFullScreen() async {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await _exitFullScreen();
    }
  }

  Future<void> _exitFullScreen() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
*/
  // ---------------------------
  // UI
  // ---------------------------

  @override
  Widget build(BuildContext context) {
    /*if (_isFullScreen && _videoController != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        body: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoControls(
                controller: _videoController!,
                isFullScreen: true,
              ),
            ),
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.fullscreen_exit,
                    color: Colors.white, size: 32),
                onPressed: _toggleFullScreen,
              ),
            ),
          ],
        ),
      );
    }*/

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_currentIndex == 0) const Submenu(),
          Expanded(child: _buildCurrentScreen()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCurrentScreen() {
    if (_currentIndex == 1) return const SearchScreen();
    if (_currentIndex == 2) return const VideolistScreen();
    return _buildHomeContent();
  }

  Widget _buildHomeContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    return OrientationBuilder(
      builder: (_, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              if (_selectedVideo != null)
                /*VideoPlayerCard(
                  selectedVideo: _selectedVideo,
                  controller: _videoController,
                  isVideoInitialized: _isVideoInitialized,
                  onPlayPause: () {
                    setState(() {
                      if (_videoController!.value.isPlaying) {
                        _videoController!.pause();
                      } else {
                        _videoController!.play();
                      }
                    });
                  },
                  controls: VideoControls(
                    controller: _videoController!,
                    onToggleFullscreen: _toggleFullScreen,
                  ),
                ),*/
                const SizedBox(height: 12),
              SizedBox(
                height: isLandscape ? 320 : 480,
                child: VideoCarousel(
                  videos: videos ?? [],
                  onTap: _onVideoTap,
                ),
              ),
              const SizedBox(height: 16),
              VideosLayout(
                videos: videos ?? [],
                onVideoTap: _onVideoTap,
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF121212),
      elevation: 0,
      centerTitle: true,
      title: Image.asset(
        "assets/img/justflix.png",
        height: 44,
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Búsqueda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.video_library), label: 'Mi lista'),
      ],
    );
  }
}
