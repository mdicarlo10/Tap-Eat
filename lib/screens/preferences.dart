import 'package:flutter/material.dart';

class Preferences extends StatefulWidget {
  const Preferences({super.key});

  @override
  State<Preferences> createState() => _SearchingState();
}

class _SearchingState extends State<Preferences> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Preferences"));
  }
}
