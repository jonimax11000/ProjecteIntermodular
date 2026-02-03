import 'package:flutter/material.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';

class VideoListItem extends StatelessWidget {
  final Video video;

  const VideoListItem({
    super.key,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF1E1E1E),
      child: ListTile(
        title: Text(
          video.titol,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          video.duracio,
          style: const TextStyle(color: Colors.white54),
        ),
        leading: const Icon(Icons.play_circle, color: Colors.white70),
        onTap: () {
          // Navegar al VideoScreen completo
        },
      ),
    );
  }
}
