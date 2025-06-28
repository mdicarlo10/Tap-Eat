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

  List<Map<String, dynamic>> get _filteredRestaurants {
    if (_searchQuery.isEmpty) return _restaurants;
    return _restaurants.where((rest) {
      final name = (rest['name'] as String).toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final center =
        _restaurants.isNotEmpty
            ? (_restaurants[0]['location'] as LatLng)
            : LatLng(45.4642, 9.1900);

    return Scaffold(
      appBar: AppBar(title: const Text('Ristoranti')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Cerca ristorante',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(center: center, zoom: 13),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.tapeat',
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: _filteredRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _filteredRestaurants[index];
                return ListTile(
                  title: Text(restaurant['name']),
                  subtitle: Text(
                    '${restaurant['type']} • ${restaurant['distance']}',
                  ),
                  onTap: () {
                    // Qui puoi navigare alla pagina dettaglio
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
