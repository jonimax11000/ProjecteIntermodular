import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/screens/series_screen.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/screens/videos_screen.dart';
import 'package:flutter/material.dart';

class Submenu extends StatelessWidget {
  const Submenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF121212),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*Flexible(
            fit: FlexFit.loose,
            child: _HoverSubmenuButton(
              child: const Text('Categorías',
                  style: TextStyle(color: Colors.white)),
              menuChildren: const [
                _HoverMenuItem(text: 'Acción'),
                _HoverMenuItem(text: 'Drama'),
                _HoverMenuItem(text: 'Terror'),
              ],
            ),
          ),
          const SizedBox(width: 20),*/
          Flexible(
            fit: FlexFit.loose,
            child: _HoverSubmenuButton(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.movie, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Vídeos', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const VideosScreen(categoriaId: null))),
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            fit: FlexFit.loose,
            child: _HoverSubmenuButton(
              child: Center(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.tv, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Series', style: TextStyle(color: Colors.white)),
                ],
              )),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SeriesScreen())),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de Submenu con efecto hover y opcionalmente con hijos
class _HoverSubmenuButton extends StatefulWidget {
  final Widget child;
  final List<Widget>? menuChildren;
  final VoidCallback? onPressed;

  const _HoverSubmenuButton({
    required this.child,
    this.menuChildren,
    this.onPressed,
  });

  @override
  State<_HoverSubmenuButton> createState() => _HoverSubmenuButtonState();
}

class _HoverSubmenuButtonState extends State<_HoverSubmenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform:
            _isHovered ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
        child: widget.menuChildren != null && widget.menuChildren!.isNotEmpty
            ? SubmenuButton(
                child: widget.child,
                menuChildren: widget.menuChildren!,
                menuStyle: MenuStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFF121212)),
                  elevation: MaterialStateProperty.all(0),
                ),
              )
            : TextButton(
                onPressed: widget.onPressed,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFF121212)),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                          color: Color.fromARGB(255, 119, 119, 119),
                          width: 1), // contorno blanco
                    ),
                  ),
                  alignment: Alignment.center, // mantiene el botón centrado
                ),
                child: Center(
                  child: widget.child, // aquí el Row se centra dentro del botón
                ),
              ),
      ),
    );
  }
}
/*
/// Items del menú desplegable con hover
class _HoverMenuItem extends StatefulWidget {
  final String text;
  const _HoverMenuItem({required this.text});

  @override
  State<_HoverMenuItem> createState() => _HoverMenuItemState();
}

class _HoverMenuItemState extends State<_HoverMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform:
            _isHovered ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
        child: MenuItemButton(
          onPressed: () {},
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xFF121212)),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          child: Text(widget.text, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
*/
