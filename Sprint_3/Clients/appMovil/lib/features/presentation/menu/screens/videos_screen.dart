import 'package:exercici_disseny_responsiu_stateful/features/core/service_locator.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/categorias.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/edat.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/nivell.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/series.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_videos.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/screens/video_player_screen.dart';
import 'package:flutter/material.dart';

enum FilterType { none, name, categoria, edat, nivell, serie }

class VideosScreen extends StatefulWidget {
  final int? categoriaId;
  const VideosScreen({super.key, this.categoriaId});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  List<Video> videos = [];
  bool isLoading = true;
  String? errorMessage;
  late final GetVideos getVideos;

  FilterType activeFilter = FilterType.none;
  dynamic activeFilterValue;
  final TextEditingController _searchController = TextEditingController();

  List<Categorias> categories = [];
  List<Edat> edats = [];
  List<Nivell> nivells = [];
  List<Series> seriesList = [];

  @override
  void initState() {
    super.initState();
    getVideos = ServiceLocator().getVideos;
    _loadMetadata();
    if (widget.categoriaId != null) {
      activeFilter = FilterType.categoria;
      activeFilterValue = widget.categoriaId;
    }
    _loadVideos();
  }

  Future<void> _loadMetadata() async {
    try {
      final results = await Future.wait([
        ServiceLocator().getCategorias(),
        ServiceLocator().getEdats(),
        ServiceLocator().getNivells(),
        ServiceLocator().getSeries(),
      ]);
      setState(() {
        categories = results[0] as List<Categorias>;
        edats = results[1] as List<Edat>;
        nivells = results[2] as List<Nivell>;
        seriesList = results[3] as List<Series>;
      });
    } catch (e) {
      debugPrint('Error loading metadata: $e');
    }
  }

  Future<void> _loadVideos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      List<Video> result;
      switch (activeFilter) {
        case FilterType.name:
          result = await getVideos.callByName(activeFilterValue as String);
          break;
        case FilterType.categoria:
          result = await getVideos.callByCategoria(activeFilterValue as int);
          break;
        case FilterType.edat:
          result = await getVideos.callByEdat(activeFilterValue as int);
          break;
        case FilterType.nivell:
          result = await getVideos.callByNivell(activeFilterValue as int);
          break;
        case FilterType.serie:
          result = await getVideos.callBySerie(activeFilterValue as int);
          break;
        case FilterType.none:
        default:
          result = await getVideos();
          break;
      }

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

  void _onFilterChanged(FilterType type, dynamic value) {
    setState(() {
      activeFilter = type;
      activeFilterValue = value;
    });
    _loadVideos();
  }

  void _onVideoTap(BuildContext context, Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(video: video),
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
        children: [
          _buildSearchBar(),
          _buildFilterBar(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Videos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Buscar por nombre...",
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    _onFilterChanged(FilterType.none, null);
                  },
                )
              : null,
        ),
        onSubmitted: (val) {
          if (val.trim().isNotEmpty) {
            _onFilterChanged(FilterType.name, val.trim());
          } else {
            _onFilterChanged(FilterType.none, null);
          }
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          _FilterChip(
            label: "Todas",
            isSelected: activeFilter == FilterType.none,
            onSelected: () => _onFilterChanged(FilterType.none, null),
          ),
          _buildDropdownFilter<Categorias>(
            label: "Categoría",
            items: categories,
            getLabel: (c) => c.categoria,
            getValue: (c) => c.id,
            isActive: activeFilter == FilterType.categoria,
            currentValue: activeFilterValue,
            onChanged: (id) => _onFilterChanged(FilterType.categoria, id),
          ),
          _buildDropdownFilter<Edat>(
            label: "Edad",
            items: edats,
            getLabel: (e) => "+${e.edat}",
            getValue: (e) => e.id,
            isActive: activeFilter == FilterType.edat,
            currentValue: activeFilterValue,
            onChanged: (id) => _onFilterChanged(FilterType.edat, id),
          ),
          _buildDropdownFilter<Nivell>(
            label: "Nivel",
            items: nivells,
            getLabel: (n) => n.nivell,
            getValue: (n) => n.id,
            isActive: activeFilter == FilterType.nivell,
            currentValue: activeFilterValue,
            onChanged: (id) => _onFilterChanged(FilterType.nivell, id),
          ),
          _buildDropdownFilter<Series>(
            label: "Serie",
            items: seriesList,
            getLabel: (s) => s.nom,
            getValue: (s) => s.id,
            isActive: activeFilter == FilterType.serie,
            currentValue: activeFilterValue,
            onChanged: (id) => _onFilterChanged(FilterType.serie, id),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter<T>({
    required String label,
    required List<T> items,
    required String Function(T) getLabel,
    required int Function(T) getValue,
    required bool isActive,
    required dynamic currentValue,
    required Function(int) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<int>(
        child: Chip(
          backgroundColor:
              isActive ? Colors.blueAccent : const Color(0xFF2A2A2A),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isActive
                    ? items.any((i) => getValue(i) == currentValue)
                        ? getLabel(items
                            .firstWhere((i) => getValue(i) == currentValue))
                        : label
                    : label,
                style: const TextStyle(color: Colors.white),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
        itemBuilder: (context) => items
            .map((item) => PopupMenuItem<int>(
                  value: getValue(item),
                  child: Text(getLabel(item)),
                ))
            .toList(),
        onSelected: onChanged,
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

    if (videos.isEmpty) {
      return const Center(
        child: Text(
          "No hay vídeos para este filtro",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        itemCount: videos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 9,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _onVideoTap(context, videos[index]),
            child: VideoGridCard(video: videos[index]),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: Colors.blueAccent,
        backgroundColor: const Color(0xFF2A2A2A),
        labelStyle: const TextStyle(color: Colors.white),
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
