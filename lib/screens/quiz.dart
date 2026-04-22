import 'package:flutter/material.dart';
import 'package:pvt/screens/home_screen.dart';

class quiz extends StatelessWidget {
  const quiz({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),

              const Text(
                'Fråga x',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A3A1A),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEE7A),
                  border: Border.all(
                    color: const Color(0xFFF8ED76),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'riktiga frågan här, riktig fråga här, riktigt fråga här',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4E341C),
                    height: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 28),
              _answerButton('alternativ 1'),
              const SizedBox(height: 18),
              _answerButton('alternativ 2'),
              const SizedBox(height: 18),
              _answerButton('alternativ 3'),

              const Spacer(),

              Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);(
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
    );
  }

  Widget _answerButton(String text) {
    return SizedBox(
      width: 220,
      height: 90,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFEE7A),
          foregroundColor: const Color(0xFF5A3A1A),
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
