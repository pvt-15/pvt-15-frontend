import 'package:flutter/material.dart';

class PlantsLibrary extends StatefulWidget {
  const PlantsLibrary({super.key});

  @override
  State<PlantsLibrary> createState() => _PlantsLibraryState();
}

class _PlantsLibraryState extends State<PlantsLibrary> {
  // Ändra sen när vi har riktiga bilder
  final List<String> plants = [
    'Vitsippa',
    'Ros',
    'Tulpan',
    'Blåklocka',
    //'Lavendel',
    //'Maskros',
  ];

  String getPlantImage(String plant) {
    switch (plant) {
      case 'Vitsippa':
        return 'assets/vitsippa.png';
      case 'Ros':
        return 'assets/ros.jpg';
      case 'Blåklocka':
        return 'assets/blaklocka.jpg';
      case 'Tulpan':
        return 'assets/tulpan.jpg';
        default:
          return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: Text(
                'Mina växter',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),

            // Grid för bilder
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:GridView.builder(
                  itemCount: plants.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: plants.length <= 3 ? 1 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: plants.length <= 3 ? 1.4 : 0.8,
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  getPlantImage(plants[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            plants[index],
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