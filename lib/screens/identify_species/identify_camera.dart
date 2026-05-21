import 'dart:io';

import 'package:Skogsjakten/screens/identify_species/species_results.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:Skogsjakten/services/session_storage.dart';
import 'package:Skogsjakten/services/camera_service.dart';
import 'package:http/http.dart' as http;
import 'package:Skogsjakten/services/gamification_popup_helper.dart';
import 'package:Skogsjakten/services/upload_picture.dart';
import 'package:Skogsjakten/services/translation_service.dart';

import '../home.dart';

class IdentifyCamera extends StatefulWidget{
  const IdentifyCamera({super.key});

  @override
  State<StatefulWidget> createState() => _IdentifyCameraState();

}

class _IdentifyCameraState extends State<IdentifyCamera> {
  final sessionStorage = SessionStorage();
  File? selectedImage;
  String? selectedCategory;

  bool isOpeningCamera = true;
  bool isIdentifying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      takePicture();
    });
  }

  Future<void> takePicture() async {
    setState(() {
      isOpeningCamera = true;
    });

    final image = await CameraService.takePicture();

    if (!mounted) return;

    setState(() {
      isOpeningCamera = false;
    });

    if (image == null) {
      Navigator.pop(context); // går tillbaka om användaren avbryter kameran
      return;
    }

    setState(() {
      selectedImage = image;
    });

    showCategoryDialog();
  }

    Future<void> showCategoryDialog() async {
      final category = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Vad tog du bild på?", textAlign: TextAlign.center,),
            content: const Text("Välj kategori för identifieringen.", textAlign: TextAlign.center,),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(110, 50),
                ),
                onPressed: () {
                  Navigator.pop(context, "PLANT");

                },
                child: const Text("Planta"),
              ),
              const SizedBox(width: 20,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(110, 50),
                ),
                onPressed: () {
                  Navigator.pop(context, "ANIMAL");
                },
                child: const Text("Djur"),
              ),
            ],
          );
        },
      );


      if (category == null) return;

      setState(() {
        selectedCategory = category;
      });

      await identifySpecies(category);

      print("Vald kategori: $selectedCategory");
    }

  Future<void> identifySpecies(String category) async {
    if (selectedImage == null) return;

    setState(() {
      isIdentifying = true;
    });

    final session = await sessionStorage.getUserAndToken();

    if (session == null) {
      print("Ingen session/token hittades");

      if (mounted) {
        setState(() {
          isIdentifying = false;
        });

        showDialog(
          context: context,
          builder: (context) => errorMessageUploadPicture(),
        );
      }

      return;
    }

    try {
      final uploader = UploadPicture(jwtToken: session.token);

      final result = await uploader.sendPictureToBackend(
        selectedImage!,
        category,
        'COLLECTION',
        null,
      );

      if (!mounted) return;

      setState(() {
        isIdentifying = false;
      });

      if (result == null || result['accepted'] != true || result['picture'] == null) {
        showDialog(
          context: context,
          builder: (context) => errorMessageUploadPicture(),
        );
        return;
      }

      final gamification = result['gamification'];

      await GamificationPopupService.showIfNeeded(
        context: context,
        leveledUp: gamification?['leveledUp'] ?? false,
        previousLevel: gamification?['previousLevel'],
        currentLevel: gamification?['currentLevel'],
        newlyUnlockedBadges: gamification?['newlyUnlockedBadges'] ?? [],
      );

      if (!mounted) return;

      final picture = result['picture'];

      final translatedLabel = await TranslationService.translateWord(
        picture['label'] ?? '',
      );

      picture['label'] = translatedLabel;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpeciesResults(
            image: selectedImage!,
            category: category,
            result: picture,
          ),
        ),
      );
    } catch (e) {
      print("Identifiering fel: $e");

      if (!mounted) return;

      setState(() {
        isIdentifying = false;
      });

      showDialog(
        context: context,
        builder: (context) => errorMessageUploadPicture(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: isOpeningCamera
            ? const Text("Öppnar kameran...")
            : isIdentifying
            ? const Text("Identifierar art...")
            : const SizedBox(),
        ),
    );
  }

  AlertDialog errorMessageUploadPicture() {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      content: Text(
        'Ojdå, bilden kunde inte sparas. Vill du testa igen?',
        textAlign: TextAlign.center,
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            takePicture();
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(110, 50),
          ),
          child: Text(
            'Ok',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(110, 50),
          ),
          child: Text(
            'Till hem',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}