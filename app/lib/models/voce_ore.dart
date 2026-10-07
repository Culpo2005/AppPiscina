/// Ore lavorate in una singola giornata (ordinarie + eventuali straordinari).
class VoceOre {
  final DateTime data;
  final double oreOrdinarie;
  final double oreStraordinarie;

  const VoceOre({
    required this.data,
    required this.oreOrdinarie,
    this.oreStraordinarie = 0,
  });

  double get totale => oreOrdinarie + oreStraordinarie;

  factory VoceOre.fromJson(Map<String, dynamic> json) => VoceOre(
        data: DateTime.parse(json['data'] as String),
        oreOrdinarie: (json['oreOrdinarie'] as num).toDouble(),
        oreStraordinarie: (json['oreStraordinarie'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'data': data.toIso8601String(),
        'oreOrdinarie': oreOrdinarie,
        'oreStraordinarie': oreStraordinarie,
      };
}
