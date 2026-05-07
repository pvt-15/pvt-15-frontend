import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        title: const Text("Min titel"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text("Innehåll här"),
      ),
    );
  }
}