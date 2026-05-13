import 'dart:core';
import 'dart:io';

import 'package:Skogsjakten/services/upload_picture.dart';
import 'package:Skogsjakten/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/camera_service.dart';
import '../../services/session_storage.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../home.dart';
import '../override_dialog.dart';
import 'http_help_methods.dart';

class BingoHardMode extends StatefulWidget{
  final String typeOfBingo;
  final int? challengeId;

  const BingoHardMode({super.key, required this.typeOfBingo, this.challengeId});

  @override
  State<BingoHardMode> createState() => _BingoHardMode();
}

class _BingoHardMode extends State<BingoHardMode> {

  Future<String?> token = SessionStorage().getToken();

  late HttpHelpMethods helpMethodsHttp;
  late UploadPicture helpMethodsUploadPicture;

  late String question;
  late int challengeId;

  String? imageUrl1;
  String? imageUrl2;

  File? image1;
  File? image2;

  @override
  void initState() {
    super.initState();
    question = 'Laddar utmaning...';
    initStart();
    //loadPictures();
  }

  Future<void> initStart() async {
    try {
      final jwtToken = await token;
      helpMethodsHttp = HttpHelpMethods(jwtToken: jwtToken);
      helpMethodsUploadPicture = UploadPicture(jwtToken: jwtToken);

      await setupChallenge();
      getPictures();

      List<dynamic> pictures = await helpMethodsHttp.getPictures();
      debugPrint('DEBUG: $pictures');

    } catch (e) {
      debugPrint('Initieringsfel: $e');
    }
  }

  Future<void> setupChallenge() async {
    try {
      Map<String, dynamic> data;
      if (widget.challengeId != null) {
        data = await helpMethodsHttp.getStartedQuestion(widget.challengeId!);
      } else {
        data = await helpMethodsHttp.getOrCreateBingoChallenge(widget.typeOfBingo, 'EASY');
      }

      setState(() {
        question = data['description'];
        challengeId = data['id'];
      });

    } catch (e) {
      setState(() {
        question = 'Kunde inte ladda utmaning: $e';
      });
    }
  }

  void getPictures() async {
    try {
      Map<String, dynamic> response = await helpMethodsHttp.getPicturesForChallenge(challengeId);
      debugPrint('Hämtade bilder: $response');
      if (response.isNotEmpty) {
        setState(() {
          if (response is List && response.isNotEmpty) {
            imageUrl1 = response[0]['imageUrl'];
            if (response.length > 1) {
              imageUrl2 = response[1]['imageUrl'];
            }
          }
        });
      }
    } catch (e) {
      debugPrint('DEBUG getpictures $e');
    }
  }

  /*
  //Metod för att hämta ut bilder från en utmaning med flera mindre utmaningar it sig
  void getPictures() async {
    try {
      Map<String, dynamic> response = await helpMethodsHttp.getPicturesForChallenge(challengeId);
      debugPrint('Hämtade bilder: $response');

      if (response.containsKey('tasks')) {
        List<dynamic> tasks = response['tasks'];
        List<String> urls = [];

        for (var task in tasks) {
          if (task['pictures'] != null && (task['pictures'] as List).isNotEmpty) {
            // Hämta imageUrl från den första bilden i varje task
            String? url = task['pictures'][0]['imageUrl'];
            if (url != null) {
              urls.add(url);
            }
          }
        }

        setState(() {
          if (urls.isNotEmpty) imageUrl1 = urls[0];
          if (urls.length > 1) imageUrl2 = urls[1];
        });
      }
    } catch (e) {
      debugPrint('DEBUG getpictures $e');
    }
  }

   */

  Future<File> getAssetFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file = File('${(await getTemporaryDirectory()).path}/test_ek.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
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
                        if (imageUrl1 == null){
                          //final File? file = await CameraService.takePicture();
                          final file = await getAssetFile('assets/ek.jpg');

                          final compressedXFile = await FlutterImageCompress.compressAndGetFile(file.path, '${file.path}_compressed.jpg', quality: 70,);

                          final File compressedFile = File(compressedXFile!.path);

                          //bool success = await helpMethodsUploadPicture.sendPictureToBackend(compressedFile, challengeId);
                          //bool success = await helpMethodsUploadPicture.sendPictureToBackend(compressedFile, helpMethodsHttp.mapCategoryToBackend(widget.typeOfBingo), 'CHALLENGE', challengeId);

                          //TODO vet inte om detta är en så bra lösning för success bool
                          bool success = false;

                          if(widget.typeOfBingo == 'Blandad') {
                            if(decideTargetTypeMixedBingo() != null) {
                              String type = decideTargetTypeMixedBingo() as String;
                              success = await helpMethodsUploadPicture.sendPictureToBackend(compressedFile, type, 'CHALLENGE', challengeId);
                            }
                          } else {
                            success = await helpMethodsUploadPicture.sendPictureToBackend(compressedFile, 'PLANT', 'CHALLENGE', challengeId);
                          }

                          if (file != null && success) {
                            setState(() {
                              image1 = file;
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
                            image: image1 != null ? DecorationImage(image: FileImage(image1!), fit: BoxFit.cover)
                                : (imageUrl1 != null ? DecorationImage(image: NetworkImage(imageUrl1!), fit: BoxFit.cover)
                                : null)
                        ),
                        child: (image1 == null && imageUrl1 == null) ? const Center(child: Icon(Icons.image, size: 50)) : null,
                      ),
                    ),

                    const SizedBox(width: 50),

                    InkWell(
                      onTap: () async {
                        if (imageUrl2 == null){
                          final File? file = await CameraService.takePicture();

                          //BingoHelpMethods.sendPictureToGoogleStorage(token as String, file);
                          //sendPictureToGoogleStorage(file);

                          //TODO check om det gick igenom

                          if (file != null) {
                            setState(() {
                              image2 = file;
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
                            image: image2 != null ? DecorationImage(image: FileImage(image2!), fit: BoxFit.cover)
                                : (imageUrl2 != null ? DecorationImage(image: NetworkImage(imageUrl2!), fit: BoxFit.cover)
                                : null)
                        ),
                        child: (image2 == null && imageUrl2 == null) ? const Center(child: Icon(Icons.image, size: 50)) : null,
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
                final user = await SessionStorage().getUser();

                if (success) {

                  resetBingo();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(),
                    ),
                  );
                } else {
                  showDialog(
                      context: context,
                      builder: (context) {

                        /*
                        return CustomAlertDialog(
                          title: 'Är du säker?',
                          content: 'Är du säker? Om du avslutar nu registeras inga poäng',
                          cancelText: 'Avbryt',
                          confirmText: 'Bekräfta',
                          onCancel: () => Navigator.pop,
                          onConfirm: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()),
                          ),
                        );

                         */



                        return AlertDialog(
                          actionsAlignment: MainAxisAlignment.spaceBetween,
                          content: Text(
                            'Är du säker? Om du avslutar nu registeras inga poäng',
                            textAlign: TextAlign.center,
                          ),

                          actions: [
                            TextButton(
                              onPressed: () {

                                //TODO kan behöva någon check för om det gick igenom eller inte
                                helpMethodsHttp.endStartedChallenge(challengeId);

                                resetBingo();

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => HomeScreen(),
                                    ),
                                );

                              },
                              child: Text('Bekräfta', style: Theme.of(context).textTheme.headlineMedium),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Avbryt', style: Theme.of(context).textTheme.headlineMedium),
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

  String? decideTargetTypeMixedBingo() {

    AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceBetween,
      content: Text(
        'Bestäm typen! Vad var det du tog en bild på?',
        textAlign: TextAlign.center,
      ),

      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, 'PLANT');
          },
          child: Text('Växt', style: Theme.of(context).textTheme.bodyMedium),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, 'TREE');
          },
          child: Text('Träd', style: Theme.of(context).textTheme.bodyMedium),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, 'ANIMAL');
          },
          child: Text('Djur', style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );

    return null;

  }

/*
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

 */

  //TODO egentligen bättre med andra hållet för true false return
  Future<bool> checkBingoCompletionStatus() async {
    if (imageUrl1 == null || imageUrl2 == null) {
      return false;
    } else {
      return true;
    }
  }

// metod för att rensa bingo efter avklarad utmaning
  void resetBingo() {
      imageUrl1 = null;
      imageUrl2 = null;
  }

}