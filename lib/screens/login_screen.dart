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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF84C06C),
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
                  "Skogsjakten", style: TextStyle(color: Color(0xFFB1067E), fontSize: 30)
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
                      vertical: 30.0,
                    ),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Email",
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
                      vertical: 30.0,
                    ),
                    child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Lösenord",
                        ),

                        validator: (value){
                          if(value == null || value.isEmpty) return "Ogiltigt lösenord";
                          return null;
                        }
                        ),
                  ),

                ElevatedButton(
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
                      onPressed: () async {
                        try {
                          String idToken= await signIn();

                          bool success = await loginWithGoogle(idToken);

                          if (success) {
                            Navigator.push(
                              //TODO context ska inte användas vid async
                              context,
                              MaterialPageRoute(
                                //TODO ska inte vara idToken som skickas som namn
                                builder: (_) => HomeScreen(name: idToken),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Inloggning misslyckad")),
                            );
                          }
                        } catch (e) {
                          debugPrint (e.toString());
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Något gick fel")),
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

  Future<String> signIn() async {
    final idToken = "";
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      unawaited(
          googleSignIn.initialize()
      );

      final account = await googleSignIn.authenticate();

      final auth = account.authentication;

      final idToken = auth.idToken;

      if (idToken == null) {
        throw SkogsjaktenException("Ingen token mottagen");
      }
    } catch (e) {
      throw e;
    }
      return idToken;
  }

  Future<bool> loginWithGoogle(String idToken) async {
    final response = await http.post(
      Uri.parse('https://group-6-15.pvt.dsv.su.se/auth/google'),
      body: {'idToken': idToken},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}