import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../main.dart';

import 'attivita.dart';
import 'abbonamenti.dart';
import 'eventi.dart';

import '../services/mqtt_service.dart';

import '../../models/course.dart';
import '../../models/recovery.dart';

import 'login_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late AuthService _authService;
  late MqttService _mqttService;

  // ============================================================
  // DATI RICEVUTI DA MQTT
  // ============================================================

  List<Attivita> _attivita = [];

  List<CorsoAbbonamento> _corsi = [];

  List<Recupero> _recuperi = [];

  List<Evento> _eventi = [];

  double _calorie = 0;

  bool _mqttLoading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _authService = context.read<AuthService>();

    _mqttService = MqttService(
      broker: '192.168.1.164',
      port: 5000,
    );

    _inizializzaMqtt();
  }

  // ============================================================
  // INIZIALIZZAZIONE MQTT
  // ============================================================

  Future<void> _inizializzaMqtt() async {
    try {
      await _mqttService.connect();

      // --------------------------------------------------------
      // ATTIVITÀ
      // --------------------------------------------------------

      _mqttService.onAttivitaResponse = (data) {
        final lista = data['attivita'];

        if (lista is! List) {
          debugPrint('MQTT: formato attività non valido');
          return;
        }

        final nuoveAttivita = lista
            .map(
              (json) => Attivita.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();

        if (!mounted) return;

        setState(() {
          _attivita = nuoveAttivita;
        });
      };

      // --------------------------------------------------------
      // EVENTI
      // --------------------------------------------------------

      _mqttService.onEventiResponse = (data) {
        final lista = data['eventi'];

        if (lista is! List) {
          debugPrint('MQTT: formato eventi non valido');
          return;
        }

        final nuoviEventi = lista
            .map(
              (json) => Evento.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();

        if (!mounted) return;

        setState(() {
          _eventi = nuoviEventi;
        });
      };

      // --------------------------------------------------------
      // CORSI
      // --------------------------------------------------------

      _mqttService.onCorsiResponse = (data) {
        final lista = data['corsi'];

        if (lista is! List) {
          debugPrint('MQTT: formato corsi non valido');
          return;
        }

        final nuoviCorsi = lista
            .map(
              (json) => CorsoAbbonamento.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();

        if (!mounted) return;

        setState(() {
          _corsi = nuoviCorsi;
        });
      };

      // --------------------------------------------------------
      // RECUPERI
      // --------------------------------------------------------

      _mqttService.onRecuperiResponse = (data) {
        final lista = data['recuperi'];

        if (lista is! List) {
          debugPrint('MQTT: formato recuperi non valido');
          return;
        }

        final nuoviRecuperi = lista
            .map(
              (json) => Recupero.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();

        if (!mounted) return;

        setState(() {
          _recuperi = nuoviRecuperi;
        });
      };

      // --------------------------------------------------------
      // CALORIE
      // --------------------------------------------------------

      _mqttService.onCalorieResponse = (data) {
        final valore = data['calorie'];

        if (valore == null) {
          return;
        }

        if (!mounted) return;

        setState(() {
          _calorie = double.tryParse(
                valore.toString(),
              ) ??
              0;
        });
      };

      // --------------------------------------------------------
      // PRENOTAZIONE RECUPERO
      // --------------------------------------------------------

      _mqttService.onPrenotaRecuperoResponse = (data) {
        final success = data['success'] == true;

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Recupero prenotato con successo'
                  : 'Errore nella prenotazione del recupero',
            ),
          ),
        );

        if (success) {
          _richiediDati();
        }
      };

      // --------------------------------------------------------
      // RICHIESTA DATI
      // --------------------------------------------------------

      await _richiediDati();

      if (!mounted) return;

      setState(() {
        _mqttLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Errore inizializzazione MQTT: $e',
      );

      if (!mounted) return;

      setState(() {
        _mqttLoading = false;
      });
    }
  }

  // ============================================================
  // RICHIESTA DI TUTTI I DATI
  // ============================================================

  Future<void> _richiediDati() async {
    final user = _authService.user;
    final token = _authService.token;

    if (user == null) {
      debugPrint('MQTT: utente non disponibile');
      return;
    }

    if (token == null) {
      debugPrint('MQTT: token non disponibile');
      return;
    }

    final userId = user.id;

    // Attività
    _mqttService.requestAttivita(
      userId: userId,
      token: token,
    );

    // Corsi
    _mqttService.requestCorsi(
      userId: userId,
      token: token,
    );

    // Recuperi
    _mqttService.requestRecuperi(
      userId: userId,
      token: token,
    );

    // Eventi
    _mqttService.requestEventi(
      userId: userId,
      token: token,
    );

    // Calorie
    _mqttService.requestCalorie(
      userId: userId,
      token: token,
    );
  }

  // ============================================================
  // PRENOTAZIONE RECUPERO
  // ============================================================

  void _prenotaRecupero(Recupero recupero) {
    final token = _authService.token;

    if (token == null) {
      return;
    }

    _mqttService.requestPrenotaRecupero(
      recuperoId: recupero.id,
      disponibilita: recupero.disponibilita,
      token: token,
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void _esci() {
    _mqttService.disconnect();

    _authService.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // NAVIGAZIONE
  // ============================================================

  List<_NavDestination> _destinazioni() {
    return [
      _NavDestination(
        titolo: 'Home',
        icona: Icons.home_outlined,
        iconaAttiva: Icons.home,
        pagina: _HomeTabCliente(
          authService: _authService,
          calorie: _calorie,
          corsi: _corsi,
          attivita: _attivita,
          onRefresh: _richiediDati,
        ),
      ),

      // ========================================================
      // ATTIVITÀ
      // ========================================================

      _NavDestination(
        titolo: 'Attività',
        icona: Icons.fitness_center_outlined,
        iconaAttiva: Icons.fitness_center,
        pagina: AttivitaPage(
          attivita: _attivita,
        ),
      ),

      // ========================================================
      // ABBONAMENTI
      // ========================================================

      _NavDestination(
        titolo: 'Abbonamenti',
        titoloAppBar: 'I miei abbonamenti',
        icona: Icons.card_membership_outlined,
        iconaAttiva: Icons.card_membership,
        pagina: AbbonamentiPage(
          corsi: _corsi,
          recuperi: _recuperi,
          onPrenotaRecupero: _prenotaRecupero, 
        ),
      ),

      // ========================================================
      // EVENTI
      // ========================================================

      _NavDestination(
        titolo: 'Eventi',
        icona: Icons.event_outlined,
        iconaAttiva: Icons.event,
        nuovo: true,
        pagina: EventiPage(
          eventi: _eventi,
        ),
      ),

      // ========================================================
      // AREA PERSONALE
      // ========================================================

      const _NavDestination(
        titolo: 'Area personale',
        icona: Icons.person_outline,
        iconaAttiva: Icons.person,
        pagina: _PaginaSegnaposto(
          titolo: 'Area personale',
          icona: Icons.person,
        ),
      ),

      // ========================================================
      // COLLABORATORI
      // ========================================================

      if (collaboratore)
        const _NavDestination(
          titolo: 'Collaboratori',
          icona: Icons.groups_outlined,
          iconaAttiva: Icons.groups,
          pagina: _PaginaSegnaposto(
            titolo: 'Collaboratori',
            icona: Icons.groups,
          ),
        ),
    ];
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final destinazioni = _destinazioni();

    final indice = _selectedIndex.clamp(
      0,
      destinazioni.length - 1,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          destinazioni[indice].titoloAppBar ??
              destinazioni[indice].titolo,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'esci') {
                _esci();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'esci',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Esci'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: _mqttLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : IndexedStack(
              index: indice,
              children: destinazioni
                  .map(
                    (d) => d.pagina,
                  )
                  .toList(),
            ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indice,
        onTap: (i) {
          setState(() {
            _selectedIndex = i;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: destinazioni
            .map(
              (d) => BottomNavigationBarItem(
                icon: _iconaNav(
                  d.icona,
                  d.nuovo,
                ),
                activeIcon: _iconaNav(
                  d.iconaAttiva,
                  d.nuovo,
                ),
                label: d.titolo,
              ),
            )
            .toList(),
      ),
    );
  }

  // ============================================================
  // ICONA NAVIGAZIONE
  // ============================================================

  Widget _iconaNav(
    IconData icona,
    bool nuovo,
  ) {
    final icon = Icon(icona);

    if (!nuovo) {
      return icon;
    }

    return Badge(
      label: const Text('new'),
      child: icon,
    );
  }
}

// ================================================================
// NAV DESTINATION
// ================================================================

class _NavDestination {
  final String titolo;
  final String? titoloAppBar;
  final IconData icona;
  final IconData iconaAttiva;
  final bool nuovo;
  final Widget pagina;

  const _NavDestination({
    required this.titolo,
    this.titoloAppBar,
    required this.icona,
    required this.iconaAttiva,
    required this.pagina,
    this.nuovo = false,
  });
}

// ================================================================
// PAGINA SEGNAPOSTO
// ================================================================

class _PaginaSegnaposto extends StatelessWidget {
  final String titolo;
  final IconData icona;

  const _PaginaSegnaposto({
    required this.titolo,
    required this.icona,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icona,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            titolo,
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Pagina in costruzione',
          ),
        ],
      ),
    );
  }
}

// ================================================================
// PREMI
// ================================================================

class _Premio {
  final String nome;
  final String descrizione;
  final IconData icona;
  final int soglia;

  const _Premio({
    required this.nome,
    required this.descrizione,
    required this.icona,
    required this.soglia,
  });
}

// ================================================================
// HOME CLIENTE
// ================================================================

class _HomeTabCliente extends StatefulWidget {
  final AuthService authService;
  final double calorie;
  final List<CorsoAbbonamento> corsi;
  final List<Attivita> attivita;
  final Future<void> Function() onRefresh;

  const _HomeTabCliente({
    required this.authService,
    required this.calorie,
    required this.corsi,
    required this.attivita,
    required this.onRefresh,
  });

  @override
  State<_HomeTabCliente> createState() =>
      _HomeTabClienteState();
}

class _HomeTabClienteState
    extends State<_HomeTabCliente> {
  // Questa lista è separata dalle Attivita disponibili.
  //
  // La classe Attivita nuova contiene:
  // nome
  // descrizione
  // immagine
  //
  // quindi NON possiamo più usare attivita.data.
  //
  // Quando il backend fornirà lo storico delle attività svolte
  // con una data, potremo popolare questa lista tramite MQTT.

  final List<AttivitaSvolta> _attivitaSvolte = [];

  static const List<_Premio> _premiDisponibili = [
    _Premio(
      nome: 'Primo Passo',
      descrizione: 'Completa la tua prima attività',
      icona: Icons.flag,
      soglia: 1,
    ),
    _Premio(
      nome: 'Bronzo',
      descrizione: 'Completa 5 attività',
      icona: Icons.military_tech,
      soglia: 5,
    ),
    _Premio(
      nome: 'Argento',
      descrizione: 'Completa 20 attività',
      icona: Icons.military_tech,
      soglia: 20,
    ),
    _Premio(
      nome: 'Oro',
      descrizione: 'Completa 40 attività',
      icona: Icons.emoji_events,
      soglia: 40,
    ),
    _Premio(
      nome: 'Platino',
      descrizione: 'Completa 60 attività',
      icona: Icons.emoji_events,
      soglia: 60,
    ),
  ];

  // ============================================================
  // GIORNI ATTIVI
  // ============================================================

  List<bool> _giorniAttiviSettimana() {
    final oggi = DateTime.now();

    final oggiSenzaOra = DateTime(
      oggi.year,
      oggi.month,
      oggi.day,
    );

    final inizioSettimana =
        oggiSenzaOra.subtract(
      Duration(
        days: oggiSenzaOra.weekday - 1,
      ),
    );

    final giorniConAttivita = _attivitaSvolte
        .map(
          (attivita) => DateTime(
            attivita.data.year,
            attivita.data.month,
            attivita.data.day,
          ),
        )
        .toSet();

    return List.generate(
      7,
      (i) {
        final giorno =
            inizioSettimana.add(
          Duration(days: i),
        );

        return giorniConAttivita.contains(
          giorno,
        );
      },
    );
  }

  // ============================================================
  // STREAK
  // ============================================================

  int _calcolaStreakSettimanale() {
    if (_attivitaSvolte.isEmpty) {
      return 0;
    }

    final settimaneConAttivita =
        <DateTime>{};

    for (final attivita in _attivitaSvolte) {
      final data = DateTime(
        attivita.data.year,
        attivita.data.month,
        attivita.data.day,
      );

      final lunedi = data.subtract(
        Duration(
          days: data.weekday - 1,
        ),
      );

      settimaneConAttivita.add(
        DateTime(
          lunedi.year,
          lunedi.month,
          lunedi.day,
        ),
      );
    }

    final oggi = DateTime.now();

    var settimanaCorrente =
        DateTime(
      oggi.year,
      oggi.month,
      oggi.day,
    ).subtract(
      Duration(
        days: oggi.weekday - 1,
      ),
    );

    int streak = 0;

    while (
        settimaneConAttivita
            .contains(settimanaCorrente)) {
      streak++;

      settimanaCorrente =
          settimanaCorrente.subtract(
        const Duration(days: 7),
      );
    }

    return streak;
  }

  // ============================================================
  // SLANCIO
  // ============================================================

  Widget _buildSlancioSettimanale(
    BuildContext context,
  ) {
    final giorniAttivi =
        _giorniAttiviSettimana();

    final streak =
        _calcolaStreakSettimanale();

    const labels = [
      'L',
      'M',
      'M',
      'G',
      'V',
      'S',
      'D',
    ];

    final oggiIndex =
        DateTime.now().weekday - 1;

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Slancio settimanale',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
                if (streak > 0)
                  Row(
                    children: [
                      const Icon(
                        Icons
                            .local_fire_department,
                        color:
                            Colors.deepOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak sett.',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              streak == 0
                  ? 'Inizia questa settimana'
                  : streak == 1
                      ? '1 settimana consecutiva'
                      : '$streak settimane consecutive',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: List.generate(
                7,
                (i) {
                  final attivo =
                      giorniAttivi[i];

                  final isOggi =
                      i == oggiIndex;

                  return Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment:
                            Alignment.center,
                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,
                          color: attivo
                              ? AppColors.primary
                              : Colors.grey[200],
                          border: isOggi
                              ? Border.all(
                                  color:
                                      AppColors.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: attivo
                            ? const Icon(
                                Icons.check,
                                color:
                                    Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        labels[i],
                        style: Theme.of(
                                context)
                            .textTheme
                            .bodySmall,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PREMI
  // ============================================================

  Widget _buildPremi(
    BuildContext context,
  ) {
    final totale =
        widget.attivita.length;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'I tuoi premi',
          style: Theme.of(context)
              .textTheme
              .titleMedium,
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection:
                Axis.horizontal,
            itemCount:
                _premiDisponibili.length,
            separatorBuilder:
                (_, __) =>
                    const SizedBox(
              width: 12,
            ),
            itemBuilder:
                (context, index) {
              final premio =
                  _premiDisponibili[
                      index];

              final sbloccato =
                  totale >=
                      premio.soglia;

              final progresso =
                  (totale /
                          premio.soglia)
                      .clamp(
                        0.0,
                        1.0,
                      )
                      .toDouble();

              return Container(
                width: 140,
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration:
                    BoxDecoration(
                  color: sbloccato
                      ? AppColors
                          .primary
                          .withValues(
                          alpha: 0.1,
                        )
                      : Colors.grey[100],
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                  border: Border.all(
                    color: sbloccato
                        ? AppColors
                            .primary
                        : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Icon(
                      premio.icona,
                      color: sbloccato
                          ? AppColors
                              .primary
                          : Colors.grey[400],
                      size: 28,
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      premio.nome,
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        color: sbloccato
                            ? Colors.black87
                            : Colors.grey[500],
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      premio.descrizione,
                      style: Theme.of(
                              context)
                          .textTheme
                          .bodySmall,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    if (sbloccato)
                      Row(
                        children: [
                          Icon(
                            Icons
                                .check_circle,
                            color:
                                AppColors
                                    .success,
                            size: 14,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            'Sbloccato',
                            style:
                                TextStyle(
                              fontSize:
                                  11,
                              color: AppColors
                                  .success,
                            ),
                          ),
                        ],
                      )
                    else
                      ClipRRect(
                        borderRadius:
                            BorderRadius
                                .circular(
                          4,
                        ),
                        child:
                            LinearProgressIndicator(
                          value:
                              progresso,
                          minHeight:
                              4,
                          backgroundColor:
                              Colors
                                  .grey[300],
                          color:
                              AppColors
                                  .primary,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD HOME
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          32,
        ),
        children: [
          Text(
            'Ciao, ${widget.authService.user?.nome ?? "Cliente"}',
            style: Theme.of(context)
                .textTheme
                .headlineMedium,
          ),

          const SizedBox(height: 24),

          _buildSlancioSettimanale(
            context,
          ),

          const SizedBox(height: 24),

          // ======================================================
          // CALORIE
          // ======================================================

          Text(
            'Calorie consumate',
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color:
                        AppColors.primary,
                    value:
                        widget.calorie,
                    title:
                        widget.calorie
                            .toStringAsFixed(
                      0,
                    ),
                    radius: 60,
                    titleStyle:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  PieChartSectionData(
                    color:
                        Colors.grey[300]!,
                    value: (2000 -
                            widget.calorie)
                        .clamp(
                          0,
                          double.infinity,
                        ),
                    title:
                        'Rimanenti',
                    radius: 60,
                    titleStyle:
                        const TextStyle(
                      color:
                          Colors.black54,
                      fontWeight:
                          FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ======================================================
          // PREMI
          // ======================================================

          _buildPremi(context),

          const SizedBox(height: 24),

          // ======================================================
          // PROSSIMI CORSI
          // ======================================================

          Text(
            'Prossimi corsi',
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),

          const SizedBox(height: 12),

          if (widget.corsi.isEmpty)
            const Padding(
              padding:
                  EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Nessun corso programmato',
                ),
              ),
            )
          else
            ...widget.corsi
                .take(3)
                .map(
                  (corso) => Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: ListTile(
                      title: Text(
                        corso.nomeCorso,
                      ),
                      subtitle: Text(
                        '${corso.giorno} - ${corso.ora}\n'
                        'Istruttore: ${corso.istruttore}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(
                        Icons.arrow_forward,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ================================================================
// ATTIVITÀ SVOLTA
// ================================================================
//
// Questa NON è la stessa cosa di Attivita.
//
// Attivita = attività disponibili nell'app.
// AttivitaSvolta = storico delle attività eseguite dall'utente.
//
// Serve per lo streak.

class AttivitaSvolta {
  final DateTime data;

  const AttivitaSvolta({
    required this.data,
  });
}