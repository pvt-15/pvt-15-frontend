import 'package:flutter/material.dart';
import 'bibliotek.dart';
import 'artprofil.dart';
import 'quiz.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
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



            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const bibliotek(),
                  ),
                );
              },
              child: const Text("Bibliotek"),
            ),


            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const artprofil(),
                  ),
                );
              },
              child: const Text("Artprofil"),
            ),


            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const quiz(),
                  ),
                );
              },
              child: const Text("Quiz"),
            ),
          ],
        ),
      ),
    );
  }
}