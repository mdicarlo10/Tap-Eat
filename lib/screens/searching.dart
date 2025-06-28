import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Searching extends StatefulWidget {
  const Searching({Key? key}) : super(key: key);

  @override
  _SearchingPageState createState() => _SearchingPageState();
}

class _SearchingPageState extends State<Searching> {
  late final MapController _mapController;
  late List<Map<String, dynamic>> _restaurants;
  String _searchQuery = '';
  bool _isDrawingArea = false;
  List<LatLng> polygonPoints = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _restaurants = [
      {
        'name': 'Ristorante 1',
        'type': 'Italiana',
        'distance': '500 m',
        'location': LatLng(45.4642, 9.1900),
      },
      {
        'name': 'Pizzeria Bella',
        'type': 'Pizzeria',
        'distance': '1 km',
        'location': LatLng(45.4650, 9.1910),
      },
    ];
  }

  void _toggleDrawing() {
    setState(() {
      if (_isDrawingArea) {
        polygonPoints.clear();
        _isDrawingArea = false;
      } else {
        _isDrawingArea = true;
      }
    });
  }

  void _addPointToPolygon(LatLng point) {
    if (_isDrawingArea) {
      setState(() {
        polygonPoints.add(point);
      });
    }
  }

  List<Map<String, dynamic>> get _filteredRestaurants {
    if (_searchQuery.isEmpty) return _restaurants;
    return _restaurants.where((rest) {
      final name = (rest['name'] as String).toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    final center =
        _restaurants.isNotEmpty
            ? (_restaurants[0]['location'] as LatLng)
            : LatLng(45.4642, 9.1900);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ristoranti'),
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
          GestureDetector(
            onTapUp: (details) {
              if (_isDrawingArea) {
                final RenderBox renderBox =
                    context.findRenderObject() as RenderBox;
                final localOffset = renderBox.globalToLocal(
                  details.globalPosition,
                );
                final point = _mapController.pointToLatLng(
                  CustomPoint(localOffset.dx, localOffset.dy),
                );
                if (point != null) {
                  _addPointToPolygon(point);
                }
              }
            },
            child: FlutterMap(
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
                      _restaurants.map((rest) {
                        final LatLng point = rest['location'];
                        return Marker(
                          point: point,
                          width: 40,
                          height: 40,
                          builder:
                              (_) => const Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),

          // Search input
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(4),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Cerca ristorante',
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

          // Risultati della ricerca
          if (_searchQuery.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 250,
              child: Container(
                color: Colors.white.withOpacity(0.95),
                child:
                    _filteredRestaurants.isEmpty
                        ? const Center(child: Text('Nessun risultato'))
                        : ListView.builder(
                          itemCount: _filteredRestaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = _filteredRestaurants[index];
                            return ListTile(
                              title: Text(restaurant['name']),
                              subtitle: Text(
                                '${restaurant['type']} • ${restaurant['distance']}',
                              ),
                              onTap: () {
                                final loc = restaurant['location'] as LatLng;
                                _mapController.move(loc, 15);
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
