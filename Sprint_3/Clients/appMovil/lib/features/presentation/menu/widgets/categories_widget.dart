import 'package:exercici_disseny_responsiu_stateful/features/core/service_locator.dart';
import 'package:exercici_disseny_responsiu_stateful/features/domain/entities/categorias.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/screens/videos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget(
      {super.key, this.selectedCategoriaId, this.onCategoriaSelected});

  final int? selectedCategoriaId;
  final void Function(int?)? onCategoriaSelected;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Categorias>>(
      future: ServiceLocator().getCategorias(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories found'));
        }
        final categories = snapshot.data!;
        final hasCategories = categories.isNotEmpty;
        if (categories.isEmpty) {
          return const Center(child: Text('No categories available'));
        }
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: hasCategories ? categories.length + 1 : 0,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (categories.isEmpty) {
                return const SizedBox.shrink();
              }

              if (index == 0) {
                return ElevatedButton(
                    onPressed: () => onCategoriaSelected!(null),
                    child: const Text("Totes"));
              }

              final categoria = categories[index - 1];
              final isSelected = categoria.id == selectedCategoriaId;

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A2A2A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onCategoriaSelected != null
                    ? () => onCategoriaSelected!(categoria.id)
                    : null,
                child: Text(categoria.categoria.toUpperCase()),
              );
            },
          ),
        );
      },
    );
  }
}
