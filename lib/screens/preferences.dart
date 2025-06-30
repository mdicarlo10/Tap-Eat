import 'package:flutter/material.dart';
import '../database/restaurant_db.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_list.dart';
import '../main.dart';

class Preferences extends StatefulWidget {
  const Preferences({Key? key}) : super(key: key);

  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  bool _isSearching = false;
  List<Restaurant> _searchResults = [];
  bool _hasSearched = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final results = await RestaurantDatabase.instance.getFavorites();
    setState(() {
      _searchResults = results;
      _hasSearched = true;
    });
  }

  Future<void> _performSearch(String query) async {
    final favorites = await RestaurantDatabase.instance.getFavorites();
    final results =
        favorites
            .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
    setState(() {
      _searchResults = results;
      _hasSearched = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Cerca ristorante...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (query) {
                    _performSearch(query);
                  },
                )
                : Text(
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
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _loadFavorites();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body:
          _hasSearched
              ? (_searchResults.isEmpty
                  ? Center(
                    child: Text(
                      'Nessun ristorante preferito',
                      style: TextStyle(color: secondaryTextColor, fontSize: 18),
                    ),
                  )
                  : RestaurantList(
                    restaurants: _searchResults,
                    favorites: _searchResults,
                    toggleFavorite: (restaurant) {
                      // Puoi lasciare vuoto per ora, o ricaricare la lista
                      _loadFavorites();
                    },
                  ))
              : Container(),
    );
  }
}
