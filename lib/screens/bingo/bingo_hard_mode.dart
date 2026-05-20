import 'dart:core';
import 'dart:io';

import 'package:Skogsjakten/services/upload_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../services/camera_service.dart';
import '../../services/session_storage.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../home.dart';
import 'http_help_methods.dart';

class BingoHardMode extends StatefulWidget{
  final String typeOfBingo;
  final int? challengeId;

  const BingoHardMode({super.key, required this.typeOfBingo, this.challengeId});

  @override
  State<BingoHardMode> createState() => _BingoHardMode();
}

class _BingoHardMode extends State<BingoHardMode> {

  List<dynamic> images = [null, null, null, null];

  List<String> specificQuestionsForTask = ['', '', '', ''];

  Future<String?> token = SessionStorage().getToken();

  late HttpHelpMethods helpMethodsHttp;
  late UploadPicture helpMethodsUploadPicture;

  late String question;
  late int challengeId;

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
      } else {
        data = await helpMethodsHttp.getOrCreateBingoChallenge(widget.typeOfBingo, 'HARD');
        //data = await helpMethodsHttp.getNewQuestionOnId();
      }

      setState(() {
        question = data['description'];
        challengeId = data['id'];
      });

      await setSpecificQuestions();

    } catch (e) {
      setState(() {
        question = 'Kunde inte ladda utmaning: $e';
      });
    }
  }

  //Metod för att hämta ut bilder från en utmaning med flera mindre utmaningar it sig
  void getPictures() async {
    try {
      Map<String, dynamic> response = await helpMethodsHttp.getPicturesForChallenge(challengeId);
      //debugPrint('Hämtade bilder: $response');

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
          if (urls.isNotEmpty) {
            images[0] = urls[0];
          }
          if (urls.length > 1) {
            images[1] = urls[1];
          }
          if (urls.length > 2) {
            images[2] = urls[2];
          }
          if (urls.length > 3) {
            images[3] = urls[3];
          }
        });
      }
    } catch (e) {
      debugPrint('DEBUG getpictures $e');
    }
  }

  Future<void> setSpecificQuestions() async {
    try {
      Map<String, dynamic> response = await helpMethodsHttp.getStartedQuestion(challengeId);

      if (response.containsKey('tasks')) {
        List<dynamic> tasks = response['tasks'];
        List<String> questions = [];

        for (var task in tasks) {
          if (task['taskText'] != null) {
            questions.add(task['taskText']);
          }
        }

        if (questions.length > 1) {
          setState(() {
            if (questions.isNotEmpty) {
              specificQuestionsForTask[0] = questions[0];
            }
            if (questions.length > 1) {
              specificQuestionsForTask[1] = questions[1];
            }
            if (questions.length > 2) {
              specificQuestionsForTask[2] = questions[2];
            }
            if (questions.length > 3) {
              specificQuestionsForTask[3] = questions[3];
            }
          });
        }

      }

    } catch (e) {
      debugPrint('DEBUG setSpecificQuestions $e');
    }
  }

  Future<File> getAssetFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file = File('${(await getTemporaryDirectory()).path}/test_asset.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
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
                Row (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Column (
                      children: [
                        InkWell(

                          onTap: () async {

                            if (images[0] == null) {
                              //final File? file = await CameraService.takePicture();
                              //final File? file = await getAssetFile('assets/gran.png');

                              final File assetFile = await getAssetFile('assets/gran.png');
                              final compressedXFile = await FlutterImageCompress.compressAndGetFile(assetFile.path, '${assetFile.path}_comp.jpg', quality: 70);
                              final File file = File(compressedXFile!.path);

                              bool success = false;
                              String? type;

                              if (widget.typeOfBingo == 'Blandad') {
                                type = await showDialog<String>(
                                    context: context,
                                    builder: (context) => decideTargetTypeMixedBingo());
                              } else {
                                type = helpMethodsHttp.mapCategoryToBackend(widget.typeOfBingo);
                              }

                              if (type != null) {
                                success = await uploadPicture(file, type);
                              }
                              if (file != null && success) {
                                setState(() {
                                  images[0] = file;
                                });
                              }
                            }
                            },



                          //onTap: () => handleImageAction(0, fromGallery: true),

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
                        Text(specificQuestionsForTask[0]),
                      ],
                    ),

                    const SizedBox(width: 50),

                    Column (
                      children: [

                        InkWell(
                          onTap: () async {

                            if (images[1] == null){
                              //final File? file = await CameraService.takePicture();

                              final File assetFile = await getAssetFile('assets/gran.png');
                              final compressedXFile = await FlutterImageCompress.compressAndGetFile(assetFile.path, '${assetFile.path}_comp.jpg', quality: 50);
                              final File file = File(compressedXFile!.path);

                              bool success = false;
                              String? type;

                              if(widget.typeOfBingo == 'Blandad') {
                                type = await showDialog<String>(
                                    context: context,
                                    builder: (context) => decideTargetTypeMixedBingo());
                              } else {
                                type = helpMethodsHttp.mapCategoryToBackend(widget.typeOfBingo);
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
                        Text(specificQuestionsForTask[1]),
                      ],
                    ),

                  ],
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Column (
                      children: [

                        InkWell(
                          onTap: () async {

                            if (images[2] == null){
                              final File? file = await CameraService.takePicture();
                              bool success = false;
                              String? type;

                              if(widget.typeOfBingo == 'Blandad') {
                                type = await showDialog<String>(
                                    context: context,
                                    builder: (context) => decideTargetTypeMixedBingo());
                              } else {
                                type = helpMethodsHttp.mapCategoryToBackend(widget.typeOfBingo);
                              }

                              if(type != null) {
                                success = await uploadPicture(file, type);
                              }

                              if (file != null && success) {
                                setState(() {
                                  images[2] = file;
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
                              image: images[2] != null ? DecorationImage(image: FileImage(images[2]!), fit: BoxFit.cover) : null,
                            ),
                            child: (images[2] == null) ? Center(child: Icon(MdiIcons.camera, size: 50)) : null,
                          ),
                        ),
                        Text(specificQuestionsForTask[2]),
                      ],
                    ),

                    const SizedBox(width: 50),

                    Column (
                      children: [
                        InkWell(
                          onTap: () async {

                            if (images[3] == null){
                              final File? file = await CameraService.takePicture();
                              bool success = false;
                              String? type;

                              if(widget.typeOfBingo == 'Blandad') {
                                type = await showDialog<String>(
                                    context: context,
                                    builder: (context) => decideTargetTypeMixedBingo());
                              } else {
                                type = helpMethodsHttp.mapCategoryToBackend(widget.typeOfBingo);
                              }

                              if(type != null) {
                                success = await uploadPicture(file, type);
                              }

                              if (file != null && success) {
                                setState(() {
                                  images[3] = file;
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
                              image: images[3] != null ? DecorationImage(image: FileImage(images[3]!), fit: BoxFit.cover) : null,
                            ),
                            child: (images[3] == null) ? Center(child: Icon(MdiIcons.camera, size: 50)) : null,
                          ),
                        ),
                        Text(specificQuestionsForTask[3]),
                      ],
                    ),

                  ],
                ),
              ],
            ),

            const SizedBox(height: 70),

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
  }

  Future<bool> uploadPicture(File? file, String type) async {
    try {
      helpMethodsUploadPicture = UploadPicture(jwtToken: await token);
      if (file != null) {
        Map<String, dynamic>? response = await helpMethodsUploadPicture.sendPictureToBackend(file, type, 'CHALLENGE', challengeId);

        if (response != null) {
          if (response['accepted'] == true) {
            showDialog(
              context: context,
              builder: (context) => successMessageUploadPicture(),
            );
            return true;
          } else {
            showDialog(
              context: context,
              builder: (context) => errorMessageUploadPicture(),
            );
            return false;
          }
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
    return false;
  }

  AlertDialog errorMessageUploadPicture() {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      content: Text(
        'Ojdå, bilden kunde inte sparas. Testa att ta en ny bild!',
        textAlign: TextAlign.center,
      ),

      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Okej', style: Theme.of(context).textTheme.bodyMedium),
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
          child: Text('Okej', style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

// metod för att rensa bingo efter avklarad utmaning
  void resetBingo() {
    images[0] = null;
    images[1] = null;
    images[2] = null;
    images[3] = null;
  }

}