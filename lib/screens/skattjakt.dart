import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:google_fonts/google_fonts.dart';


class skattjakt extends StatelessWidget {
  const skattjakt({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBEDBB2),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 100,
        title: Text(
          "Skattjakt",
          style: GoogleFonts.youngSerif(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C290C),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

               Text(
                'uppdraget ska stå här',
                textAlign: TextAlign.center,
                style: GoogleFonts.winkySans(
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
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 70,
                    color: Color(0xFF4C290C),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'titel på vad man ska hitta ex. vitsippa',
                textAlign: TextAlign.center,
                style: GoogleFonts.winkySans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C290C),
                ),
              ),

              const SizedBox(height: 60),

              Container(
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
                child: Center(
                  child: Text(
                    'Ta bild',
                    style: GoogleFonts.winkySans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4C290C),
                    ),
                  ),
                ),
              ),
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
    );
  }
}