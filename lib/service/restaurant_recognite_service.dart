import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tap_eat/models/restaurant.dart';

class RestaurantRecognizerService {
  static final String? _apiKey = dotenv.env['FOURSQUARE_API_KEY'];
  static const String _baseUrl = 'https://api.foursquare.com/v3/places/search';
  static const String _photoBaseUrl = 'https://api.foursquare.com/v3/places';

  static Future<List<Restaurant>> searchNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radius = 1000,
    int limit = 50,
    String? query,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'll': '$latitude,$longitude',
          'radius': radius.toString(),
          'limit': limit.toString(),
          'categories': '13065',
          if (query != null && query.isNotEmpty) 'query': query,
        },
      );

      final response = await http.get(
        uri,
        headers: {'Authorization': _apiKey!, 'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw HttpException(
          'Errore nella chiamata Foursquare: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);
      final results = decoded['results'] as List<dynamic>;

      final restaurants = await Future.wait(
        results.map((result) async {
          final name = result['name'];
          final location = result['geocodes']['main'];
          final lat = (location['latitude'] as num?)?.toDouble() ?? 0.0;
          final lng = (location['longitude'] as num?)?.toDouble() ?? 0.0;
          final distance = (result['distance'] as num?)?.toDouble() ?? 0.0;
          final type = result['categories']?[0]?['name'] ?? 'Ristorante';
          final fsqId = result['fsq_id'];

          String? imageUrl = await _fetchImageUrl(fsqId);

          return Restaurant(
            id: fsqId,
            name: name,
            latitude: lat,
            longitude: lng,
            distance: distance,
            type: type,
            imageUrl: imageUrl,
          );
        }),
      );

      return restaurants;
    } on SocketException {
      throw Exception("Nessuna connessione a Internet.");
    } catch (e) {
      throw Exception("Errore nel riconoscimento dei ristoranti: $e");
    }
  }

  static Future<String?> _fetchImageUrl(String fsqId) async {
    final uri = Uri.parse('$_photoBaseUrl/$fsqId/photos?limit=1');

    final response = await http.get(
      uri,
      headers: {'Authorization': _apiKey!, 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) return null;

    final photos = jsonDecode(response.body) as List<dynamic>;
    if (photos.isEmpty) return null;

    final photo = photos[0];
    final prefix = photo['prefix'];
    final suffix = photo['suffix'];
    return '$prefix'
        'original'
        '$suffix';
  }
}
