import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:Skogsjakten/screens/home/choose_bingo_game.dart';
import 'package:Skogsjakten/services/token_storage.dart';
import 'package:flutter/material.dart';
import '../../services/camera_service.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../home.dart';
import 'package:http/http.dart' as http;

import 'bingo_help_methods.dart';
import 'json_decode.dart';

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

  Future<String?> token = TokenStorage().getToken();

  late final BingoHelpMethods helpMethods;

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

  void startChallenge() async {
    final String? jwtToken = await token;
    helpMethods= BingoHelpMethods(jwtToken: jwtToken);
    String tempQuestion = await helpMethods.getNewQuestion('EASY', 'BINGO');
    putQuestion(tempQuestion);
  }

  void putQuestion (String tempQuestion) {
    setState(() {
      question = tempQuestion;
    });
  }


  /*

  void startChallenge() {
    Map<String, dynamic>? currentGame = findCurrentBingoGame();
    if(currentGame != null) {
      if(currentGame['challengeId'] != null) {
        //helpMethods.getStartedQuestion(jwtToken);
        getStartedQuestion();
      } else {
        //helpMethods.getNewQuestion(jwtToken, 'EASY', 'BINGO');
        getNewQuestion();
      }
    }
  }

   */




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

                          //BingoHelpMethods.sendPictureToGoogleStorage(token as String, file);
                          sendPictureToGoogleStorage(file);

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
                          sendPictureToGoogleStorage(file);

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

  //TODO borde egentligen göra en null check här istället
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



  Future<http.StreamedResponse?> sendPictureToGoogleStorage(File? imageFile) async {
    try {
      if (imageFile != null) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://group-6-15.pvt.dsv.su.se/uploads/picture'),
        );

        request.headers['Authorization'] = 'Bearer $token';

        request.files.add(
            await http.MultipartFile.fromPath(
                'file',
                imageFile.path
            ),
        );

        final response = await request.send();

        return response;

      } else {
        debugPrint('Mottagen fil var null');
        return null;
      }
    } catch (e) {
      debugPrint('GoogleStorage Error $e');
      return null;
    }

  }


  Future<bool> sendPictureToBackend(File? imageFile) async {
    try {
      //Vänta på att bilden laddas upp och få tillbaka URL:en
      final imageURL = await sendPictureToGoogleStorage(imageFile);

      //Skicka URL till backend
      final response = await http.post(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/pictures'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          //skicka med url till backend som google ger tillbaka
          'imageUrl': imageURL,
          'targetType': 'PLANT',
          'PictureMode': 'CHALLENGE',

        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Backend Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Skicka bild till backend Error $e');
      return false;
    }
  }



/*

//TODO ger 500 error
  Future<void> getStartedQuestion() async {
    int id = currentGame!['challengeId'];

    debugPrint('DEBUG: $id');

    try {
      final String? jwtToken = await token;
      debugPrint('DEBUG: $jwtToken');

      final response = await http.get(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/challenges/$id'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          //'Id': 'id: $id',
        },
      );

      debugPrint(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          question = jsonDecodeDescription(data);
        });
      } else {
        setState(() {
          question = 'Kunde inte hämta fråga (${response.statusCode})';
        });
      }

    } catch (e) {
      setState(() {
        question = 'Något gick fel vid inhämtning av fråga';
      });
    }
  }

  void setCurrentChallengeId(Map<String, dynamic> data) {
    Map<String, dynamic>? currentGame = findCurrentBingoGame();
    if(currentGame != null) {
      //currentGame['challengeId'] = JsonDecode.jsonDecodeChallengeId(data);
      currentGame['challengeId'] = jsonDecodeChallengeId(data);
    }
  }

 */


}