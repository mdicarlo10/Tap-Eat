import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/restaurant_favorite_provider.dart';
import '../widgets/restaurant_list.dart';
import '../main.dart';

class Preferences extends ConsumerWidget {
  const Preferences({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allFavorites = ref.watch(favoritesProvider);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'I tuoi preferiti',
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
      ),
      body:
          allFavorites.isEmpty
              ? const Center(
                child: Text(
                  'Nessun ristorante preferito',
                  style: TextStyle(color: secondaryTextColor, fontSize: 18),
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
