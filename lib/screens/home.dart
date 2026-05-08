import 'package:flutter/material.dart';
import 'home/home_library.dart';
import 'home/species_profile.dart';
import 'home/quiz.dart';
import 'home/choose_bingo_game.dart';
import 'home/skattjakt.dart';
import 'choose_difficulty.dart';

class HomeScreen extends StatelessWidget {
  final String name;

  const HomeScreen({super.key, required this.name});


  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'name': 'Dagens utmaning', 'page': const HomeLibrary()},
      {'name': 'Bingo', 'page': ChooseBingoGame()},
      {'name': 'Skattjakt', 'page': const Skattjakt()},
      {'name': 'Samla art', 'page': const SpeciesProfile()},
      {'name': 'Quiz', 'page': const ChooseDifficulty()},
      {'name': 'Platsuppdrag', 'page': const HomeLibrary()},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBEDBB2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF000000)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  "Dags för en\nutmaning!",
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff84c06c),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Text(
                    "10020 Poäng",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Nivå 8 - Skogsjägare",
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  "Utmaningar",
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xfff0e36d),
                        foregroundColor: Colors.brown.shade900,
                        minimumSize: const Size(double.infinity, 58),
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        elevation: 5,
                        shadowColor: Colors.black38,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => menuItems[index]['page'],
                          ),
                        );
                      },
                      child: Text(
                        menuItems[index]['name'],
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10)

            /*

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChooseDifficulty(
                      nextPage: (difficulty) => ChooseBingoGame(),
                    ),
                  ),
                );
              },
              child: const Text("Difficulty"),
            ),

             */

          ],
        ),
      ),
    );
  }
}