import 'package:flutter/material.dart';
import 'screens/homepage.dart';
import 'screens/navigationpage.dart';
import 'screens/searching.dart';
import 'screens/preferences.dart';

const backgroundColor = Color(0xFFFFF8F0);
const primaryColor = Color(0xFFEB5E28);
const textColor = Color(0xFF252422);
const secondaryTextColor = Color(0xFF403D39);
const borderColor = Color(0xFFCCC5B9);

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap&Eat',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: NavigationWrapper(),
    );
  }
}

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => NavigationWrapperState();
}

class NavigationWrapperState extends State<NavigationWrapper> {
  int selectedIndex = 0;

  final List<Widget> _pages = [Homepage(), Searching(), Preferences()];

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
        selectedItemColor: Colors.deepOrange,
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
