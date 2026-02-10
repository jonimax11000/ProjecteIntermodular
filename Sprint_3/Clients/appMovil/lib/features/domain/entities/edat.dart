class Edat {
  final int id;
  final int edat;
  final String? descripcio;

  Edat({required this.id, required this.edat, this.descripcio});

  factory Edat.fromJson(Map<String, dynamic> json) => Edat(
        id: json['id'] as int,
        edat: json['edat'] as int,
        descripcio: json['descripcio'] as String?,
      );
}
