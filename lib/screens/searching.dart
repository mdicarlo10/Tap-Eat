import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../screens/navigationpage.dart';
import 'package:tap_eat/models/restaurant.dart';
import '../service/restaurant_recognite_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class Searching extends StatefulWidget {
  const Searching({super.key});

  @override
  SearchingPageState createState() => SearchingPageState();
}

class SearchingPageState extends State<Searching> {
  late final MapController _mapController;
  List<Restaurant> _restaurants = [];
  String _searchQuery = '';
  bool _isDrawingArea = false;
  List<LatLng> polygonPoints = [];

  LatLng? _userPosition;
  Timer? _debounce;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Servizi di localizzazione disabilitati.'),
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      final msg =
          permission == LocationPermission.denied
              ? 'Permesso di localizzazione negato.'
              : 'Permesso di localizzazione negato permanentemente.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      _userPosition = LatLng(position.latitude, position.longitude);
    });
    _mapController.move(_userPosition!, 13);
    await _fetchRestaurants(position.latitude, position.longitude);

    _positionSubscription = Geolocator.getPositionStream().listen((pos) async {
      if (!mounted) return;
      setState(() {
        _userPosition = LatLng(pos.latitude, pos.longitude);
      });
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.isNotEmpty) {
        LatLng center = _mapController.center;
        await _fetchRestaurants(
          center.latitude,
          center.longitude,
          query: value,
          radius: 4000,
        );
      } else {
        if (_userPosition != null) {
          await _fetchRestaurants(
            _userPosition!.latitude,
            _userPosition!.longitude,
          );
        }
      }
    });
  }

  Future<void> _fetchRestaurants(
    double latitude,
    double longitude, {
    String? query,
    int radius = 2000,
  }) async {
    try {
      final results = await RestaurantRecognizerService.searchNearbyRestaurants(
        latitude: latitude,
        longitude: longitude,
        query: query,
        radius: radius,
      );
      if (!mounted) return;
      setState(() {
        _restaurants = results;
      });
    } catch (e) {
      debugPrint("Errore nel caricamento ristoranti: $e");
      if (mounted) {
        setState(() => _restaurants = []);
      }
    }
  }

  void _toggleDrawing() {
    setState(() {
      polygonPoints.clear();
      _isDrawingArea = !_isDrawingArea;
      _searchQuery = '';
    });
  }

  LatLng _convertToLatLng(Offset position) {
    final bounds = _mapController.bounds!;
    final size = MediaQuery.of(context).size;

    final lat =
        bounds.north +
        (bounds.south - bounds.north) * (position.dy / size.height);
    final lng =
        bounds.west + (bounds.east - bounds.west) * (position.dx / size.width);

    return LatLng(lat, lng);
  }

  void _confirmPolygon() async {
    if (polygonPoints.length < 3) return;

    double sumLat = 0;
    double sumLng = 0;
    for (final p in polygonPoints) {
      sumLat += p.latitude;
      sumLng += p.longitude;
    }
    final center = LatLng(
      sumLat / polygonPoints.length,
      sumLng / polygonPoints.length,
    );

    if (_userPosition != null) {
      final dist = const Distance().as(
        LengthUnit.Meter,
        _userPosition!,
        center,
      );
      if (dist > 2000) {
        await _fetchRestaurants(center.latitude, center.longitude);
      }
    }

    setState(() {
      _isDrawingArea = false;
    });
  }

  bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      LatLng a = polygon[j];
      LatLng b = polygon[j + 1];
      if (((a.latitude > point.latitude) != (b.latitude > point.latitude)) &&
          (point.longitude <
              (b.longitude - a.longitude) *
                      (point.latitude - a.latitude) /
                      (b.latitude - a.latitude) +
                  a.longitude)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }

  List<Restaurant> get _filteredRestaurants {
    if (_searchQuery.isNotEmpty) {
      return _restaurants.where((rest) {
        final name = rest.name.toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    } else if (polygonPoints.length >= 3) {
      return _restaurants.where((rest) {
        final point = LatLng(rest.latitude, rest.longitude);
        return _pointInPolygon(point, polygonPoints);
      }).toList();
    } else if (_userPosition != null) {
      return _restaurants.where((rest) {
        final dist = const Distance().as(
          LengthUnit.Meter,
          _userPosition!,
          LatLng(rest.latitude, rest.longitude),
        );
        return dist <= 2000;
      }).toList();
    } else {
      return _restaurants;
    }
  }

  @override
  Widget build(BuildContext context) {
    final center =
        polygonPoints.isNotEmpty && polygonPoints.length >= 3
            ? polygonPoints[0]
            : _userPosition ??
                (_restaurants.isNotEmpty
                    ? LatLng(
                      _restaurants[0].latitude,
                      _restaurants[0].longitude,
                    )
                    : LatLng(41.9028, 12.4964));

    final results = _filteredRestaurants;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Ricerca ristoranti',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(_isDrawingArea ? Icons.close : Icons.edit),
            tooltip: _isDrawingArea ? 'Annulla disegno' : 'Disegna area',
            onPressed: _toggleDrawing,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(center: center, zoom: 13),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tapeat',
              ),
              if (polygonPoints.length > 2)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: polygonPoints,
                      color: Colors.blue,
                      borderStrokeWidth: 2.0,
                      borderColor: Colors.blue,
                    ),
                  ],
                ),
              if (_userPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userPosition!,
                      width: 40,
                      height: 40,
                      builder:
                          (_) =>
                              const Icon(Icons.my_location, color: Colors.blue),
                    ),
                  ],
                ),
              MarkerLayer(
                markers:
                    results.map((restaurant) {
                      final loc = LatLng(
                        restaurant.latitude,
                        restaurant.longitude,
                      );
                      return Marker(
                        point: loc,
                        width: 40,
                        height: 40,
                        builder:
                            (_) => const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                            ),
                      );
                    }).toList(),
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(4),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Ricerca ristoranti',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
          if (_isDrawingArea)
            Positioned.fill(
              top: 70,
              child: GestureDetector(
                onPanUpdate: (details) {
                  final point = _convertToLatLng(details.localPosition);
                  setState(() {
                    polygonPoints.add(point);
                  });
                },
                onPanEnd: (_) {
                  _confirmPolygon();
                },
                child: Container(color: Colors.transparent),
              ),
            ),
          if (results.isNotEmpty)
            DraggableScrollableSheet(
              initialChildSize: 0.15,
              minChildSize: 0.10,
              maxChildSize: 0.55,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 6,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final restaurant = results[index];
                            return ListTile(
                              title: Text(
                                restaurant.name,
                                style: TextStyle(color: colorScheme.onSurface),
                              ),
                              subtitle: Text(
                                '${restaurant.type} • ${restaurant.distance}',
                                style: TextStyle(color: colorScheme.secondary),
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => NavigationPage(
                                          restaurant: restaurant,
                                        ),
                                  ),
                                );
                                if (!mounted) return;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
