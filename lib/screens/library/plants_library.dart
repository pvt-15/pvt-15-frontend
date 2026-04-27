import 'package:flutter/material.dart';

class PlantsLibrary extends StatefulWidget{
  const PlantsLibrary({super.key});

  @override
  State<PlantsLibrary> createState() => _PlantsLibrary();
}

class _PlantsLibrary extends State<PlantsLibrary> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFBEDBB2),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Mina växter',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}