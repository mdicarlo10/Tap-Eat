class Restaurant {
  final String name;
  final double latitude;
  final double longitude;
  final String distance;
  final String type;
  final String? imageUrl;

  Restaurant({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.type,
    this.imageUrl,
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      name: map['name'] ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      distance: map['distance'] ?? '',
      type: map['type'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'type': type,
      'imageUrl': imageUrl,
    };
  }
}
