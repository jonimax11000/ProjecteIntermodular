import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/widgets/categories_widget.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/widgets/grid_all_videos.dart';
import 'package:flutter/material.dart';
import 'package:exercici_disseny_responsiu_stateful/features/core/service_locator.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_videos.dart';

class VideosScreen extends StatefulWidget {
  final categoriaId;
  const VideosScreen({super.key, required this.categoriaId});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  List<Video>? videos = [];
  List<Video>? filteredVideos = [];
  int? selectedCategoriaId;
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
        filteredVideos = videos;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _filteredByCategoria(int? categoriaId) {
    setState(() {
      selectedCategoriaId = categoriaId;
      if (categoriaId == null) {
        filteredVideos = videos;
      } else {
        filteredVideos = videos!
            .where((video) => video.categories!.contains(categoriaId))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          "assets/img/justflix.png",
          height: 40,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: CategoriesWidget(
              onCategoriaSelected: _filteredByCategoria,
              selectedCategoriaId: selectedCategoriaId,
            ),
          ),
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
          Flexible(child: _buildContent()),
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        itemCount: filteredVideos!.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 9,
          mainAxisSpacing: 0,
          childAspectRatio: 1.20,
        ),
        itemBuilder: (context, index) {
          return VideoGridCard(video: filteredVideos![index]);
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
        // Thumbnail
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
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
                      size: 40,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        // Título
        Text(
          video.titol,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600, // SemiBold
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 2),

        // Categorías / metadatos
        if (video.categories!.isNotEmpty)
          Text(
            "Categoría: ${video.categories?.join(', ')}",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400, // Regular
              color: Colors.white70,
            ),
          ),
      ],
    );
  }
}
