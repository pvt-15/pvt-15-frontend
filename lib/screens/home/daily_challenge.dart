import 'package:flutter/material.dart';
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

  DailyChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.rewardPoints,
    required this.tasks,
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
    );
  }
}

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _sessionStorage.getToken();
      final httpHelper = HttpHelpMethods(jwtToken: token);

      // Bugfix: getAllChallenges returnerar List<dynamic>, inte String
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
      builder: (context) => _ChallengeCompleteDialog(
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
                  'För denna uppgift får du ${_challenge!.rewardPoints} poäng!',
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

// --- Pop-up med bildsteg ---

class _ChallengeCompleteDialog extends StatefulWidget {
  final DailyChallengeModel challenge;
  final SessionStorage sessionStorage;

  const _ChallengeCompleteDialog({
    required this.challenge,
    required this.sessionStorage,
  });

  @override
  State<_ChallengeCompleteDialog> createState() =>
      _ChallengeCompleteDialogState();
}

class _ChallengeCompleteDialogState extends State<_ChallengeCompleteDialog> {
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
      final uploader = UploadPicture(jwtToken: token);

      // Ladda upp till GCS och skicka till backend med UNKNOWN-label
      // pictureMode=CHALLENGE och challengeId kopplar bilden till utmaningen
      final result = await uploader.sendPictureToBackend(
        _takenImage,
        'UNKNOWN',         // targetType – sparas med label UNKNOWN
        'CHALLENGE',       // pictureMode
        widget.challenge.id,
      );

      if (!mounted) return;

      if (result != null) {
        setState(() {
          _isDone = true;
          _isUploading = false;
        });
      } else {
        setState(() {
          _uploadError = 'Uppladdningen misslyckades. Försök igen.';
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
              width: double.infinity,
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
              width: double.infinity,
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
}

/*
import 'package:flutter/material.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../../services/session_storage.dart';
import 'dart:convert';
import '../bingo/http_help_methods.dart';
import 'package:http/http.dart' as http;

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
  final String title;
  final String description;
  final String difficulty;
  final int rewardPoints;
  final List<ChallengeTask> tasks;

  DailyChallengeModel({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.rewardPoints,
    required this.tasks,
  });

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeModel(
      title: json['title'] ?? 'Daglig utmaning',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? 'EASY',
      rewardPoints: json['rewardPoints'] ?? 0,
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map((t) => ChallengeTask.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _sessionStorage.getToken();
      final httpHelper = HttpHelpMethods(jwtToken: token);

      // Steg 1: Hämta lista och hitta DAILY
      final String allChallengesBody = await httpHelper.getAllChallenges();
      final List<dynamic> challenges = jsonDecode(allChallengesBody);

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

      // Steg 2: Hämta detaljer med tasks
      final Map<String, dynamic> details = await httpHelper.getStartedQuestion(challengeId);

      setState(() {
        _challenge = DailyChallengeModel.fromJson(details);
        _isLoading = false;
      });

    } catch (e) {
      print('Error: $e');
      setState(() {
        _errorMessage = 'Något gick fel. Kolla din internetanslutning.';
        _isLoading = false;
      });
    }
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

    // Hämta första uppgiftens text, eller faller tillbaka på description
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

                // Titel från backend
                Text(
                  _challenge!.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                // Belöning
                Text(
                  'För denna uppgift får du ${_challenge!.rewardPoints} poäng!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 20),

                // Uppgiftens text från backend
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

                // Klar-knapp
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: const Color(0xfff8ed76),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            title: Text(
                              "Bra jobbat!",
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            content: Text(
                              "Du klarade dagens utmaning och fick ${_challenge!.rewardPoints} poäng!",
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            actions: [
                              Center(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffb1067e),
                                  ),
                                  child: Text(
                                    "Tack!",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
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

/*import 'package:flutter/material.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../../services/session_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DailyChallengeModel {
  final int id;
  final String title;
  final String description;

  DailyChallengeModel({
    required this.id,
    required this.title,
    required this.description,
  });

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }
}

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {

      // FEJKAD DATA JUST NU


      await Future.delayed(const Duration(seconds: 1));

      /*final fakeChallenge = DailyChallengeModel(
        id: 1,
        title: 'Dagens utmaning',
        description: 'Måla en sten så det blir en nyckelpiga!',
      );

      setState(() {
        _challenge = fakeChallenge;
        _isLoading = false;
      });*/

      // SENARE BACKEND

      /*
      final token = await _sessionStorage.getToken();

      final response = await http.post(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/challenges/start '),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _challenge = DailyChallengeModel.fromJson(data);
          _isLoading = false;
        });
      }
      */
    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte hämta utmaningen';
        _isLoading = false;
      });
    }
  }

  void _showCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xfff8ed76),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Bra jobbat!', textAlign: TextAlign.center),
          content: const Text(
            'Du klarade dagens utmaning!',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff84c06c),
                ),
                child: const Text('Tack!'),
              ),
            ),
          ],
        );
      },
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          /// troll och pratbubbla
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
                        "Välkommen till dagens utmaning!\n"
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

          // GUL UTMANINGSRUTA
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
                const SizedBox(height: 18),

                /*
                /// TITEL
                const Text(
                  "Dagens utmaning",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),*/

                const SizedBox(height: 20),

                // SJÄLVA UTMANINGEN
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "Måla en sten så det blir en nyckelpiga!",
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 28),

                // klar knapp
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: const Color(0xfff8ed76),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),

                            title: Text(
                              "Bra jobbat!",
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),

                            content: Text(
                              "Du klarade dagens utmaning!",
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),

                            actions: [
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffb1067e),
                                  ),
                                  child: Text(
                                      "Tack!",
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },

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

 */
 
 */
