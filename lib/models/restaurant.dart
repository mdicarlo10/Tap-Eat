import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Restaurant {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String distance;
  final String type;
  final String? imageUrl;
  final int timestamp;
  final bool isFavorite;

  Restaurant({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.type,
    this.imageUrl,
    this.isFavorite = false,
    int? timestamp,
    String? id,
  }) : id = id ?? uuid.v4(),
       timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'type': type,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      distance: map['distance'] ?? '',
      type: map['type'] ?? '',
      imageUrl: map['imageUrl'],
      timestamp: map['timestamp'],
      isFavorite: map['isFavorite'] == 1,
    );
  }
}
