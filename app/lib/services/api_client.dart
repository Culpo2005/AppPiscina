import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../models/course.dart';
import '../models/recovery.dart';

class ApiClient {
  static const String baseUrl = 'http://192.168.1.100:8000/api';
  
  // Metodo di login
  static Future<LoginResponse> login(String username, String password) async {
    // try {
    //   final response = await http.post(
    //     Uri.parse('$baseUrl/auth/login'),
    //     headers: {
    //       'Content-Type': 'application/json',
    //     },
    //     body: jsonEncode({
    //       'username': username,
    //       'password': password,
    //     }),
    //   );

    //   if (response.statusCode == 200) {
    //     final data = jsonDecode(response.body);
    //     return LoginResponse(
    //       success: true,
    //       user: User.fromJson(data['user']),
    //       token: data['token'],
    //       message: 'Login riuscito',
    //     );
    //   } else {
    //     final data = jsonDecode(response.body);
    //     return LoginResponse(
    //       success: false,
    //       message: data['message'] ?? 'Errore di login',
    //     );
    //   }
    // } catch (e) {
    //   return LoginResponse(
    //     success: false,
    //     message: 'Errore di connessione: $e',
    //   );
    // }
      try{
        if (username == 'admin' && password == '1234') {
            return LoginResponse(
              success: true,
              user: User(
                id: '1',
                nome: 'Marco Rossi',
                username: 'admin',
                email: 'marco@piscina.it',
                ruolo: UserRole.collaboratore,
                createdAt: DateTime.now(),
              ),
              token: 'mock_token_123',
              message: 'Login riuscito',
            );
          }
          else if (username == 'cliente' && password == '1234') {
            return LoginResponse(
              success: true,
              user: User(
                id: '2',
                nome: 'Luca Bianchi',
                username: 'cliente',
                email: 'luca@piscina.it',
                ruolo: UserRole.cliente,
                createdAt: DateTime.now(),
              ),
              token: 'mock_token_456',
              message: 'Login riuscito',
            );
          }
          else {
            return LoginResponse(
              success: false,
              message: 'Credenziali non valide',
            );
          }
      }catch (e) {
        return LoginResponse(
          success: false,
          message: 'Errore di connessione: $e',
        );
      }
  }

  // Metodo per ottenere i dettagli dell'utente
  static Future<User?> getUserDetails(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      }
      return null;
    } catch (e) {
      print('Errore nel recupero utente: $e');
      return null;
    }
  }

  // Metodo per ottenere i corsi dell'utente
  static Future<List<Course>> getCorsi(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/corsi'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final corsiFetchati = data['corsi'] as List? ?? [];
        return corsiFetchati.map((c) => Course.fromJson(c)).toList();
      }
      return [];
    } catch (e) {
      print('Errore nel recupero corsi: $e');
      return [];
    }
  }

  // Metodo per salvare i km di nuoto (solo collaboratori)
  static Future<bool> saveKmNuoto(
      String corsoId, double km, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/corsi/$corsoId/km-nuoto'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'km': km,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Errore nel salvataggio km: $e');
      return false;
    }
  }

  // Metodo per ottenere gli infortuni di un corso
  static Future<List<InfortunioCorso>> getInfortuni(String corsoId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/corsi/$corsoId/infortuni'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final infortuniFetchati = data['infortuni'] as List? ?? [];
        return infortuniFetchati.map((i) => InfortunioCorso.fromJson(i)).toList();
      }
      return [];
    } catch (e) {
      print('Errore nel recupero infortuni: $e');
      return [];
    }
  }

  // Metodo per ottenere i corsisti di un corso
  static Future<List<Corsista>> getCorsisti(String corsoId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/corsi/$corsoId/corsisti'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final corsistiFetchati = data['corsisti'] as List? ?? [];
        return corsistiFetchati.map((c) => Corsista.fromJson(c)).toList();
      }
      return [];
    } catch (e) {
      print('Errore nel recupero corsisti: $e');
      return [];
    }
  }

  // Metodo per ottenere i recuperi disponibili
  static Future<List<Recovery>> getRecuperi(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/recuperi'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recuperiFetchati = data['recuperi'] as List? ?? [];
        return recuperiFetchati.map((r) => Recovery.fromJson(r)).toList();
      }
      return [];
    } catch (e) {
      print('Errore nel recupero recuperi: $e');
      return [];
    }
  }

  // Metodo per prenotare un recupero
  static Future<bool> prenotaRecupero(String recuperoId, String corsoId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recuperi/$recuperoId/prenota'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'corsoId': corsoId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Errore nella prenotazione recupero: $e');
      return false;
    }
  }

  // Metodo per calcolare le calorie
  static Future<double> calcolaCalorie(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/calorie'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['calorie'] ?? 0).toDouble();
      }
      return 0.0;
    } catch (e) {
      print('Errore nel calcolo calorie: $e');
      return 0.0;
    }
  }
}

class LoginResponse {
  final bool success;
  final User? user;
  final String? token;
  final String message;

  LoginResponse({
    required this.success,
    this.user,
    this.token,
    required this.message,
  });
}
