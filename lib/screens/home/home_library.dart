import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../home.dart';
import '../library/animals_library.dart';
import '../library/plants_library.dart';
import '../library/medals_library.dart';

class HomeLibrary extends StatefulWidget {
  const HomeLibrary({super.key});

  @override
  State<HomeLibrary> createState() => _HomeLibraryState();
}

class _HomeLibraryState extends State<HomeLibrary> {

  final List<Map<String, dynamic>> games = [
    {'name': 'Mina växter', 'icon': MdiIcons.flower, 'page': const PlantsLibrary()},
    {'name': 'Mina djur', 'icon': Icons.emoji_nature, 'page': const AnimalsLibrary()},
    {'name': 'Mina medaljer', 'icon': Icons.emoji_events, 'page': const MedalsLibrary()},
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
                'Bibliotek',
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
                                  (context) => games[index]['page'])
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
