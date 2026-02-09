import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/video.dart';

class WishlistNotifier extends StateNotifier<List<Video>> {
  WishlistNotifier() : super([]);

  void add(Video video) {
    if (!state.any((v) => v.id == video.id)) {
      state = [...state, video];
    }
  }

  void remove(Video video) {
    state = state.where((v) => v.id != video.id).toList();
  }

  bool contains(Video video) {
    return state.any((v) => v.id == video.id);
  }
}

// Provider global
final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, List<Video>>(
        (ref) => WishlistNotifier());
