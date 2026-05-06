import 'package:flutter/material.dart';
import '../../widgets/custom_navigation_bar.dart';

class InsectBingoPage extends StatefulWidget{
  const InsectBingoPage({super.key});

  @override
  State<InsectBingoPage> createState() => _InsectBingoPage();
}

class _InsectBingoPage extends State<InsectBingoPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFBEDBB2),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}