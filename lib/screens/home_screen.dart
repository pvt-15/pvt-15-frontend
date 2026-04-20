import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String name;

  const HomeScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        title: const Text("Skogsjakten"),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hej $name! ",
              style: const TextStyle(fontSize: 24),
            ),
            Image.asset(
              'assets/maskot_skogstroll.png',
              width: 100,
              height: 100,
            ),
          ],
        ),
      ),
    );

  }
}