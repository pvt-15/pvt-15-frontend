import 'package:flutter/material.dart';
import '../../widgets/custom_navigation_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../bingo/bingo_easy_mode.dart';
import '../bingo/bingo_hard_mode.dart';
import '../bingo/bingo_medium_mode.dart';
import '../choose_difficulty.dart';

class ChooseBingoGame extends StatefulWidget {

  const ChooseBingoGame({
    super.key,
  });

  //vill inte spara, static final = går ej att ändra svårighetsgrad senare.
  static final List<Map<String, dynamic>> startedGames = [
    {'name': 'Träd', 'status': false, 'route': null},
    {'name': 'Växter', 'status': false, 'route': null},
    {'name': 'Djur', 'status': false, 'route': null},
    {'name': 'Blandad', 'status': false, 'route': null},
  ];

  @override
  State<ChooseBingoGame> createState() => _ChooseBingoGame();
}

class _ChooseBingoGame extends State<ChooseBingoGame> {

  final List<Map<String, dynamic>> games = [
    {'name': 'Träd', 'icon': MdiIcons.tree},
    {'name': 'Växter', 'icon': MdiIcons.flower},
    {'name': 'Djur', 'icon': MdiIcons.ladybug},
    {'name': 'Blandad', 'icon': Icons.sunny},
  ];

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFBEDBB2),
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
          icon: const Icon(Icons.arrow_back)
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

                          for(var game in ChooseBingoGame.startedGames) {
                            if (game['name'] == games[index]['name']) {
                              if (game['status'] == false){

                                final Difficulty? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const ChooseDifficulty(
                                  gameTitle: 'Bingo',
                                )),);

                                if (result != null) {
                                  if (result == Difficulty.easy) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          BingoEasyMode(
                                              typeOfBingo: games[index]['name'])),);
                                    game['route'] = BingoEasyMode(
                                        typeOfBingo: games[index]['name']);
                                  }

                                  if (result == Difficulty.medium) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          BingoMediumMode(
                                              typeOfBingo: games[index]['name'])),);
                                    game['route'] = BingoMediumMode(
                                        typeOfBingo: games[index]['name']);
                                  }

                                  if (result == Difficulty.hard) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          BingoHardMode(
                                              typeOfBingo: games[index]['name'])),);
                                    game['route'] = BingoHardMode(
                                        typeOfBingo: games[index]['name']);
                                  }

                                  game['status'] = true;
                                }

                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>  game['route']),);
                              }
                            }
                          }
                        },

                        child: SizedBox(
                          width: 200,
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 50,
                              child: Icon(
                                games[index]['icon'],
                              size: 50,
                              color: Colors.black87),
                          ),
                              const SizedBox(width: 20),
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
}
