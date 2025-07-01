import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/homepage.dart';
import 'screens/searching.dart';
import 'screens/preferences.dart';
import 'database/restaurant_db.dart';

final customColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: const Color(0xFFE4572E),
  primary: const Color(0xFFE07A5F),
  onPrimary: const Color(0xFFFFF8F0),
  surface: const Color(0xFFFFF8F0),
  onSurface: const Color(0xFF403D39),
);

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await RestaurantDatabase.instance.database;

  runApp(const ProviderScope(child: TapEatApp()));
}

class TapEatApp extends StatelessWidget {
  const TapEatApp({super.key});

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
      home: const NavigationWrapper(),
    );
  }
}

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int selectedIndex = 0;

  final List<Widget> _pages = const [Homepage(), Searching(), Preferences()];

  void _onTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: customColorScheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Preferences",
          ),
        ],
      ),
    );
  }
}
