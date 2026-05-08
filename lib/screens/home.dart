import 'package:flutter/material.dart';
import 'home/home_library.dart';
import 'home/species_profile.dart';
import 'home/quiz.dart';
import 'home/choose_bingo_game.dart';
//import 'bingo/choose_bingo_game.dart';
import 'home/skattjakt.dart';
import 'choose_difficulty.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../widgets/auth_guard.dart';

class HomeScreen extends StatelessWidget {
  final String name;

  const HomeScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> gameItems = [
      {
        'name': 'Identifiera art',
        'page': const SpeciesProfile(),
        'image': 'assets/maskot_kamera.png',
      },
      {
        'name': 'Bingo',
        'page': const ChooseBingoGame(),
        'image': 'assets/maskot_bingo.png',
      },
      {
        'name': 'Skattjakt',
        'page': const Skattjakt(),
        'image': 'assets/maskot_skattjakt.png',
      },
      {
        'name': 'Quiz',
        'page': ChooseDifficulty(
          gameTitle: 'Quiz',
        ),
        'image': 'assets/maskot_quiz.png',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBEDBB2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4C290C)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Column(
            children: [
              Text(
                'Skogsjakten',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),


              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xfff8ed76),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Text(
                      'Skogsjägare',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 8,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '875 poäng',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              _wideMenuCard(
                context: context,
                title: 'Dagens utmaning',
                page: const HomeLibrary(),
              ),

              const SizedBox(height: 34),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gameItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 26,
                  crossAxisSpacing: 26,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return _squareMenuCard(
                    context: context,
                    title: gameItems[index]['name'],
                    page: gameItems[index]['page'],
                    imagePath: gameItems[index]['image'],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: 1),
    );
  }

  Widget _wideMenuCard({
    required BuildContext context,
    required String title,
    required Widget page,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 110,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xfff8ed76),
          foregroundColor: Colors.black,
          elevation: 4,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _squareMenuCard({
    required BuildContext context,
    required String title,
    required Widget page,
    required String imagePath,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xfff8ed76),
        foregroundColor: Colors.black,
        elevation: 4,
        shadowColor: Colors.black38,
        padding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}