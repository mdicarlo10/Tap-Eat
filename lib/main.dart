import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'database/restaurant_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/tutorial_screen.dart';
import 'widgets/navigation_wrapper.dart';

final customColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: const Color(0xFFE4572E),
  primary: const Color(0xFFE07A5F),
  onPrimary: const Color(0xFFE0D1B9),
  surface: const Color(0xFFFFF5E8),
  onSurface: const Color(0xFF403D39),
);

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await RestaurantDatabase.instance.database;

  final prefs = await SharedPreferences.getInstance();
  final seenTutorial = prefs.getBool('seenTutorial') ?? false;

  runApp(ProviderScope(child: TapEatApp(seenTutorial: seenTutorial)));
}

class TapEatApp extends StatelessWidget {
  final bool seenTutorial;
  const TapEatApp({super.key, required this.seenTutorial});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tap&Eat',
      theme: ThemeData(
        colorScheme: customColorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: customColorScheme.primary,
          titleTextStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            color: Color(0xFFFFF8F0),
          ),
          iconTheme: IconThemeData(color: customColorScheme.onPrimary),
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: seenTutorial ? const NavigationWrapper() : const TutorialScreen(),
    );
  }
}
