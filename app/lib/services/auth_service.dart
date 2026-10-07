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

      mqttService.onAuthResponse = (data) {
        try {
          final response = AuthResponse.fromJson(data);

          if (!completer.isCompleted) {
            completer.complete(response);
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      };

      // Connessione MQTT
      await mqttService.connect();

      // Richiesta autenticazione
      mqttService.requestLogin(
        username: username,
        password: password,
      );

      // Aspetta la risposta del Raspberry
      final response = await completer.future.timeout(
        const Duration(seconds: 10),
      );

      if (!response.isAuthorized) {
        _error = 'Username o password errati';
        return false;
      }

      // Salviamo il token
      _token = response.token;

      // Creiamo l'utente
      _user = User(
        id: response.userId,
        nome: response.nome,
        username: response.username,
        email: response.email,
        ruolo: _roleFromString(response.role),
        createdAt: response.createdAt,
      );
      return true;
    } on TimeoutException {
      _error = 'Il server non ha risposto in tempo';
      return false;
    } catch (e) {
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