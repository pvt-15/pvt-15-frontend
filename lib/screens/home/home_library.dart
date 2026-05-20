import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../library/animals_library.dart';
import '../library/daily_library.dart';
import '../library/plants_library.dart';
import '../library/medals_library.dart';

class HomeLibrary extends StatefulWidget {
  const HomeLibrary({super.key});

  @override
  State<HomeLibrary> createState() => _HomeLibraryState();
}

class _HomeLibraryState extends State<HomeLibrary> {

  final List<Map<String, dynamic>> games = [
    {
      'name': 'Mina växter',
      'image': 'assets/Icons/vaxt.png',
      'page': const PlantsLibrary(),
    },
    {
      'name': 'Mina djur',
      'image': 'assets/Icons/djur_bibliotek.png',
      'page': const AnimalsLibrary(),
    },
    {
      'name': 'Mina medaljer',
      'image': 'assets/Icons/medalj.png',
      'page': const MedalsLibrary(),
    },
    {'name': 'Daglig utmaning', 'icon': Icons.sunny, 'page': const DailyLibrary()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFBEDBB2),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Bibliotek'),
      ),
        // Lägga in någon text antingen 'Skattjakt' eller 'Bibliotek' istället för att ha det i body?
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
                          child: SizedBox(
                              width: 260,
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
                              const SizedBox(width: 30),
                              Expanded(
                              child: Text(
                                games[index]['name'] as String,
                                style: Theme.of(context).textTheme.headlineLarge,
                                /*maxLines: 1,
                                overflow: TextOverflow.ellipsis,*/
                              ),
                              ),
                            ],
                          ),
                      ),
                      )
                    );
                        },
                ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const CustomNavigationBar(selectedIndex: 2),

    );
  }
}
