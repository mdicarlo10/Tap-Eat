import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/restaurant.dart';

class NavigationPage extends StatefulWidget {
  final Restaurant restaurant;

  const NavigationPage({super.key, required this.restaurant});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(
            widget.restaurant.latitude,
            widget.restaurant.longitude,
          ),
          zoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.tua_app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  widget.restaurant.latitude,
                  widget.restaurant.longitude,
                ),
                width: 40,
                height: 40,
                builder:
                    (context) => const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
