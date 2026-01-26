import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/series.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/screens/series_detall_screen.dart';
import 'package:flutter/material.dart';
import 'package:exercici_disseny_responsiu_stateful/features/core/service_locator.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/usecases/get_series.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  List<Series>? series;
  bool isLoading = true;
  String? errorMessage;
  late final GetSeries getSeries;

  @override
  void initState() {
    super.initState();
    getSeries = ServiceLocator().getSeries;
    _loadSeries();
  }

  Future<void> _loadSeries() async {
    try {
      final result = await getSeries();
      setState(() {
        series = result;
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
            "Series",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
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

    if (series == null || series!.isEmpty) {
      return const Center(
        child: Text(
          "No hay series",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        itemCount: series!.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          return SerieGridCard(serie: series![index]);
        },
      ),
    );
  }
}

class SerieGridCard extends StatelessWidget {
  final Series serie;

  const SerieGridCard({super.key, required this.serie});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SeriesDetallScreen(
              series: serie,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 8 / 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                color: const Color(0xFF2A2A2A),
                child: const Icon(
                  Icons.tv,
                  color: Colors.white38,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            serie.nom,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            "Temporada ${serie.temporada}",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }
}
