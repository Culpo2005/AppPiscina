const _giorniSettimana = [
  'Lunedì',
  'Martedì',
  'Mercoledì',
  'Giovedì',
  'Venerdì',
  'Sabato',
  'Domenica',
];

const _mesiAnno = [
  'gennaio',
  'febbraio',
  'marzo',
  'aprile',
  'maggio',
  'giugno',
  'luglio',
  'agosto',
  'settembre',
  'ottobre',
  'novembre',
  'dicembre',
];

/// Es. 4.5 -> "4,5", 8.0 -> "8"
String formatOre(double ore) {
  if (ore == ore.roundToDouble()) return ore.toInt().toString();
  return ore.toStringAsFixed(1).replaceAll('.', ',');
}

/// Es. 09:05
String formatOra(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Es. 29/08/2026
String formatDataBreve(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Es. Sabato
String formatGiorno(DateTime d) => _giorniSettimana[d.weekday - 1];

/// Es. Sabato 29 agosto
String formatDataEstesa(DateTime d) =>
    '${_giorniSettimana[d.weekday - 1]} ${d.day} ${_mesiAnno[d.month - 1]}';
