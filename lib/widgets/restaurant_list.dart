import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import 'restaurant_card.dart';

class RestaurantList extends StatelessWidget {
  final List<Restaurant> restaurants;
  final List<Restaurant> favorites;
  final Function(Restaurant) toggleFavorite;

  const RestaurantList({
    Key? key,
    required this.restaurants,
    required this.favorites,
    required this.toggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // evita doppio scroll
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          child: RestaurantCard(restaurant: restaurant),
        );
      },
    );
  }
}
