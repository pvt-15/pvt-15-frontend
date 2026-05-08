import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../services/camera_service.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../home.dart';
import 'package:http/http.dart' as http;

class BingoMediumMode extends StatefulWidget{
  final String typeOfBingo;

  const BingoMediumMode({super.key, required this.typeOfBingo});

  @override
  State<BingoMediumMode> createState() => _BingoMediumMode();
}

class _BingoMediumMode extends State<BingoMediumMode> {

  static final List<Map<String, dynamic>> games = [
    {'name': 'Träd', 'images': <File?>[null, null, null], "isCompleted": false},
    {'name': 'Växter', 'images': <File?>[null, null, null], "isCompleted": false},
    {'name': 'Djur', 'images': <File?>[null, null, null], "isCompleted": false},
    {'name': 'Blandad', 'images': <File?>[null, null, null], "isCompleted": false},
  ];


  late bool isCompleted;

  File? image1;
  File? image2;
  File? image3;

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
                'test medel',
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

                          //TODO beroende på lösningen med jwt token, samt att man behöver skicka med vilken typ det är

                          //bool success = await checkPictureContent(file);

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
                        // Logik för kamera 2 kommer här
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color(0xfff8ed76),
                          borderRadius: BorderRadius.circular(15),
                          //image: _image2 != null ? DecorationImage(image: FileImage(_image2!), fit: BoxFit.cover) : null,
                        ),
                        child: const Center(child: Icon(Icons.image, size: 50,)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 70),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        // Logik för kamera 3 kommer här
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color(0xfff8ed76),
                          borderRadius: BorderRadius.circular(15),
                          //image: _image3 != null ? DecorationImage(image: FileImage(_image3!), fit: BoxFit.cover) : null,
                        ),
                        child: const Center(child: Icon(Icons.image, size: 50,)),
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

                //TODO innan reset ska bilderna skickas till bibliotek

                if (success){
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
                                Navigator.pop(context);
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
                "DEBUG hem",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

          ],
        ),
      ),

      bottomNavigationBar: const CustomNavigationBar(),

    );
  }

  Future<bool> checkPictureContent(File? file, String token) async {
    final response = await http.post(
      Uri.parse('https://group-6-15.pvt.dsv.su.se/pictures'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jwt': token,
        'request': file,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  //TODO egentligen bättre med andra hållet för true false return
  Future<bool> checkBingoCompletionStatus () async {
    if (image1 == null || image2 == null || image3 == null) {
      return false;
    } else {
      isCompleted = true;
      updateIsCompletedInList(isCompleted);
      return true;
    }
  }

//TODO metod för att rensa bingo efter avklarad utmaning
  void resetBingo () {
    if (isCompleted == true) {
      image1 = null;
      image2 = null;
      image3 = null;
      isCompleted = false;
      updateIsCompletedInList(isCompleted);
    }
  }

  void updateImageInList(File image, int index) {
    Map<String, dynamic>? currentGame = findCurrentBingoGame();

    if(currentGame != null) {
      currentGame['images'][index] = image;
    }
  }

  void updateIsCompletedInList(bool isCompleted) {
    Map<String, dynamic>? currentGame = findCurrentBingoGame();

    if(currentGame != null) {
      currentGame['isCompleted'] = isCompleted;
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

  @override
  void initState() {
    super.initState();

    loadPictures();
  }

  void loadPictures() {
    Map<String, dynamic>? currentGame = findCurrentBingoGame();

    if(currentGame != null) {
      setState(() {
        image1 = currentGame['images'][0];
        image2 = currentGame['images'][1];
        image3 = currentGame['images'][2];
      });

      isCompleted = currentGame['isCompleted'];
    }

  }
//TODO metod för att skicka bilderna till bibliotek via backend

}