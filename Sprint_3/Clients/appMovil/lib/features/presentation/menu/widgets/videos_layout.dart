import 'package:exercici_disseny_responsiu_stateful/features/core/service_locator.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';
import 'package:flutter/material.dart';

class VideosLayout extends StatelessWidget {
  const VideosLayout({
    super.key,
    required this.videos,
    required this.onVideoTap,
  });

  final List<Video> videos;
  final Function(Video) onVideoTap;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return const Center(
        child: Text(
          'No videos found',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Para ti',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final video = videos[index];
              return _VideoLayoutCard(
                  video: video, onTap: () => onVideoTap(video));
            },
          ),
        ),
      ],
    );
  }
}

class _VideoLayoutCard extends StatefulWidget {
  final Video video;
  final VoidCallback onTap;

  const _VideoLayoutCard({required this.video, required this.onTap});

  @override
  State<_VideoLayoutCard> createState() => _VideoLayoutCardState();
}

class _VideoLayoutCardState extends State<_VideoLayoutCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final String videoURL = ServiceLocator().getVideoUrl();

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          width: 140, // Ancho fijo para las tarjetas
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.video.thumbnailURL.isNotEmpty
                        ? Image.network(
                            "$videoURL${widget.video.thumbnailURL}",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _thumbnailFallback(),
                          )
                        : _thumbnailFallback(),

                    // Gradiente sutil en la parte inferior de la imagen
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
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
                      ),
                    ),

                    // Badge de duración
                    if (widget.video.duracio.isNotEmpty)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.video.duracio,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Información del video
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.titol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.video.descripcio != null)
                      Text(
                        widget.video.descripcio!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbnailFallback() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: const Center(
        child: Icon(
          Icons.play_circle_outline,
          color: Colors.white38,
          size: 32,
        ),
      ),
    );
  }
}
