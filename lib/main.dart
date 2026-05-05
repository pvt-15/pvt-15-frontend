import 'screens/home.dart';
import 'package:flutter/material.dart';
import 'screens/login/login.dart';
//import 'screens/home.dart';
import 'screens/profile/profile.dart';



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
        ),

        navigationBarTheme: NavigationBarThemeData(
          height: 70,
          backgroundColor: const Color(0xff84c06c), indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          iconTheme: WidgetStateProperty.all(const IconThemeData(color: Color(0xFF4C290C), size: 45),),
          shadowColor: Colors.black12,
        ),


      ),

      //home: const LoginScreen(),
      home: const Profile(),
    );
  }
}