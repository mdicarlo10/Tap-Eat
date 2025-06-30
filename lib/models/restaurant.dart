class Restaurant {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String distance;
  final String type;
  final String? imageUrl;
  final bool isFavorite;

  Restaurant({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.type,
    this.imageUrl,
    this.isFavorite = false,
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'],
      name: map['name'] ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      distance: map['distance'] ?? '',
      type: map['type'] ?? '',
      imageUrl: map['imageUrl'],
      isFavorite: map['isFavorite'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'type': type,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }
}
