import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tap_eat/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Navigazione tra Home, Cerca, Preferiti, bottone matita e tap preferiti',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Tap & Eat'), findsOneWidget);

      final searchButton = find.byIcon(Icons.search);
      expect(searchButton, findsOneWidget);
      await tester.tap(searchButton);
      await tester.pumpAndSettle();
      expect(find.text('Ricerca ristoranti'), findsOneWidget);

      final pencilButton = find.byIcon(Icons.edit);
      expect(pencilButton, findsOneWidget);
      await tester.tap(pencilButton);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.edit), findsOneWidget);

      final favoriteIcon = find.byIcon(Icons.favorite_border);
      if (favoriteIcon.evaluate().isNotEmpty) {
        await tester.tap(favoriteIcon.first);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.favorite), findsWidgets);
      }

      final favoritesButton = find.byIcon(Icons.favorite);
      expect(favoritesButton, findsWidgets);
      await tester.tap(favoritesButton.first);
      await tester.pumpAndSettle();
      expect(find.text('I tuoi preferiti'), findsOneWidget);

      final homeButton = find.byIcon(Icons.home);
      expect(homeButton, findsOneWidget);
      await tester.tap(homeButton);
      await tester.pumpAndSettle();
      expect(find.text('Tap & Eat'), findsOneWidget);
    },
  );
}
