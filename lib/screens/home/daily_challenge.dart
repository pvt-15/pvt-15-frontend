import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../widgets/custom_navigation_bar.dart';
import '../../services/session_storage.dart';
import '../../services/camera_service.dart';
import '../../services/upload_picture.dart';
import 'dart:convert';
import '../bingo/http_help_methods.dart';

// --- Modeller ---

class ChallengeTask {
  final String taskText;
  final String taskType;
  final int requiredCount;

  ChallengeTask({
    required this.taskText,
    required this.taskType,
    required this.requiredCount,
  });

  factory ChallengeTask.fromJson(Map<String, dynamic> json) {
    return ChallengeTask(
      taskText: json['taskText'] ?? '',
      taskType: json['taskType'] ?? '',
      requiredCount: json['requiredCount'] ?? 1,
    );
  }
}

class DailyChallengeModel {
  final int id;
  final String title;
  final String description;
  final String difficulty;
  final int rewardPoints;
  final List<ChallengeTask> tasks;
  final String? category;

  DailyChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.rewardPoints,
    required this.tasks,
    this.category,
  });

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Daglig utmaning',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? 'EASY',
      rewardPoints: json['rewardPoints'] ?? 0,
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map((t) => ChallengeTask.fromJson(t as Map<String, dynamic>))
          .toList(),
      category: json['category'] as String?,
    );
  }
}

// TODO ändra bild och fixa pratbubbla.
// TODO dubbelkolla att man inte kan få en massa poäng samma dag- att poäng registreras
// TODO kolla om man kan få nästa fråga

// --- Widget ---

class DailyChallenge extends StatefulWidget {
  final String gameTitle;

  const DailyChallenge({super.key, required this.gameTitle});

  @override
  State<DailyChallenge> createState() => _DailyChallengeState();
}

class _DailyChallengeState extends State<DailyChallenge> {
  final SessionStorage _sessionStorage = SessionStorage();

  DailyChallengeModel? _challenge;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDailyChallenge();
  }

  Future<void> _fetchDailyChallenge() async {
    print(">>> _fetchDailyChallenge anropad");
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _sessionStorage.getToken();
      final httpHelper = HttpHelpMethods(jwtToken: token);

      // Bugfix: getAllChallenges returnerar List<dynamic>
      final List<dynamic> challenges = await httpHelper.getAllChallenges();

      final dailyChallenge = challenges.firstWhere(
            (c) => c['type'] == 'DAILY',
        orElse: () => null,
      );

      if (dailyChallenge == null) {
        setState(() {
          _errorMessage = 'Ingen daglig utmaning hittades';
          _isLoading = false;
        });
        return;
      }

      final int challengeId = dailyChallenge['id'];

      final Map<String, dynamic> details =
      await httpHelper.getStartedQuestion(challengeId);

      setState(() {
        _challenge = DailyChallengeModel.fromJson(details);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        _errorMessage = 'Något gick fel. Kolla din internetanslutning.';
        _isLoading = false;
      });
    }
  }

  // Visar pop-upen med två steg: ta bild → bekräfta
  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ChallengeCompletePopUp(
        challenge: _challenge!,
        sessionStorage: _sessionStorage,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDailyChallenge,
              child: const Text('Försök igen'),
            ),
          ],
        ),
      );
    }

    if (_challenge == null) {
      return const Center(child: Text('Du har redan gjort dagens utmaning!'));
    }

    final taskText = _challenge!.tasks.isNotEmpty
        ? _challenge!.tasks.first.taskText
        : _challenge!.description;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Troll och pratbubbla
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xff84c06c),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        "Välkommen till dagens utmaning!\n\n"
                            "Här får du varje dag en ny utmaning att göra. När du är klar klicka på knappen!",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const Positioned(
                      right: -35,
                      top: 26,
                      child: Icon(
                        Icons.arrow_right,
                        size: 60,
                        color: Color(0xff84c06c),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Image.asset(
                'assets/maskot_skogstroll.png',
                width: 120,
                height: 120,
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Gul utmaningsruta
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xfff8ed76),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.emoji_events, size: 60),
                const SizedBox(height: 12),
                Text(
                  _challenge!.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'För denna uppgift får du 25 poäng!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    taskText,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showCompleteDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffb1067e),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "KLAR!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBEDBB2),
        elevation: 0,
        title: Text(widget.gameTitle),
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: -1),
    );
  }
}

// Pop-up när det är klart

class _ChallengeCompletePopUp extends StatefulWidget {
  final DailyChallengeModel challenge;
  final SessionStorage sessionStorage;

  const _ChallengeCompletePopUp({
    required this.challenge,
    required this.sessionStorage,
  });

  @override
  State<_ChallengeCompletePopUp> createState() =>
      _ChallengeCompletePopUpState();
}

class _ChallengeCompletePopUpState extends State<_ChallengeCompletePopUp> {
  File? _takenImage;
  bool _isUploading = false;
  bool _isDone = false;
  String? _uploadError;

  Future<void> _takePicture() async {
    final File? file = await CameraService.takePicture();
    if (file != null) {
      setState(() {
        _takenImage = file;
        _uploadError = null;
      });
    }
  }

  Future<void> _confirmAndUpload() async {
    if (_takenImage == null) return;

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      final token = await widget.sessionStorage.getToken();

      // Steg 0: starta challenge först
      final startResponse = await http.post(
        Uri.parse(
          'https://group-6-15.pvt.dsv.su.se/challenges/${widget.challenge.id}/start',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint('>>> start status: ${startResponse.statusCode}');
      debugPrint('>>> start body: ${startResponse.body}');

      final uploader = UploadPicture(jwtToken: token);
      final uploadResult = await uploader.uploadPicture(_takenImage!);

      if (!mounted) return;

      if (uploadResult == null || uploadResult['objectKey'] == null) {
        setState(() {
          _uploadError = 'Uppladdningen misslyckades. Försök igen.';
          _isUploading = false;
        });
        return;
      }

      final String objectKey = uploadResult['objectKey'];

      final response = await http.post(
        Uri.parse(
          'https://group-6-15.pvt.dsv.su.se/challenges/${widget.challenge.id}/daily-picture',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'imageObjectKey': objectKey,
          'taskId': null,
          //'imageUrl': uploadResult['imageUrl'],
        }),
      );

      debugPrint('>>> daily-picture status: ${response.statusCode}');
      debugPrint('>>> daily-picture body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isDone = true;
          _isUploading = false;
        });
      } else {
        setState(() {
          _uploadError = 'Fel från server: ${response.statusCode}';
          _isUploading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploadError = 'Något gick fel: $e';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xfff8ed76),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        _isDone ? 'Bra jobbat!' : 'Ta en bild',
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      content: _isDone ? _buildDoneContent() : _buildCameraContent(),
      actions: [
        if (_isDone)
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffb1067e),
              ),
              child: Text(
                'Tack!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          )
        else if (_takenImage != null && !_isUploading)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: _takePicture,
                    child: const Text('Ta om'),
                  ),
                  ElevatedButton(
                    onPressed: _confirmAndUpload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffb1067e),
                    ),
                    child: Text(
                      'Skicka in',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ],
          )
        else if (!_isUploading)
            Center(
              child: ElevatedButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Öppna kamera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffb1067e),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildCameraContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Ta en bild som bevis att du klarat utmaningen!',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Förhandsvisning av tagen bild
        if (_takenImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _takenImage!,
              height: 180,
              width: 240,        // fast bredd istället för double.infinity
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.camera_alt, size: 50, color: Colors.grey),
            ),
          ),

        if (_isUploading) ...[
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
          const SizedBox(height: 8),
          const Text('Laddar upp...'),
        ],

        if (_uploadError != null) ...[
          const SizedBox(height: 12),
          Text(
            _uploadError!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildDoneContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_takenImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _takenImage!,
              height: 160,
              width: 240,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Du klarade dagens utmaning och fick ${widget.challenge.rewardPoints} poäng!',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /*
  // Från Maja bingo att avluta challange
  Future<void> _endChallenge() async {
    try {
      final token = await widget.sessionStorage.getToken();
      debugPrint('>>> Försöker avsluta challenge id: ${widget.challenge.id}');

      final response = await http.delete(
        Uri.parse(
          'https://group-6-15.pvt.dsv.su.se/challenges/${widget.challenge.id}/progress',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint('>>> endChallenge status: ${response.statusCode}');
      debugPrint('>>> endChallenge body: ${response.body}');
    } catch (e) {
      debugPrint('Något gick fel vid avslutande av utmaning: $e');
    }
  }*/
}
