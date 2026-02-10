import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatefulWidget {
  final void Function(String url) initialize;

  const VideoPlayerWidget({
    super.key,
    required this.initialize,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
