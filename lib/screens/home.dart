import 'dart:convert';

import 'package:Skogsjakten/screens/identify_species/identify_camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/custom_navigation_bar.dart';
import 'home/home_library.dart';
import 'home/species_profile.dart';
import 'home/quiz.dart';
import 'home/choose_bingo_game.dart';
import 'home/skattjakt.dart';
import 'choose_difficulty.dart';
import 'package:Skogsjakten/services/session_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final sessionStorage = SessionStorage();

  int points = 0;
  String level = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final session = await sessionStorage.getUserAndToken();

    if (session == null) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      return;
    }

    final response = await http.get(
      Uri.parse('https://group-6-15.pvt.dsv.su.se/auth/me'),
      headers: {
        'Authorization': 'Bearer ${session.token}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          points = data['totalPoints'] ?? 0;
          level = data['level'] ?? '';
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> gameItems = [
      {
        'name': 'Identifiera art',
        'page': const IdentifyCamera(),
        'image': 'assets/maskot_kamera.png',
      },
      {
        'name': 'Bingo',
        'page': const ChooseBingoGame(),
        'image': 'assets/maskot_bingo.png',
      },
      {
        'name': 'Skattjakt',
        'page': null,
        'image': 'assets/maskot_skattjakt.png',
      },
      {
        'name': 'Quiz',
        'page': Container(),
        'image': 'assets/maskot_quiz.png',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        title: const Text('Skogsjakten'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Column(
            children: [

              Container(
                width: 350,
                height: 170,
                child: Card(
                  color: const Color(0xFFF8ED76),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.eco,
                              color: Color(0xFF84C06C),
                              size: 35,
                            ),
                            Text("Level: $level"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 250,
                          child: LinearProgressIndicator(
                            backgroundColor: const Color(0xFFDE75BF),
                            color: const Color(0xFFC0008B),
                            value: (points % 300) / 300,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text("Poäng: $points"),
                      ],
                    ),
                  ),
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
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
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
        onPressed: () async {
          if (title == 'Quiz') {
            final Difficulty? result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChooseDifficulty(gameTitle: 'Quiz'),
              ),
            );

            if (result != null && context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Quiz(difficulty: result),
                ),
              );
            }
            return;
          }

          if (title == 'Skattjakt') {
            final Difficulty? result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChooseDifficulty(gameTitle: 'Skattjakt'),
              ),
            );

            if (result != null && context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Skattjakt(difficulty: result),
                ),
              );
            }
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
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
    required Widget? page,
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
      onPressed: () async {
        if (title == 'Quiz') {
          final Difficulty? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChooseDifficulty(gameTitle: 'Quiz'),
            ),
          );

          if (result != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Quiz(difficulty: result),
              ),
            );
          }
          return;
        }

        if (title == 'Skattjakt') {
          final Difficulty? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChooseDifficulty(gameTitle: 'Skattjakt'),
            ),
          );

          if (result != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Skattjakt(difficulty: result),
              ),
            );
          }
          return;
        }

        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        }
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
