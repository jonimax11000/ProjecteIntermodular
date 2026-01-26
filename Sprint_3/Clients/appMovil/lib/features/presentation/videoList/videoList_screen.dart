import 'package:flutter/material.dart';

class VideolistScreen extends StatelessWidget {
  const VideolistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          'Lista de Videos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Text(
          'Aquí va la lista de videos',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
