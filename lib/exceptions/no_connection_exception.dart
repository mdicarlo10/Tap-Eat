class NoConnectionException implements Exception {
  final String message;
  NoConnectionException([this.message = 'Nessuna connessione Internet.']);

  @override
  String toString() => message;
}
