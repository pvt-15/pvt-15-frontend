import 'package:flutter/material.dart';
import 'home_screen.dart';

class quiz extends StatelessWidget {
  const quiz({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
        appBar: AppBar(
          title: const Text("Quiz"),
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