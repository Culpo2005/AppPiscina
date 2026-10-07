/// Represents a work shift or course at the swimming pool
class Shift {
  final String id;
  final String courseName;
  final String courseLevel;       // es. "Livello 1", "Avanzato"
  final String lane;               // es. "Corsia 1"
  final DateTime startTime;
  final DateTime endTime;
  final ShiftStatus status;
  final String? notes;

  Shift({
    required this.id,
    required this.courseName,
    required this.courseLevel,
    required this.lane,
    required this.startTime,
    required this.endTime,
    this.status = ShiftStatus.scheduled,
    this.notes,
  });

  /// Duration of the shift in minutes
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// Check if shift is currently happening
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Check if shift is in the past
  bool get isPast {
    return endTime.isBefore(DateTime.now());
  }

  /// Check if shift is in the future
  bool get isFuture {
    return startTime.isAfter(DateTime.now());
  }

  /// Format time as HH:mm
  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String get timeRange {
    return "${formatTime(startTime)} - ${formatTime(endTime)}";
  }

  @override
  String toString() => 'Shift(id: $id, courseName: $courseName, timeRange: $timeRange)';
}

/// Status of a shift
enum ShiftStatus {
  scheduled,    // Programmato
  ongoing,      // In corso
  completed,    // Completato
  cancelled,    // Annullato
}

extension ShiftStatusExtension on ShiftStatus {
  String get label {
    switch (this) {
      case ShiftStatus.scheduled:
        return 'Programmato';
      case ShiftStatus.ongoing:
        return 'In corso';
      case ShiftStatus.completed:
        return 'Completato';
      case ShiftStatus.cancelled:
        return 'Annullato';
    }
  }

  String get abbreviation {
    switch (this) {
      case ShiftStatus.scheduled:
        return 'PGM';
      case ShiftStatus.ongoing:
        return 'ON';
      case ShiftStatus.completed:
        return 'CMP';
      case ShiftStatus.cancelled:
        return 'ANN';
    }
  }
}
