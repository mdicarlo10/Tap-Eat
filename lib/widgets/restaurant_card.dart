import 'package:flutter/material.dart';
import 'package:tap_eat/models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final bool showFavoriteIcon;
  final Color? favoriteColor;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.showFavoriteIcon = true,
    this.favoriteColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            if (restaurant.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  restaurant.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: colorScheme.secondary,
                      ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.restaurant,
                  size: 32,
                  color: colorScheme.secondary,
                ),
              ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tipo: ${restaurant.type}',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Distanza: ${restaurant.distance}',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            if (showFavoriteIcon)
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color:
                      isFavorite
                          ? (favoriteColor ?? Colors.red)
                          : colorScheme.outline,
                ),
                onPressed: onFavoriteToggle,
              ),
          ],
        ),
      ),
    );
  }
}
