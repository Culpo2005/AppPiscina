import 'package:flutter/material.dart';

class Evento {
  final String id;
  final String nome;
  final String descrizione;
  final String data;
  final String ora;
  final String luogo;
  final String immagine;

  Evento({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.data,
    required this.ora,
    required this.luogo,
    required this.immagine,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      descrizione: json['descrizione']?.toString() ?? '',
      data: json['data']?.toString() ?? '',
      ora: json['ora']?.toString() ?? '',
      luogo: json['luogo']?.toString() ?? '',
      immagine: json['immagine']?.toString() ?? '',
    );
  }
}

class EventiPage extends StatelessWidget {
  final List<Evento> eventi;

  const EventiPage({
    super.key,
    this.eventi = const [],
  });

  Widget _buildEvento(BuildContext context, Evento evento) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMMAGINE
          if (evento.immagine.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 180,
              child: Image.network(
                evento.immagine,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NOME
                Text(
                  evento.nome,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // DESCRIZIONE
                if (evento.descrizione.isNotEmpty)
                  Text(
                    evento.descrizione,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                    ),
                  ),

                const SizedBox(height: 16),

                // DATA
                if (evento.data.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(evento.data),
                    ],
                  ),

                const SizedBox(height: 8),

                // ORA
                if (evento.ora.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(evento.ora),
                    ],
                  ),

                const SizedBox(height: 8),

                // LUOGO
                if (evento.luogo.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(evento.luogo),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Eventi'),
      ),
      body: eventi.isEmpty
          ? const Center(
              child: Text(
                'Nessun evento disponibile',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: eventi.length,
              itemBuilder: (context, index) {
                return _buildEvento(
                  context,
                  eventi[index],
                );
              },
            ),
    );
  }
}