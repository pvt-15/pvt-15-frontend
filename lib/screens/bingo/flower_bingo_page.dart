import 'package:flutter/material.dart';
import '../../widgets/custom_navigation_bar.dart';

class FlowerBingoPage extends StatefulWidget{
  const FlowerBingoPage({super.key});

  @override
  State<FlowerBingoPage> createState() => _FlowerBingoPage();
}

class _FlowerBingoPage extends State<FlowerBingoPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFBEDBB2),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}