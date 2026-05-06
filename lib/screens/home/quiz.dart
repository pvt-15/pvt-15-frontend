import 'package:flutter/material.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../home.dart';
import '../choose_difficulty.dart';


class Quiz extends StatelessWidget {
  final Difficulty difficulty;


  const Quiz({
    super.key,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBEDBB2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4C290C)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                'Fråga x',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEE7A),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Här kommer den riktiga frågan att stå!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
                ),
              ),
              const SizedBox(height: 40),
              _answerButton(context, 'Alternativ 1'),
              const SizedBox(height: 18),
              _answerButton(context, 'Alternativ 2'),
              const SizedBox(height: 18),
              _answerButton(context, 'Alternativ 3'),
              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }

  Widget _answerButton(BuildContext context, String text) {
    return SizedBox(
      width: 250,
      height: 70,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implementera svarslogik
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFEE7A),
          foregroundColor: const Color(0xFF4C290C),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
