import 'dart:core';
import 'dart:io';

import 'package:Skogsjakten/screens/home/choose_bingo_game.dart';
import 'package:Skogsjakten/services/upload_picture.dart';
import 'package:flutter/material.dart';
import '../../services/camera_service.dart';
import '../../services/session_storage.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../home.dart';
import 'http_help_methods.dart';

class BingoEasyMode extends StatefulWidget{
  final String typeOfBingo;

  const BingoEasyMode({super.key, required this.typeOfBingo});

  @override
  State<BingoEasyMode> createState() => _BingoEasyMode();
}

class _BingoEasyMode extends State<BingoEasyMode> {

  static final List<Map<String, dynamic>> games = [
    //alla startade lätta spel
    {'name': 'Träd', 'images': <File?>[null, null], "isCompleted": false, 'challengeId': null},
    {'name': 'Växter', 'images': <File?>[null, null], "isCompleted": false, 'challengeId': null},
    {'name': 'Djur', 'images': <File?>[null, null], "isCompleted": false, 'challengeId': null},
    {'name': 'Blandad', 'images': <File?>[null, null], "isCompleted": false, 'challengeId': null},
  ];

  Future<String?> token = SessionStorage().getToken();

  late final HttpHelpMethods helpMethodsChallenge;

  late final UploadPicture helpMethodsUploadPicture;

  late Map<String, dynamic>? currentGame = findCurrentBingoGame();

  late bool isCompleted;

  late String question;

  //TODO kanske inte behöver göra "lokala" lagring av detta
  File? image1;
  File? image2;

  @override
  void initState() {
    super.initState();
    question = 'Laddar utmaning...';
    startChallenge();
    //loadPictures();
  }

  void getPictures() async {
    try {
      helpMethodsChallenge = HttpHelpMethods(jwtToken: await token);
      //helpMethodsChallenge.getPicturesForChallenge();
    } catch (e) {
      debugPrint('DEBUG $e');
    }

  }

  void startChallenge() async {
    try {
      //TODO hitta ett bättre sätt med instansera http
      helpMethodsChallenge = HttpHelpMethods(jwtToken: await token);

      Map<String, dynamic>? currentGame = findCurrentBingoGame();

      List<dynamic> response = await helpMethodsChallenge.getAllChallenges();

      if (currentGame != null) {
        debugPrint('DEBUG: $response\n');

        bool success = setStartedQuestion(response);

        if (success == false) {
          //TODO va?
          Map<String, dynamic> data = await helpMethodsChallenge.getStartedQuestion(currentGame['challengeId']);
          setState(() {
            question = data['description'];
          });
        } else {
          setStartedQuestion(response);
        }
      }
    } catch (e) {
      setState(() {
        question = '$e';
      });
    }
  }

  bool setStartedQuestion(List<dynamic> response) {
    //TODO if check för om det var blandad bingo
    for (var challenge in response) {
      if(challenge['type'] == 'BINGO' && challenge['category'] == null && challenge['difficulty'] == 'HARD' && challenge['status'] == 'IN_PROGRESS') {
        setState(() {
          question = challenge['description'];
        });
        return true;
      }
    }
    return false;
  }

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
                widget.typeOfBingo,
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
                question,
                //'test lätt',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        if (image1 == null){
                          final File? file = await CameraService.takePicture();

                          //UploadPicture.sendPictureToGoogleStorage(file);
                          //sendPictureToGoogleStorage(file);

                          //TODO check om det gick igenom

                          if (file != null) {
                            setState(() {
                              image1 = file;
                              updateImageInList(file, 0);
                            });
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color(0xfff8ed76),
                          borderRadius: BorderRadius.circular(15),
                          image: image1 != null ? DecorationImage(image: FileImage(image1!), fit: BoxFit.cover) : null,
                        ),
                        child: image1 == null ? const Center(child: Icon(Icons.image, size: 50)) : null,
                      ),
                    ),

                    const SizedBox(width: 50),

                    InkWell(
                      onTap: () async {
                        if (image2 == null){
                          final File? file = await CameraService.takePicture();

                          //BingoHelpMethods.sendPictureToGoogleStorage(token as String, file);
                          //sendPictureToGoogleStorage(file);

                          //TODO check om det gick igenom

                          if (file != null) {
                            setState(() {
                              image2 = file;
                              updateImageInList(file, 1);
                            });
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color(0xfff8ed76),
                          borderRadius: BorderRadius.circular(15),
                          image: image2 != null ? DecorationImage(image: FileImage(image2!), fit: BoxFit.cover) : null,
                        ),
                        child: image2 == null ? const Center(child: Icon(Icons.image, size: 50)) : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 90),

            ElevatedButton(
              onPressed: () async {
                bool success = await checkBingoCompletionStatus();

                if (success) {

                  resetBingo();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(name: 'test'),
                    ),
                  );
                } else {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Bekräfta', style: Theme.of(context).textTheme.titleMedium),
                          content: Text('Är du säker, alla bilder är inte insamlade', style: Theme.of(context).textTheme.headlineLarge),

                          actions: [
                            TextButton(
                              onPressed: () {

                                isCompleted = true;

                                resetBingo();

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const HomeScreen(name: 'test'),
                                    ),
                                );

                              },
                              child: Text('Klar', style: Theme.of(context).textTheme.headlineLarge),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Avbryt', style: Theme.of(context).textTheme.headlineLarge),
                            ),
                          ],
                        );
                      }
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff84c06c),
                minimumSize: Size(290, 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                "Klar",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

          ],
        ),
      ),

      bottomNavigationBar: const CustomNavigationBar(selectedIndex: -1),

    );
  }


  //Behövs allt detta? Kan man göra det på annat sätt?
  Future<bool> uploadPicture(File? file) async {
    try {
      helpMethodsUploadPicture = UploadPicture(jwtToken: await token);
      if (file != null) {
        bool response = await helpMethodsUploadPicture.sendPictureToBackend(file);

        if (response == true) {
          debugPrint('DEBUG uppladdning lyckades');
          return true;
        } else {
          debugPrint('DEBUG uppladdning misslyckades');
          return false;
        }

      } else {
        debugPrint('DEBUG mottagen fil var null');
        return false;
      }

    } catch (e) {
      debugPrint('DEBUG: $e');
      return false;
    }
  }

  //TODO egentligen bättre med andra hållet för true false return
  Future<bool> checkBingoCompletionStatus () async {
    if (image1 == null || image2 == null) {
      return false;
    } else {
      isCompleted = true;
      updateIsCompletedInList(isCompleted);
      return true;
    }
  }

// metod för att rensa bingo efter avklarad utmaning
  void resetBingo () {
    if (isCompleted == true) {
      image1 = null;
      image2 = null;
      isCompleted = false;

      updateIsCompletedInList(isCompleted);
      updateImageInList(image1, 0);
      updateImageInList(image2, 1);

      for(var game in ChooseBingoGame.startedGames) {
        Map<String, dynamic>? currentGame = findCurrentBingoGame();

        if (currentGame != null) {
          if (game['name'] == currentGame['name']) {
            game['status'] = false;
            game['route'] = null;
          }
        }
      }

    }
  }

  void updateImageInList(File? image, int index) {
    if(currentGame != null) {
      currentGame!['images'][index] = image;
    }
  }

  void updateIsCompletedInList(bool isCompleted) {
    if(currentGame != null) {
      currentGame!['isCompleted'] = isCompleted;
    }
  }

  Map<String, dynamic>? findCurrentBingoGame() {
    Map<String, dynamic>? currentGame;

    for(var game in games) {
      if (game['name'] == widget.typeOfBingo) {
        currentGame = game;
        break;
      }
    }
    return currentGame;
  }

  void loadPictures() {
    if(currentGame != null) {
      setState(() {
        image1 = currentGame!['images'][0];
        image2 = currentGame!['images'][1];
      });

      isCompleted = currentGame!['isCompleted'];
    }

  }

  void setCurrentChallengeId(Map<String, dynamic> data) {
    Map<String, dynamic>? currentGame = findCurrentBingoGame();
    if(currentGame != null) {
      currentGame['challengeId'] = data['id'];
    }
  }

}