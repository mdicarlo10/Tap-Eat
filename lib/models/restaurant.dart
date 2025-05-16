class Restaurant {
  final int? id;
  final String name;
  final String distance;
  final String type;
  final double latitude;
  final double longitude;
  final String? address;
  final String? imageUrl;
  final double? rating;
  final int timestamp;

  Restaurant({
    this.id,
    required this.name,
    required this.distance,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.address,
    this.imageUrl,
    this.rating,
    required this.timestamp,
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'],
      name: map['name'],
      distance: map['distance'],
      type: map['type'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      address: map['address'],
      imageUrl: map['imageUrl'],
      rating: map['rating']?.toDouble(),
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'distance': distance,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'imageUrl': imageUrl,
      'rating': rating,
      'timestamp': timestamp,
    };
  }
}
