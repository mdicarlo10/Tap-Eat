import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../screens/navigationpage.dart';
import '../models/restaurant.dart';
import '../service/restaurant_recognite_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

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

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool? _isOffline;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _checkConnection();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      if (!mounted) return;
      setState(() {
        _isOffline = result.contains(ConnectivityResult.none);
      });
    });
    _initLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _positionSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivityResult.contains(ConnectivityResult.none);
    });
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Servizi di localizzazione disabilitati.'),
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (!mounted) return;
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permesso di localizzazione negato.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permesso di localizzazione negato permanentemente.'),
        ),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      _userPosition = LatLng(position.latitude, position.longitude);
    });
    if (!mounted || !_mapReady) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _userPosition != null && _mapReady) {
        _mapController.move(_userPosition!, 13);
      }
    });

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
      if (!mounted) return;
      setState(() {
        _restaurants = [];
      });
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
    final colorScheme = Theme.of(context).colorScheme;

    if (_isOffline == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_isOffline!) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Sei offline!\nNon si può usare la mappa',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      );
    }

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
            options: MapOptions(
              center: center,
              zoom: 13,
              onMapReady: () {
                if (mounted) {
                  setState(() {
                    _mapReady = true;
                  });
                }
              },
            ),
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
