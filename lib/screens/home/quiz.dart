import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/custom_navigation_bar.dart';
import '../../services/token_storage.dart';
import '../home.dart';
import '../choose_difficulty.dart';

// ─── Datamodeller ─────────────────────────────────────────────────────────────

class QuizOption {
  final int id;
  final String text;
  const QuizOption({required this.id, required this.text});

  factory QuizOption.fromJson(Map<String, dynamic> j) =>
      QuizOption(id: j['id'] as int, text: j['optionText'] as String);
}

class QuizQuestion {
  final int id;
  final String text;
  final List<QuizOption> options;
  final int? correctOptionId;
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    this.correctOptionId,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> j) => QuizQuestion(
    id: j['id'] as int,
    text: j['questionText'] as String,
    options: (j['options'] as List)
        .map((o) => QuizOption.fromJson(o as Map<String, dynamic>))
        .toList(),
    correctOptionId: j['correctOptionId'] as int?,
  );
}

class QuizResult {
  final int correct;
  final int total;
  final int pointsAwarded;
  final List<QuizQuestion> questions;
  const QuizResult({
    required this.correct,
    required this.total,
    required this.pointsAwarded,
    required this.questions,
  });
}

// ─── Quiz-widget ───────────────────────────────────────────────────────────────

class Quiz extends StatefulWidget {
  final Difficulty difficulty;
  final int questionCount;

  const Quiz({
    super.key,
    required this.difficulty,
    this.questionCount = 5,
  });

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  static const String _baseUrl = 'https://group-6-15.pvt.dsv.su.se';

  bool _loading = true;
  String? _error;
  String? _jwtToken;

  int _attemptId = -1;
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  final Map<int, int> _answers = {};

  bool _submitting = false;
  QuizResult? _result;

  // ── Difficulty → API-sträng ──
  String get _difficultyParam {
    switch (widget.difficulty) {
      case Difficulty.easy:
        return 'EASY';
      case Difficulty.medium:
        return 'MEDIUM';
      case Difficulty.hard:
        return 'HARD';
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  // Hämta token först, sedan frågor
  Future<void> _init() async {
    final token = await TokenStorage().getToken();
    setState(() => _jwtToken = token);
    await _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse(
        '$_baseUrl/quiz?difficulty=$_difficultyParam&count=${widget.questionCount}',
      );

      final headers = <String, String>{};
      if (_jwtToken != null) {
        headers['Authorization'] = 'Bearer $_jwtToken';
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _attemptId = body['attemptId'] as int;
          _questions = (body['questions'] as List)
              .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
              .toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Kunde inte hämta frågor (${response.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Nätverksfel: $e';
        _loading = false;
      });
    }
  }

  Future<void> _submitAnswers() async {
    setState(() => _submitting = true);
    try {
      final uri = Uri.parse('$_baseUrl/quiz/submit');
      final response = await http.post(
        uri,
        headers: {
          if (_jwtToken != null) 'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'attemptId': _attemptId,
          'answers': _answers.entries
              .map((e) => {'questionId': e.key, 'selectedOptionId': e.value})
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _result = QuizResult(
            correct: body['score'] as int,
            total: body['totalQuestions'] as int,
            pointsAwarded: body['pointsAwarded'] as int,
            questions: _questions,
          );
          _submitting = false;
        });
      } else {
        setState(() => _submitting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fel vid inlämning (${response.statusCode})')),
          );
        }
      }
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nätverksfel: $e')),
        );
      }
    }
  }

  bool get _allAnswered =>
      _questions.isNotEmpty &&
          _questions.every((q) => _answers.containsKey(q.id));

  void _selectAnswer(int questionId, int optionId) =>
      setState(() => _answers[questionId] = optionId);

  void _goTo(int index) =>
      setState(() => _currentIndex = index.clamp(0, _questions.length - 1));

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading();
    if (_error != null) return _buildError();
    if (_result != null) return _buildResult();
    return _buildQuiz();
  }

  Widget _buildLoading() => Scaffold(
    backgroundColor: const Color(0xFFBEDBB2),
    body: const Center(
      child: CircularProgressIndicator(color: Color(0xFF000000)),
    ),
  );

  Widget _buildError() => Scaffold(
    backgroundColor: const Color(0xFFBEDBB2),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Color(0xFF000000)),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _init,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEE7A)),
              child: const Text('Försök igen'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildQuiz() {
    final question = _questions[_currentIndex];
    final selectedOptionId = _answers[question.id];
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == _questions.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBEDBB2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF000000)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_answers.length}/${_questions.length} besvarade',
                style: const TextStyle(
                    color: Color(0xFF000000), fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Text(
                'Fråga ${_currentIndex + 1} av ${_questions.length}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              _buildProgressDots(),
              const SizedBox(height: 20),

              // Frågetext
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEE7A),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 3))
                  ],
                ),
                child: Text(
                  question.text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
              ),
              const SizedBox(height: 30),

              // Svarsalternativ
              ...question.options.map((option) {
                final isSelected = selectedOptionId == option.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: () => _selectAnswer(question.id, option.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFF84C06C)
                            : const Color(0xFFFFEE7A),
                        foregroundColor: const Color(0xFF000000),
                        elevation: isSelected ? 2 : 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: isSelected
                              ? const BorderSide(color: Color(0xFF000000), width: 2)
                              : BorderSide.none,
                        ),
                      ),
                      child: Text(
                        option.text,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),

              // Navigeringspilarna
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: isFirst ? null : () => _goTo(_currentIndex - 1),
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 40,
                      color: isFirst ? Colors.black26 : const Color(0xFF000000),
                    ),
                  ),
                  if (isLast)
                    ElevatedButton(
                      onPressed: _allAnswered && !_submitting ? _submitAnswers : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        _allAnswered ? const Color(0xFFC0008F) : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _submitting
                          ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                          : const Text('Lämna in',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  IconButton(
                    onPressed: isLast ? null : () => _goTo(_currentIndex + 1),
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 40,
                      color: isLast ? Colors.black26 : const Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: -1),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_questions.length, (i) {
        final answered = _answers.containsKey(_questions[i].id);
        final isCurrent = i == _currentIndex;
        return GestureDetector(
          onTap: () => _goTo(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isCurrent ? 20 : 12,
            height: 12,
            decoration: BoxDecoration(
              color: isCurrent
                  ? const Color(0xFFB1067E) // aktiv fråga
                  : answered
                  ? const Color(0xFFB1067E) // besvarad fråga
                  : const Color(0xFF84C06C),
              borderRadius: BorderRadius.circular(6), // nästa fråga
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResult() {
    final result = _result!;
    final pct = result.total > 0 ? result.correct / result.total : 0.0;
    final text = pct == 1.0
        ? 'Toppen! Du är en riktig skogsexpert!'
        : pct >= 0.6
        ? 'Riktigt bra jobbat!'
        : 'Bra jobbat! Forstätt öva så blir du bättre och bättre!';

    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBEDBB2),
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Color(0xFF000000)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Resultatkort
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEE7A),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 4))
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/mascot_happy.png',
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${result.correct}/${result.total} rätt!',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontSize: 36),
                    ),
                    const SizedBox(height: 6),
                    Text(text,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: const Color(0xFF000000))),
                    const SizedBox(height: 10),
                    Text(
                      '+${result.pointsAwarded} poäng!',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: const Color(0xFFC0008F), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text('Ditt resultat',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 14),

              ...result.questions.asMap().entries.map((entry) {
                final i = entry.key;
                final q = entry.value;
                final userOptionId = _answers[q.id];
                // Backend returnerar inte correctOptionId – vi vet ej vilket som är rätt
                final hasCorrectInfo = q.correctOptionId != null;
                final isCorrect = hasCorrectInfo && userOptionId == q.correctOptionId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0x6484c06c),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasCorrectInfo
                          ? (isCorrect ? const Color(0xFFFFFFFF) : const Color(0xFFE53935))
                          : Colors.black12,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (hasCorrectInfo)
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFFE53935),
                            )
                          else
                            const Icon(Icons.help_outline, color: Colors.black38),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Fråga ${i + 1}: ${q.text}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...q.options.map((opt) {
                        final isRight = hasCorrectInfo && opt.id == q.correctOptionId;
                        final isUserPick = opt.id == userOptionId;
                        Color? bg;
                        if (isRight) bg = const Color(0xFF84C06C).withOpacity(0.25);
                        if (isUserPick && !isRight)
                          bg = const Color(0xFFE53935).withOpacity(0.15);
                        if (isUserPick && !hasCorrectInfo)
                          bg = const Color(0xFFFFEE7A).withOpacity(0.6);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: bg ?? Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isRight
                                  ? const Color(0xFF84C06C)
                                  : isUserPick
                                  ? const Color(0xFFE53935)
                                  : Colors.black12,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (isRight)
                                const Icon(Icons.check,
                                    size: 16, color: Color(0xFF000000))
                              else if (isUserPick)
                                const Icon(Icons.close,
                                    size: 16, color: Color(0xFFE53935))
                              else
                                const SizedBox(width: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text(opt.text)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.replay),
                    label: const Text('Försök igen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB1067E),
                      foregroundColor: const Color(0xFF000000),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HomeScreen(name: 'test')),
                          (route) => false,
                    ),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Hem'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF84C06C),
                      foregroundColor: const Color(0xFF000000),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}