// screens/home/skattjakt.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/camera_service.dart';
import '../../services/session_storage.dart';
import '../../services/treasure_hunt_service.dart';
import '../../models/treasure_hunt_models.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../home.dart';

class Skattjakt extends StatefulWidget {
  final String difficulty;
  final int? challengeId;

  const Skattjakt({
    super.key,
    required this.difficulty,
    this.challengeId,
  });

  @override
  State<Skattjakt> createState() => _SkattjaktState();
}

class _SkattjaktState extends State<Skattjakt> {
  final SessionStorage _sessionStorage = SessionStorage();

  bool _isLoading = true;
  String? _errorMessage;

  List<TreasureHuntTask> _pendingTasks = [];
  TreasureHuntTask? _currentTask;

  int _totalTasksCount = 0;
  int _completedCount = 0;
  bool _allCompleted = false;

  File? _currentImage;
  bool _isVerifying = false;
  bool _isSubmitting = false;
  String? _verificationErrorMessage;

  late TreasureHuntService _treasureHuntService;

  @override
  void initState() {
    super.initState();
    _initializeTasks();
  }

  Future<void> _initializeTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _sessionStorage.getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Ingen inloggning hittades';
          _isLoading = false;
        });
        return;
      }

      _treasureHuntService = TreasureHuntService(jwtToken: token);

      final allTasks = await _treasureHuntService.getAllTasksByDifficulty(
          widget.difficulty
      );

      _totalTasksCount = allTasks.length;

      // Hämta slutförda task-id:n från backend i stället för SharedPreferences.
      // user_challenge_task_progress uppdateras automatiskt av backend när en
      // CHALLENGE-bild godkänns mot rätt challengeId.
      final savedCompletedTaskIds = await _treasureHuntService.getCompletedTaskIds();

      for (var task in allTasks) {
        if (savedCompletedTaskIds.contains(task.id)) {
          task.isCompleted = true;
        }
      }

      _completedCount = allTasks.where((t) => t.isCompleted).length;
      final incompleteTasks = allTasks.where((t) => !t.isCompleted).toList();

      if (incompleteTasks.isEmpty) {
        setState(() {
          _allCompleted = true;
          _currentTask = null;
          _pendingTasks = [];
          _isLoading = false;
        });
      } else {
        final shuffledTasks = List<TreasureHuntTask>.from(incompleteTasks);
        shuffledTasks.shuffle();

        setState(() {
          _pendingTasks = shuffledTasks;
          _currentTask = _pendingTasks.isNotEmpty ? _pendingTasks.removeAt(0) : null;
          _isLoading = false;
        });
      }

    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte ladda skattjakt: $e';
        _isLoading = false;
      });
    }
  }

  Future<Set<int>> _loadCompletedTasks() async {
    // Behållen som tunn wrapper för att inte sprida ändringar i andra
    // metoder. Returnerar nu progress från backend i stället för
    // SharedPreferences.
    return _treasureHuntService.getCompletedTaskIds();
  }

  void _skipCurrentTask() {
    if (_currentTask == null) return;

    setState(() {
      if (_pendingTasks.isEmpty && _currentTask != null) {
        _pendingTasks.add(_currentTask!);
        _currentTask = _pendingTasks.removeAt(0);
      } else {
        _pendingTasks.add(_currentTask!);
        _currentTask = _pendingTasks.removeAt(0);
      }
      _currentImage = null;
      _verificationErrorMessage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Uppgift hoppades över. Du får den igen senare!',
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _takePictureAndVerify() async {
    if (_isVerifying || _isSubmitting) return;
    if (_currentTask == null) return;

    setState(() {
      _isSubmitting = true;
      _verificationErrorMessage = null;
    });

    final File? imageFile = await CameraService.takePicture();

    if (!mounted) {
      setState(() => _isSubmitting = false);
      return;
    }

    if (imageFile == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    setState(() {
      _currentImage = imageFile;
      _isVerifying = true;
      _isSubmitting = false;
    });

    final result = await _treasureHuntService.takeAndVerifyPicture(
      imageFile: imageFile,
      targetType: _currentTask!.getTargetType(),
      challengeId: _currentTask!.challengeId,
    );

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

    if (result.success) {
      // Backend har redan uppdaterat user_challenge_task_progress till
      // COMPLETED via POST /pictures med pictureMode=CHALLENGE. Ingen
      // lokal markering behövs.
      _handleSuccessfulVerification();
    } else {
      setState(() {
        _verificationErrorMessage = result.errorMessage ?? 'Bilden kunde inte verifieras. Försök igen!';
        _currentImage = null;
      });
    }
  }

  void _handleSuccessfulVerification() async {
    setState(() {
      _completedCount++;
      if (_currentTask != null) {
        _currentTask!.isCompleted = true;
      }
    });

    _showSuccessDialog();
    await _loadNextTask();
  }

  Future<void> _loadNextTask() async {
    setState(() {
      _isLoading = true;
      _currentImage = null;
      _verificationErrorMessage = null;
    });

    try {
      if (_pendingTasks.isEmpty) {
        final allTasks = await _treasureHuntService.getAllTasksByDifficulty(
            widget.difficulty
        );

        final completedIds = await _loadCompletedTasks();
        final incompleteTasks = allTasks.where((t) => !completedIds.contains(t.id)).toList();

        if (incompleteTasks.isEmpty) {
          setState(() {
            _allCompleted = true;
            _currentTask = null;
            _isLoading = false;
          });
        } else {
          final shuffledTasks = List<TreasureHuntTask>.from(incompleteTasks);
          shuffledTasks.shuffle();

          setState(() {
            _pendingTasks = shuffledTasks;
            _currentTask = _pendingTasks.removeAt(0);
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _currentTask = _pendingTasks.removeAt(0);
          _isLoading = false;
        });
      }

    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte ladda nästa uppgift: $e';
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    final completedTask = _currentTask;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Bra jobbat!',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              completedTask?.getDisplayText() ?? 'Uppgift slutförd!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF84C06C).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${completedTask?.rewardPoints ?? 0} poäng',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentImage = null;
                _verificationErrorMessage = null;
              });
              if (_allCompleted) {
                _showCompletionDialog();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF84C06C),
              minimumSize: const Size(120, 45),
            ),
            child: const Text(
              'Fortsätt',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Grattis!',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: 60,
              color: const Color(0xFF84C06C),
            ),
            const SizedBox(height: 16),
            Text(
              'Du har slutfört alla ${_getDifficultyName(widget.difficulty)}-uppgifter!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '$_completedCount/$_totalTasksCount uppgifter slutförda',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Kom tillbaka senare för fler uppgifter!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF84C06C),
              minimumSize: const Size(140, 45),
            ),
            child: const Text(
              'Tillbaka',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAlreadyFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Redan hittad',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Du har redan hittat denna typ!\nFörsök hitta något annat.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentImage = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF84C06C),
            ),
            child: const Text('Okej'),
          ),
        ],
      ),
    );
  }

  void _showConfirmExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Avsluta skattjakt?',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Dina framsteg sparas automatiskt.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Avbryt'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF84C06C),
            ),
            child: const Text('Avsluta'),
          ),
        ],
      ),
    );
  }

  String _getDifficultyName(String difficulty) {
    switch (difficulty) {
      case 'EASY': return 'lätta';
      case 'MEDIUM': return 'medelsvåra';
      case 'HARD': return 'svåra';
      default: return difficulty.toLowerCase();
    }
  }

  Widget _buildPlaceholder() {
    if (_currentTask == null) {
      return const Center(
        child: Text('Ingen uppgift tillgänglig'),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(_getIconForTask(_currentTask!), size: 80, color: Colors.black),
        const SizedBox(height: 10),
        if (_currentTask!.helpText != null && _currentTask!.helpText!.isNotEmpty && _currentTask!.helpText != 'null')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _currentTask!.helpText!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          )
        else
          Text(
            'Ta en bild på det du ser!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        if (_verificationErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              _verificationErrorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  IconData _getIconForTask(TreasureHuntTask task) {
    final category = task.requiredCategory?.toLowerCase() ?? '';
    switch (category) {
      case 'tree': return Icons.park;
      case 'animal': return Icons.pets;
      case 'bird': return Icons.flutter_dash;
      case 'flower': return Icons.local_florist;
      case 'plant': return Icons.grass;
      case 'insect': return Icons.bug_report;
      default: return Icons.photo_camera;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFBEDBB2),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFBEDBB2),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Skattjakt'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeTasks,
                child: const Text('Försök igen'),
              ),
            ],
          ),
        ),
      );
    }

    if (_allCompleted) {
      return Scaffold(
        backgroundColor: const Color(0xFFBEDBB2),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Skattjakt'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.celebration,
                size: 80,
                color: const Color(0xFF84C06C),
              ),
              const SizedBox(height: 24),
              Text(
                'Grattis!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Du har slutfört alla ${_getDifficultyName(widget.difficulty)}-uppgifter!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Kom tillbaka senare för fler uppgifter.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tillbaka'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomNavigationBar(selectedIndex: -1),
      );
    }

    if (_currentTask == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFBEDBB2),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Skattjakt'),
        ),
        body: const Center(
          child: Text('Ingen uppgift tillgänglig'),
        ),
      );
    }

    final currentTask = _currentTask!;
    final referenceImageUrl = currentTask.getFullReferenceImageUrl();

    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        leading: IconButton(
          onPressed: _showConfirmExitDialog,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Skattjakt'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  if (currentTask.requiredCount > 1)
                    Text(
                      '${currentTask.completedCount}/${currentTask.requiredCount}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  Text(
                    currentTask.taskText.isNotEmpty && currentTask.taskText != 'null'
                        ? currentTask.taskText
                        : currentTask.getDisplayText(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xfff8ed76),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_currentImage == null && referenceImageUrl != null && referenceImageUrl.isNotEmpty)
                          Image.network(
                            referenceImageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                          )
                        else if (_currentImage == null)
                          _buildPlaceholder()
                        else
                          Image.file(
                            _currentImage!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        if (_isVerifying)
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!_isVerifying && !_allCompleted)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton.icon(
                  onPressed: _takePictureAndVerify,
                  icon: const Icon(Icons.camera_alt, size: 30),
                  label: const Text('Öppna Kameran'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8ED76),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(200, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    textStyle: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            if (!_isVerifying && !_allCompleted && _pendingTasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextButton(
                  onPressed: _skipCurrentTask,
                  child: const Text('Hoppa över ->'),
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