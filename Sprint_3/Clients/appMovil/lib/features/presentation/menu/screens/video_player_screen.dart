import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:video_player/video_player.dart';

import 'package:exercici_disseny_responsiu_stateful/features/core/service_locator.dart';
import 'package:exercici_disseny_responsiu_stateful/features/core/session_service.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_videos.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/widgets/video_controls.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Video video;

  const VideoPlayerScreen({
    super.key,
    required this.video,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPlaying = false;
  bool _showFullScreen = false;
  
  List<Video> _allVideos = [];
  bool _isLoadingMoreVideos = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _loadMoreVideos();
  }

  Future<void> _loadMoreVideos() async {
    try {
      final getVideos = ServiceLocator().getVideos;
      final videos = await getVideos();
      if (mounted) {
        setState(() {
          _allVideos = videos;
          _isLoadingMoreVideos = false;
        });
      }
    } catch (e) {
      // Manejar error silenciosamente o mostrar
      if (mounted) {
        setState(() {
          _isLoadingMoreVideos = false;
        });
      }
      print("Error loading more videos: $e");
    }
  }

  Future<void> _initializeVideo() async {
    final String baseUrl = ServiceLocator().getVideoUrl();
    final sessionService = SessionService(const FlutterSecureStorage());
    final token = await sessionService.ensureValidAccessToken();

    print("DEBUG: Initializing video: $baseUrl${widget.video.videoURL}");
    print("DEBUG: Token available: ${token != null}");
    
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse("$baseUrl${widget.video.videoURL}"),
      httpHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    try {
      await _videoController!.initialize();
      await _videoController!.setVolume(1.0);

      setState(() {
        _isVideoInitialized = true;
      });

      // Reproducir automáticamente
      await _videoController!.play();

      // Escuchar cambios
      _videoController!.addListener(_videoListener);
    } catch (e) {
      print('Error inicializando video: $e');
    }
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = _videoController?.value.isPlaying ?? false;
      });
    }
  }

  void _togglePlayPause() {
    if (_videoController == null) return;

    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _showFullScreen = !_showFullScreen;
    });

    if (_showFullScreen) {
      // Entrar en fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Salir de fullscreen
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    // Restaurar orientación
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: _buildAppBar(),
      body: _buildContent(),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // VIDEO (16:9)
          _buildVideoPlayer(),

          // TÍTULO Y DURACIÓN
          _buildTitleAndDuration(),

          // DESCRIPCIÓN (si existe)
          if (widget.video.descripcio != null &&
              widget.video.descripcio!.isNotEmpty)
            _buildDescription(),

          // ESPACIO PARA FUTURA LISTA DE VIDEOS
          _buildFutureVideosPlaceholder(videos: _allVideos),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // VIDEO
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _isVideoInitialized && _videoController != null
                ? VideoPlayer(_videoController!)
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
          ),

          // CONTROLES DEL VIDEO
          if (_videoController != null && _isVideoInitialized)
            Positioned.fill(
              child: VideoControls(
                controller: _videoController!,
                onToggleFullscreen: _toggleFullScreen,
              ),
            ),

          // BOTÓN DE PLAY/PAUSE CENTRAL
          if (_videoController != null && _isVideoInitialized)
            Positioned.fill(
              child: Center(
                child: AnimatedOpacity(
                  opacity: _isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleAndDuration() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TÍTULO
          Text(
            widget.video.titol,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // DURACIÓN
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                widget.video.duracio,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // DESCRIPCIÓN
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.video.descripcio!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFutureVideosPlaceholder({required List<Video> videos}) {
    // Filtramos videos que no sean el actual
    if (_isLoadingMoreVideos) {
       return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final otherVideos = videos.where((v) => v.id != widget.video.id).toList();

    if (otherVideos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          'No hay otros videos disponibles',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Más videos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: otherVideos.map((video) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Card(
                  elevation: 4,
                  color: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      // Navegar al nuevo video
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(
                              video: video),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 80,
                      child: Row(
                        children: [
                          // THUMBNAIL
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                            child: Image.network(
                              "${ServiceLocator().getVideoUrl()}${video.thumbnailURL}",
                              width: 120,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 120,
                                  height: 80,
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.broken_image, color: Colors.white),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // TÍTULO
                          Expanded(
                            child: Text(
                              video.titol,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
