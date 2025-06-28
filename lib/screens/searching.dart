import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class Searching extends StatefulWidget {
  const Searching({Key? key}) : super(key: key);

  @override
  _SearchingPageState createState() => _SearchingPageState();
}

class _SearchingPageState extends State<Searching> {
  late final MapController _mapController;
  late List<Map<String, dynamic>> _restaurants;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Lista statica dei ristoranti
    _restaurants = [
      {
        'name': 'Ristorante 1',
        'type': 'Italiana',
        'distance': '500 m',
        'location': LatLng(45.4642, 9.1900),
      },
      {
        'name': 'Ristorante 2',
        'type': 'Pizzeria',
        'distance': '1 km',
        'location': LatLng(45.4650, 9.1910),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final center =
        _restaurants.isNotEmpty
            ? (_restaurants[0]['location'] as LatLng)
            : LatLng(45.4642, 9.1900); // esempio: Milano

    return Scaffold(
      appBar: AppBar(title: const Text('Ristoranti')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(center: center, zoom: 13),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.tapeat',
          ),
        ],
      ),
    );
  }
}
