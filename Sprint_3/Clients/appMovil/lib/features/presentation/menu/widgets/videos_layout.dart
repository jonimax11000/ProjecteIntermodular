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

  const _VideoLayoutCard({
    required this.video,
    required this.onTap,
  });

  @override
  State<_VideoLayoutCard> createState() => _VideoLayoutCardState();
}

class _VideoLayoutCardState extends State<_VideoLayoutCard> {
  bool _pressed = false;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = ref.watch(wishlistProvider);
    final String videoURL = ServiceLocator().getVideoUrl();

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: 160, // ancho cómodo para filas
          child: Card(
            elevation: 6,
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🎬 THUMBNAIL
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.video.thumbnailURL.isNotEmpty
                          ? Image.network(
                              "$videoURL${widget.video.thumbnailURL}",
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _thumbnailFallback(),
                            )
                          : _thumbnailFallback(),

                      /// Gradiente
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
                                Colors.black.withOpacity(0.75),
                              ],
                            ),
                          ),
                        ),
                      ),

                      /// Duración
                      if (widget.video.duracio.isNotEmpty)
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.video.duracio,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                /// 📝 INFO
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TÍTULO
                      Expanded(
                        child: Text(
                          widget.video.titol,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      /// ❤️ FAVORITO
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                          final notifier = ref.read(wishlistProvider.notifier);
                          if (_isFavorite) {
                            notifier.add(widget.video);
                          } else {
                            notifier.remove(widget.video);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(

                            /*_isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite
                                ? Colors.redAccent
                                : Colors.white38,*/

                            wishlistProvider.contains(widget.video)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: wishlistProvider.contains(widget.video)
                                ? Colors.redAccent
                                : Colors.white38,
                            size: 18,
                          ),
                          
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          size: 42,
        ),
      ),
    );
  }
}

