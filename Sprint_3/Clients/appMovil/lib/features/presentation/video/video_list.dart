import 'package:flutter/material.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';


class VideoScreen extends StatelessWidget {
  final Video video;

  const VideoScreen({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Text(
          video.titol,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Text(
          video.titol,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
