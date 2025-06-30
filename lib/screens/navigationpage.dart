import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/restaurant_favorite_provider.dart';
import '../models/restaurant.dart';
import '../database/restaurant_db.dart';
import '../service/map_launcher_service.dart';

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
    final mapLauncher = MapLauncherService();
    final success = await mapLauncher.launchNavigation(
      widget.restaurant.latitude,
      widget.restaurant.longitude,
    );
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aprire Google Maps')),
      );
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Dettagli ristorante',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.white : colorScheme.onPrimary,
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
                        errorBuilder:
                            (context, error, stackTrace) => Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: colorScheme.secondary,
                            ),
                      )
                      : Container(
                        width: double.infinity,
                        height: 180,
                        color: colorScheme.outline,
                        child: Icon(
                          Icons.restaurant,
                          size: 60,
                          color: colorScheme.secondary,
                        ),
                      ),
            ),
            const SizedBox(height: 20),

            Text(
              widget.restaurant.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tipo: ${widget.restaurant.type}",
              style: TextStyle(fontSize: 16, color: colorScheme.secondary),
            ),
            const SizedBox(height: 4),
            Text(
              "Distanza: ${widget.restaurant.distance}",
              style: TextStyle(fontSize: 16, color: colorScheme.secondary),
            ),
            const SizedBox(height: 4),
            Text(
              "Posizione: (${widget.restaurant.latitude.toStringAsFixed(4)}, ${widget.restaurant.longitude.toStringAsFixed(4)})",
              style: TextStyle(fontSize: 16, color: colorScheme.secondary),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _launchMaps,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
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
