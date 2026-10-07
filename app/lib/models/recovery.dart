class Recovery {
  final String id;
  final String corsista;
  final String corsistaNome;
  final String corsoOriginale;
  final DateTime dataCorso;
  final bool prenotato;
  final DateTime? dataRecupero;
  final String disponibilita; // ID del corso dove recuperare

  Recovery({
    required this.id,
    required this.corsista,
    required this.corsistaNome,
    required this.corsoOriginale,
    required this.dataCorso,
    this.prenotato = false,
    this.dataRecupero,
    required this.disponibilita,
  });

  factory Recovery.fromJson(Map<String, dynamic> json) {
    return Recovery(
      id: json['id'] ?? '',
      corsista: json['corsista'] ?? '',
      corsistaNome: json['corsistaNome'] ?? '',
      corsoOriginale: json['corsoOriginale'] ?? '',
      dataCorso: json['dataCorso'] != null ? DateTime.parse(json['dataCorso']) : DateTime.now(),
      prenotato: json['prenotato'] ?? false,
      dataRecupero: json['dataRecupero'] != null ? DateTime.parse(json['dataRecupero']) : null,
      disponibilita: json['disponibilita'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'corsista': corsista,
      'corsistaNome': corsistaNome,
      'corsoOriginale': corsoOriginale,
      'dataCorso': dataCorso.toIso8601String(),
      'prenotato': prenotato,
      'dataRecupero': dataRecupero?.toIso8601String(),
      'disponibilita': disponibilita,
    };
  }
}
