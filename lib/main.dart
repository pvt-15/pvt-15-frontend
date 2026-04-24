import 'package:flutter/material.dart';
//import 'screens/login/login.dart'; // login har pajat???
import 'screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skogsjakten',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFBEDBB2),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: 30,
            color: Color(0xFF4C290C),
          ),
          headlineMedium: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: 24,
            color: Color(0xFF4C290C),
          ),
          titleLarge: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C290C),
          ),
          titleMedium: TextStyle(
            fontFamily: 'WinkySans',
            fontSize: 18,
            color: Color(0xFF4C290C),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'WinkySans',
            fontSize: 16,
            color: Color(0xFF4C290C),
          ),
        ),
      ),
      //home: const LoginScreen(), // Ändra så första screen är login
      home: const HomeScreen(name: 'Test'),
    );
  }
}
