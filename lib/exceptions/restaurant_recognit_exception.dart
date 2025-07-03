class RestaurantRecognitionException implements Exception {
  final String message;
  RestaurantRecognitionException([
    this.message = "Errore nel riconoscimento dei ristoranti.",
  ]);

  @override
  String toString() => "RestaurantRecognitionException: $message";
}
