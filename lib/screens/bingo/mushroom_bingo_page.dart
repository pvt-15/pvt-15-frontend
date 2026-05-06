import 'package:flutter/material.dart';
import '../../widgets/custom_navigation_bar.dart';

class MushroomBingoPage extends StatefulWidget{
  const MushroomBingoPage({super.key});

  @override
  State<MushroomBingoPage> createState() => _MushroomBingoPage();
}

class _MushroomBingoPage extends State<MushroomBingoPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFBEDBB2),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}