import 'package:exercici_disseny_responsiu_stateful/features/presentation/video/video_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/provider/wishlist_notifier.dart';

class VideolistScreen extends ConsumerWidget {
  const VideolistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Video> myWishList = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Mi lista'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: myWishList.isEmpty
          ? const Center(
              child: Text(
                'No tienes vídeos en favoritos',
                style: const TextStyle(color: Colors.white70),
              ),
            )
          : ListView.separated(
              itemCount: myWishList.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                final video = myWishList[index];

                return ListTile(
                  leading: const Icon(
                    Icons.play_circle_outline,
                    color: Colors.white70,
                  ),
                  title: Text(
                    video.titol,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: video.duracio.isNotEmpty
                      ? Text(
                          video.duracio,
                          style: const TextStyle(color: Colors.white54),
                        )
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.chevron_right),
                    color: Colors.white38,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoScreen(video: video),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoScreen(video: video),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
