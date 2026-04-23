import 'package:flutter/material.dart';
import 'home_screen.dart';

class ChooseBingoGame extends StatefulWidget{
  const ChooseBingoGame({super.key});

  @override
  State<ChooseBingoGame> createState() => _ChooseBingoGame();
}


class _ChooseBingoGame extends State<ChooseBingoGame> {

  final List<Map<String, dynamic>> games = [
    {'name': 'Trädbingo', 'icon': Icons.park},
    {'name': 'Svampbingo', 'icon': Icons.mail},
    {'name': 'Blombingo', 'icon': Icons.local_florist},
    {'name': 'Insektsbingo', 'icon': Icons.bug_report},
    {'name': 'Blandad bingo', 'icon': Icons.sunny},
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
                  bottom: 20
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
                          print('Valde: ${games[index]['name']}');
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

        bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xff84c06c),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10),
          ],
        ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(icon: const Icon(Icons.home), onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(name: 'test'),
                  ),
                );
                },
              )
            ],
          ),
        ),
    );
  }
}
