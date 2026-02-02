import 'package:exercici_disseny_responsiu_stateful/features/core/service_locator.dart';
import 'package:exercici_disseny_responsiu_stateful/features/core/session_service.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_videos.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/widgets/videos_layout.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/widgets/submenu.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/widgets/video_carousel.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/perfil/perfil_screen.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/search/search_screen.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/videoList/videoList_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Video? _selectedVideo;
  late final GetVideos getVideos;
  List<Video>? videos;
  bool isLoading = true;
  String? errorMessage;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isScrubbing = false;
  bool _wasPlayingBeforeScrubbing = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    getVideos = ServiceLocator().getVideos;
    _loadVideos();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _exitFullScreen();
    super.dispose();
  }

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

  Future<void> _initializeVideo(String video) async {
    final String videoURL = ServiceLocator().getVideoUrl();

    final sessionService = SessionService(FlutterSecureStorage());
    final token = await sessionService.getToken();

    await _videoController?.dispose();
    setState(() {
      _isVideoInitialized = false;
      _isScrubbing = false;
    });

    print("DEBUG: Loading video from URL: $videoURL$video");
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse("$videoURL$video"),
      httpHeaders: token != null
          ? {
              'Authorization': 'Bearer $token',
            }
          : {},
    );

    try {
      await _videoController!.initialize();
      await _videoController!.setVolume(1.0);

      setState(() {
        _isVideoInitialized = true;
      });

      await _videoController!.play();

      _videoController!.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _isVideoInitialized = false;
      });
    }
  }

  Future<void> _onVideoTap(Video video) async {
    final sessionService = SessionService(FlutterSecureStorage());
    final tokenData = await sessionService.getTokenData();
    if (tokenData == null) {
      print("Token data not found");
      return;
    }
    print(tokenData);
    final userLevel =
        int.tryParse(tokenData['subscription_level'].toString()) ?? 0;
    print(userLevel);
    print(video.nivell);

    if (userLevel < (video.nivell ?? 0)) {
      print("Video is not available for your level");
      return;
    }

    setState(() {
      _selectedVideo = video;
    });

    if (video.videoURL.isNotEmpty) {
      _initializeVideo(video.videoURL);
    } else {
      print('Video URL not available');
    }

    print('Video selected: ${video.titol}');
  }

  Future<void> _seekTo(Duration position) async {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }

    await _videoController!.pause();
    await Future.delayed(const Duration(milliseconds: 100));

    await _videoController!.seekTo(position);

    await _videoController!.setVolume(1.0);

    await Future.delayed(const Duration(milliseconds: 100));

    if (_wasPlayingBeforeScrubbing) {
      await _videoController!.play();
    }

    setState(() {
      _isScrubbing = false;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        body: Stack(
          children: [
            Center(
              child: _isVideoInitialized && _videoController != null
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_videoController!),
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_videoController!.value.isPlaying) {
                                    _videoController!.pause();
                                  } else {
                                    _videoController!.play();
                                  }
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: AnimatedOpacity(
                                    opacity: _videoController!.value.isPlaying
                                        ? 0.0
                                        : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E1E1E),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: _buildVideoControls(isFullScreen: true),
                          ),
                        ],
                      ),
                    )
                  : const CircularProgressIndicator(color: Colors.blueAccent),
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
    }

    final listaScreens = [
      _buildHomeScreen(),
      _buildSearchScreen(),
      _buildVideoListScreen(),
      //_perfilScreen()
    ];

    return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          centerTitle: true,
          title: SafeArea(
            child: Image.asset(
              "assets/img/justflix.png",
              height: 44,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF2A2A2A),
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 64,
                  ),
                );
              },
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentIndex == 0) const Submenu(),
            Expanded(
              child: listaScreens[_currentIndex],
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => {
            setState(() {
              _currentIndex = index;
            })
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), label: 'Búsqueda'),
            BottomNavigationBarItem(
                icon: Icon(Icons.video_library), label: 'Mi lista'),
          ],
        ));
  }

  Widget _buildSearchScreen() {
    return const SearchScreen();
  }

  Widget _buildVideoListScreen() {
    return const VideolistScreen();
  }

  Widget _perfilScreen() {
    return const PerfilScreen();
  }

  Widget _buildHomeScreen() {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent))
        : errorMessage != null
            ? Center(
                child: Text(
                  'Error: $errorMessage',
                  style: const TextStyle(color: Colors.white70),
                ),
              )
            : OrientationBuilder(
                builder: (context, orientation) {
                  final isLandscape = orientation == Orientation.landscape;
                  if (isLandscape && _selectedVideo != null) {
                    return _buildLandscapeLayout();
                  } else {
                    return _buildPortraitLayout();
                  }
                },
              );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Reproductor de video seleccionado
            if (_selectedVideo != null) ...[
              _buildVideoPlayerCard(),
              const SizedBox(height: 8),
            ],

            // Carrusel de videos recomendados
            SizedBox(
              height: 450,
              child: VideoCarousel(onTap: _onVideoTap, videos: videos ?? []),
            ),

            const SizedBox(height: 16),
            // Grid de videos adicionales
            VideosLayout(
              videos: videos ?? [],
              onVideoTap: _onVideoTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: _buildVideoPlayerCard(),
          ),
        ),
        SizedBox(
          width: 360, // ancho controlado
          child: VideoCarousel(onTap: _onVideoTap, videos: videos ?? []),
        ),
        /*Flexible(
          flex: 3,
          /*child: MyListWidget(
            videos: videos ?? [],
            onVideoTap: _onVideoTap,
          ),*/
          child: GridAllVideos(),
        ),*/
      ],
    );
  }

  Widget _buildVideoPlayerCard() {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 600,
        minHeight: 200,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Container(
              color: Colors.black,
              constraints: const BoxConstraints(
                minHeight: 200,
                maxHeight: 400,
              ),
              child: _isVideoInitialized && _videoController != null
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_videoController!),
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_videoController!.value.isPlaying) {
                                    _videoController!.pause();
                                  } else {
                                    _videoController!.play();
                                  }
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: AnimatedOpacity(
                                    opacity: _videoController!.value.isPlaying
                                        ? 0.0
                                        : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: _buildVideoControls(),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 250,
                      child: Center(
                        child: _selectedVideo!.thumbnailURL.isNotEmpty
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    _selectedVideo!.thumbnailURL,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.blueAccent,
                                        ),
                                      );
                                    },
                                  ),
                                  const CircularProgressIndicator(
                                    color: Colors.blueAccent,
                                  ),
                                ],
                              )
                            : const CircularProgressIndicator(
                                color: Colors.blueAccent,
                              ),
                      ),
                    ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedVideo!.titol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedVideo!.duracio,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    /*Text(
                      _selectedVideo!.descripcio,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),*/
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*Widget _buildVideoPlayerCard() {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 600,
        minHeight: 200,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Container(
              color: Colors.black,
              constraints: const BoxConstraints(
                minHeight: 200,
                maxHeight: 400,
              ),
              child: _selectedVideo != null &&
                      _selectedVideo!.thumbnailURL.isNotEmpty
                  ? Image.network(
                      _selectedVideo!.thumbnailURL,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 48,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child:
                          CircularProgressIndicator(color: Colors.blueAccent),
                    ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedVideo?.titol ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedVideo?.duracio ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedVideo?.duracio ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }*/

  Widget _buildVideoControls({bool isFullScreen = false}) {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onHorizontalDragStart: (details) {
              setState(() {
                _isScrubbing = true;
                _wasPlayingBeforeScrubbing = _videoController!.value.isPlaying;
              });
              if (_wasPlayingBeforeScrubbing) {
                _videoController!.pause();
              }
            },
            onHorizontalDragUpdate: (details) {
              if (!_isScrubbing) return;

              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;

              final position = details.localPosition.dx / box.size.width;
              final duration = _videoController!.value.duration;
              final newPosition = duration * position.clamp(0.0, 1.0);

              _videoController!.seekTo(newPosition);
            },
            onHorizontalDragEnd: (details) {
              final currentPosition = _videoController!.value.position;
              _seekTo(currentPosition);
            },
            child: VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.blueAccent,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white12,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_videoController!.value.isPlaying) {
                        _videoController!.pause();
                      } else {
                        _videoController!.play();
                      }
                    });
                  },
                ),
                const Spacer(),
                Text(
                  _formatDuration(_videoController!.value.position),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  ' / ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDuration(_videoController!.value.duration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isFullScreen) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                    onPressed: _toggleFullScreen,
                  ),
                ],
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
