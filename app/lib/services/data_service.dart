import 'dart:async';

import 'package:flutter/foundation.dart';

import 'mqtt_service.dart';
import 'mqtt_models.dart';

class DataService extends ChangeNotifier {
  final MqttService mqttService;

  // ============================================================
  // CACHE DATI
  // ============================================================

  List<CorsoMqtt> _corsi = [];
  List<RecuperoMqtt> _recuperi = [];
  List<AttivitaMqtt> _attivita = [];
  List<EventoMqtt> _eventi = [];
  double _calorie = 0.0;

  bool _isLoading = false;
  String? _error;

  // ============================================================
  // GETTERS
  // ============================================================

  List<CorsoMqtt> get corsi => _corsi;
  List<RecuperoMqtt> get recuperi => _recuperi;
  List<AttivitaMqtt> get attivita => _attivita;
  List<EventoMqtt> get eventi => _eventi;
  double get calorie => _calorie;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============================================================
  // COSTRUTTORE
  // ============================================================

  DataService({required this.mqttService}) {
    _setupHandlers();
  }

  // ============================================================
  // SETUP HANDLERS MQTT
  // ============================================================

  void _setupHandlers() {
    // Corsi
    mqttService.registerHandler(
      MqttService.corsiResponseTopic,
      _handleCorsiResponse,
    );

    // Recuperi
    mqttService.registerHandler(
      MqttService.recuperiResponseTopic,
      _handleRecuperiResponse,
    );

    // Attività
    mqttService.registerHandler(
      MqttService.attivitaResponseTopic,
      _handleAttivitaResponse,
    );

    // Eventi
    mqttService.registerHandler(
      MqttService.eventiResponseTopic,
      _handleEventiResponse,
    );

    // Calorie
    mqttService.registerHandler(
      MqttService.calorieResponseTopic,
      _handleCalorieResponse,
    );

    // Prenotazione
    mqttService.registerHandler(
      MqttService.prenotaResponseTopic,
      _handlePrenotaResponse,
    );

    // Nota
    mqttService.registerHandler(
      MqttService.notaResponseTopic,
      _handleNotaResponse,
    );
  }

  // ============================================================
  // HANDLER CORSI
  // ============================================================

  void _handleCorsiResponse(Map<String, dynamic> data) {
    try {
      if (_isMyUserData(data)) {
        final response = CorsiResponse.fromJson(data);
        _corsi = response.corsi;
        _error = null;
        notifyListeners();
        print('DataService: ${_corsi.length} corsi ricevuti');
      }
    } catch (e) {
      _error = 'Errore parsing corsi: $e';
      debugPrint(_error);
    }
  }

  // ============================================================
  // HANDLER RECUPERI
  // ============================================================

  void _handleRecuperiResponse(Map<String, dynamic> data) {
    try {
      if (_isMyUserData(data)) {
        final response = RecuperiResponse.fromJson(data);
        _recuperi = response.recuperi;
        _error = null;
        notifyListeners();
        print('DataService: ${_recuperi.length} recuperi ricevuti');
      }
    } catch (e) {
      _error = 'Errore parsing recuperi: $e';
      debugPrint(_error);
    }
  }

  // ============================================================
  // HANDLER ATTIVITÀ
  // ============================================================

  void _handleAttivitaResponse(Map<String, dynamic> data) {
    try {
      if (_isMyUserData(data)) {
        final response = AttivitaResponse.fromJson(data);
        _attivita = response.attivita;
        _error = null;
        notifyListeners();
        print('DataService: ${_attivita.length} attività ricevute');
      }
    } catch (e) {
      _error = 'Errore parsing attività: $e';
      debugPrint(_error);
    }
  }

  // ============================================================
  // HANDLER EVENTI
  // ============================================================

  void _handleEventiResponse(Map<String, dynamic> data) {
    try {
      if (_isMyUserData(data)) {
        final response = EventiResponse.fromJson(data);
        _eventi = response.eventi;
        _error = null;
        notifyListeners();
        print('DataService: ${_eventi.length} eventi ricevuti');
      }
    } catch (e) {
      _error = 'Errore parsing eventi: $e';
      debugPrint(_error);
    }
  }

  // ============================================================
  // HANDLER CALORIE
  // ============================================================

  void _handleCalorieResponse(Map<String, dynamic> data) {
    try {
      if (_isMyUserData(data)) {
        final response = CalorieResponse.fromJson(data);
        _calorie = response.calorie;
        _error = null;
        notifyListeners();
        print('DataService: ${_calorie} calorie ricevute');
      }
    } catch (e) {
      _error = 'Errore parsing calorie: $e';
      debugPrint(_error);
    }
  }

  // ============================================================
  // HANDLER PRENOTAZIONE
  // ============================================================

  void _handlePrenotaResponse(Map<String, dynamic> data) {
    try {
      final response = PrenotaResponse.fromJson(data);
      if (response.success) {
        _error = null;
        print('DataService: Prenotazione riuscita');
      } else {
        _error = response.message;
        print('DataService: Errore prenotazione: ${response.message}');
      }
      notifyListeners();
    } catch (e) {
      _error = 'Errore parsing prenotazione: $e';
      debugPrint(_error);
    }
  }

  // ============================================================
  // HANDLER NOTA
  // ============================================================

  void _handleNotaResponse(Map<String, dynamic> data) {
    try {
      final response = NotaResponse.fromJson(data);
      if (response.success) {
        _error = null;
        print('DataService: Nota salvata con successo');
      } else {
        _error = response.message;
        print('DataService: Errore salvataggio nota: ${response.message}');
      }
      notifyListeners();
    } catch (e) {
      _error = 'Errore parsing nota: $e';
      debugPrint(_error);
    }
  }

  // ============================================================
  // CONTROLLO USER ID
  // ============================================================

  bool _isMyUserData(Map<String, dynamic> data) {
    final userId = mqttService.userId;
    if (userId == null) {
      return false;
    }

    final responseUserId = data['user_id']?.toString();
    return responseUserId == userId;
  }

  // ============================================================
  // RICHIESTA TUTTI I DATI
  // ============================================================

  Future<void> fetchAllData({
    required String userId,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Richiedi tutti i dati in parallelo
      mqttService.requestCorsi(
        userId: userId,
        token: token,
      );

      mqttService.requestRecuperi(
        userId: userId,
        token: token,
      );

      mqttService.requestAttivita(
        userId: userId,
        token: token,
      );

      mqttService.requestEventi(
        userId: userId,
        token: token,
      );

      mqttService.requestCalorie(
        userId: userId,
        token: token,
      );

      print('DataService: Richieste dati inviate');

      // Aspetta un po' che arrivino le risposte
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _error = 'Errore richiesta dati: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // RICHIESTA SINGOLI DATI
  // ============================================================

  Future<void> fetchCorsi({
    required String userId,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      mqttService.requestCorsi(
        userId: userId,
        token: token,
      );
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _error = 'Errore richiesta corsi: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecuperi({
    required String userId,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      mqttService.requestRecuperi(
        userId: userId,
        token: token,
      );
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _error = 'Errore richiesta recuperi: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAttivita({
    required String userId,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      mqttService.requestAttivita(
        userId: userId,
        token: token,
      );
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _error = 'Errore richiesta attività: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchEventi({
    required String userId,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      mqttService.requestEventi(
        userId: userId,
        token: token,
      );
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _error = 'Errore richiesta eventi: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCalorie({
    required String userId,
    required String token,
  }) async {
    try {
      mqttService.requestCalorie(
        userId: userId,
        token: token,
      );
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _error = 'Errore richiesta calorie: $e';
      debugPrint(_error);
    }
  }

  // ============================================================
  // AZIONI
  // ============================================================

  Future<void> prenotaRecupero({
    required String recuperoId,
    required String disponibilita,
    required String token,
  }) async {
    try {
      mqttService.requestPrenotaRecupero(
        recuperoId: recuperoId,
        disponibilita: disponibilita,
        token: token,
      );
      print('DataService: Richiesta prenotazione inviata');
    } catch (e) {
      _error = 'Errore prenotazione: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  Future<void> salvaNota({
    required String corsoId,
    required String nota,
    required String token,
  }) async {
    try {
      mqttService.requestSalvaNota(
        corsoId: corsoId,
        nota: nota,
        token: token,
      );
      print('DataService: Richiesta salvataggio nota inviata');
    } catch (e) {
      _error = 'Errore salvataggio nota: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  void clearData() {
    _corsi = [];
    _recuperi = [];
    _attivita = [];
    _eventi = [];
    _calorie = 0.0;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    mqttService.clearHandlers(MqttService.corsiResponseTopic);
    mqttService.clearHandlers(MqttService.recuperiResponseTopic);
    mqttService.clearHandlers(MqttService.attivitaResponseTopic);
    mqttService.clearHandlers(MqttService.eventiResponseTopic);
    mqttService.clearHandlers(MqttService.calorieResponseTopic);
    mqttService.clearHandlers(MqttService.prenotaResponseTopic);
    mqttService.clearHandlers(MqttService.notaResponseTopic);
    super.dispose();
  }
}
