import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/restaurant_db.dart';
import '../models/restaurant.dart';

class RestaurantFavorites extends StateNotifier<List<Restaurant>> {
  RestaurantFavorites() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await RestaurantDatabase.instance.getFavorites();
    state = favorites;
  }

  Future<void> addToFavorites(Restaurant restaurant) async {
    await RestaurantDatabase.instance.updateFavoriteStatus(restaurant, true);
    state = [...state, restaurant];
  }

  Future<void> removeFromFavorites(Restaurant restaurant) async {
    await RestaurantDatabase.instance.updateFavoriteStatus(restaurant, false);
    state = state.where((r) => r.id != restaurant.id).toList();
  }

  bool isFavorite(Restaurant restaurant) {
    return state.any((r) => r.id == restaurant.id);
  }
}

final favoritesProvider =
    StateNotifierProvider<RestaurantFavorites, List<Restaurant>>(
      (ref) => RestaurantFavorites(),
    );
