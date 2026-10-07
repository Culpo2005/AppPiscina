import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/mqtt_service.dart';
import 'pages/main_shell.dart';

// import 'pages/client/client_home_screen.dart';
// import 'pages/collaborator/home_page.dart';

// variabili super globali
bool collaboratore = false;
void main() {
  final mqttService = MqttService(
    broker: '192.168.1.164',
    //broker: '100.69.190.75',
    port: 1883,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(
        mqttService: mqttService,
      ),
      child: const GestionalePiscinaApp(),
    ),
  );
}

class GestionalePiscinaApp extends StatelessWidget { 
  
  const GestionalePiscinaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestionale Piscina',
      theme: AppTheme.light,
      home: const LoginPage(),
    );
  }
}
// LOGIN PAGE
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //--------------------------------------------------------
  // LOGIN
  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Controllo campi
    if (username.isEmpty || password.isEmpty) {
      _mostraMessaggio('Inserisci username e password',);
      return;
    }

    // AuthService
    final authService =context.read<AuthService>();
    final success = await authService.login(username,password,);
    if (!mounted) {return;}
    // Login riuscito
    if (success) {
      // COLLABORATORE
      if (authService.isCollaboratore) {
        collaboratore = true;
        print('Collaboratore loggato');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
        
        return;
      }
      // CLIENTE
      if (authService.isCliente) {
        collaboratore = false;
        print('Cliente loggato');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
        return;
      }

      // Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(
      //       builder: (_) => const HomeScreen(),
      //     ),
      //   );
      //   return;
    }
    // login fallito
    else {
      _mostraMessaggio(authService.error ?? 'Errore durante il login',);
    }
  }

  // MESSAGGIO
  void _mostraMessaggio(
    String testo,
  ) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(testo),
      ),
    );
  }






  // UI
  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding:
                const EdgeInsets.all(28),

            child: ConstrainedBox(

              constraints:
                  const BoxConstraints(
                maxWidth: 380,
              ),

              child: Column(

                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  // ------------------------------------------------
                  // LOGO
                  // ------------------------------------------------

                  Container(

                    width: 72,

                    height: 72,

                    decoration:
                        BoxDecoration(

                      color:
                          AppColors.primary,

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: const Icon(

                      Icons.pool,

                      color: Colors.white,

                      size: 36,
                    ),
                  ),


                  const SizedBox(
                    height: 20,
                  ),


                  // ------------------------------------------------
                  // TITOLO
                  // ------------------------------------------------

                  Text(

                    'Gestionale Piscina',

                    style:
                        Theme.of(context)
                            .textTheme
                            .headlineMedium,

                    textAlign:
                        TextAlign.center,
                  ),


                  const SizedBox(
                    height: 6,
                  ),


                  // ------------------------------------------------
                  // SOTTOTITOLO
                  // ------------------------------------------------

                  Text(

                    'Accedi per continuare',

                    style:
                        Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color:
                                  AppColors
                                      .textSecondary,
                            ),

                  ),


                  const SizedBox(
                    height: 32,
                  ),


                  // ------------------------------------------------
                  // USERNAME
                  // ------------------------------------------------

                  TextField(

                    controller:
                        _usernameController,

                    textInputAction:
                        TextInputAction.next,

                    decoration:
                        const InputDecoration(

                      labelText:
                          'Username',

                      prefixIcon:
                          Icon(
                        Icons.person_outline,
                      ),
                    ),
                  ),


                  const SizedBox(
                    height: 16,
                  ),


                  // ------------------------------------------------
                  // PASSWORD
                  // ------------------------------------------------

                  TextField(

                    controller:
                        _passwordController,

                    obscureText:
                        _obscurePassword,

                    textInputAction:
                        TextInputAction.done,

                    onSubmitted: (_) =>
                        _login(),

                    decoration:
                        InputDecoration(

                      labelText:
                          'Password',

                      prefixIcon:
                          const Icon(
                        Icons.lock_outline,
                      ),

                      suffixIcon:
                          IconButton(

                        icon: Icon(

                          _obscurePassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),

                        onPressed: () {

                          setState(() {

                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),


                  const SizedBox(
                    height: 24,
                  ),


                  // ------------------------------------------------
                  // PULSANTE LOGIN
                  // ------------------------------------------------

                  Consumer<AuthService>(

                    builder:
                        (
                          context,
                          authService,
                          _,
                        ) {

                      return SizedBox(

                        width:
                            double.infinity,

                        height: 52,

                        child:
                            ElevatedButton(

                          onPressed:
                              authService
                                      .isLoading
                                  ? null
                                  : _login,

                          child:
                              authService
                                      .isLoading

                                  ? const SizedBox(

                                      width: 22,

                                      height: 22,

                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,

                                        color:
                                            Colors
                                                .white,
                                      ),
                                    )

                                  : const Text(
                                      'Accedi',
                                    ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}