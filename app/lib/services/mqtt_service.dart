import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final String broker;
  final int port;

  MqttServerClient? _client;

  final Map<String, List<void Function(Map<String, dynamic>)>>
      _topicHandlers = {};

  // ==========================================================
  // CALLBACK GENERICI
  // ==========================================================

  Function(String topic, Map<String, dynamic> data)? onMessage;

  // ==========================================================
  // CALLBACK AUTENTICAZIONE
  // ==========================================================

  Function(Map<String, dynamic> data)? onAuthResponse;

  // ==========================================================
  // CALLBACK DATI UTENTE
  // ==========================================================

  Function(Map<String, dynamic> data)? onUserData;

  // ==========================================================
  // CALLBACK DATI APP
  // ==========================================================

  Function(Map<String, dynamic> data)? onCorsiResponse;

  Function(Map<String, dynamic> data)? onRecuperiResponse;

  Function(Map<String, dynamic> data)? onCalorieResponse;

  Function(Map<String, dynamic> data)? onPrenotaRecuperoResponse;

  Function(Map<String, dynamic> data)? onAttivitaResponse;

  Function(Map<String, dynamic> data)? onEventiResponse;

  Function(Map<String, dynamic> data)? onNotaResponse;

  // ==========================================================
  // TOPIC AUTENTICAZIONE
  // ==========================================================

  static const String authRequestTopic = 'app/request/auth';

  static const String authResponseTopic = 'app/response/auth';

  static const String userDataTopic = 'app/data/user';

  // ==========================================================
  // TOPIC DATI
  // ==========================================================

  static const String dataRequestTopic = 'app/request/data';

  static const String corsiResponseTopic = 'app/response/corsi';

  static const String recuperiResponseTopic = 'app/response/recuperi';

  static const String calorieResponseTopic = 'app/response/calorie';

  static const String prenotaResponseTopic =
      'app/response/prenota_recupero';

  static const String attivitaResponseTopic = 'app/response/attivita';

  static const String eventiResponseTopic = 'app/response/eventi';

  static const String notaResponseTopic = 'app/response/nota';

  // ==========================================================
  // USER ID
  // ==========================================================

  String? _userId;

  String? get userId => _userId;

  // ==========================================================
  // COSTRUTTORE
  // ==========================================================

  MqttService({
    required this.broker,
    this.port = 1883,
  });

  // ==========================================================
  // STATO CONNESSIONE
  // ==========================================================

  bool get isConnected =>
      _client != null &&
      _client!.connectionStatus?.state ==
          MqttConnectionState.connected;

  // ==========================================================
  // REGISTRAZIONE HANDLER PER TOPIC
  // ==========================================================

  void registerHandler(
    String topic,
    void Function(Map<String, dynamic>) handler,
  ) {
    final handlers = _topicHandlers.putIfAbsent(
      topic,
      () => <void Function(Map<String, dynamic>)>[] ,
    );

    if (!handlers.contains(handler)) {
      handlers.add(handler);
    }
  }

  void unregisterHandler(
    String topic,
    void Function(Map<String, dynamic>) handler,
  ) {
    final handlers = _topicHandlers[topic];
    if (handlers == null) {
      return;
    }

    handlers.remove(handler);

    if (handlers.isEmpty) {
      _topicHandlers.remove(topic);
    }
  }

  void clearHandlers(String topic) {
    _topicHandlers.remove(topic);
  }

  void _dispatchToTopicHandlers(
    String topic,
    Map<String, dynamic> data,
  ) {
    final handlers = _topicHandlers[topic];
    if (handlers == null || handlers.isEmpty) {
      return;
    }

    for (final handler in List<void Function(Map<String, dynamic>)>.from(handlers)) {
      handler(data);
    }
  }

  // ==========================================================
  // IMPOSTA USER ID
  // ==========================================================

  void setUserId(String userId) {
    _userId = userId;

    print(
      'MQTT: userId impostato -> $_userId',
    );
  }

  // ==========================================================
  // CONNESSIONE
  // ==========================================================

  Future<void> connect() async {
    if (isConnected) {
      print('MQTT: già connesso');
      return;
    }

    final clientId =
        'flutter_${DateTime.now().millisecondsSinceEpoch}';

    print(
      'MQTT: connessione a $broker:$port...',
    );

    _client = MqttServerClient(
      broker,
      clientId,
    );

    _client!.port = port;
    _client!.keepAlivePeriod = 60;
    _client!.logging(on: false);

    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;

    final connMessage =
        MqttConnectMessage()
            .withClientIdentifier(clientId)
            .startClean();

    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect();
    } catch (e) {
      print(
        'MQTT: errore connessione: $e',
      );

      _client!.disconnect();

      rethrow;
    }

    if (!isConnected) {
      throw Exception(
        'MQTT: connessione fallita '
        '(${_client!.connectionStatus?.state})',
      );
    }

    print(
      'MQTT: connessione riuscita',
    );

    _client!.updates?.listen(
      _onMessage,
    );
  }

  // ==========================================================
  // SUBSCRIBE
  // ==========================================================

  void subscribe(String topic) {
    if (!isConnected) {
      print(
        'MQTT: impossibile sottoscriversi, '
        'client non connesso',
      );

      return;
    }

    _client!.subscribe(
      topic,
      MqttQos.atLeastOnce,
    );

    print(
      'MQTT → subscribe: $topic',
    );
  }

  // ==========================================================
  // PUBLISH
  // ==========================================================

  void publish(
    String topic,
    Map<String, dynamic> data,
  ) {
    if (!isConnected) {
      throw Exception(
        'MQTT: client non connesso',
      );
    }

    final builder =
        MqttClientPayloadBuilder();

    builder.addString(
      jsonEncode(data),
    );

    _client!.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      builder.payload!,
    );

    print(
      'MQTT → $topic: $data',
    );
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  void requestLogin({
    required String username,
    required String password,
  }) {
    if (!isConnected) {
      throw Exception(
        'MQTT: non connesso',
      );
    }

    subscribe(
      authResponseTopic,
    );

    subscribe(
      userDataTopic,
    );

    publish(
      authRequestTopic,
      {
        'action': 'login',
        'username': username,
        'password': password,
      },
    );
  }

  // ==========================================================
  // RICHIESTA CORSI
  // ==========================================================

  void requestCorsi({
    required String userId,
    required String token,
  }) {
    publish(
      dataRequestTopic,
      {
        'action': 'get_corsi',
        'user_id': userId,
        'token': token,
      },
    );
  }

  // ==========================================================
  // RICHIESTA RECUPERI
  // ==========================================================

  void requestRecuperi({
    required String userId,
    required String token,
  }) {
    publish(
      dataRequestTopic,
      {
        'action': 'get_recuperi',
        'user_id': userId,
        'token': token,
      },
    );
  }

  // ==========================================================
  // RICHIESTA CALORIE
  // ==========================================================

  void requestCalorie({
    required String userId,
    required String token,
  }) {
    publish(
      dataRequestTopic,
      {
        'action': 'get_calorie',
        'user_id': userId,
        'token': token,
      },
    );
  }

  // ==========================================================
  // RICHIESTA ATTIVITÀ
  // ==========================================================

  void requestAttivita({
    required String userId,
    required String token,
  }) {
    publish(
      dataRequestTopic,
      {
        'action': 'get_attivita',
        'user_id': userId,
        'token': token,
      },
    );
  }

  // ==========================================================
  // RICHIESTA EVENTI
  // ==========================================================

  void requestEventi({
    required String userId,
    required String token,
  }) {
    publish(
      dataRequestTopic,
      {
        'action': 'get_eventi',
        'user_id': userId,
        'token': token,
      },
    );
  }

  // ==========================================================
  // PRENOTAZIONE RECUPERO
  // ==========================================================

  void requestPrenotaRecupero({
    required String recuperoId,
    required String disponibilita,
    required String token,
  }) {
    final id = _requireUserId();

    subscribe(
      prenotaResponseTopic,
    );

    publish(
      dataRequestTopic,
      {
        'action': 'prenota_recupero',
        'user_id': id,
        'recupero_id': recuperoId,
        'disponibilita': disponibilita,
        'token': token,
      },
    );
  }

  // ==========================================================
  // SALVA NOTA
  // ==========================================================

  void requestSalvaNota({
    required String corsoId,
    required String nota,
    required String token,
  }) {
    final id = _requireUserId();

    subscribe(
      notaResponseTopic,
    );

    publish(
      dataRequestTopic,
      {
        'action': 'salva_nota',
        'user_id': id,
        'corso_id': corsoId,
        'nota': nota,
        'token': token,
      },
    );
  }

  // ==========================================================
  // CONTROLLO USER ID
  // ==========================================================

  String _requireUserId() {
    if (_userId == null || _userId!.isEmpty) {
      throw Exception(
        'MQTT: userId non impostato',
      );
    }

    return _userId!;
  }

  // ==========================================================
  // CALLBACK CONNESSIONE
  // ==========================================================

  void _onConnected() {
    print(
      'MQTT: connesso al Raspberry',
    );
  }

  // ==========================================================
  // CALLBACK DISCONNESSIONE
  // ==========================================================

  void _onDisconnected() {
    print(
      'MQTT: disconnesso dal Raspberry',
    );
  }

  // ==========================================================
  // RICEZIONE MESSAGGI
  // ==========================================================

  void _onMessage(
    List<MqttReceivedMessage<MqttMessage>> messages,
  ) {
    for (final message in messages) {
      final payload =
          message.payload as MqttPublishMessage;

      final text = MqttPublishPayload.bytesToStringAsString(
        payload.payload.message,
      );

      print(
        'MQTT ← ${message.topic}',
      );

      print(
        'MQTT ← payload: $text',
      );

      try {
        final decoded = jsonDecode(text);

        if (decoded is! Map<String, dynamic>) {
          print(
            'MQTT: il JSON ricevuto '
            'non è un oggetto',
          );

          continue;
        }

        final data = decoded;

        onMessage?.call(
          message.topic,
          data,
        );

        _dispatchToTopicHandlers(
          message.topic,
          data,
        );

        // ====================================================
        // AUTENTICAZIONE
        // ====================================================

        if (message.topic == authResponseTopic) {
          print(
            'MQTT: risposta autenticazione ricevuta',
          );

          final receivedUserId = data['user_id']?.toString();

          if (receivedUserId != null && receivedUserId.isNotEmpty) {
            setUserId(receivedUserId);
          }

          onAuthResponse?.call(data);
        }

        // ====================================================
        // DATI UTENTE
        // ====================================================

        else if (message.topic == userDataTopic) {
          print(
            'MQTT: dati utente ricevuti',
          );

          onUserData?.call(data);
        }

        // ====================================================
        // CORSI
        // ====================================================

        else if (message.topic == corsiResponseTopic) {
          print(
            'MQTT: risposta corsi ricevuta',
          );

          if (_isMyUserData(data)) {
            onCorsiResponse?.call(data);
          }
        }

        // ====================================================
        // RECUPERI
        // ====================================================

        else if (message.topic == recuperiResponseTopic) {
          print(
            'MQTT: risposta recuperi ricevuta',
          );

          if (_isMyUserData(data)) {
            onRecuperiResponse?.call(data);
          }
        }

        // ====================================================
        // CALORIE
        // ====================================================

        else if (message.topic == calorieResponseTopic) {
          print(
            'MQTT: risposta calorie ricevuta',
          );

          if (_isMyUserData(data)) {
            onCalorieResponse?.call(data);
          }
        }

        // ====================================================
        // PRENOTAZIONE RECUPERO
        // ====================================================

        else if (message.topic == prenotaResponseTopic) {
          print(
            'MQTT: risposta prenotazione ricevuta',
          );

          if (_isMyUserData(data)) {
            onPrenotaRecuperoResponse?.call(data);
          }
        }

        // ====================================================
        // ATTIVITÀ
        // ====================================================

        else if (message.topic == attivitaResponseTopic) {
          print(
            'MQTT: risposta attività ricevuta',
          );

          if (_isMyUserData(data)) {
            onAttivitaResponse?.call(data);
          }
        }

        // ====================================================
        // EVENTI
        // ====================================================

        else if (message.topic == eventiResponseTopic) {
          print(
            'MQTT: risposta eventi ricevuta',
          );

          if (_isMyUserData(data)) {
            onEventiResponse?.call(data);
          }
        }

        // ====================================================
        // NOTA
        // ====================================================

        else if (message.topic == notaResponseTopic) {
          print(
            'MQTT: risposta salvataggio nota ricevuta',
          );

          if (_isMyUserData(data)) {
            onNotaResponse?.call(data);
          }
        }

        // ====================================================
        // TOPIC NON GESTITO
        // ====================================================

        else {
          print(
            'MQTT: topic non gestito: '
            '${message.topic}',
          );
        }
      } catch (e) {
        print(
          'MQTT: errore parsing JSON: $e',
        );
      }
    }
  }

  // ==========================================================
  // CONTROLLO USER ID RISPOSTA
  // ==========================================================

  bool _isMyUserData(
    Map<String, dynamic> data,
  ) {
    if (_userId == null) {
      return false;
    }

    final responseUserId = data['user_id']?.toString();

    return responseUserId == _userId;
  }

  // ==========================================================
  // DISCONNESSIONE
  // ==========================================================

  void disconnect() {
    print(
      'MQTT: disconnessione...',
    );

    if (isConnected) {
      _client!.disconnect();
    }
  }
}
