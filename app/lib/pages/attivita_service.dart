import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'attivita.dart';

/// Carica le attività svolte dal cliente da un file JSON locale
/// (nessuna chiamata API: i dati sono letti da un asset incluso nell'app).
///
/// NOTA: `_assetPath` deve corrispondere esattamente al percorso reale del
/// file nel progetto e a quanto dichiarato in pubspec.yaml sotto
/// `flutter: assets:`. Se la cartella delle schermate cliente non è
/// `lib/screens/cliente/`, aggiorna questa costante di conseguenza.
class AttivitaService {
  static const String _assetPath = 'attivita_svolte.json';

  static Future<List<Attivita>> getAttivitaSvolte() async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final List<dynamic> lista = jsonData['attivita'] as List<dynamic>;

    return lista
        .map((e) => Attivita.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
