import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Searching extends StatefulWidget {
  const Searching({Key? key}) : super(key: key);

  @override
  State<Searching> createState() => _SearchingState();
}

class _SearchingState extends State<Searching> {
  final MapController _mapController = MapController();

  // Centro iniziale (es. Roma)
  LatLng center = LatLng(41.9028, 12.4964);

  // Area selezionata (qui semplice bounding box simulata)
  LatLng? areaTopLeft;
  LatLng? areaBottomRight;
  bool isSelectingArea = false;

  // Lista fittizia di ristoranti
  final List<Map<String, dynamic>> allRestaurants = [
    {"name": "Ristorante A", "location": LatLng(41.9, 12.49)},
    {"name": "Ristorante B", "location": LatLng(41.91, 12.48)},
    {"name": "Ristorante C", "location": LatLng(41.89, 12.50)},
    {"name": "Ristorante D", "location": LatLng(41.88, 12.47)},
  ];

  List<Map<String, dynamic>> filteredRestaurants = [];

  @override
  void initState() {
    super.initState();
    filteredRestaurants = allRestaurants;
  }

  void startSelectingArea() {
    setState(() {
      isSelectingArea = true;
      areaTopLeft = null;
      areaBottomRight = null;
      filteredRestaurants = [];
    });
  }

  void finishSelectingArea() {
    if (areaTopLeft != null && areaBottomRight != null) {
      filterRestaurantsInArea();
      setState(() {
        isSelectingArea = false;
      });
    }
  }

  void filterRestaurantsInArea() {
    final topLat = areaTopLeft!.latitude;
    final leftLng = areaTopLeft!.longitude;
    final bottomLat = areaBottomRight!.latitude;
    final rightLng = areaBottomRight!.longitude;

    filteredRestaurants =
        allRestaurants.where((restaurant) {
          final loc = restaurant["location"] as LatLng;
          return loc.latitude <= topLat &&
              loc.latitude >= bottomLat &&
              loc.longitude >= leftLng &&
              loc.longitude <= rightLng;
        }).toList();
  }

  // Simuliamo la selezione area con due tap: primo tap = angolo alto-sinistro,
  // secondo tap = angolo basso-destro della selezione
  void onMapTap(LatLng tappedPoint) {
    if (!isSelectingArea) return;

    setState(() {
      if (areaTopLeft == null) {
        areaTopLeft = tappedPoint;
      } else if (areaBottomRight == null) {
        areaBottomRight = tappedPoint;
      } else {
        // Reset se doppio tap
        areaTopLeft = tappedPoint;
        areaBottomRight = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mappa - Cerca area'),
        actions: [
          if (!isSelectingArea)
            IconButton(
              icon: const Icon(Icons.crop_square),
              tooltip: 'Seleziona Area',
              onPressed: startSelectingArea,
            ),
          if (isSelectingArea)
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Conferma Area',
              onPressed: finishSelectingArea,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: center,
                zoom: 13,
                onTap: (tapPosition, point) => onMapTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.tap_eat',
                ),
                if (areaTopLeft != null && areaBottomRight != null)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: [
                          areaTopLeft!,
                          LatLng(
                            areaTopLeft!.latitude,
                            areaBottomRight!.longitude,
                          ),
                          areaBottomRight!,
                          LatLng(
                            areaBottomRight!.latitude,
                            areaTopLeft!.longitude,
                          ),
                        ],
                        color: Colors.orange.withOpacity(0.3),
                        borderStrokeWidth: 2,
                        borderColor: Colors.deepOrange,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers:
                      filteredRestaurants
                          .map(
                            (rest) => Marker(
                              point: rest['location'] as LatLng,
                              width: 40,
                              height: 40,
                              builder:
                                  (context) => const Icon(
                                    Icons.restaurant,
                                    color: Colors.deepOrange,
                                    size: 30,
                                  ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              child:
                  filteredRestaurants.isEmpty
                      ? const Center(
                        child: Text(
                          'Nessun ristorante nell\'area selezionata.',
                        ),
                      )
                      : ListView.builder(
                        itemCount: filteredRestaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = filteredRestaurants[index];
                          return ListTile(
                            leading: const Icon(
                              Icons.restaurant_menu,
                              color: Colors.deepOrange,
                            ),
                            title: Text(restaurant['name']),
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
