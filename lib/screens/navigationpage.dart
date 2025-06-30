import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/restaurant_favorite_provider.dart';
import '../models/restaurant.dart';
import '../database/restaurant_db.dart';
import '../main.dart';

class NavigationPage extends ConsumerStatefulWidget {
  final Restaurant restaurant;

  const NavigationPage({super.key, required this.restaurant});

  ConsumerState<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<NavigationPage> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    final favorites = ref.read(favoritesProvider);
    _isFavorite = favorites.any((r) => r.id == widget.restaurant.id);
    _saveAsRecentlyViewed();
  }

  Future<void> _saveAsRecentlyViewed() async {
    await RestaurantDatabase.instance.insert(
      Restaurant(
        id: widget.restaurant.id,
        name: widget.restaurant.name,
        latitude: widget.restaurant.latitude,
        longitude: widget.restaurant.longitude,
        distance: widget.restaurant.distance,
        type: widget.restaurant.type,
        imageUrl: widget.restaurant.imageUrl,
        isFavorite: widget.restaurant.isFavorite,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  void _launchMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${widget.restaurant.latitude},${widget.restaurant.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossibile aprire Google Maps';
    }
  }

  void _toggleFavorite() {
    final favoritesNotifier = ref.read(favoritesProvider.notifier);
    final wasFavorite = _isFavorite;

    setState(() {
      _isFavorite = !wasFavorite;
    });

    if (!wasFavorite) {
      favoritesNotifier.addToFavorites(widget.restaurant);
    } else {
      favoritesNotifier.removeFromFavorites(widget.restaurant);
    }

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasFavorite
              ? '${widget.restaurant.name} rimosso dai preferiti'
              : '${widget.restaurant.name} aggiunto ai preferiti',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
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
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : textColor,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  widget.restaurant.imageUrl != null
                      ? Image.network(
                        widget.restaurant.imageUrl!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        width: double.infinity,
                        height: 180,
                        color: borderColor,
                        child: const Icon(
                          Icons.restaurant,
                          size: 60,
                          color: secondaryTextColor,
                        ),
                      ),
            ),
            const SizedBox(height: 20),

            Text(
              widget.restaurant.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tipo: ${widget.restaurant.type}",
              style: const TextStyle(fontSize: 16, color: secondaryTextColor),
            ),
            const SizedBox(height: 4),
            Text(
              "Distanza: ${widget.restaurant.distance}",
              style: const TextStyle(fontSize: 16, color: secondaryTextColor),
            ),
            const SizedBox(height: 4),
            Text(
              "Posizione: (${widget.restaurant.latitude.toStringAsFixed(4)}, ${widget.restaurant.longitude.toStringAsFixed(4)})",
              style: const TextStyle(fontSize: 16, color: secondaryTextColor),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.navigation, color: Colors.white),
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
