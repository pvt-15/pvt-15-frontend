import 'package:Skogsjakten/screens/home.dart';
import 'package:Skogsjakten/services/check_current_user.dart';
import 'package:flutter/material.dart';
import 'package:Skogsjakten/screens/login/login.dart';
import 'package:Skogsjakten/services/session_storage.dart';



void main() async {
  //gör main asynkron och ladda in Flutter-motorn
  WidgetsFlutterBinding.ensureInitialized();

  //Kolla om användaren är inloggad och har giltig token
  bool isTokenValid = await CheckCurrentUser().checkValidToken();
  String? userName;
  Widget initialScreen;

  if (isTokenValid) {
    final user = await SessionStorage().getUser();
    userName = user?.username;

    if (userName != null) {
      initialScreen = HomeScreen();
    } else {
      await SessionStorage().clear();
      initialScreen = const LoginScreen();
    }
  } else {
    initialScreen = const LoginScreen();
  }

  //Starta appen och skicka med resultatet

  runApp(
      MyApp(
        startScreen: initialScreen,
        //startScreen: LoginScreen(),
        //startScreen: HomeScreen(),
      )
  );

}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

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
            backgroundColor: const Color(0xFFF8ED76),
            foregroundColor: const Color(0xFF000000),
            minimumSize: const Size(180, 60),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(
              fontFamily: 'WinkySans',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFB1067E),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(
              fontFamily: 'WinkySans',
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
            color: Color(0xFF000000),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          //färgen på fältet
          filled: true,
          fillColor: const Color(0xFFF8ED76),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),

          //stilen för typsnittet
          labelStyle: const TextStyle(
            color: Color(0xFF000000),
            fontFamily: 'WinkySans',
          ),

          //stilen för errormeddelanden
          errorStyle: const TextStyle(fontFamily: 'WinkySans', fontSize: 12),

          //bordern runt
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
        ),

        navigationBarTheme: NavigationBarThemeData(
          height: 60,
          backgroundColor: const Color(0xff84c06c),
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,

          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: Color(0xFFD470B7),
                size: 45,
              );
            }

            return const IconThemeData(
              color: Color(0xFFB1067E),
              size: 45,
            );
          }),

          shadowColor: Colors.black12,
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFFFFF9B3),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

          titleTextStyle: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: 22,
            color: Color(0xFF000000),
          ),

          contentTextStyle: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: 18,
            color: Color(0xFF000000),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFBEDBB2),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Color(0xFF000000),
          ),
          titleTextStyle: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000000),
          ),
        ),
      ),
      home: startScreen,
    );
  }
}