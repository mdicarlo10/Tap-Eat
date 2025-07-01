import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import 'restaurant_card.dart';

class RestaurantList extends StatelessWidget {
  final List<Restaurant> restaurants;
  final List<Restaurant> favorites;
  final Function(Restaurant) toggleFavorite;

  const RestaurantList({
    super.key,
    required this.restaurants,
    required this.favorites,
    required this.toggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        final isFavorite = favorites.any((fav) => fav.id == restaurant.id);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          child: RestaurantCard(
            restaurant: restaurant,
            isFavorite: isFavorite,
            onFavoriteToggle: () => toggleFavorite(restaurant),
            showFavoriteIcon: true,
            favoriteColor: const Color(0xFFE07A5F),
          ),
        );
      },
    );
  }
}
