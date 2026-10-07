// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:provider/provider.dart';
// import '../../theme/app_theme.dart';
// import '../../services/auth_service.dart';
// import '../../services/api_client.dart';
// import '../../models/course.dart';
// import '../../models/recovery.dart';
// import 'login_page.dart';
// import 'attivita_service.dart';
// import 'attivita.dart';

// class ClienteHomeScreen extends StatefulWidget {
//   const ClienteHomeScreen({super.key});

//   @override
//   State<ClienteHomeScreen> createState() => _ClienteHomeScreenState();
// }

// class _ClienteHomeScreenState extends State<ClienteHomeScreen> {
//   int _selectedIndex = 0;
//   late AuthService _authService;

//   @override
//   void initState() {
//     super.initState();
//     _authService = context.read<AuthService>();
//   }

//   void _esci() {
//     _authService.logout();
//     if (mounted) {
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (_) => const LoginPage()),
//         (route) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final pages = [
//       _HomeTabCliente(authService: _authService),
//       _CoursesTabCliente(authService: _authService),
//       _RecoveryTabCliente(authService: _authService),
//     ];

//     const titles = ['Home', 'I miei corsi', 'Recuperi'];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(titles[_selectedIndex]),
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert),
//             onSelected: (value) {
//               if (value == 'esci') _esci();
//             },
//             itemBuilder: (context) => const [
//               PopupMenuItem(
//                 value: 'esci',
//                 child: ListTile(
//                   leading: Icon(Icons.logout),
//                   title: Text('Esci'),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: pages,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) => setState(() => _selectedIndex = index),
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             activeIcon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.school_outlined),
//             activeIcon: Icon(Icons.school),
//             label: 'Corsi',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.restore_outlined),
//             activeIcon: Icon(Icons.restore),
//             label: 'Recuperi',
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Definisce un premio sbloccabile in base al numero totale di attività
// /// svolte. Le soglie sono statiche e definite lato app (non arrivano dal
// /// JSON, che contiene solo lo storico delle attività).
// class _Premio {
//   final String nome;
//   final String descrizione;
//   final IconData icona;
//   final int soglia;

//   const _Premio({
//     required this.nome,
//     required this.descrizione,
//     required this.icona,
//     required this.soglia,
//   });
// }

// class _HomeTabCliente extends StatefulWidget {
//   final AuthService authService;
//   const _HomeTabCliente({required this.authService});

//   @override
//   State<_HomeTabCliente> createState() => _HomeTabClienteState();
// }

// class _HomeTabClienteState extends State<_HomeTabCliente> {
//   double _calorieConsummate = 0;
//   bool _loading = true;
//   List<Course> _corsi = [];
//   List<Attivita> _attivita = [];

//   static const List<_Premio> _premiDisponibili = [
//     _Premio(
//       nome: 'Primo Passo',
//       descrizione: 'Completa la tua prima attività',
//       icona: Icons.flag,
//       soglia: 1,
//     ),
//     _Premio(
//       nome: 'Bronzo',
//       descrizione: 'Completa 5 attività',
//       icona: Icons.military_tech,
//       soglia: 5,
//     ),
//     _Premio(
//       nome: 'Argento',
//       descrizione: 'Completa 20 attività',
//       icona: Icons.military_tech,
//       soglia: 20,
//     ),
//     _Premio(
//       nome: 'Oro',
//       descrizione: 'Completa 40 attività',
//       icona: Icons.emoji_events,
//       soglia: 40,
//     ),
//     _Premio(
//       nome: 'Platino',
//       descrizione: 'Completa 60 attività',
//       icona: Icons.emoji_events,
//       soglia: 60,
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _carica();
//   }

//   Future<void> _carica() async {
//     if (widget.authService.user == null || widget.authService.token == null) return;

//     try {
//       final calorie = await ApiClient.calcolaCalorie(
//         widget.authService.user!.id,
//         widget.authService.token!,
//       );

//       final corsi = await ApiClient.getCorsi(
//         widget.authService.user!.id,
//         widget.authService.token!,
//       );

//       final attivita = await AttivitaService.getAttivitaSvolte();

//       if (!mounted) return;
//       setState(() {
//         _calorieConsummate = calorie;
//         _corsi = corsi;
//         _attivita = attivita;
//         _loading = false;
//       });
//     } catch (e) {
//       print('Errore nel caricamento: $e');
//       if (mounted) {
//         setState(() => _loading = false);
//       }
//     }
//   }

//   /// Per ciascuno dei 7 giorni della settimana corrente (Lunedì -> Domenica),
//   /// indica se è presente almeno un'attività svolta quel giorno.
//   List<bool> _giorniAttiviSettimana() {
//     final oggi = DateTime.now();
//     final oggiSenzaOra = DateTime(oggi.year, oggi.month, oggi.day);
//     final inizioSettimana =
//         oggiSenzaOra.subtract(Duration(days: oggiSenzaOra.weekday - 1));

//     final giorniConAttivita = _attivita
//         .map((a) => DateTime(a.data.year, a.data.month, a.data.day))
//         .toSet();

//     return List.generate(7, (i) {
//       final giorno = inizioSettimana.add(Duration(days: i));
//       return giorniConAttivita.contains(giorno);
//     });
//   }

//   /// Giorni consecutivi di attività fino ad oggi. Se oggi non ha ancora
//   /// un'attività registrata, il conteggio parte da ieri, così lo slancio
//   /// non si azzera subito appena si apre l'app al mattino.
//   int _calcolaStreak() {
//     final giorniConAttivita = _attivita
//         .map((a) => DateTime(a.data.year, a.data.month, a.data.day))
//         .toSet();

//     final oggi = DateTime.now();
//     var cursore = DateTime(oggi.year, oggi.month, oggi.day);

//     if (!giorniConAttivita.contains(cursore)) {
//       cursore = cursore.subtract(const Duration(days: 1));
//     }

//     var streak = 0;
//     while (giorniConAttivita.contains(cursore)) {
//       streak++;
//       cursore = cursore.subtract(const Duration(days: 1));
//     }
//     return streak;
//   }

//   Widget _buildSlancioSettimanale(BuildContext context) {
//     final giorniAttivi = _giorniAttiviSettimana();
//     final streak = _calcolaStreak();
//     const labels = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];
//     final oggiIndex = DateTime.now().weekday - 1;

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Slancio settimanale',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//                 if (streak > 0)
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.local_fire_department,
//                         color: Colors.deepOrange,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         '$streak',
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: List.generate(7, (i) {
//                 final attivo = giorniAttivi[i];
//                 final isOggi = i == oggiIndex;
//                 return Column(
//                   children: [
//                     Container(
//                       width: 36,
//                       height: 36,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: attivo ? AppColors.primary : Colors.grey[200],
//                         border: isOggi
//                             ? Border.all(color: AppColors.primary, width: 2)
//                             : null,
//                       ),
//                       child: attivo
//                           ? const Icon(Icons.check, color: Colors.white, size: 18)
//                           : null,
//                     ),
//                     const SizedBox(height: 6),
//                     Text(labels[i], style: Theme.of(context).textTheme.bodySmall),
//                   ],
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPremi(BuildContext context) {
//     final totale = _attivita.length;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'I tuoi premi',
//           style: Theme.of(context).textTheme.titleMedium,
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           height: 172,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: _premiDisponibili.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (context, index) {
//               final premio = _premiDisponibili[index];
//               final sbloccato = totale >= premio.soglia;
//               final progresso =
//                   (totale / premio.soglia).clamp(0.0, 1.0).toDouble();

//               return Container(
//                 width: 140,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: sbloccato
//                       ? AppColors.primary.withValues(alpha: 0.1)
//                       : Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: sbloccato ? AppColors.primary : Colors.grey[300]!,
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Icon(
//                       premio.icona,
//                       color: sbloccato ? AppColors.primary : Colors.grey[400],
//                       size: 28,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       premio.nome,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: sbloccato ? Colors.black87 : Colors.grey[500],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       premio.descrizione,
//                       style: Theme.of(context).textTheme.bodySmall,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const Spacer(),
//                     if (sbloccato)
//                       Row(
//                         children: [
//                           Icon(Icons.check_circle, color: AppColors.success, size: 14),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Sbloccato',
//                             style: TextStyle(fontSize: 11, color: AppColors.success),
//                           ),
//                         ],
//                       )
//                     else
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(4),
//                         child: LinearProgressIndicator(
//                           value: progresso,
//                           minHeight: 4,
//                           backgroundColor: Colors.grey[300],
//                           color: AppColors.primary,
//                         ),
//                       ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return RefreshIndicator(
//       onRefresh: _carica,
//       child: ListView(
//         padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
//         children: [
//           Text(
//             'Ciao, ${widget.authService.user?.nome ?? "Cliente"} 👋',
//             style: Theme.of(context).textTheme.headlineMedium,
//           ),
//           const SizedBox(height: 24),
//           _buildSlancioSettimanale(context),
//           const SizedBox(height: 24),
//           Text(
//             'Calorie consumate',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 250,
//             child: PieChart(
//               PieChartData(
//                 sections: [
//                   PieChartSectionData(
//                     color: AppColors.primary,
//                     value: _calorieConsummate,
//                     title: '${_calorieConsummate.toStringAsFixed(0)}',
//                     radius: 60,
//                     titleStyle: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   PieChartSectionData(
//                     color: Colors.grey[300]!,
//                     value: (2000 - _calorieConsummate).clamp(0, double.infinity),
//                     title: 'Rimanenti',
//                     radius: 60,
//                     titleStyle: const TextStyle(
//                       color: Colors.black54,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//           _buildPremi(context),
//           const SizedBox(height: 24),
//           Text(
//             'Prossimi corsi',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           const SizedBox(height: 12),
//           if (_corsi.isEmpty)
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Center(
//                 child: Text('Nessun corso programmato'),
//               ),
//             )
//           else
//             ..._corsi.take(3).map(
//               (corso) => Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 child: ListTile(
//                   title: Text(corso.nome),
//                   subtitle: Text(
//                     '${corso.dataOra.day}/${corso.dataOra.month} - '
//                     '${corso.dataOra.hour.toString().padLeft(2, '0')}:${corso.dataOra.minute.toString().padLeft(2, '0')}',
//                   ),
//                   trailing: const Icon(Icons.arrow_forward),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _CoursesTabCliente extends StatefulWidget {
//   final AuthService authService;
//   const _CoursesTabCliente({required this.authService});

//   @override
//   State<_CoursesTabCliente> createState() => _CoursesTabClienteState();
// }

// class _CoursesTabClienteState extends State<_CoursesTabCliente> {
//   bool _loading = true;
//   List<Course> _corsi = [];

//   @override
//   void initState() {
//     super.initState();
//     _carica();
//   }

//   Future<void> _carica() async {
//     if (widget.authService.user == null || widget.authService.token == null) return;

//     try {
//       final corsi = await ApiClient.getCorsi(
//         widget.authService.user!.id,
//         widget.authService.token!,
//       );

//       if (!mounted) return;
//       setState(() {
//         _corsi = corsi;
//         _loading = false;
//       });
//     } catch (e) {
//       print('Errore nel caricamento: $e');
//       if (mounted) {
//         setState(() => _loading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return RefreshIndicator(
//       onRefresh: _carica,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: _corsi.length,
//         itemBuilder: (context, index) {
//           final corso = _corsi[index];
//           return Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: ListTile(
//               title: Text(corso.nome),
//               subtitle: Text(
//                 'Istruttore: ${corso.istruttore}\n'
//                 '${corso.dataOra.day}/${corso.dataOra.month} - '
//                 '${corso.dataOra.hour.toString().padLeft(2, '0')}:${corso.dataOra.minute.toString().padLeft(2, '0')}',
//               ),
//               isThreeLine: true,
//               trailing: const Icon(Icons.arrow_forward),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _RecoveryTabCliente extends StatefulWidget {
//   final AuthService authService;
//   const _RecoveryTabCliente({required this.authService});

//   @override
//   State<_RecoveryTabCliente> createState() => _RecoveryTabClienteState();
// }

// class _RecoveryTabClienteState extends State<_RecoveryTabCliente> {
//   bool _loading = true;
//   List<Recovery> _recuperi = [];
//   List<Recovery> _recuperiDisponibili = [];

//   @override
//   void initState() {
//     super.initState();
//     _carica();
//   }

//   Future<void> _carica() async {
//     if (widget.authService.user == null || widget.authService.token == null) return;

//     try {
//       final recuperi = await ApiClient.getRecuperi(
//         widget.authService.user!.id,
//         widget.authService.token!,
//       );

//       if (!mounted) return;
//       setState(() {
//         _recuperi = recuperi.where((r) => !r.prenotato).toList();
//         _recuperiDisponibili = recuperi;
//         _loading = false;
//       });
//     } catch (e) {
//       print('Errore nel caricamento: $e');
//       if (mounted) {
//         setState(() => _loading = false);
//       }
//     }
//   }

//   Future<void> _prenotaRecupero(Recovery recupero) async {
//     if (widget.authService.token == null) return;

//     final success = await ApiClient.prenotaRecupero(
//       recupero.id,
//       recupero.disponibilita,
//       widget.authService.token!,
//     );

//     if (!mounted) return;

//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Recupero prenotato con successo!')),
//       );
//       _carica();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Errore nella prenotazione')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_recuperi.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: _carica,
//         child: ListView(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Card(
//                 color: AppColors.success.withValues(alpha: 0.1),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.check_circle,
//                         color: AppColors.success,
//                         size: 32,
//                       ),
//                       const SizedBox(width: 16),
//                       const Expanded(
//                         child: Text(
//                           'Non hai recuperi da fare! 🎉',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.success,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _carica,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: _recuperi.length,
//         itemBuilder: (context, index) {
//           final recupero = _recuperi[index];
//           return Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Corso: ${recupero.corsoOriginale}',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Data: ${recupero.dataCorso.day}/${recupero.dataCorso.month}',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () => _prenotaRecupero(recupero),
//                       child: const Text('Prenota recupero'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
