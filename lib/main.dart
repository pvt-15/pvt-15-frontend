import 'package:flutter/material.dart';
import 'package:Skogsjakten/screens/login/login.dart';
import 'package:Skogsjakten/screens/home.dart';
import 'package:Skogsjakten/services/session_storage.dart';
import 'package:Skogsjakten/services/session.dart';

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
          headlineLarge: TextStyle(fontFamily: 'YoungSerif', fontSize: 30, color: Color(0xFF4C290C)),
          headlineMedium: TextStyle(fontFamily: 'YoungSerif', fontSize: 24, color: Color(0xFF4C290C)),
          titleLarge: TextStyle(fontFamily: 'YoungSerif', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4C290C)),
          bodyMedium: TextStyle(fontFamily: 'WinkySans', fontSize: 16, color: Color(0xFF4C290C)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF84C06C),
            foregroundColor: const Color(0xFF4C290C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF8ED76),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
      ),


      home: FutureBuilder<Session?>(
        future: SessionStorage().get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final session = snapshot.data;

          if (session != null && session.token.isNotEmpty) {
            return HomeScreen(name: session.user.username);
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
