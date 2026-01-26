import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  final Function(String) onSearch;
  const SearchWidget({super.key, required this.onSearch});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final SearchController _controller = SearchController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SearchBar(
        controller: _controller,
        hintText: 'Buscar vídeos y series ...',
        leading: const Icon(Icons.search),
        onChanged: widget.onSearch,
      ),
    );
  }
}
