class Edat {
  final int id;
  final int edat;
  final String? descripcio;

  Edat({required this.id, required this.edat, this.descripcio});

  factory Edat.fromJson(Map<String, dynamic> json) => Edat(
        id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
        edat: json['edat'] is int ? json['edat'] as int : int.tryParse(json['edat'].toString()) ?? 0,
        descripcio: json['descripcio'] as String?,
      );
}
