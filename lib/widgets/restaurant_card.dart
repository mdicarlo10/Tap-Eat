import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../main.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with your actual widget implementation
    return Container(child: Text('Restaurant Card'));
  }
}
