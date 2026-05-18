import 'package:flutter/material.dart';
import '../../widgets/custom_navigation_bar.dart';

class MedalsLibrary extends StatefulWidget{
  const MedalsLibrary({super.key});

  @override
  State<MedalsLibrary> createState() => _MedalsLibrary();
}

class _MedalsLibrary extends State<MedalsLibrary> {
// Ändra sen när vi har riktiga bilder
  final List<String> medals = [
    'Utforskare',
    'Krypexpert',
    'Blomälskare',
    'Maskrosjägare'
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
                'Mina medaljer',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),

            // Grid för bilder
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:GridView.builder(
                    itemCount: medals.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: medals.length <= 3 ? 1 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: medals.length <= 3 ? 1.4 : 0.8,
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
                                  Icons.emoji_events,
                                  size: 50,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              medals[index],
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
      bottomNavigationBar: const CustomNavigationBar(
        selectedIndex: 2,
      ),
    );
  }
}