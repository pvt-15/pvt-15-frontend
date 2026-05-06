import 'package:Skogsjakten/screens/profile/profile.dart';
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
          headlineLarge: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: 30,
            color: Color(0xFF000000),
          ),
          headlineMedium: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: 24,
            color: Color(0xFF000000),
          ),
          titleLarge: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000000),
          ),
          titleMedium: TextStyle(
            fontFamily: 'WinkySans',
            fontSize: 18,
            color: Color(0xFF000000),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'WinkySans',
            fontSize: 16,
            color: Color(0xFF000000),
          ),

        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(

            backgroundColor: Color(0xFF84C06C),
            foregroundColor: Color(0xFF000000), //Bruna: 0xFF4C290C

            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF8ED76),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),

          //stilen för typsnittet
          labelStyle: const TextStyle(
            color: Color(0xFF000000),
            fontFamily: 'WinkySans',
          ),

          //stilen för errormeddelanden
          errorStyle: const TextStyle(
            fontFamily: 'WinkySans',
            fontSize: 12,
          ),

          //bordern runt

          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
        ),


        navigationBarTheme: NavigationBarThemeData(
          height: 70,
          backgroundColor: const Color(0xff84c06c), indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          iconTheme: WidgetStateProperty.all(const IconThemeData(color: Color(0xFF000000), size: 45),),
          shadowColor: Colors.black12,
        ),


      ),

      //home: const LoginScreen(),
      //home: const Profile(),
      //home: const HomeScreen(name: 'test'),


      /*home: FutureBuilder<Session?>(
        future: SessionStorage().get(),
        builder: (context, snapshot) {
          final session = snapshot.data;

          if (session != null && session.token.isNotEmpty) {
            return HomeScreen(name: session.user.username);
          }

          return const LoginScreen();
        },
      ),*/

    );
  }
}



