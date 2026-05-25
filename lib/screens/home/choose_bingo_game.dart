import 'package:flutter/material.dart';
import '../../services/session_storage.dart';
import '../../widgets/custom_navigation_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../bingo/bingo_easy_mode.dart';
import '../bingo/bingo_hard_mode.dart';
import '../bingo/bingo_medium_mode.dart';
import '../bingo/http_help_methods.dart';
import '../choose_difficulty.dart';

class ChooseBingoGame extends StatefulWidget {

  const ChooseBingoGame({super.key});

  @override
  State<ChooseBingoGame> createState() => _ChooseBingoGame();
}

class _ChooseBingoGame extends State<ChooseBingoGame> {
  String? jwtToken;

  final List<Map<String, dynamic>> games = [
    {
      'name': 'Träd',
      'image': 'assets/Icons/trad.png',
    },
    {
      'name': 'Växter',
      'image': 'assets/Icons/vaxt.png',
    },
    {
      'name': 'Djur',
      'image': 'assets/Icons/djur_bibliotek.png',
    },
    {
      'name': 'Blandad',
      'image': 'assets/Icons/blandad.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
    jwtToken = await SessionStorage().getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFBEDBB2),
        appBar: AppBar(
          leading: Center(
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
          icon: const Icon(Icons.arrow_back)
          ),
          ),
        title: const Text('Bingo'),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 30,
                  top: 40,
                  bottom: 30
                ),
                child: Text(
                  'Välj ett Bingo-spel',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xfff8ed76),
                          minimumSize: const Size(double.infinity, 130),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {

                          findCorrectBingoPage(index);

                        },

                        child: SizedBox(
                          width: 210,
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 50,
                              child: Image.asset(
                                games[index]['image'] as String,
                                width: 55,
                                height: 55,
                                fit: BoxFit.contain,
                            ),
                            ),
                              const SizedBox(width: 35),
                              Expanded(
                                child: Text(
                                  games[index]['name'],
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                           ),
                          ],
                        ),
                      ),
                    ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: -1),
    );
  }

  Future<void> findCorrectBingoPage(int index) async {
    String selectedCategory = games[index]['name'];

    // Kolla om det redan finns en aktiv utmaning för denna kategori
    Map<String, dynamic>? activeChallenge = await findActiveBingoChallenge(selectedCategory);

    if (activeChallenge != null) {
      if (!mounted) return;
      openBingoMode(
        activeChallenge['difficulty'], 
        selectedCategory, 
        activeChallenge['id']
      );
    } else {
      final Difficulty? result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChooseDifficulty(gameTitle: 'Bingo'),
        ),
      );

      if (!mounted || result == null) return;
      openBingoMode(result.name.toUpperCase(), selectedCategory, null);
    }
  }

  void openBingoMode(String difficulty, String category, int? challengeId) {
    if (difficulty == 'EASY') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BingoEasyMode(typeOfBingo: category, challengeId: challengeId)),
      );
    } else if (difficulty == 'MEDIUM') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BingoMediumMode(typeOfBingo: category, challengeId: challengeId)),
      );
    } else if (difficulty == 'HARD') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BingoHardMode(typeOfBingo: category, challengeId: challengeId)),
      );
    }
  }

  Future<Map<String, dynamic>?> findActiveBingoChallenge(String category) async {
    HttpHelpMethods helpMethodsHttp = HttpHelpMethods(jwtToken: jwtToken);
    
    String? backendCategory = helpMethodsHttp.mapCategoryToBackendForChallenge(category);
    
    try {
      List<dynamic> allChallenges = await helpMethodsHttp.getAllChallenges();
      for (var challenge in allChallenges) {
        if (challenge['type'] == 'BINGO' && challenge['category'] == backendCategory && challenge['status'] == 'IN_PROGRESS') {
          return challenge;
        }
      }
    } catch (e) {
      debugPrint('Fel vid check: $e');
    }
    return null;
  }

}
