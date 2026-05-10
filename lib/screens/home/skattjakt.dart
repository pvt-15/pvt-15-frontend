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
  final List<String> treeNames = [
    'Björk',
    'Ek',
    'Tall',
    'Gran',
  ];

  final List<File?> images = <File?>[null, null, null, null];
  final List<bool> isVerified = <bool>[false, false, false, false];
  final List<bool> isChecking = <bool>[false, false, false, false];
  bool allCompleted = false;

  String translationResult = '';
  bool isTranslating = false;

  Future<void> takePictureAndVerify(int index) async {
    if (images[index] != null) return;

    final File? file = await CameraService.takePicture();

    if (file != null && mounted) {
      setState(() {
        images[index] = file;
        isChecking[index] = true;
      });

      // TODO: Implementera AI-verifiering via backend
      // Exempelanrop:
      // final bool result = await verifyTreeWithAI(file, treeNames[index]);

      // simulerar verifiering (ersatt med riktigt API-anrop)
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          isVerified[index] = true;
          isChecking[index] = false;
          _checkAllCompleted();
        });
      }
    }
  }

  void _checkAllCompleted() {
    setState(() {
      allCompleted = !isVerified.contains(false);
    });
  }

  void resetAll() {
    setState(() {
      for (int i = 0; i < images.length; i++) {
        images[i] = null;
        isVerified[i] = false;
        isChecking[i] = false;
      }
      allCompleted = false;
    });
  }

  Future<void> testTranslation() async {
    setState(() {
      isTranslating = true;
      translationResult = 'Översätter...';
    });

    TranslationService.debugPrintManualTranslations();

    final List<String> testWords = [
      'Daisy',
      'Wood anemone',
      'Bluebell',
      'Lily of the valley',
      'Buttercup',
      'Birch',
      'Oak',
      'Pine',
    ];

    String result = 'Översattningstest från API:\n\n';

    for (final word in testWords) {
      final translated = await TranslationService.translateWord(word);
      result += '$word -> $translated\n';
      await Future.delayed(const Duration(milliseconds: 200));
    }

    final bool apiAvailable = await TranslationService.checkApiAvailability();
    result += '\n=== Status ===\n';
    result += 'API tillgängligt: ${apiAvailable ? "Ja" : "Nej"}\n';

    setState(() {
      translationResult = result;
      isTranslating = false;
    });

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 10,
                left: 20,
                right: 20,
              ),
              child: Text(
                'Ta bild på dessa träd',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  itemCount: treeNames.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    return _buildTreeCard(index);
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: isTranslating ? null : testTranslation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF84C06C),
                minimumSize: const Size(200, 50),
              ),
              child: Text(
                isTranslating ? 'Översätter...' : 'Testa översätt API',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            const SizedBox(height: 10),

            if (allCompleted)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: resetAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff84c06c),
                    minimumSize: const Size(200, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Alla träd hittade! Börja om?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),

            const SizedBox(height: 10),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: -1),
    );
  }

  Widget _buildTreeCard(int index) {
    final File? image = images[index];
    final bool verified = isVerified[index];
    final bool checking = isChecking[index];

    return InkWell(
      onTap: () => takePictureAndVerify(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: verified
              ? const Color(0xff84c06c)
              : const Color(0xfff8ed76),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: verified
                ? const Color(0xFF4C290C)
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (image != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: Image.file(
                        image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    const Icon(
                      Icons.image_outlined,
                      size: 50,
                      color: Color(0xFF4C290C),
                    ),

                  if (checking)
                    const CircularProgressIndicator(
                      color: Color(0xFF4C290C),
                    ),

                  if (verified)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        Icons.check_circle,
                        color: Color(0xFF4C290C),
                        size: 30,
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  treeNames[index],
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}