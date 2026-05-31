import 'dart:core';
import 'dart:io';

import 'package:Skogsjakten/services/upload_picture.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../services/camera_service.dart';
import '../../services/gamification_popup_helper.dart';
import '../../services/session_storage.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../home.dart';
import '../home/choose_bingo_game.dart';
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
        data = await helpMethodsHttp.getNewQuestion('EASY', 'BINGO', helpMethodsHttp.mapCategoryToBackendForChallenge(widget.typeOfBingo));
      }

      setState(() {
        question = data['description'];
        challengeId = data['id'];
      });

      getPictures();

    } catch (e) {
      setState(() {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                actionsAlignment: MainAxisAlignment.spaceBetween,
                content: const Text(
                  'Kunde inte ladda utmaning, testa starta ett annat bingo!',
                  textAlign: TextAlign.center,
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChooseBingoGame(),
                        ),
                      );
                    },
                    child: Text('Okej', style: Theme.of(context).textTheme.headlineMedium),
                  ),
                ],
              );
            }
        );
      });
    }
  }

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

  ImageProvider? getImageFromList(int index) {
    var image = images[index];

    if (image == null) {
      return null;
    }

    if (image is File) {
      return FileImage(image);
    } else if (image is String) {
      return NetworkImage(image);
    }
    return null;
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
                  top: 20,
                  bottom: 30
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

                          bool success = false;
                          String? type;

                          if (widget.typeOfBingo == 'Blandad' && file != null) {
                            type = await showDialog<String>(
                                context: context,
                                builder: (context) => decideTargetTypeMixedBingo());
                          } else {
                            String category = widget.typeOfBingo;
                            if (category == 'Växter') category = 'Växt';
                            type = helpMethodsHttp.mapCategoryToBackendForPictureUpload(category);
                          }

                          if (type != null && file != null) {
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
                            image: images[0] != null ? DecorationImage(image: getImageFromList(0)!, fit: BoxFit.cover) : null,
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

                          if (widget.typeOfBingo == 'Blandad' && file != null) {
                            type = await showDialog<String>(
                                context: context,
                                builder: (context) => decideTargetTypeMixedBingo());
                          } else {
                            String category = widget.typeOfBingo;
                            if (category == 'Växter') category = 'Växt';
                            type = helpMethodsHttp.mapCategoryToBackendForPictureUpload(category);
                          }

                          if (type != null && file != null) {
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
                            image: images[1] != null ? DecorationImage(image: getImageFromList(1)!, fit: BoxFit.cover) : null,
                        ),
                        child: (images[1] == null) ? Center(child: Icon(MdiIcons.camera, size: 50)) : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 120),

            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> challenge = await helpMethodsHttp.getStartedQuestion(challengeId);
                String status = challenge['status'];

                if (status == 'COMPLETED') {

                  resetBingo();

                  await showDialog(
                    context: context,
                    builder: (context) => finishedChallengeDialog(),
                  );

                  if (!mounted) return;

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
                              onPressed: () async {

                                Map<String, dynamic> data = await helpMethodsHttp.endStartedChallenge(challengeId);
                                String status = data['status'];

                                if (status == 'NOT_STARTED') {
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
                                    builder: (context) => const AlertDialog(
                                      content: Text('Ojdå, något gick fel. Försök igen'),
                                    ),
                                  );
                                }
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
      actionsAlignment: MainAxisAlignment.center,
      title: const Text('Vad tog du en bild på?', textAlign: TextAlign.center,),
      content: const Text("Välj kategori för identifieringen.", textAlign: TextAlign.center,),

      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(110, 50),
          ),
          onPressed: () {
            Navigator.pop(context, "PLANT");
          },
          child: const Text("Växt"),
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
  }

  Widget dialogButton(String text, String value) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context, value);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(120, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Future<bool> uploadPicture(File? file, String type) async {
    try {
      helpMethodsUploadPicture = UploadPicture(jwtToken: await token);
        Map<String, dynamic>? response = await helpMethodsUploadPicture.sendPictureToBackend(file, type, 'CHALLENGE', challengeId);

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
            builder: (context) => errorMessageUploadPicture(response?['rejectionReason']),
          );
          return false;
        }

    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => errorMessageUploadPicture(null),
      );
      return false;
    }
  }

  AlertDialog errorMessageUploadPicture(String? rejectionReason) {
    String errorMessage = '';

    if (rejectionReason == null) {
      errorMessage = 'Ojdå, bilden kunde inte sparas. Vill du testa igen?';
    } else if (rejectionReason == 'LOW_CONFIDENCE'){
      errorMessage = 'Bilden var lite suddig. Testa ta en ny bild!';
    } else if (rejectionReason == 'CHALLENGE_NO_MATCH') {
      errorMessage = 'Bilden passar inte uppgiften. Titta på uppgiften och försök igen!';
    } else if (rejectionReason == 'UNKNOWN_CATEGORY') {
      errorMessage = 'Det gick inte att se vad som är på bilden. Testa ta en ny bild!';
    } else {
      errorMessage = 'Ojdå, bilden kunde inte sparas. Vill du testa igen?';
    }

    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      content: Text(
        errorMessage,
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

  AlertDialog finishedChallengeDialog() {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      content: const Text(
        'Bra jobbat! Dina poäng har nu sparats',
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
  }

}
