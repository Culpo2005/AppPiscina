// ============================================================
// MODELLI DI RISPOSTA MQTT
// ============================================================

class MqttDataResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  MqttDataResponse({
    this.success = false,
    this.message,
    this.data,
    this.error,
  });
}

// ============================================================
// RISPOSTA CORSI
// ============================================================

class CorsiResponse {
  final List<CorsoMqtt> corsi;
  final String userId;

  CorsiResponse({
    required this.corsi,
    required this.userId,
  });

  factory CorsiResponse.fromJson(Map<String, dynamic> json) {
    final corsiList = (json['corsi'] as List?)
        ?.map((c) => CorsoMqtt.fromJson(c as Map<String, dynamic>))
        .toList() ?? [];

    return CorsiResponse(
      corsi: corsiList,
      userId: json['user_id']?.toString() ?? '',
    );
  }
}

class CorsoMqtt {
  final String id;
  final String nome;
  final String giorno;
  final String ora;
  final String istruttore;
  final String corsia;
  final String note;

  CorsoMqtt({
    required this.id,
    required this.nome,
    required this.giorno,
    required this.ora,
    required this.istruttore,
    required this.corsia,
    this.note = '',
  });

  factory CorsoMqtt.fromJson(Map<String, dynamic> json) {
    return CorsoMqtt(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      giorno: json['giorno']?.toString() ?? '',
      ora: json['ora']?.toString() ?? '',
      istruttore: json['istruttore']?.toString() ?? '',
      corsia: json['corsia']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
    );
  }
}

// ============================================================
// RISPOSTA RECUPERI
// ============================================================

class RecuperiResponse {
  final List<RecuperoMqtt> recuperi;
  final String userId;

  RecuperiResponse({
    required this.recuperi,
    required this.userId,
  });

  factory RecuperiResponse.fromJson(Map<String, dynamic> json) {
    final recuperiList = (json['recuperi'] as List?)
        ?.map((r) => RecuperoMqtt.fromJson(r as Map<String, dynamic>))
        .toList() ?? [];

    return RecuperiResponse(
      recuperi: recuperiList,
      userId: json['user_id']?.toString() ?? '',
    );
  }
}

class RecuperoMqtt {
  final String id;
  final String nomeCorso;
  final String giorno;
  final String ora;
  final String istruttore;
  final String corsia;
  final String disponibilita;
  final bool prenotato;

  RecuperoMqtt({
    required this.id,
    required this.nomeCorso,
    required this.giorno,
    required this.ora,
    required this.istruttore,
    required this.corsia,
    required this.disponibilita,
    this.prenotato = false,
  });

  factory RecuperoMqtt.fromJson(Map<String, dynamic> json) {
    return RecuperoMqtt(
      id: json['id']?.toString() ?? '',
      nomeCorso: json['nomeCorso']?.toString() ?? '',
      giorno: json['giorno']?.toString() ?? '',
      ora: json['ora']?.toString() ?? '',
      istruttore: json['istruttore']?.toString() ?? '',
      corsia: json['corsia']?.toString() ?? '',
      disponibilita: json['disponibilita']?.toString() ?? '',
      prenotato: json['prenotato'] == true,
    );
  }
}

// ============================================================
// RISPOSTA ATTIVITÀ
// ============================================================

class AttivitaResponse {
  final List<AttivitaMqtt> attivita;
  final String userId;

  AttivitaResponse({
    required this.attivita,
    required this.userId,
  });

  factory AttivitaResponse.fromJson(Map<String, dynamic> json) {
    final attivitaList = (json['attivita'] as List?)
        ?.map((a) => AttivitaMqtt.fromJson(a as Map<String, dynamic>))
        .toList() ?? [];

    return AttivitaResponse(
      attivita: attivitaList,
      userId: json['user_id']?.toString() ?? '',
    );
  }
}

class AttivitaMqtt {
  final String id;
  final String nome;
  final String descrizione;
  final String immagine;

  AttivitaMqtt({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.immagine,
  });

  factory AttivitaMqtt.fromJson(Map<String, dynamic> json) {
    return AttivitaMqtt(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      descrizione: json['descrizione']?.toString() ?? '',
      immagine: json['immagine']?.toString() ?? '',
    );
  }
}

// ============================================================
// RISPOSTA EVENTI
// ============================================================

class EventiResponse {
  final List<EventoMqtt> eventi;
  final String userId;

  EventiResponse({
    required this.eventi,
    required this.userId,
  });

  factory EventiResponse.fromJson(Map<String, dynamic> json) {
    final eventiList = (json['eventi'] as List?)
        ?.map((e) => EventoMqtt.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return EventiResponse(
      eventi: eventiList,
      userId: json['user_id']?.toString() ?? '',
    );
  }
}

class EventoMqtt {
  final String id;
  final String nome;
  final String descrizione;
  final String data;
  final String ora;
  final String luogo;
  final String immagine;

  EventoMqtt({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.data,
    required this.ora,
    required this.luogo,
    required this.immagine,
  });

  factory EventoMqtt.fromJson(Map<String, dynamic> json) {
    return EventoMqtt(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      descrizione: json['descrizione']?.toString() ?? '',
      data: json['data']?.toString() ?? '',
      ora: json['ora']?.toString() ?? '',
      luogo: json['luogo']?.toString() ?? '',
      immagine: json['immagine']?.toString() ?? '',
    );
  }
}

// ============================================================
// RISPOSTA CALORIE
// ============================================================

class CalorieResponse {
  final double calorie;
  final String userId;

  CalorieResponse({
    required this.calorie,
    required this.userId,
  });

  factory CalorieResponse.fromJson(Map<String, dynamic> json) {
    return CalorieResponse(
      calorie: (json['calorie'] as num?)?.toDouble() ?? 0.0,
      userId: json['user_id']?.toString() ?? '',
    );
  }
}

// ============================================================
// RISPOSTA PRENOTAZIONE
// ============================================================

class PrenotaResponse {
  final bool success;
  final String message;
  final String userId;
  final String? recuperoId;

  PrenotaResponse({
    required this.success,
    required this.message,
    required this.userId,
    this.recuperoId,
  });

  factory PrenotaResponse.fromJson(Map<String, dynamic> json) {
    return PrenotaResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      recuperoId: json['recupero_id']?.toString(),
    );
  }
}

// ============================================================
// RISPOSTA NOTA
// ============================================================

class NotaResponse {
  final bool success;
  final String message;
  final String userId;
  final String? corsoId;

  NotaResponse({
    required this.success,
    required this.message,
    required this.userId,
    this.corsoId,
  });

  factory NotaResponse.fromJson(Map<String, dynamic> json) {
    return NotaResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      corsoId: json['corso_id']?.toString(),
    );
  }
}
