// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../theme/app_theme.dart';
// import '../services/auth_service.dart';
// import 'main_shell.dart';
// // import 'client_home_screen.dart';
// import '../models/user.dart';
// // import 'collaborator/home_page.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text;

//     if (username.isEmpty || password.isEmpty) {
//       _mostraMessaggio('Inserisci username e password');
//       return;
//     }

//     final authService = context.read<AuthService>();
//     final success = await authService.login(username, password);

//     if (!mounted) return;

//     if (success) {
//       // Reindirizza in base al ruolo
//       if (authService.isCollaboratore) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (_) => const HomePage()),
//         );
//       } else if (authService.isCliente) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (_) => const ClienteHomeScreen()),
//         );
//       }
//     } else {
//       _mostraMessaggio(authService.error ?? 'Errore durante il login');
//     }
//   }

//   void _mostraMessaggio(String testo) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(testo)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(28),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 380),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 72,
//                     height: 72,
//                     decoration: BoxDecoration(
//                       color: AppColors.primary,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Icon(Icons.pool, color: Colors.white, size: 36),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     'Gestionale Piscina',
//                     style: Theme.of(context).textTheme.headlineMedium,
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     'Accedi per continuare',
//                     style: Theme.of(context)
//                         .textTheme
//                         .bodyMedium
//                         ?.copyWith(color: AppColors.textSecondary),
//                   ),
//                   const SizedBox(height: 32),
//                   TextField(
//                     controller: _usernameController,
//                     textInputAction: TextInputAction.next,
//                     decoration: const InputDecoration(
//                       labelText: 'Username',
//                       prefixIcon: Icon(Icons.person_outline),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: _passwordController,
//                     obscureText: _obscurePassword,
//                     textInputAction: TextInputAction.done,
//                     onSubmitted: (_) => _login(),
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       prefixIcon: const Icon(Icons.lock_outline),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword
//                               ? Icons.visibility_outlined
//                               : Icons.visibility_off_outlined,
//                         ),
//                         onPressed: () =>
//                             setState(() => _obscurePassword = !_obscurePassword),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Consumer<AuthService>(
//                     builder: (context, authService, _) {
//                       return SizedBox(
//                         width: double.infinity,
//                         height: 52,
//                         child: ElevatedButton(
//                           onPressed: authService.isLoading ? null : _login,
//                           child: authService.isLoading
//                               ? const SizedBox(
//                                   width: 22,
//                                   height: 22,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                               : const Text('Accedi'),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
