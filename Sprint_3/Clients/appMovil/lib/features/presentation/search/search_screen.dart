import 'package:exercici_disseny_responsiu_stateful/features/core/service_locator.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/series.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/screens/series_screen.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/widgets/video_carousel.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/screens/video_player_screen.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/search/widgets/search_widget.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Video> _videos = [];
  List<Series> _series = [];
  bool isLoading = false;

  void _onSearch(String query) async {
    if (query.length < 2) return;

    setState(() {
      isLoading = true;
    });

    try {
      final videos = await ServiceLocator().getVideos.callByName(query);
      final series = await ServiceLocator().getSeries.callByName(query);

      setState(() {
        _videos = videos;
        _series = series;
      });
    } catch (e) {
      debugPrint('Error en búsqueda: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onVideoTap(Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(video: video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchWidget(onSearch: _onSearch),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        Expanded(
          child: ListView(
            children: [
              if (_videos.isNotEmpty) ...[
                const Text('Vídeos', style: TextStyle(fontSize: 18)),
                ..._videos.map((v) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: VideoCard(
                          video: v,
                          onTap: () => _onVideoTap(v),
                        ),
                      ),
                    )),
              ],
              if (_series.isNotEmpty) ...[
                const Text('Series', style: TextStyle(fontSize: 18)),
                ..._series.map((s) => SerieGridCard(serie: s)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
