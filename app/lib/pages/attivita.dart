import 'package:flutter/material.dart';
// import '../theme/app_theme.dart';


class Attivita {
  final String nome;
  final String descrizione;
  final String immagine;

  Attivita({
    required this.nome,
    required this.descrizione,
    required this.immagine,
  });

  factory Attivita.fromJson(Map<String, dynamic> json) {
    return Attivita(
      nome: json['nome']?.toString() ?? '',
      descrizione: json['descrizione']?.toString() ?? '',
      immagine: json['immagine']?.toString() ?? '',
    );
  }
}



class AttivitaPage extends StatelessWidget {
  final List<Attivita> attivita;

  const AttivitaPage({
    super.key,
    required this.attivita,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Attività'),
      // ),
      body: attivita.isEmpty
          ? const Center(
              child: Text(
                'Nessuna attività disponibile',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: attivita.length,
              itemBuilder: (context, index) {
                final attivitaCorrente = attivita[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // IMMAGINE
                      SizedBox(
                        width: double.infinity,
                        height: 180,
                        child: Image.network(
                          attivitaCorrente.immagine,
                          fit: BoxFit.cover,

                          // Immagine alternativa in caso di errore
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

                      // CONTENUTO
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attivitaCorrente.nome,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              attivitaCorrente.descrizione,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}