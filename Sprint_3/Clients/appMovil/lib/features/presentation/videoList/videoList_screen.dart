import 'package:exercici_disseny_responsiu_stateful/features/core/service_locator.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/screens/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/provider/wishlist_notifier.dart';

class VideolistScreen extends ConsumerWidget {
  const VideolistScreen({super.key});

  void _onVideoTap(BuildContext context, Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(video: video, allVideos: []),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myWishList = ref.watch(wishlistProvider);
    final wishlistNotifier = ref.read(wishlistProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TÍTULO "FAVORITOS"
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Text(
              'Favoritos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // LISTA DE FAVORITOS
          Expanded(
            child: myWishList.isEmpty
                ? const Center(
                    child: Text(
                      'No tienes vídeos en favoritos',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: myWishList.length,
                    itemBuilder: (context, index) {
                      final video = myWishList[index];
                      return GestureDetector(
                        onTap: () => _onVideoTap(context, video),
                        child: _VideoWishlistCard(
                          video: video,
                          onDelete: () {
                            wishlistNotifier.remove(video);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _VideoWishlistCard extends StatelessWidget {
  final Video video;
  final VoidCallback onDelete;

  const _VideoWishlistCard({
    required this.video,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String videoURL = ServiceLocator().getVideoUrl();

    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 10),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child: SizedBox(
              width: 150,
              height: 90,
              child: video.thumbnailURL.isNotEmpty
                  ? Image.network(
                      "$videoURL${video.thumbnailURL}",
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (_, __, ___) => _thumbnailFallback(),
                    )
                  : _thumbnailFallback(),
            ),
          ),

          const SizedBox(width: 16),

          // Título
          Expanded(
            child: Text(
              video.titol,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Papelera
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _thumbnailFallback() {
    return Container(
      color: Colors.black26,
      child: const Icon(
        Icons.play_circle_outline,
        color: Colors.white38,
        size: 40,
      ),
    );
  }
}
