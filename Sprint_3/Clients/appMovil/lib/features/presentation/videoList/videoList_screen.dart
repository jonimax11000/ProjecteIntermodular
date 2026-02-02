import 'package:flutter/material.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/widgets/videos_layout.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/video/video_list.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/provider/wishlist_notifier.dart';



class VideolistScreen extends StatefulWidget {
  const VideolistScreen({super.key});

  @override
  State<VideolistScreen> createState() => _VideolistScreenState();
}

class _VideolistScreenState extends State<VideolistScreen> {

  @override
  Widget build(BuildContext context) {
    final _myWishList = ref.watch(wishlistProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          'Mi lista',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: _myWishList.length,
        itemBuilder: (context, index) {
          final video = _myWishList[index];
          return 
        },
      ),
    );
  }
}
