import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_eat/models/restaurant.dart';
import 'package:tap_eat/widgets/restaurant_card.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final mockRestaurant = Restaurant(
    id: '1',
    name: 'Pizzeria RossoPeperoncino',
    latitude: 40.0,
    longitude: 14.0,
    address: 'Via Roma 23, Milano',
    distance: 4000,
    type: 'Pizzeria',
    imageUrl: null,
    isFavorite: false,
    timestamp: DateTime.now().millisecondsSinceEpoch,
  );

  testWidgets('RestaurantCard mostra i dati correttamente', (
    WidgetTester tester,
  ) async {
    bool favoriteToggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantCard(
            restaurant: mockRestaurant,
            isFavorite: false,
            onFavoriteToggle: () {
              favoriteToggled = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Pizzeria RossoPeperoncino'), findsOneWidget);
    expect(find.textContaining('Pizzeria'), findsWidgets);
    expect(find.textContaining('4000'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite_border));
    expect(favoriteToggled, isTrue);
  });
}
