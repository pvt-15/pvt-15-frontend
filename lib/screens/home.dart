import 'package:flutter/material.dart';
import 'home/home_library.dart';
import 'home/species_profile.dart';
import 'home/quiz.dart';
import 'home/choose_bingo_game.dart';
//import 'bingo/choose_bingo_game.dart';
import 'home/skattjakt.dart';
import 'choose_difficulty.dart';

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
                    builder: (_) => const HomeLibrary(),
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
                    builder: (_) => const SpeciesProfile(),
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
                    builder: (_) => const Quiz(),
                  ),
                );
              },
              child: const Text("Quiz"),
            ),

/*
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChooseBingoGame(),
                  ),
                );
              },
              child: const Text("Bingo"),
            ),*/

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Skattjakt(),
                  ),
                );
              },
              child: const Text("Skattjakt"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChooseDifficulty(
                      nextPage: (difficulty) => ChooseBingoGame(difficulty: difficulty),
                    ),
                  ),
                );
              },
              child: const Text("Difficulty"),
            ),
          ],
        ),
      ),
    );
  }
}