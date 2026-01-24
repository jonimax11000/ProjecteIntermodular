// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:exercici_disseny_responsiu_stateful/features/core/service_locator.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/repositories/videos_repository.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_videos.dart';

class GridAllVideos extends StatefulWidget {
  const GridAllVideos({super.key});

  @override
  State<GridAllVideos> createState() => _GridAllVideosState();
}

class _GridAllVideosState extends State<GridAllVideos> {
  List<Video>? listaVideos;
  late final GetVideos getVideos;
  bool isLoading = true;
  String? errorMessage;

  PageController pageController = PageController(viewportFraction: 0.6);

  @override
  void initState() {
    super.initState();
    getVideos = ServiceLocator().getVideos;
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final result = await getVideos();
      setState(() {
        listaVideos = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return SizedBox(
      height: 600,
      child: PageView.builder(
        controller: pageController,
        itemCount: listaVideos!.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: pageController,
            builder: (context, child) {
              double value = 1.0;
              if (pageController.position.haveDimensions) {
                value = pageController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }
              return Center(
                child: Transform.scale(
                  scale: value,
                  child: VideoCard(video: listaVideos![index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class VideoCard extends StatefulWidget {
  final Video video;

  const VideoCard({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final String videoURL = ServiceLocator().getVideoUrl();

    return SizedBox(
      width: 250,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Card(
          elevation: 8, // 🌑 sombra suave
          color: const Color.fromARGB(255, 81, 81, 81),
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // 🔘 bordes grandes
          ),
          child: InkWell(
            onTap: () {
              // navegación o acción
            },
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: Stack(
              children: [
                Positioned.fill(
                  child: widget.video.thumbnailURL.isNotEmpty
                      ? Image.network(
                          "$videoURL${widget.video.thumbnailURL}",
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _thumbnailFallback(),
                        )
                      : _thumbnailFallback(),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 70,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),
                ),

                /// 📝 TÍTULO
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Text(
                    widget.video.titol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
          size: 48,
        ),
      ),
    );
  }
}

/*
class GridAllVideos extends StatefulWidget {
  const GridAllVideos({super.key});

  @override
  State<GridAllVideos> createState() => _GridAllVideosState();
}

class _GridAllVideosState extends State<GridAllVideos> {
  List<Video> listaVideos = [];
  late final GetVideos getVideos;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getVideos = ServiceLocator().getVideos;
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final result = await getVideos();
      setState(() {
        listaVideos = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: listaVideos.length,
      itemBuilder: (context, index) {
        return VideoCard(video: listaVideos[index]);
      },
    );
  }
}

class VideoCard extends StatelessWidget {
  final Video video;

  const VideoCard({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String videoURL = ServiceLocator().getVideoUrl();

    return Card(
      color: const Color(0xFF1E1E1E),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navegación a detalle / reproductor
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: video.thumbnailURL.isNotEmpty
                  ? Image.network(
                      "$videoURL${video.thumbnailURL}",
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _thumbnailFallback(),
                    )
                  : _thumbnailFallback(),
            ),
          ],
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
          size: 48,
        ),
      ),
    );
  }
}*/
