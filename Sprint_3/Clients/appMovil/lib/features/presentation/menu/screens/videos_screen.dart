import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/widgets/grid_all_videos.dart';
import 'package:flutter/material.dart';
import 'package:exercici_disseny_responsiu_stateful/features/core/service_locator.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_videos.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  List<Video>? videos;
  bool isLoading = true;
  String? errorMessage;
  late final GetVideos getVideos;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          "assets/img/justflix.png",
          height: 40,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            "Videos",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
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

    if (videos == null || videos!.isEmpty) {
      return const Center(
        child: Text(
          "No hay vídeos",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        itemCount: videos!.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          return VideoGridCard(video: videos![index]);
        },
      ),
    );
  }
}

class VideoGridCard extends StatelessWidget {
  final Video video;

  const VideoGridCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final String videoURL = ServiceLocator().getVideoUrl();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 8 / 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: video.thumbnailURL.isNotEmpty
                ? Image.network(
                    "$videoURL${video.thumbnailURL}",
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: const Color(0xFF2A2A2A),
                    child: const Icon(
                      Icons.play_circle_outline,
                      color: Colors.white38,
                      size: 32,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          video.titol,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
