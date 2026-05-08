import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/custom_navigation_bar.dart';
import '../../services/token_storage.dart';
import '../home.dart';
import '../choose_difficulty.dart';

// Datamodeller, gör klasser av det vi får (data) från backend

// svars alt.
class QuizOption {
  final int id;
  final String text;
  const QuizOption({required this.id, required this.text});

  factory QuizOption.fromJson(Map<String, dynamic> j) =>
      QuizOption(id: j['id'] as int, text: j['optionText'] as String);
}

// quiz fråga
class QuizQuestion {
  final int id;
  final String text;
  final List<QuizOption> options;
  final int? correctOptionId; // kan vara okänt, vi får svar efter vi skickar. Så null nu
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    this.correctOptionId,
  });

  // backend skcikar id, questionText och options
  factory QuizQuestion.fromJson(Map<String, dynamic> j) => QuizQuestion(
    id: j['id'] as int,
    text: j['questionText'] as String,
    options: (j['options'] as List)
        .map((o) => QuizOption.fromJson(o as Map<String, dynamic>))
        .toList(),
    correctOptionId: j['correctOptionId'] as int?,
  );
}

// Modell för ett svar från review-endpointen
class ReviewAnswer {
  final int questionId;
  final String questionText;
  final int selectedOptionId;
  final String selectedOptionText;
  final int correctOptionId;
  final String correctOptionText;
  final bool correct; // true om rätt, false om fel svar
  final String explanation; // förklaring till svaret, "En gran är oftast grön"

  const ReviewAnswer({
    required this.questionId,
    required this.questionText,
    required this.selectedOptionId,
    required this.selectedOptionText,
    required this.correctOptionId,
    required this.correctOptionText,
    required this.correct,
    required this.explanation,
  });

  factory ReviewAnswer.fromJson(Map<String, dynamic> j) => ReviewAnswer(
    questionId: j['questionId'] as int,
    questionText: j['questionText'] as String,
    selectedOptionId: j['selectedOptionId'] as int,
    selectedOptionText: j['selectedOptionText'] as String,
    correctOptionId: j['correctOptionId'] as int,
    correctOptionText: j['correctOptionText'] as String,
    correct: j['correct'] as bool,
    explanation: j['explanation'] as String,
  );
}

// resultatet från quizet
class QuizResult {
  final int correct;
  final int total;
  final int pointsAwarded;
  final List<ReviewAnswer> answers; // från review-endpointen
  const QuizResult({
    required this.correct,
    required this.total,
    required this.pointsAwarded,
    required this.answers,
  });
}

// Här börjar Quiz-klassen
class Quiz extends StatefulWidget {
  final Difficulty difficulty; // Alternativet vi valde i choose_difficulty.dart
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
  // bas URL till backend
  static const String _baseUrl = 'https://group-6-15.pvt.dsv.su.se';

  bool _loading = true;
  String? _error;
  String? _jwtToken;

  int _attemptId = -1;  // ID för detta quiz (för att kunna skicka in svaren)
  List<QuizQuestion> _questions = []; // alla frågor
  int _currentIndex = 0; // index för den aktuella frågan
  // sparar användarens svar
  final Map<int, int> _answers = {};

  bool _submitting = false; // true medan vi väntar på svar från backend
  QuizResult? _result; // null tills quiz är rättat

  // enum för olika nivåer av svårighet
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

  // hämta JWT token, hämta frågor
  Future<void> _init() async {
    final token = await TokenStorage().getToken();
    setState(() => _jwtToken = token);
    await _fetchQuestions();
  }

  // frågor från backend
  Future<void> _fetchQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    // URL med svårighetsgrad och antal frågor
    try {
      final uri = Uri.parse(
        '$_baseUrl/quiz?difficulty=$_difficultyParam&count=${widget.questionCount}',
      );
      final headers = <String, String>{};
      if (_jwtToken != null) headers['Authorization'] = 'Bearer $_jwtToken';

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

  // skicka in svaren till backend
  Future<void> _submitAnswers() async {
    setState(() => _submitting = true);
    try {
      // Skicka in svaren
      final submitUri = Uri.parse('$_baseUrl/quiz/submit');
      final submitResponse = await http.post(
        submitUri,
        headers: {
          if (_jwtToken != null) 'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        // request body med attemptID och alla svar
        body: jsonEncode({
          'attemptId': _attemptId,
          'answers': _answers.entries
              .map((e) => {'questionId': e.key, 'selectedOptionId': e.value})
              .toList(),
        }),
      );

      // fel vid inlämning
      if (submitResponse.statusCode != 200) {
        setState(() => _submitting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fel vid inlämning (${submitResponse.statusCode})')),
          );
        }
        return;
      }

      // Plocka poäng från submit svaret
      final submitBody = jsonDecode(submitResponse.body) as Map<String, dynamic>;
      final score = submitBody['score'] as int;
      final total = submitBody['totalQuestions'] as int;
      final points = submitBody['pointsAwarded'] as int;

      // Hämta rättning GET för att få rätt/fel per fråga
      final reviewUri = Uri.parse('$_baseUrl/quiz/attempts/$_attemptId/review');
      final reviewResponse = await http.get(reviewUri, headers: {
        if (_jwtToken != null) 'Authorization': 'Bearer $_jwtToken',
      });

      // Tolka svaret om det lyckas, annars tom lista
      List<ReviewAnswer> reviewAnswers = [];
      if (reviewResponse.statusCode == 200) {
        final reviewBody = jsonDecode(reviewResponse.body) as Map<String, dynamic>;
        reviewAnswers = (reviewBody['answers'] as List)
            .map((a) => ReviewAnswer.fromJson(a as Map<String, dynamic>))
            .toList();
      }

      // spara resultatet
      setState(() {
        _result = QuizResult(
          correct: score,
          total: total,
          pointsAwarded: points,
          answers: reviewAnswers,
        );
        _submitting = false;
      });
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

  // spara svar och uppdatera UI
  void _selectAnswer(int questionId, int optionId) =>
      setState(() => _answers[questionId] = optionId);

  void _goTo(int index) =>
      setState(() => _currentIndex = index.clamp(0, _questions.length - 1));

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading();
    if (_error != null) return _buildError();
    if (_result != null) return _buildResult();
    return _buildQuiz();
  }

  // laddningsskärm, visar när vi väntar på svar från backend
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

  // screen för Quiz, en fråga i taget med navigeringspilar
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
        actions: [ // visar 3/5 besvarade
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
                'Fråga ${_currentIndex + 1} av ${_questions.length}', // frågenummer
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),

              // prickar som visar progress, klickbara
              _buildProgressDots(),
              const SizedBox(height: 20),

              // gul ruta med frågan
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

              // svarsalternativ, klickbara.
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
                            ? const Color(0xFF84C06C) // valda alternativ
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

              // navigeringsrad, bakåtpil, lämna in, framåtpil
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
                        foregroundColor: Colors.white, // knapp är grå tills alla frågor är besvarade
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

  // progressprickar
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
                  ? const Color(0xFFB1067E) //nuvarande
                  : answered
                  ? const Color(0xFFB1067E) //besvarad
                  : const Color(0xFF84C06C), // ej besvarad
              borderRadius: BorderRadius.circular(6),
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
        : 'Bra jobbat! Fortsätt öva så blir du bättre och bättre!';

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
              // Resultatkort med maskot
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
                    Image.asset('assets/mascot_happy.png', width: 120, height: 120),
                    const SizedBox(height: 8),
                    Text(
                      '${result.correct}/${result.total} rätt!',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontSize: 36),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: const Color(0xFF000000)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '+${result.pointsAwarded} poäng!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFC0008F),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text('Ditt resultat',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 14),

              // loopar alla rättade svar och visar en ruta per fråga
              ...result.answers.asMap().entries.map((entry) {
                final i = entry.key; // fråga 1, fråga 2 osv.
                final a = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0x6484c06c),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: a.correct
                      // grön kant om rättad, röd om fel
                          ? const Color(0xFF84C06C)
                          : const Color(0xFFE53935),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Frågetext + ikon
                      Row(
                        children: [
                          Icon(
                            a.correct ? Icons.check_circle : Icons.cancel,
                            color: a.correct
                                ? const Color(0xFF4C290C)
                                : const Color(0xFFE53935),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Fråga ${i + 1}: ${a.questionText}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Ditt svar
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: a.correct
                              ? const Color(0xFF84C06C).withValues(alpha: 0.3)
                              : const Color(0xFFE53935).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: a.correct
                                ? const Color(0xFF84C06C)
                                : const Color(0xFFE53935),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              a.correct ? Icons.check : Icons.close,
                              size: 16,
                              color: a.correct
                                  ? const Color(0xFF000000)
                                  : const Color(0xFFE53935),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Ditt svar: ${a.selectedOptionText}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Rätt svar (visas bara om fel)
                      if (!a.correct) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF84C06C).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF84C06C)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check,
                                  size: 16, color: Color(0xFF000000)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Rätt svar: ${a.correctOptionText}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Förklaring på svaret från backend
                      if (a.explanation.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          a.explanation,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // knappar längst ner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context), // tillbaka till ChooseDifficulty
                    icon: const Icon(Icons.replay),
                    label: const Text('Försök igen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB1067E),
                      foregroundColor: Colors.white,
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
                    // TODO hemikonen
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