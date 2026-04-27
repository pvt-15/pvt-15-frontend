import 'package:flutter/material.dart';
import 'screens/login/login.dart'; // login har pajat???
// import 'screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skogsjakten',
      theme: ThemeData(
        primarySwatch: Colors.green,

        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: 30,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: 24,
          ),
          titleMedium: TextStyle(
            fontFamily: 'WinkySans',
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'WinkySans',
            fontSize: 16,
          ),
        ),

      ),
      home: const LoginScreen(), // Ändra så första screen är login
      //home: const HomeScreen(name: 'Test'),
    );
  }
}