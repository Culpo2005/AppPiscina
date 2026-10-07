// import 'main_shell.dart';
import 'package:flutter/material.dart';

class CorsoAbbonamento {
  final String id;
  final String nomeCorso;
  final String giorno;
  final String ora;
  final String istruttore;
  final String corsia;
  final String nota;

  CorsoAbbonamento({
    required this.id,
    required this.nomeCorso,
    required this.giorno,
    required this.ora,
    required this.istruttore,
    required this.corsia,
    this.nota = '',
  });

  factory CorsoAbbonamento.fromJson(Map<String, dynamic> json) {
    return CorsoAbbonamento(
      id: json['id']?.toString() ?? '',
      nomeCorso: json['nomeCorso']?.toString() ?? '',
      giorno: json['giorno']?.toString() ?? '',
      ora: json['ora']?.toString() ?? '',
      istruttore: json['istruttore']?.toString() ?? '',
      corsia: json['corsia']?.toString() ?? '',
      nota: json['nota']?.toString() ?? '',
    );
  }
}

class Recupero {
  final String id;
  final String nomeCorso;
  final String giorno;
  final String ora;
  final String istruttore;
  final String corsia;
  final bool prenotato;
  final String disponibilita;

  Recupero({
    required this.id,
    required this.nomeCorso,
    required this.giorno,
    required this.ora,
    required this.istruttore,
    required this.corsia,
    this.prenotato = false,
    required this.disponibilita,  
  });

  factory Recupero.fromJson(Map<String, dynamic> json) {
    return Recupero(
      id: json['id']?.toString() ?? '',
      nomeCorso: json['nomeCorso']?.toString() ?? '',
      giorno: json['giorno']?.toString() ?? '',
      ora: json['ora']?.toString() ?? '',
      istruttore: json['istruttore']?.toString() ?? '',
      corsia: json['corsia']?.toString() ?? '',
      prenotato: json['prenotato'] == true,
      disponibilita: json['disponibilita']?.toString() ?? '',
    );
  }
}

class AbbonamentiPage extends StatefulWidget {
  static void _defaultOnPrenotaRecupero(Recupero recupero) {}
  final List<CorsoAbbonamento> corsi;
  final List<Recupero> recuperi;
  final void Function(Recupero) onPrenotaRecupero;
  const AbbonamentiPage({
    super.key,
    this.corsi = const [],
    this.recuperi = const [],
    this.onPrenotaRecupero = _defaultOnPrenotaRecupero,
  });

  @override
  State<AbbonamentiPage> createState() => _AbbonamentiPageState();
}

class _AbbonamentiPageState extends State<AbbonamentiPage> {
  late List<CorsoAbbonamento> _corsi;
  late List<Recupero> _recuperi;

  @override
  void initState() {
    super.initState();

    _corsi = List.from(widget.corsi);
    _recuperi = List.from(widget.recuperi);
  }

  void _modificaNota(CorsoAbbonamento corso) {
    final controller = TextEditingController(
      text: corso.nota,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nota per l\'istruttore'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Scrivi una nota...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                final nuovaNota = controller.text.trim();

                setState(() {
                  final index = _corsi.indexWhere(
                    (c) => c.id == corso.id,
                  );

                  if (index != -1) {
                    _corsi[index] = CorsoAbbonamento(
                      id: corso.id,
                      nomeCorso: corso.nomeCorso,
                      giorno: corso.giorno,
                      ora: corso.ora,
                      istruttore: corso.istruttore,
                      corsia: corso.corsia,
                      nota: nuovaNota,
                    );
                  }
                });

                /*
                 * QUI DOVRAI INVIARE LA NOTA TRAMITE MQTT.
                 *
                 * Esempio:
                 *
                 * mqttService.inviaNota(
                 *   corsoId: corso.id,
                 *   nota: nuovaNota,
                 * );
                 */

                Navigator.pop(context);
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  void _prenotaRecupero(Recupero recupero) {
    if (recupero.prenotato) {
      return;
    }

    /*
     * QUI DOVRAI INVIARE LA RICHIESTA DI PRENOTAZIONE
     * TRAMITE MQTT.
     *
     * Esempio:
     *
     * mqttService.prenotaRecupero(
     *   recuperoId: recupero.id,
     * );
     */

    setState(() {
      final index = _recuperi.indexWhere(
        (r) => r.id == recupero.id,
      );

      if (index != -1) {
        final r = _recuperi[index];

        _recuperi[index] = Recupero(
          id: r.id,
          nomeCorso: r.nomeCorso,
          giorno: r.giorno,
          ora: r.ora,
          istruttore: r.istruttore,
          corsia: r.corsia,
          prenotato: true,
          disponibilita: r.disponibilita,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recupero prenotato'),
      ),
    );
  }

  Widget _buildCorso(CorsoAbbonamento corso) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              corso.nomeCorso,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.calendar_today_outlined),
                const SizedBox(width: 10),
                Text(corso.giorno),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 10),
                Text(corso.ora),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.person_outline),
                const SizedBox(width: 10),
                Text(corso.istruttore),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.pool_outlined),
                const SizedBox(width: 10),
                Text('Corsia ${corso.corsia}'),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nota per l\'istruttore',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _modificaNota(corso);
                  },
                ),
              ],
            ),

            if (corso.nota.isEmpty)
              Text(
                'Nessuna nota',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(corso.nota),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecupero(Recupero recupero) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recupero.nomeCorso,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 20),
                const SizedBox(width: 8),
                Text(recupero.giorno),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text(recupero.ora),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.person_outline, size: 20),
                const SizedBox(width: 8),
                Text(recupero.istruttore),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.pool_outlined, size: 20),
                const SizedBox(width: 8),
                Text('Corsia ${recupero.corsia}'),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: recupero.prenotato
                    ? null
                    : () {
                        _prenotaRecupero(recupero);
                      },
                child: Text(
                  recupero.prenotato
                      ? 'Recupero prenotato'
                      : 'Prenota recupero',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Abbonamenti'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_corsi.isNotEmpty) ...[
            const Text(
              'I miei corsi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ..._corsi.map(
              (corso) => _buildCorso(corso),
            ),
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'Nessun corso disponibile',
                ),
              ),
            ),

          const SizedBox(height: 20),

          if (_recuperi.isNotEmpty) ...[
            const Text(
              'Recuperi disponibili',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ..._recuperi.map(
              (recupero) => _buildRecupero(recupero),
            ),
          ],
        ],
      ),
    );
  }
}