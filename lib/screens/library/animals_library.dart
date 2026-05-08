import 'package:flutter/material.dart';

class AnimalsLibrary extends StatefulWidget{
  const AnimalsLibrary({super.key});

  @override
  State<AnimalsLibrary> createState() => _AnimalsLibrary();
}

class _AnimalsLibrary extends State<AnimalsLibrary> {
// Ändra sen när vi har riktiga bilder
  final List<String> animals = [
    'Älg',
    'Humla',
    'Myra',
    'Ko',
    'Snigel',
    'Ekorre',
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
        title: const Text('Bibliotek'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: Text(
                'Mina djur',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),

            // Grid för bilder
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:GridView.builder(
                    itemCount: animals.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: animals.length <= 3 ? 1 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: animals.length <= 3 ? 1.4 : 0.8,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xfff8ed76),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.emoji_nature,
                                  size: 50,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              animals[index],
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      );
                    },
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}