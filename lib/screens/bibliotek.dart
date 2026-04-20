import 'package:flutter/material.dart';
import 'home_screen.dart';

class bibliotek extends StatelessWidget {
  const bibliotek({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        title: const Text("Bibliotek"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(name: "home"),
              ),
            );
          },
          child: const Text("Till home"),
        ),
      ),
    );
  }
}