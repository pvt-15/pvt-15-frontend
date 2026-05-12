import 'package:flutter/material.dart';

import '../../widgets/custom_navigation_bar.dart';
import '../home.dart';


class SpeciesProfile extends StatelessWidget {
  const SpeciesProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
        icon:  const Icon(Icons.arrow_back),
      ),
        title: const Text('Artprofil'),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),

              Text(
                "Vitsippa",
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  color: Color(0xff4e4e4a),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Hittad!",
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 70),

              Container(
                width: 300,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xfff8ed76),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    "info",
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
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
}