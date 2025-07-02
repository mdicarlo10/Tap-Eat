import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../database/restaurant_db.dart';
import 'restaurant_card.dart';

class LatestRestaurant extends StatefulWidget {
  const LatestRestaurant({super.key});

  @override
  State<LatestRestaurant> createState() => _LatestRestaurantState();
}

class _LatestRestaurantState extends State<LatestRestaurant> {
  List<Restaurant> restaurants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _loadRestaurants() async {
    try {
      final loadedRestaurants = await RestaurantDatabase.instance.getHistory(
        limit: 2,
      );
      setState(() {
        restaurants = loadedRestaurants;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Ultimi ristoranti visualizzati',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        if (restaurants.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Nessun ristorante visitato di recente',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children:
                  restaurants.map((restaurant) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: RestaurantCard(
                        restaurant: restaurant,
                        isFavorite: restaurant.isFavorite,
                        onFavoriteToggle: () {},
                        showFavoriteIcon: false,
                      ),
                    );
                  }).toList(),
            ),
          ),
      ],
    );
  }
}
