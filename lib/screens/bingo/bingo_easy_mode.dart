import 'dart:core';
import 'dart:io';

import 'package:Skogsjakten/services/upload_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/camera_service.dart';
import '../../services/gamification_popup_helper.dart';
import '../../services/session_storage.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../home.dart';
import 'http_help_methods.dart';

class BingoEasyMode extends StatefulWidget{
  final String typeOfBingo;
  final int? challengeId;

  const BingoEasyMode({super.key, required this.typeOfBingo, this.challengeId});

  @override
  State<BingoEasyMode> createState() => _BingoEasyMode();
}

class _BingoEasyMode extends State<BingoEasyMode> {

  List<dynamic> images = [null, null];

  Future<String?> token = SessionStorage().getToken();

  late HttpHelpMethods helpMethodsHttp;
  late UploadPicture helpMethodsUploadPicture;

  late String question;
  late int challengeId;
  late int points;

  @override
  void initState() {
    super.initState();
    question = 'Laddar utmaning...';
    initStart();
  }

  Future<void> initStart() async {
    try {
      final jwtToken = await token;
      helpMethodsHttp = HttpHelpMethods(jwtToken: jwtToken);
      helpMethodsUploadPicture = UploadPicture(jwtToken: jwtToken);

      await setupChallenge();
      getPictures();

    } catch (e) {
      debugPrint('Initieringsfel: $e');
    }
  }

  Future<void> setupChallenge() async {
    try {
      Map<String, dynamic> data;
      if (widget.challengeId != null) {
        data = await helpMethodsHttp.getStartedQuestion(widget.challengeId!);
        print(data);
      } else {
        data = await helpMethodsHttp.getOrCreateBingoChallenge(widget.typeOfBingo, 'EASY');
      }

      setState(() {
        question = data['description'];
        challengeId = data['id'];
        //points = data['points'];
      });

    } catch (e) {
      setState(() {
        question = 'Kunde inte ladda utmaning: $e';
      });
    }
  }

  /*
  //Metod för att hämta ut bilder från en utmaning från databasen
  void getPictures() async {
    try {
      Map<String, dynamic> response = await helpMethodsHttp.getPicturesForChallenge(challengeId);

      if (response.containsKey('tasks')) {
        List<dynamic> tasks = response['tasks'];
        List<String> urls = [];

        for (var task in tasks) {
          if (task['pictures'] != null && (task['pictures'] as List).isNotEmpty) {
            String? url = task['pictures'][0]['imageUrl'];
            if (url != null) {
              urls.add(url);
            }
          }
        }

        setState(() {
          if (urls.isNotEmpty) images[0] = urls[0];
          if (urls.length > 1) images[1] = urls[1];
        });
      }
    } catch (e) {
      debugPrint('DEBUG getpictures $e');
    }
  }

   */

  //Metod för att hämta ut bilder från en utmaning från databasen
  void getPictures() async {
    try {
      Map<String, dynamic> response = await helpMethodsHttp.getPicturesForChallenge(challengeId);

      if (response.containsKey('tasks')) {
        List<dynamic> tasks = response['tasks'];
        List<String> urls = [];

        for (var task in tasks) {
          if (task['pictures'] != null && (task['pictures'] as List).isNotEmpty) {
            if (task['requiredCount'] == 2) {
              for (var picture in task['pictures']) {
                String url = picture['imageUrl'];
                if (url != null) {
                  urls.add(url);
                }
              }

            } else {
              String? url = task['pictures'][0]['imageUrl'];
              if (url != null) {
                urls.add(url);
              }
            }
          }
        }

        setState(() {
          if (urls.isNotEmpty) {
            images[0] = urls[0];
          }
          if (urls.length > 1) {
            images[1] = urls[1];
          }
        });
      }
    } catch (e) {
      debugPrint('DEBUG getpictures $e');
    }
  }

  Future<File> getAssetFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file = File('${(await getTemporaryDirectory()).path}/test_asset.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  /*
  Object? getImageFromList(int index) {
    var image = images[index];

    if (image != null) {
      if (image is File) {
        return FileImage(image);
      } else if (image is String) {
        return NetworkImage(image);
      }
    }
    return null;
  }

   */

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
        title: const Text('Bingo'),
      ),
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

                        if (images[0] == null){
                          final File? file = await CameraService.takePicture();

                          //final File assetFile = await getAssetFile('assets/gran.png');
                          //final compressedXFile = await FlutterImageCompress.compressAndGetFile(assetFile.path, '${assetFile.path}_comp.jpg', quality: 85, minWidth: 1000);
                          //final File file = File(compressedXFile!.path);

                          bool success = false;
                          String? type;

                          if(widget.typeOfBingo == 'Blandad') {
                            type = await showDialog<String>(
                                context: context,
                                builder: (context) => decideTargetTypeMixedBingo());
                          } else {
                            type = helpMethodsHttp.mapCategoryToBackendForPictureUpload(widget.typeOfBingo);
                          }

                          if(type != null) {
                            success = await uploadPicture(file, type);
                          }

                          if (file != null && success) {
                            setState(() {
                              images[0] = file;
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
                            image: images[0] != null ? DecorationImage(image: FileImage(images[0]!), fit: BoxFit.cover) : null,
                        ),
                        child: (images[0] == null) ? Center(child: Icon(MdiIcons.camera, size: 50)) : null,
                      ),
                    ),

                    const SizedBox(width: 50),

                    InkWell(
                      onTap: () async {

                        if (images[1] == null){
                          final File? file = await CameraService.takePicture();
                          bool success = false;

                          String? type;

                          if(widget.typeOfBingo == 'Blandad') {
                            type = await showDialog<String>(
                                context: context,
                                builder: (context) => decideTargetTypeMixedBingo());
                          } else {
                            type = helpMethodsHttp.mapCategoryToBackendForPictureUpload(widget.typeOfBingo);
                          }

                          if(type != null) {
                            success = await uploadPicture(file, type);
                          }

                          if (file != null && success) {
                            setState(() {
                              images[1] = file;
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
                            image: images[1] != null ? DecorationImage(image: FileImage(images[1]!), fit: BoxFit.cover) : null,
                        ),
                        child: (images[1] == null) ? Center(child: Icon(MdiIcons.camera, size: 50)) : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 90),

            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> challenge = await helpMethodsHttp.getStartedQuestion(challengeId);
                String status = challenge['status'];

                if (status == 'COMPLETED') {

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
                              child: Text('Klar', style: Theme.of(context).textTheme.headlineMedium),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(110, 50),
                              ),
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
  AlertDialog decideTargetTypeMixedBingo() {
    return AlertDialog(
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
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(110, 50),
          ),
          child: Text('Växt', style: Theme.of(context).textTheme.bodyMedium),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, 'TREE');
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(110, 50),
          ),
          child: Text('Träd', style: Theme.of(context).textTheme.bodyMedium),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, 'ANIMAL');
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(110, 50),
          ),
          child: Text('Djur', style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Future<bool> uploadPicture(File? file, String type) async {
    try {
      helpMethodsUploadPicture = UploadPicture(jwtToken: await token);
      if (file != null) {
        Map<String, dynamic>? response = await helpMethodsUploadPicture.sendPictureToBackend(file, type, 'CHALLENGE', challengeId);
        //print('uploadPicture $response');

        /*if (response != null) {
          if (response['accepted'] == true) {
            showDialog(
              context: context,
              builder: (context) => successMessageUploadPicture(),
            );
            return true;
          }*/
        if (response != null && response['accepted'] == true) {
          final gamification = response['gamification'];

          if (mounted) {
            await GamificationPopupService.showIfNeeded(
              context: context,
              leveledUp: gamification?['leveledUp'] ?? false,
              previousLevel: gamification?['previousLevel'],
              currentLevel: gamification?['currentLevel'],
              newlyUnlockedBadges: gamification?['newlyUnlockedBadges'] ?? [],
            );
          }

          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => successMessageUploadPicture(),
            );
          }

          return true;
        } else {
          showDialog(
            context: context,
            builder: (context) => errorMessageUploadPicture(),
          );
          return false;
        }

      } else {
        showDialog(
          context: context,
          builder: (context) => errorMessageUploadPicture(),
        );
        return false;
      }

    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => errorMessageUploadPicture(),
      );
      return false;
    }
    //return false;
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
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(110, 50),
          ),
          child: Text('Ok', style: Theme.of(context).textTheme.bodyMedium),
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
          child: Text('Till hem', style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  AlertDialog successMessageUploadPicture() {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      content: const Text(
        'Bra jobbat! Bilden har sparats.',
        textAlign: TextAlign.center,
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(110, 50),
          ),
          child: Text('Okej', style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

// metod för att rensa bingo efter avklarad utmaning
  void resetBingo() {
    images[0] = null;
    images[1] = null;
  }

}