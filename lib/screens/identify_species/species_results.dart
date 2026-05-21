import 'dart:io';
import 'package:Skogsjakten/screens/home/home_library.dart';
import 'package:flutter/material.dart';
import 'package:Skogsjakten/widgets/custom_navigation_bar.dart';
import 'package:Skogsjakten/screens/identify_species/identify_camera.dart';

class SpeciesResults extends StatelessWidget {
  final File image;
  final String category;
  final Map <String, dynamic> result;

  SpeciesResults({
    super.key,
    required this.image,
    required this.category,
    required this.result
  });

  @override
  Widget build(BuildContext context) {
    final String label = result['label'] ?? 'Okänd art';
    final String categoryName = result['category'] ?? category;
    final num points = result['pointsAwarded'] ?? 0;
    final double confidence = (result['aiConfidence'] ?? 0).toDouble();
    final String imageUrl = result['imageUrl'] ?? '';

    String mascotText;

    if (points != 0) {
      mascotText =
      "Wow! Vilken fantastik upptäckare du är! För din nya upptäckt får du ${points.toStringAsFixed(1)} poäng!";
    } else {
      mascotText =
      "Visst är naturen spännande! Du har faktiskt redan hittat $label tidigare!";
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Center(
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          title: const Text("Identifiera art"),
        ),

        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Text("Du har hittat en: $label", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 400,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFB1067E),
                        width: 15,
                      ),
          
                      borderRadius: BorderRadius.circular(20),
                    ),
          
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.file(
                        image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Enligt vår artigenkänning är det ${(confidence * 100).toStringAsFixed(1)}% att ni hittat en $label!"),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8ED76),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mascotText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
          
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Column(
                      children: [
          
                        CustomPaint(
                          size: const Size(24, 14),
                          painter: SpeechBubbleTrianglePainter(),
                        ),
                        const SizedBox(height: 10),
                        Image.asset(
                          'assets/maskot_skogstroll.png',
                          height: 90,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IdentifyCamera(),
                      ),
                    );
                  },
                  child: const Text("Identifiera ny art!"),

                ),
                const SizedBox(height: 30)
              ]

            ),
          
          ),

        ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: -1,),

    );
  }
  
}
class SpeechBubbleTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF8ED76)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}