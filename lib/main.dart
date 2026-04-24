import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}
//test2

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
            color: Color(0xFF4C290C),
          ),
          headlineMedium: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: 24,
            color: Color(0xFF4C290C),
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

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF84C06C),
            foregroundColor: Color(0xFF4C290C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(
              fontFamily: 'WinkySans',
              fontSize: 16,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFFB1067E),
            textStyle: const TextStyle(
              fontFamily: 'WinkySans',
              fontSize: 14,
            ),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 15.0,
          ),
          contentTextStyle: const TextStyle(
            fontFamily: 'WinkySans',
            fontSize: 16,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          //färgen på fältet
          filled: true,
          fillColor: const Color(0xFFF8ED76),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),

          //stilen för typsnittet
          labelStyle: const TextStyle(
            color: Color(0xFF4C290C),
            fontFamily: 'WinkySans',
          ),

          //stilen för errormeddelanden
          errorStyle: const TextStyle(
            fontFamily: 'WinkySans',
            fontSize: 12,
          ),

          //bordern runt
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        )

      ),

      //home: const LoginScreen(),
      home: const HomeScreen(name: 'test'),
    );
  }
}