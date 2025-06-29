import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/restaurant.dart';
import '../main.dart';

class NavigationPage extends StatelessWidget {
  final Restaurant restaurant;

  const NavigationPage({super.key, required this.restaurant});

  void _launchMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${restaurant.latitude},${restaurant.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossibile aprire Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Dettagli ristorante',
          style: const TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  restaurant.imageUrl != null
                      ? Image.network(
                        restaurant.imageUrl!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        width: double.infinity,
                        height: 180,
                        color: borderColor.withOpacity(0.3),
                        child: const Icon(
                          Icons.restaurant,
                          size: 60,
                          color: secondaryTextColor,
                        ),
                      ),
            ),
            const SizedBox(height: 20),

            Text(
              restaurant.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tipo: ${restaurant.type}",
              style: const TextStyle(fontSize: 16, color: secondaryTextColor),
            ),
            const SizedBox(height: 4),
            Text(
              "Distanza: ${restaurant.distance}",
              style: const TextStyle(fontSize: 16, color: secondaryTextColor),
            ),
            const SizedBox(height: 4),
            Text(
              "Posizione: (${restaurant.latitude.toStringAsFixed(4)}, ${restaurant.longitude.toStringAsFixed(4)})",
              style: const TextStyle(fontSize: 16, color: secondaryTextColor),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _launchMaps,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                label: const Text(
                  "Portami al ristorante",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
