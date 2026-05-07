import 'package:flutter/material.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../home.dart';


class Quiz extends StatelessWidget {
  const Quiz({super.key});

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
      title: const Text('Quiz'),
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
              Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(name: 'test'),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.home_outlined,
                    color: Color(0xFFC0008F),
                    size: 60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: -1),
    );
  }

  Widget _answerButton(BuildContext context, String text) {
    return SizedBox(
      width: 220,
      height: 90,
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
