import 'package:flutter/material.dart';
import 'home_screen.dart';

class TreeBingoPage extends StatefulWidget{
  const TreeBingoPage({super.key});

  @override
  State<TreeBingoPage> createState() => _TreeBingoPage();
}

class _TreeBingoPage extends State<TreeBingoPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 40,
                  bottom: 40
              ),
              child: Text(
                'Trädbingo',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                  bottom: 50,
                  left: 40,
                  right: 40
              ),
              child: Text(
                'Hitta och fota 4 stycken olika träd!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centrerar horisontellt
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: const Color(0xfff8ed76),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(child: Icon(Icons.image, size: 50,)),
                    ),

                    const SizedBox(width: 50), // Mellanrum mellan rutorna

                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: const Color(0xfff8ed76),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(child: Icon(Icons.image, size: 50,)),
                    ),
                  ],
                ),

                const SizedBox(height: 70), // Mellanrum mellan raderna

                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centrerar horisontellt
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: const Color(0xfff8ed76),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(child: Icon(Icons.image, size: 50,)),
                    ),

                    const SizedBox(width: 50), // Mellanrum mellan rutorna

                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: const Color(0xfff8ed76),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(child: Icon(Icons.image, size: 50,)),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 90),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(name: 'test'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff84c06c),
                minimumSize: Size(290, 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                  "DEBUG hem",
                  style: Theme.of(context).textTheme.headlineMedium,
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