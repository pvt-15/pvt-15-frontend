import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String name;

  const HomeScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(title: const Text("Skogsjakten")),
      body: Center(
        child: Text(
          "Hej $name! 🌳",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}