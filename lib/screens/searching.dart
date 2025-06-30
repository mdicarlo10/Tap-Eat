import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../screens/navigationpage.dart';
import '../models/restaurant.dart';
import '../main.dart';

class Searching extends StatefulWidget {
  const Searching({Key? key}) : super(key: key);

  @override
  _SearchingPageState createState() => _SearchingPageState();
}

class _SearchingPageState extends State<Searching> {
  late final MapController _mapController;
  late List<Restaurant> _restaurants;
  String _searchQuery = '';
  bool _isDrawingArea = false;
  List<LatLng> polygonPoints = [];
  List<Restaurant> _filteredInPolygon = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _restaurants = [
      Restaurant(
        id: "1",
        name: 'Ristorante 1',
        type: 'Italiana',
        distance: '500 m',
        latitude: 45.4642,
        longitude: 9.1900,
        imageUrl: null,
      ),
      Restaurant(
        id: "2",
        name: 'Pizzeria Bella',
        type: 'Pizzeria',
        distance: '1 km',
        latitude: 45.4650,
        longitude: 9.1910,
        imageUrl: null,
      ),
    ];
  }

  void _toggleDrawing() {
    setState(() {
      polygonPoints.clear();
      _filteredInPolygon.clear();
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

  void _confirmPolygon() {
    if (polygonPoints.length < 3) return;

    final filtered =
        _restaurants.where((rest) {
          final point = LatLng(rest.latitude, rest.longitude);
          return _pointInPolygon(point, polygonPoints);
        }).toList();

    setState(() {
      _filteredInPolygon = filtered;
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
    } else {
      return _restaurants;
    }
  }

  @override
  Widget build(BuildContext context) {
    final center =
        _restaurants.isNotEmpty
            ? LatLng(_restaurants[0].latitude, _restaurants[0].longitude)
            : LatLng(45.4642, 9.1900);

    final showResults = _searchQuery.isNotEmpty || (polygonPoints.length >= 3);
    final results = _filteredRestaurants;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ricerca ristoranti',
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textColor,
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
                      color: Colors.blue.withOpacity(0.3),
                      borderStrokeWidth: 2.0,
                      borderColor: Colors.blue,
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
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          if (_isDrawingArea)
            GestureDetector(
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
          if (showResults)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 250,
                color: backgroundColor,
                child:
                    results.isEmpty
                        ? const Center(child: Text('Nessun risultato'))
                        : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final restaurant = results[index];
                            return ListTile(
                              title: Text(restaurant.name),
                              subtitle: Text(
                                '${restaurant.type} • ${restaurant.distance}',
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => NavigationPage(
                                          restaurant: restaurant,
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
              ),
            ),
        ],
      ),
    );
  }
}
