import 'package:Skogsjakten/screens/identify_species/identify_camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/custom_navigation_bar.dart';
import '../services/session_storage.dart';
import 'home/daily_challenge.dart';
import 'home/home_library.dart';
import 'home/species_profile.dart';
import 'home/quiz.dart';
import 'home/choose_bingo_game.dart';
import 'home/skattjakt.dart';
import 'choose_difficulty.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionStorage _sessionStorage = SessionStorage();

  String _username = '';
  int _points = 0;
  String _level = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = await _sessionStorage.getUserAndToken();

      if (session == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Ingen inloggning hittades';
            _isLoading = false;
          });
        }
        return;
      }

      // Set username from session
      if (mounted) {
        setState(() {
          _username = session.user.username;
        });
      }

      // Fetch user data from backend (same as profile.dart)
      final response = await http.get(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/auth-service/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.token}',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _points = data['totalPoints'] ?? 0;
          _level = data['level'] ?? '';
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Token expired, clear session
        await _sessionStorage.clear();
        if (mounted) {
          setState(() {
            _errorMessage = 'Sessionen har gått ut. Vänligen logga in igen.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Kunde inte ladda användardata';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Nätverksfel: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Calculate progress percentage for level (same as profile.dart)
  double _getProgressValue() {
    if (_points == 0) return 0.0;
    // Assuming each level requires 300 points (as shown in profile.dart)
    return (_points % 300) / 300;
  }

  // Method to handle navigation and refresh
  Future<void> _navigateAndRefresh(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    // Refresh data after returning
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> gameItems = [
      {
        'name': 'Identifiera art',
        'page': const IdentifyCamera(),
        'image': 'assets/maskot_kamera.png',
      },
      {
        'name': 'Bingo',
        'page': const ChooseBingoGame(),
        'image': 'assets/maskot_bingo.png',
      },
      {
        'name': 'Skattjakt',
        'page': null,
        'image': 'assets/maskot_skattjakt.png',
      },
      {
        'name': 'Quiz',
        'page': Container(),
        'image': 'assets/maskot_quiz.png',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Skogsjakten'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // User info card with dynamic data
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xfff8ed76),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF84C06C),
                  ),
                )
                    : _errorMessage != null
                    ? Column(
                  children: [
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadUserData,
                      child: const Text('Försök igen'),
                    ),
                  ],
                )
                    : Column(
                  children: [
                    Text(
                      _username.isEmpty ? 'Skogsjägare' : _username,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    // Poäng ovanför progress bar
                    Text(
                      '$_points poäng',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      width: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDE75BF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: _getProgressValue(),
                          backgroundColor: Colors.transparent,
                          color: const Color(0xFFC0008B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nivå: $_level',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              _wideMenuCard(
                context: context,
                title: 'Dagens utmaning',
                page: const DailyChallenge(gameTitle: 'Dagens utmaning',),
              ),

              const SizedBox(height: 34),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gameItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 26,
                  crossAxisSpacing: 26,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return _squareMenuCard(
                    context: context,
                    title: gameItems[index]['name'],
                    page: gameItems[index]['page'],
                    imagePath: gameItems[index]['image'],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: 1),
    );
  }

  Widget _wideMenuCard({
    required BuildContext context,
    required String title,
    required Widget page,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 110,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xfff8ed76),
          foregroundColor: Colors.black,
          elevation: 4,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () async {
          // QUIZ
          if (title == 'Quiz') {
            final Difficulty? result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChooseDifficulty(
                  gameTitle: 'Quiz',
                ),
              ),
            );

            if (result != null && context.mounted) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Quiz(
                    difficulty: result,
                  ),
                ),
              );
              // Refresh user data after quiz (points may have changed)
              await _loadUserData();
            }
            return;
          }

          // SKATTJAKT
          if (title == 'Skattjakt') {
            final Difficulty? result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChooseDifficulty(
                  gameTitle: 'Skattjakt',
                ),
              ),
            );

            if (result != null && context.mounted) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Skattjakt(difficulty: result),
                ),
              );
              // Refresh user data after skattjakt
              await _loadUserData();
            }
            return;
          }

          // ALLT ANNAT (Bingo, Identifiera art, etc.)
          await _navigateAndRefresh(page);
        },
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _squareMenuCard({
    required BuildContext context,
    required String title,
    required Widget? page,
    required String imagePath,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xfff8ed76),
        foregroundColor: Colors.black,
        elevation: 4,
        shadowColor: Colors.black38,
        padding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      onPressed: () async {
        // QUIZ (hanteras för båda vyerna eftersom quiz finns i båda)
        if (title == 'Quiz') {
          final Difficulty? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChooseDifficulty(
                gameTitle: 'Quiz',
              ),
            ),
          );

          if (result != null && context.mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Quiz(difficulty: result),
              ),
            );
            // Refresh user data after quiz
            await _loadUserData();
          }
          return;
        }

        // SKATTJAKT
        if (title == 'Skattjakt') {
          final Difficulty? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChooseDifficulty(
                gameTitle: 'Skattjakt',
              ),
            ),
          );

          if (result != null && context.mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Skattjakt(difficulty: result),
              ),
            );
            // Refresh user data after skattjakt
            await _loadUserData();
          }
          return;
        }

        // ALLA ANDRA (inklusive Bingo och Identifiera art)
        if (page != null) {
          await _navigateAndRefresh(page);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}