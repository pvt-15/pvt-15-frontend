import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/camera_service.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../choose_difficulty.dart';

class Skattjakt extends StatefulWidget {
  final Difficulty difficulty;

  const Skattjakt({
    super.key,
    required this.difficulty,
  });

  @override
  State<Skattjakt> createState() => _SkattjaktState();
}

class TreeTarget {
  final String name;
  final String imageAsset;

  const TreeTarget({
    required this.name,
    required this.imageAsset,
  });
}

class _SkattjaktState extends State<Skattjakt> {

  static const Map<String, String> treeImageAssets = {
    'Björk': 'assets/trees/bjork.jpg',
    'Ek': 'assets/trees/ek.jpg',
    'Tall': 'assets/trees/tall.jpg',
    'Gran': 'assets/trees/gran.jpg',
    'Alm': 'assets/trees/alm.jpg',
    'Asp': 'assets/trees/asp.jpg',
    'Lönn': 'assets/trees/lönn.jpg',
    'Pil': 'assets/trees/pil.jpg',
    'Bok': 'assets/trees/bok.jpg',
    'Hassel': 'assets/trees/hassel.jpg',
    'Rönn': 'assets/trees/rönn.jpg',
  };

  late final List<TreeTarget> treeTargets;

  int currentIndex = 0;
  late List<File?> images;
  late List<bool> isVerified;
  late List<bool> isChecking;
  bool allCompleted = false;

  @override
  void initState() {
    super.initState();
    treeTargets = _getTreesForDifficulty(widget.difficulty);
    images = List.filled(treeTargets.length, null);
    isVerified = List.filled(treeTargets.length, false);
    isChecking = List.filled(treeTargets.length, false);
  }

  List<TreeTarget> _getTreesForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return _createTargets(['Björk', 'Ek', 'Tall', 'Gran']);
      case Difficulty.medium:
        return _createTargets(['Björk', 'Ek', 'Tall', 'Gran', 'Alm', 'Asp', 'Lönn', 'Pil']);
      case Difficulty.hard:
        return _createTargets([
          'Björk', 'Ek', 'Tall', 'Gran', 'Alm', 'Asp',
          'Lönn', 'Pil', 'Bok', 'Hassel', 'Rönn'
        ]);
    }
  }

  List<TreeTarget> _createTargets(List<String> treeNames) {
    return treeNames.map((name) {
      final assetPath = treeImageAssets[name] ?? 'assets/trees/default.png';
      return TreeTarget(name: name, imageAsset: assetPath);
    }).toList();
  }

  Future<void> takePictureAndVerify() async {
    if (currentIndex >= treeTargets.length) return;
    if (images[currentIndex] != null) return;

    final File? file = await CameraService.takePicture();

    if (file != null && mounted) {
      setState(() {
        images[currentIndex] = file;
        isChecking[currentIndex] = true;
      });

      // TODO: Implementera AI-verifiering via backend
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          isVerified[currentIndex] = true;
          isChecking[currentIndex] = false;
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

  void goToNextTree() {
    if (currentIndex < treeTargets.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void goToPreviousTree() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  void resetAll() {
    setState(() {
      for (int i = 0; i < images.length; i++) {
        images[i] = null;
        isVerified[i] = false;
        isChecking[i] = false;
      }
      currentIndex = 0;
      allCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (treeTargets.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFBEDBB2),
        body: const Center(child: Text('Inga träd tillgängliga')),
      );
    }

    final TreeTarget currentTarget = treeTargets[currentIndex];
    final File? currentImage = images[currentIndex];
    final bool currentVerified = isVerified[currentIndex];
    final bool currentChecking = isChecking[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Skattjakt'),
        toolbarHeight: 100,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Rubrik
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

            // stegräknare
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(treeTargets.length, (index) {
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == currentIndex
                          ? const Color(0xFF4C290C)
                          : isVerified[index]
                          ? const Color(0xff84c06c)
                          : Colors.grey.shade400,
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            // navigation och trädnamn
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: currentIndex > 0 ? goToPreviousTree : null,
                    icon: const Icon(Icons.arrow_back_ios),
                    iconSize: 30,
                    color: currentIndex > 0
                        ? const Color(0xFF4C290C)
                        : Colors.grey,
                  ),
                  Text(
                    currentTarget.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  IconButton(
                    onPressed: currentIndex < treeTargets.length - 1
                        ? goToNextTree
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios),
                    iconSize: 30,
                    color: currentIndex < treeTargets.length - 1
                        ? const Color(0xFF4C290C)
                        : Colors.grey,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // bildruta med referensbild
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xfff8ed76),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: currentVerified
                          ? const Color(0xFF4C290C)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // visar antingen den tagna bilden eller referensbilden
                        if (currentImage != null)
                          Image.file(
                            currentImage,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        else
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // visa referensbild for trädet
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  currentTarget.imageAsset,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Column(
                                      children: [
                                        const Icon(
                                          Icons.image_outlined,
                                          size: 80,
                                          color: Color(0xFF4C290C),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Referensbild saknas',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Ta en bild på en ${currentTarget.name.toLowerCase()}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),

                        if (currentChecking)
                          const CircularProgressIndicator(
                            color: Color(0xFF4C290C),
                          ),

                        if (currentVerified)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xff84c06c),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Color(0xFF4C290C),
                                size: 30,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // kameraknapp
            if (!currentVerified && !currentChecking)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton.icon(
                  onPressed: takePictureAndVerify,
                  icon: const Icon(Icons.camera_alt, size: 30),
                  label: const Text('Ta bild'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfff8ed76),
                    foregroundColor: const Color(0xFF4C290C),
                    minimumSize: const Size(200, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    textStyle: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),

            if (currentVerified && !allCompleted)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Hittad! Gå vidare till nästa träd.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF4C290C),
                  ),
                ),
              ),

            // knapp for att börja om
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
}