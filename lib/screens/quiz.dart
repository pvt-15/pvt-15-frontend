import 'package:flutter/material.dart';

class quiz extends StatelessWidget {
  const quiz({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF4C290C)),
                      ),
                      const Text(
                        "Fråga",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C290C),
                        ),
                      ),
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF9FD37E),
                        child: Icon(
                          Icons.person_outline,
                          color: Color(0xFFB1067E),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Color(0xFFF8ED76),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: const Center(
                      child: Text(
                        "Här visas frågan",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C290C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8ED76),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: const Center(
                      child: Text(
                        "Svar 1",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C290C),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8ED76),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: const Center(
                      child: Text(
                        "Svar 2",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C290C),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8ED76),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: const Center(
                      child: Text(
                        "Svar 3",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C290C),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("← Tidigare fråga"),
                      Text("Nästa fråga →"),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            Container(
              height: 70,
              color: const Color(0xFF84C06C),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.home_outlined, color: Color(0xFFB1067E)),
                  Icon(Icons.bookmark_border, color: Color(0xFFB1067E)),
                  Icon(Icons.map_outlined, color: Color(0xFFB1067E)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}