import 'package:flutter/material.dart';

class AnimalsLibrary extends StatefulWidget{
  const AnimalsLibrary({super.key});

  @override
  State<AnimalsLibrary> createState() => _AnimalsLibrary();
}

class _AnimalsLibrary extends State<AnimalsLibrary> {

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
                  'Mina djur',
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