import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullscreenPlayer extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onExit;

  const FullscreenPlayer({
    super.key,
    required this.controller,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Stack(
        children: [
          Center(child: VideoPlayer(controller)),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
              onPressed: onExit,
            ),
          ),
        ],
      ),
    );
  }
}
