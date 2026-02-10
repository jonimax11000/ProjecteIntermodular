class Nivell {
  final int id;
  final String nivell;
  final String? nom;

  Nivell({required this.id, required this.nivell, this.nom});

  factory Nivell.fromJson(Map<String, dynamic> json) => Nivell(
        id: json['id'] as int,
        nivell: json['nivell'] as String,
        nom: json['nom'] as String?,
      );
}
