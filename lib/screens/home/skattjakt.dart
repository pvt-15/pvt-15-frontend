import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/camera_service.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../../services/translation_service.dart';

class Skattjakt extends StatefulWidget {
  const Skattjakt({super.key});

  @override
  State<Skattjakt> createState() => _SkattjaktState();
}

class _SkattjaktState extends State<Skattjakt> {

  File? image;
  String translationResult = ''; // För att visa resultat av översättningstest
  bool isTranslating = false;

  // testa översättnings-API:t med några exempelord
  Future<void> testTranslation() async {
    setState(() {
      isTranslating = true;
      translationResult = 'Översätter...';
    });

    // skriv ut alla manuella översättningar för felsökning
    TranslationService.debugPrintManualTranslations();

    final List<String> testWords = [
      'Daisy',  // Testa specifikt Daisy
      'Wood anemone',
      'Bluebell',
      'Lily of the valley',
      'Buttercup',
      'Birch',
      'Oak',
      'Pine',
    ];

    String result = 'Översättningstest från API:\n\n';

    // testa MyMemory API
    for (final word in testWords) {
      final translated = await TranslationService.translateWord(word);
      result += '$word -> $translated\n';
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // kontrollera API-tillgänglighet
    final bool apiAvailable = await TranslationService.checkApiAvailability();
    result += '\n=== Status ===\n';
    result += 'API tillgängligt: ${apiAvailable ? "Ja" : "Nej"}\n';

    setState(() {
      translationResult = result;
      isTranslating = false;
    });

    // visa resultat i en dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Översättningstest'),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Text(
                translationResult,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Stäng'),
            ),
          ],
        ),
      );
    }
  }

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
        title: const Text('Skattjakt'),
        toolbarHeight: 100,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              const Text(
                'uppdraget ska stå här',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'WinkySans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C290C),
                ),
              ),

              const SizedBox(height: 40),

              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8ED76),
                  borderRadius: BorderRadius.circular(20),
                  image: image != null ? DecorationImage(image: FileImage(image!),
                    fit: BoxFit.cover,) : null,
                ),
                child: image == null
                    ? const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 70,
                    color: Color(0xFF4C290C),
                  ),
                )
                    : null,
              ),

              const SizedBox(height: 30),

              const Text(
                'titel på vad man ska hitta ex. vitsippa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'WinkySans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C290C),
                ),
              ),

              const SizedBox(height: 20),

              // Testknapp för översättnings-API
              ElevatedButton(
                onPressed: isTranslating ? null : testTranslation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF84C06C),
                  minimumSize: const Size(200, 50),
                ),
                child: Text(
                  isTranslating ? 'Översätter...' : 'Testa Översätt API',
                  style: const TextStyle(
                    fontFamily: 'WinkySans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              InkWell(
                onTap: () async {
                  final File? file = await CameraService.takePicture();

                  if (file != null) {
                    // Tillfällig lösning för att verifiera att kameran fungerar.
                    // Just nu visas bilden kvar på samma sida.
                    // Om flödet ska följa Figma senare kan detta bytas mot navigation till nästa screen.
                    setState(() {
                      image = file;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 150,
                  height: 65,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEE7A),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Ta bild',
                      style: TextStyle(
                        fontFamily: 'WinkySans',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C290C),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: -1),
    );
  }
}