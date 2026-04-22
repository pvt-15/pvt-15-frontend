import 'package:flutter/material.dart';


class bibliotek extends StatelessWidget {
  const bibliotek({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        title: const Text("Bibliotek"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Till home"),
        ),
      ),
    );
  }
}