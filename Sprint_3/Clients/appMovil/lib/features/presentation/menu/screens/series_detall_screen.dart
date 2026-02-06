import 'package:exercici_disseny_responsiu_stateful/features/core/service_locator.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/series.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_videos.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/screens/video_player_screen.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/screens/videos_screen.dart';
import 'package:flutter/material.dart';

class SeriesDetallScreen extends StatefulWidget {
  final Series series;
  const SeriesDetallScreen({super.key, required this.series});

  @override
  State<SeriesDetallScreen> createState() => _SeriesDetallScreenState();
}

class _SeriesDetallScreenState extends State<SeriesDetallScreen> {
  late List<Video>? videosBySerie = [];
  late final GetVideos getVideosBySerie;
  bool isLoading = true;
  String? errorMessage;

  void initState() {
    super.initState();
    getVideosBySerie = ServiceLocator().getVideos;
    _loadVideosBySerie();
  }

  void _loadVideosBySerie() async {
    try {
      final result = await getVideosBySerie.callBySerie(widget.series.id);
      setState(() {
        videosBySerie = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _onVideoTap(BuildContext context, Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VideoPlayerScreen(video: video, allVideos: videosBySerie!),
      ),
    );
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SeriesTitleWidget(
              seriesName:
                  widget.series.nom, // ajusta el campo si se llama distinto
              temporada: widget.series.temporada, // puede ser null
            ),
          ),
          Expanded(child: _buildVideosContent())
        ],
      ),
    );
  }

  Widget _buildVideosContent() {
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

    if (videosBySerie == null || videosBySerie!.isEmpty) {
      return const Center(
        child: Text(
          'No hay vídeos en esta serie',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        itemCount: videosBySerie!.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _onVideoTap(context, videosBySerie![index]),
            child: VideoGridCard(video: videosBySerie![index]),
          );
        },
      ),
    );
  }
}

class SeriesTitleWidget extends StatelessWidget {
  final String seriesName;
  final int? temporada;

  const SeriesTitleWidget({
    super.key,
    required this.seriesName,
    this.temporada,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          seriesName,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (temporada != null) ...[
          const SizedBox(height: 4),
          Text(
            'Temporada $temporada',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }
}
