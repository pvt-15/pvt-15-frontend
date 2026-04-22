import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pvt/screens/reset_password.dart';
import 'home_screen.dart';
import 'create_account.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'skogsjakten_exception.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); //lägg till denna för att valideringen ska fungera vid användarnamn formfield.
  String serverClientId = '171324929378-o6f6ehfj8vtte1fasnhdd2jnjf376uto.apps.googleusercontent.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFBEDBB2),
      body: Stack(
        children: [

          Positioned(
            top: 190,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const Text(
                  "Skogsjakten", style: TextStyle(color: Color(0xFF4C290C), fontSize: 30)
              ),
                Image.asset(
                  'assets/maskot_skogstroll.png',
                  width: 90,
                  height: 90,
                ),
              ],
            ),
          ),

          Positioned(
            top: 360,
            left: 0,
            right: 0,
            child: Form(
              key: _formKey,
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        filled: true,
                        fillColor: Color(0xFFF8ED76),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                      ),

                      validator: (value){ // olika validations
                        if(value == null || value.isEmpty) return "Ogiltig mejl";
                        return null;
                        },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 15.0,
                    ),
                    child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Lösenord",
                          filled: true,
                          fillColor: Color(0xFFF8ED76),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                        ),

                        validator: (value){
                          if(value == null || value.isEmpty) return "Ogiltigt lösenord";
                          return null;
                        }
                        ),
                  ),

                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF84C06C),
                      foregroundColor: Color(0xFF4C290C),
                    ),
                  onPressed: () async {
                    final password = passwordController.text;
                    final email = nameController.text;

                    // Password controll
                    if (_formKey.currentState!.validate()) {

                      //anropa backend
                      bool success = await loginUser(email, password);

                      if (success) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeScreen(name: email),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Fel email eller lösenord")),
                        );
                      }
                    }
                  },
                  child: const Text("Logga in"),
                ),
              ],
            ),
          ),
          ),

          Positioned(
              bottom: 190,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF84C06C),
                      foregroundColor: Color(0xFF4C290C),
                    ),
                      onPressed: () async {
                        try {
                          final result = await signIn();

                          if (result == null) return; // Användaren avbröt inloggningen

                          bool success = await loginWithGoogle(result['idToken']!);

                          if (success) {
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomeScreen(name: result['name'] ?? "Användare"),
                              ),
                            );
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Inloggning misslyckad")),
                            );
                          }
                        } catch (e) {
                          debugPrint (e.toString());
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Något gick fel")),
                          );
                        }
                        },
                    child: const Text("Logga in med Google"),

                  )
                ],
              )

          ),

          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Padding(
                  padding: const EdgeInsets.only(
                      top: 10
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFFB1067E),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateAccount(),
                        ),
                      );
                      },
                    child: const Text("Skapa konto"),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      top: 10
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFFB1067E),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResetPassword(),
                        ),
                      );
                      },
                    child: const Text("Glömt lösenord?"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://group-6-15.pvt.dsv.su.se/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      //print('Du loggas in!: ${response.body}');
      return true;
    } else {
      //print('Fel lösenord eller email: ${response.body}');
      return false;
    }
  }

  Future<Map<String, String?>?> signIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        serverClientId: serverClientId,
      );

      final GoogleSignInAccount? account = await googleSignIn.authenticate();

      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw SkogsjaktenException("Ingen token mottagen från Google");
      }

      debugPrint('Google ID token mottagen');
      return {
        'idToken': idToken,
        'name': account.displayName,
      };
    } catch (e, st) {
      debugPrint("Google Sign-In Error: $e");
      debugPrint("$st");
      rethrow;
    }
  }

  Future<bool> loginWithGoogle(String idToken) async {
    final response = await http.post(
      Uri.parse('https://group-6-15.pvt.dsv.su.se/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': idToken}),
    );

    debugPrint("Backend statuskod: ${response.statusCode}");
    debugPrint("Backend svar: ${response.body}");

    return response.statusCode == 200;
  }
}