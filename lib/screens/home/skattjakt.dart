import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/camera_service.dart';
import '../../services/treasure_hunt_service.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../choose_difficulty.dart';
import '../home.dart';

class Skattjakt extends StatefulWidget {
  final Difficulty difficulty;
  final String? category;

  const Skattjakt({
    super.key,
    required this.difficulty,
    this.category,
  });

  @override
  State<Skattjakt> createState() => _SkattjaktState();
}

// Datamodell för ett träd
class TreeTarget {
  final String name;
  final String imageAsset;
  bool isFound;

  TreeTarget({
    required this.name,
    required this.imageAsset,
    this.isFound = false,
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

  late List<TreeTarget> treeTargets;
  late TreasureHuntService _treasureService;

  int currentIndex = 0;
  List<File?> images = [];
  List<bool> isVerifying = [];
  bool allCompleted = false;
  bool isSubmitting = false;  // För att förhindra dubbla anrop

  @override
  void initState() {
    super.initState();
    _treasureService = TreasureHuntService();
    _initializeTrees();
  }

  void _initializeTrees() {
    final treeNames = _getTreesForDifficulty(widget.difficulty);
    treeTargets = treeNames.map((name) {
      return TreeTarget(
        name: name,
        imageAsset: treeImageAssets[name] ?? 'assets/trees/default.png',
        isFound: false,
      );
    }).toList();

    images = List.filled(treeTargets.length, null);
    isVerifying = List.filled(treeTargets.length, false);
  }

  List<String> _getTreesForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return ['Björk', 'Ek', 'Tall', 'Gran'];
      case Difficulty.medium:
        return ['Björk', 'Ek', 'Tall', 'Gran', 'Alm', 'Asp', 'Lönn', 'Pil'];
      case Difficulty.hard:
        return [
          'Björk', 'Ek', 'Tall', 'Gran', 'Alm', 'Asp',
          'Lönn', 'Pil', 'Bok', 'Hassel', 'Rönn'
        ];
    }
  }

  Future<void> takePictureAndVerify() async {
    // Förhindra dubbla anrop
    if (isVerifying[currentIndex] || isSubmitting) {
      debugPrint('Redan verifierar, vänta...');
      return;
    }

    if (treeTargets[currentIndex].isFound) {
      debugPrint('Trädet är redan hittat!');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    // Ta bild
    final File? file = await CameraService.takePicture();

    if (!mounted) {
      setState(() => isSubmitting = false);
      return;
    }

    if (file == null) {
      setState(() => isSubmitting = false);
      return;  // Användaren avbröt
    }

    // Spara bilden lokalt och börja verifiera
    setState(() {
      images[currentIndex] = file;
      isVerifying[currentIndex] = true;
      isSubmitting = false;
    });

    // Hämta målets namn
    final targetTree = treeTargets[currentIndex];

    // Verifiera med AI
    final result = await _treasureService.verifyTreePicture(
      imageFile: file,
      targetTreeName: targetTree.name,
      targetCategory: 'TREE',
    );

    if (!mounted) return;

    setState(() {
      isVerifying[currentIndex] = false;
    });

    if (result.success) {
      // Rätt träd - lås upp
      setState(() {
        treeTargets[currentIndex].isFound = true;
      });

      // Visa bekräftelse
      _showSuccessDialog(
        treeName: targetTree.name,
        confidence: result.confidence ?? 0,
        points: result.pointsAwarded ?? 0,
      );

      // Kolla om alla är klara
      _checkAllCompleted();

    } else {
      // Fel träd eller för låg confidence
      _showRetryDialog(
        treeName: targetTree.name,
        confidence: result.confidence ?? 0,
        errorMessage: result.errorMessage ?? 'Bilden kändes inte igen',
      );

      // Rensa bilden så att användaren kan försöka igen
      setState(() {
        images[currentIndex] = null;
      });
    }
  }

  void _showSuccessDialog({
    required String treeName,
    required double confidence,
    required int points,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hittat!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Du har hittat en $treeName!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text('AI-tillförlitlighet: ${(confidence * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 8),
            Text('+$points poäng!', style: const TextStyle(color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _goToNextTree();
            },
            child: const Text('Fortsätt →'),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog({
    required String treeName,
    required double confidence,
    required String errorMessage,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Kändes inte igen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (confidence > 0)
              Text(
                'AI-tillförlitlighet: ${(confidence * 100).toStringAsFixed(0)}% (kräver 75%)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 8),
            const Text('Försök med en tydligare bild!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Ta ny bild'),
          ),
        ],
      ),
    );
  }

  void _goToNextTree() {
    if (currentIndex < treeTargets.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void _goToPreviousTree() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  void _checkAllCompleted() {
    final allFound = treeTargets.every((tree) => tree.isFound);
    if (allFound && !allCompleted) {
      setState(() {
        allCompleted = true;
      });
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Grattis!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Du har hittat alla ${treeTargets.length} träd!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text('Bra jobbat!'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Återgå till hemskärmen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
              );
            },
            child: const Text('Tillbaka till hem'),
          ),
        ],
      ),
    );
  }

  void resetAll() {
    setState(() {
      _initializeTrees();
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
    final bool currentVerifying = isVerifying[currentIndex];
    final bool currentFound = currentTarget.isFound;

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
            // Rubrik med progress
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
              child: Text(
                'Ta bild på dessa träd',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

            // Progress-indikator (prickar)
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
                          : treeTargets[index].isFound
                          ? const Color(0xff84c06c)
                          : Colors.grey.shade400,
                    ),
                  );
                }),
              ),
            ),

            // Hittade träd räknare
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${treeTargets.where((t) => t.isFound).length}/${treeTargets.length} hittade',
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 20),

            // Navigation och trädnamn
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: currentIndex > 0 ? _goToPreviousTree : null,
                    icon: const Icon(Icons.arrow_back_ios),
                    iconSize: 30,
                    color: currentIndex > 0 ? const Color(0xFF4C290C) : Colors.grey,
                  ),
                  Text(
                    currentTarget.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  IconButton(
                    onPressed: currentIndex < treeTargets.length - 1 ? _goToNextTree : null,
                    icon: const Icon(Icons.arrow_forward_ios),
                    iconSize: 30,
                    color: currentIndex < treeTargets.length - 1 ? const Color(0xFF4C290C) : Colors.grey,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bildruta
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xfff8ed76),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: currentFound ? const Color(0xFF4C290C) : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Visar tagen bild eller referensbild
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
                                        const Icon(Icons.image_outlined, size: 80, color: Color(0xFF4C290C)),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Referensbild saknas',
                                          style: Theme.of(context).textTheme.titleMedium,
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

                        // Verifierings-spinner
                        if (currentVerifying)
                          Container(
                            color: Colors.black54,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: Colors.white),
                                  SizedBox(height: 12),
                                  Text(
                                    'Verifierar bild...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Bockmarkering för hittade träd
                        if (currentFound && !currentVerifying)
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

            // Kameraknapp (visas bara om trädet inte är hittat och inte verifierar)
            if (!currentFound && !currentVerifying)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton.icon(
                  onPressed: takePictureAndVerify,
                  icon: const Icon(Icons.camera_alt, size: 30),
                  label: const Text('Ta bild och verifiera'),
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

            // Statusmeddelande för hittade träd
            if (currentFound && !allCompleted)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '✓ Hittad! Gå vidare till nästa träd.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF4C290C),
                  ),
                ),
              ),

            // Knapp för att börja om
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
                    'Alla träd hittade!',
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