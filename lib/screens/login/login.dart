import 'package:flutter/material.dart';
import '../../Authorization/user_model.dart';
import 'reset_password.dart';
import '../home.dart';
import 'create_account.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import '../skogsjakten_exception.dart';
import 'package:Skogsjakten/services/session_storage.dart';
import 'package:Skogsjakten/services/session.dart';


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
      resizeToAvoidBottomInset: false, //testa om detta löser hoppandet med "nytt konto" osv
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
                Text(
                    "Skogsjakten",
                    style: Theme.of(context).textTheme.headlineLarge
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
                      ),

                      validator: (value) { // olika validations
                        if (value == null || value.isEmpty)
                          return "Ogiltig mejl";
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
                        ),

                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Ogiltigt lösenord";
                          return null;
                        }
                    ),
                  ),

                  ElevatedButton(
                    onPressed: _handleLogin,
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
                        final result = await signIn();

                        if (result == null)
                          return; // Användaren avbröt inloggningen

                        bool success = await loginWithGoogle(result['idToken']!);

                        if (success) {
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  HomeScreen(
                                      name: result['name'] ?? "Användare"),
                            ),
                          );
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text(
                                "Inloggning misslyckad",
                                textAlign: TextAlign.center)),
                          );
                        }
                      } catch (e) {
                        debugPrint(e.toString());
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(
                              "Något gick fel", textAlign: TextAlign.center)),
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

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': nameController.text,
          'password': passwordController.text,
        }),
      );


      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);

        await SessionStorage().save(
          Session(
            token: data['token'],
            user: UserModel(
              userId: data['userId'].toString(),
              username: data['name'],
              email: data['email'],
            ),
          ),
        );


        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(name: data['name']),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Fel email eller lösenord",
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
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

      debugPrint('DEBUG: Mottagen google id token: $idToken');

      return {
        'idToken': idToken,
        'name': account.displayName,
      };
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
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

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Fel lösenord eller email: ${response.body}');
      return false;
    }
  }
}