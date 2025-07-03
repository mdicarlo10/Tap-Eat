class RestaurantNotFoundException implements Exception {
  final String message;
  RestaurantNotFoundException([
    this.message = 'Nessun ristorante trovato nell’area selezionata.',
  ]);

  @override
  String toString() => 'RestaurantNotFoundException: $message';
}
