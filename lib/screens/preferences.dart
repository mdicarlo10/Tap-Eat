import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_list.dart';
import '../main.dart';

class Preferences extends StatefulWidget {
  const Preferences({Key? key}) : super(key: key);

  @override
  State<Preferences> createState() => _SearchingState();
}

class _SearchingState extends State<Preferences> {
  //Simulo la lista dei ristoranti che poi mi dovrò recuperare dal DB
  final List<Restaurant> allRestaurants = [
    Restaurant(
      name: 'Ristorante Bella Napoli',
      latitude: 45.4642,
      longitude: 9.1900,
      distance: '500 m',
      type: 'Italiana',
      imageUrl: 'https://example.com/image1.jpg',
      isFavorite: true,
    ),
    Restaurant(
      name: 'Sushi World',
      latitude: 45.4650,
      longitude: 9.1910,
      distance: '1 km',
      type: 'Giapponese',
      imageUrl: 'https://example.com/image2.jpg',
      isFavorite: false,
    ),
    Restaurant(
      name: 'Pizzeria da Marco',
      latitude: 45.4660,
      longitude: 9.1920,
      distance: '800 m',
      type: 'Pizzeria',
      imageUrl: null,
      isFavorite: true,
    ),
  ];

  late List<Restaurant> favorites;

  @override
  void initState() {
    super.initState();
    favorites = allRestaurants.where((r) => r.isFavorite).toList();
  }

  void toggleFavorite(Restaurant restaurant) {
    setState(() {
      final isFav = favorites.any((r) => r.name == restaurant.name);
      if (isFav) {
        favorites.removeWhere((r) => r.name == restaurant.name);
      } else {
        favorites.add(restaurant);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('I tuoi preferiti'),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textColor,
      ),
      body:
          favorites.isEmpty
              ? Center(
                child: Text(
                  'Nessun ristorante preferito',
                  style: TextStyle(color: secondaryTextColor, fontSize: 18),
                ),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: RestaurantList(
                  restaurants: favorites,
                  favorites: favorites,
                  toggleFavorite: toggleFavorite,
                ),
              ),
    );
  }
}
