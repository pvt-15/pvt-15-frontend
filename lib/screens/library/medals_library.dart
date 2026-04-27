import 'package:flutter/material.dart';

class MedalsLibrary extends StatefulWidget{
  const MedalsLibrary({super.key});

  @override
  State<MedalsLibrary> createState() => _MedalsLibrary();
}

class _MedalsLibrary extends State<MedalsLibrary> {

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
                  'Mina medaljer',
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