import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/restaurant_favorite_provider.dart';
import '../widgets/restaurant_list.dart';

class Preferences extends ConsumerWidget {
  const Preferences({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allFavorites = ref.watch(favoritesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'I tuoi preferiti',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        foregroundColor: colorScheme.onPrimary,
      ),
      body:
          allFavorites.isEmpty
              ? Center(
                child: Text(
                  'Nessun ristorante preferito',
                  style: TextStyle(color: colorScheme.secondary, fontSize: 18),
                ),
              )
              : RestaurantList(
                restaurants: allFavorites,
                favorites: allFavorites,
                toggleFavorite: (restaurant) {
                  ref
                      .read(favoritesProvider.notifier)
                      .removeFromFavorites(restaurant);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${restaurant.name} rimosso dai preferiti'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
    );
  }
}
