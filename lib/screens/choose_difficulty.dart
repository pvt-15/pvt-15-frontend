import 'package:flutter/material.dart';
import '../widgets/custom_navigation_bar.dart';
import 'home.dart';
import 'home/quiz.dart';

enum Difficulty { easy, medium, hard }

class ChooseDifficulty extends StatefulWidget {
  final String gameTitle;
  //final Widget Function(Difficulty difficulty) nextPage;

  const ChooseDifficulty({
    super.key,
    required this.gameTitle,
    //required this.nextPage,
  });

  @override
  State<ChooseDifficulty> createState() => _ChooseDifficultyState();
}

class _ChooseDifficultyState extends State<ChooseDifficulty> {
  final List<Map<String, dynamic>> difficulty = [
    {'name': 'Lätt', 'level': Difficulty.easy},
    {'name': 'Medel', 'level': Difficulty.medium},
    {'name': 'Svårt', 'level': Difficulty.hard},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(widget.gameTitle),
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Troll + pratbubbla
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 210),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xff84c06c),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Text(
                        "Roligt att du vill lära dig mer om skogen! \n\nVälj svårighetsgrad så sätter vi igång!",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const Positioned(
                      right: -35,
                      top: 26,
                      child: Icon(
                        Icons.arrow_right,
                        size: 60,
                        color: Color(0xff84c06c),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Image.asset(
                  'assets/maskot_skogstroll.png',
                  width: 140,
                  height: 140,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                itemCount: difficulty.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xfff8ed76),
                        minimumSize: const Size(double.infinity, 130),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      onPressed: () {
                        // Returnerar den valda svårighetsgraden till föregående skärm
                        final selected = difficulty[index]['level'] as Difficulty;
                        Navigator.pop(context, selected);
                        /*
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => widget.nextPage(selected),
                          ),
                        );*/
                      },
                      child: Text(
                        difficulty[index]['name'],
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      /*
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xff84c06c),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen(name: 'test')),
              ),
            ),
          ],
        ),
      ),*/

      bottomNavigationBar: const CustomNavigationBar(selectedIndex: -1),

    );
  }
}