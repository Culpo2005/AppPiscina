import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'turno.dart';

enum StatoSostituzione { confermata, inAttesa, rifiutata }

extension StatoSostituzioneX on StatoSostituzione {
  String get label {
    switch (this) {
      case StatoSostituzione.confermata:
        return 'Confermata';
      case StatoSostituzione.inAttesa:
        return 'In attesa';
      case StatoSostituzione.rifiutata:
        return 'Rifiutata';
    }
  }

  Color get color {
    switch (this) {
      case StatoSostituzione.confermata:
        return AppColors.success;
      case StatoSostituzione.inAttesa:
        return AppColors.warning;
      case StatoSostituzione.rifiutata:
        return AppColors.danger;
    }
  }
}

/// Una sostituzione, programmata o già avvenuta, tra due persone.
class Sostituzione {
  final String id;
  final DateTime data;
  final DateTime orarioInizio;
  final DateTime orarioFine;
  final String personaSostituita;
  final String personaSostituente;
  final String corso;
  final LivelloCorso livello;
  final String corsia;
  final StatoSostituzione stato;

  const Sostituzione({
    required this.id,
    required this.data,
    required this.orarioInizio,
    required this.orarioFine,
    required this.personaSostituita,
    required this.personaSostituente,
    required this.corso,
    required this.livello,
    required this.corsia,
    required this.stato,
  });

  factory Sostituzione.fromJson(Map<String, dynamic> json) {
    return Sostituzione(
      id: json['id'] as String,
      data: DateTime.parse(json['data'] as String),
      orarioInizio: DateTime.parse(json['orarioInizio'] as String),
      orarioFine: DateTime.parse(json['orarioFine'] as String),
      personaSostituita: json['personaSostituita'] as String,
      personaSostituente: json['personaSostituente'] as String,
      corso: json['corso'] as String,
      livello: LivelloCorso.values.firstWhere(
        (l) => l.name == json['livello'],
        orElse: () => LivelloCorso.base,
      ),
      corsia: json['corsia'] as String,
      stato: StatoSostituzione.values.firstWhere(
        (s) => s.name == json['stato'],
        orElse: () => StatoSostituzione.inAttesa,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data.toIso8601String(),
        'orarioInizio': orarioInizio.toIso8601String(),
        'orarioFine': orarioFine.toIso8601String(),
        'personaSostituita': personaSostituita,
        'personaSostituente': personaSostituente,
        'corso': corso,
        'livello': livello.name,
        'corsia': corsia,
        'stato': stato.name,
      };
}
