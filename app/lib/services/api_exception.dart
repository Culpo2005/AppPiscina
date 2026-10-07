/// Eccezione sollevata da [ApiClient] quando una chiamata fallisce
/// (errore di rete, timeout, risposta con status code di errore...).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException(${statusCode ?? '-'}): $message';
}
