import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/camera_service.dart';

import '../../widgets/custom_navigation_bar.dart';

class Skattjakt extends StatefulWidget {
  const Skattjakt({super.key});

  @override
  State<Skattjakt> createState() => _SkattjaktState();
}

class _SkattjaktState extends State<Skattjakt> {

  File? image;

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
        title: const Text('Skattjakt'),
        toolbarHeight: 100,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

               const Text(
                'uppdraget ska stå här',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'WinkySans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C290C),
                ),
              ),

              const SizedBox(height: 40),

              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8ED76),
                  borderRadius: BorderRadius.circular(20),
                  image: image != null ? DecorationImage(image: FileImage(image!),
                  fit: BoxFit.cover,) : null,
                ),
                child: image == null
                    ? const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 70,
                        color: Color(0xFF4C290C),
                  ),
                )
                    : null,
              ),

              const SizedBox(height: 30),

              const Text(
                'titel på vad man ska hitta ex. vitsippa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'WinkySans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C290C),
                ),
              ),

              const SizedBox(height: 60),

              InkWell(
                onTap: () async {
                  final File? file = await CameraService.takePicture();

                  if (file != null) {
                    // Tillfällig lösning för att verifiera att kameran fungerar.
                    // Just nu visas bilden kvar på samma sida.
                    // Om flödet ska följa Figma senare kan detta bytas mot navigation till nästa screen.
                    setState(() {
                      image = file;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 150,
                  height: 65,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEE7A),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Ta bild',
                      style: TextStyle(
                        fontFamily: 'WinkySans',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C290C),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}