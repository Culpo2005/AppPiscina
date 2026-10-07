import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum LivelloCorso { base, intermedio, avanzato }

extension LivelloCorsoX on LivelloCorso {
  String get label {
    switch (this) {
      case LivelloCorso.base:
        return 'Base';
      case LivelloCorso.intermedio:
        return 'Intermedio';
      case LivelloCorso.avanzato:
        return 'Avanzato';
    }
  }

  Color get color {
    switch (this) {
      case LivelloCorso.base:
        return AppColors.success;
      case LivelloCorso.intermedio:
        return AppColors.info;
      case LivelloCorso.avanzato:
        return AppColors.purple;
    }
  }
}

/// Un turno di lavoro: un corso/attività con orario, livello e corsia.
class Turno {
  final String id;
  final DateTime inizio;
  final DateTime fine;
  final String corso;
  final LivelloCorso livello;
  final String corsia;
  final String? note;

  const Turno({
    required this.id,
    required this.inizio,
    required this.fine,
    required this.corso,
    required this.livello,
    required this.corsia,
    this.note,
  });

  factory Turno.fromJson(Map<String, dynamic> json) {
    return Turno(
      id: json['id'] as String,
      inizio: DateTime.parse(json['inizio'] as String),
      fine: DateTime.parse(json['fine'] as String),
      corso: json['corso'] as String,
      livello: LivelloCorso.values.firstWhere(
        (l) => l.name == json['livello'],
        orElse: () => LivelloCorso.base,
      ),
      corsia: json['corsia'] as String,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'inizio': inizio.toIso8601String(),
        'fine': fine.toIso8601String(),
        'corso': corso,
        'livello': livello.name,
        'corsia': corsia,
        if (note != null) 'note': note,
      };
}
