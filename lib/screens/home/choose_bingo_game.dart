import 'package:Skogsjakten/screens/bingo/bingo_game.dart';
import 'package:flutter/material.dart';
import '../../widgets/custom_navigation_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../bingo/flower_bingo_page.dart';
import '../bingo/insect_bingo_page.dart';
import '../bingo/mixed_bingo_page.dart';
import '../bingo/mushroom_bingo_page.dart';
import '../bingo/tree_bingo_page.dart';
import '../choose_difficulty.dart';

class ChooseBingoGame extends StatefulWidget {
  //final Difficulty difficulty;

  const ChooseBingoGame({
    super.key,
    //required this.difficulty,
  });

  @override
  State<ChooseBingoGame> createState() => _ChooseBingoGame();
}

class _ChooseBingoGame extends State<ChooseBingoGame> {

  final List<Map<String, dynamic>> games = [
    {'name': 'Träd', 'icon': MdiIcons.tree, 'page': const TreeBingoPage()},
    {'name': 'Svamp', 'icon': MdiIcons.mushroom, 'page': const MushroomBingoPage()},
    {'name': 'Blomma', 'icon': MdiIcons.flower, 'page': const FlowerBingoPage()},
    {'name': 'Insekt', 'icon': MdiIcons.ladybug, 'page': const InsectBingoPage()},
    {'name': 'Blandad', 'icon': Icons.sunny, 'page': const MixedBingoPage()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFBEDBB2),
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder:
                            //(context) => games[index]['page'])
                              (context) => BingoGame(typeOfBingo: games[index]['name'])),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(games[index]['icon'], size: 50, color: Colors.black87),
                            const SizedBox(width: 20),
                            Text(
                              games[index]['name'],
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ],
                        )
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
