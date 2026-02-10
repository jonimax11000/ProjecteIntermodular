class Nivell {
  final int id;
  final int nivell; // Ahora es int
  final String? nom;

  Nivell({required this.id, required this.nivell, this.nom});

  factory Nivell.fromJson(Map<String, dynamic> json) => Nivell(
        id: json['id'] as int,
        nivell: json['nivell'] is int ? json['nivell'] as int : int.tryParse(json['nivell'].toString()) ?? 0,
        nom: json['nom'] as String?,
      );

  // Para mostrar en UI
  String get displayName => nom ?? 'Nivel $nivell';
}
