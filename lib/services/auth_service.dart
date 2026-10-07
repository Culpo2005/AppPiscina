import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../models/auth_response.dart';
import 'mqtt_service.dart';

class AuthService extends ChangeNotifier {
  final MqttService mqttService;

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  AuthService({
    required this.mqttService,
  });

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isAuthenticated =>
      _user != null && _token != null;

  bool get isCollaboratore =>
      _user?.ruolo == UserRole.collaboratore;

  bool get isCliente =>
      _user?.ruolo == UserRole.cliente;

  Future<bool> login(
    String username,
    String password,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final completer = Completer<AuthResponse>();
      
      // ================================================================
      // STEP 1: Configura il callback PRIMA di connettersi
      // ================================================================
      mqttService.onAuthResponse = (data) {
        print('📱 [AuthService] onAuthResponse callback ricevuto');
        print('📱 [AuthService] Data ricevuta: $data');
        
        try {
          final response = AuthResponse.fromJson(data);
          print('✅ [AuthService] AuthResponse parsato correttamente');
          print('✅ [AuthService] userId: ${response.userId}, authorized: ${response.isAuthorized}');

          if (!completer.isCompleted) {
            completer.complete(response);
          }
        } catch (e) {
          print('❌ [AuthService] Errore nel parsing della risposta: $e');
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      };

      // ================================================================
      // STEP 2: Connettiti al broker MQTT
      // ================================================================
      print('🔌 [AuthService] Connessione MQTT in progress...');
      await mqttService.connect();
      print('✅ [AuthService] Connessione MQTT riuscita');

      // ================================================================
      // STEP 3: Invia la richiesta di login
      // ================================================================
      print('📤 [AuthService] Invio richiesta login: username=$username');
      mqttService.requestLogin(
        username: username,
        password: password,
      );

      // ================================================================
      // STEP 4: Aspetta la risposta dal broker (timeout 10 sec)
      // ================================================================
      print('⏳ [AuthService] In attesa della risposta dal server...');
      final response = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('❌ [AuthService] TIMEOUT: il server non ha risposto in 10 secondi');
          throw TimeoutException('Il server non ha risposto in tempo');
        },
      );

      print('📨 [AuthService] Risposta ricevuta');

      if (!response.isAuthorized) {
        print('❌ [AuthService] Autenticazione fallita - credenziali non valide');
        _error = 'Username o password errati';
        return false;
      }

      // ================================================================
      // STEP 5: Login riuscito - salva i dati
      // ================================================================
      print('✅ [AuthService] Login RIUSCITO!');
      
      // Salva il token
      _token = response.token;
      print('💾 [AuthService] Token salvato: ${_token?.substring(0, 10)}...');

      // Imposta l'userId nel MqttService per i prossimi messaggi
      mqttService.setUserId(response.userId);
      print('💾 [AuthService] userId impostato nel MqttService');

      // Crea l'utente
      _user = User(
        id: response.userId,
        nome: response.nome,
        username: response.username,
        email: response.email,
        ruolo: _roleFromString(response.role),
        createdAt: response.createdAt,
      );
      
      print('✅ [AuthService] Utente creato: ${_user?.nome} (${_user?.ruolo})');
      return true;
      
    } on TimeoutException catch (e) {
      print('❌ [AuthService] TimeoutException: $e');
      _error = 'Il server non ha risposto in tempo';
      return false;
    } catch (e) {
      print('❌ [AuthService] Errore durante il login: $e');
      _error = 'Errore durante il login: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'collaboratore':
        return UserRole.collaboratore;

      case 'cliente':
        return UserRole.cliente;

      default:
        throw Exception(
          'Ruolo utente non riconosciuto: $role',
        );
    }
  }

  void logout() {
    _user = null;
    _token = null;
    _error = null;

    mqttService.disconnect();

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
