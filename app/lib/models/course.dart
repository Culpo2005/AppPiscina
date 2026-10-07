enum LivelloCourse { base, intermedio, avanzato }

class Course {
  final String id;
  final String nome;
  final DateTime dataOra;
  final String istruttore;
  final List<String> corsisti; // IDs dei corsisti
  final LivelloCourse livello;
  final double? kmNuoto; // Aggiunto per collaboratori
  final List<InfortunioCorso> infortuni; // Aggiunto per collaboratori

  Course({
    required this.id,
    required this.nome,
    required this.dataOra,
    required this.istruttore,
    required this.corsisti,
    this.livello = LivelloCourse.base,
    this.kmNuoto,
    this.infortuni = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    LivelloCourse livello = LivelloCourse.base;
    if (json['livello'] == 'intermedio') {
      livello = LivelloCourse.intermedio;
    } else if (json['livello'] == 'avanzato') {
      livello = LivelloCourse.avanzato;
    }

    return Course(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      dataOra: json['dataOra'] != null ? DateTime.parse(json['dataOra']) : DateTime.now(),
      istruttore: json['istruttore'] ?? '',
      corsisti: List<String>.from(json['corsisti'] ?? []),
      livello: livello,
      kmNuoto: json['kmNuoto']?.toDouble(),
      infortuni: (json['infortuni'] as List?)
          ?.map((i) => InfortunioCorso.fromJson(i))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'dataOra': dataOra.toIso8601String(),
      'istruttore': istruttore,
      'corsisti': corsisti,
      'livello': livello.toString().split('.').last,
      'kmNuoto': kmNuoto,
      'infortuni': infortuni.map((i) => i.toJson()).toList(),
    };
  }
}

class InfortunioCorso {
  final String corsista;
  final String corsistaNome;
  final String descrizione;
  final DateTime data;

  InfortunioCorso({
    required this.corsista,
    required this.corsistaNome,
    required this.descrizione,
    required this.data,
  });

  factory InfortunioCorso.fromJson(Map<String, dynamic> json) {
    return InfortunioCorso(
      corsista: json['corsista'] ?? '',
      corsistaNome: json['corsistaNome'] ?? '',
      descrizione: json['descrizione'] ?? '',
      data: json['data'] != null ? DateTime.parse(json['data']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'corsista': corsista,
      'corsistaNome': corsistaNome,
      'descrizione': descrizione,
      'data': data.toIso8601String(),
    };
  }
}

class Corsista {
  final String id;
  final String nome;
  final String email;
  final bool haInfortuni;
  final List<String> infortuni;

  Corsista({
    required this.id,
    required this.nome,
    required this.email,
    this.haInfortuni = false,
    this.infortuni = const [],
  });

  factory Corsista.fromJson(Map<String, dynamic> json) {
    return Corsista(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      haInfortuni: json['haInfortuni'] ?? false,
      infortuni: List<String>.from(json['infortuni'] ?? []),
    );
  }
}
