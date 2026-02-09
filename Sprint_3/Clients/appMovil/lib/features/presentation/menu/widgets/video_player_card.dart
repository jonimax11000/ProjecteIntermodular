import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../domain/entities/video.dart';

class VideoPlayerCard extends StatelessWidget {
  final Video? selectedVideo;
  final VideoPlayerController? controller;
  final bool isVideoInitialized;
  final Widget controls;
  final VoidCallback onPlayPause;

  const VideoPlayerCard({
    super.key,
    required this.selectedVideo,
    required this.controller,
    required this.isVideoInitialized,
    required this.controls,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedVideo == null) {
      return const SizedBox.shrink();
    }

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
          _buildVideoArea(),
          _buildInfo(),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(16),
      ),
      child: Container(
        color: Colors.black,
        constraints: const BoxConstraints(
          minHeight: 200,
          maxHeight: 400,
        ),
        child: isVideoInitialized && controller != null
            ? AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(controller!),
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: onPlayPause,
                        child: Container(
                          color: Colors.transparent,
                          child: AnimatedOpacity(
                            opacity: controller!.value.isPlaying ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Center(
                              child: Container(
                                decoration: const BoxDecoration(
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
                      child: controls,
                    ),
                  ],
                ),
              )
            : _buildThumbnail(),
      ),
    );
  }

  Widget _buildThumbnail() {
    return SizedBox(
      height: 250,
      child: Center(
        child: selectedVideo!.thumbnailURL.isNotEmpty
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    selectedVideo!.thumbnailURL,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) {
                      return const CircularProgressIndicator(
                        color: Colors.blueAccent,
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
    );
  }

  Widget _buildInfo() {
    return Flexible(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedVideo!.titol,
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
                    selectedVideo!.duracio,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
