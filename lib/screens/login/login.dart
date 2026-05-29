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
      backgroundColor: const Color(0xFFBEDBB2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 90),

                Text(
                  'Skogsjakten',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),

                const SizedBox(height: 10),

                Image.asset(
                  'assets/maskot_skogstroll.png',
                  width: 90,
                  height: 90,
                ),

                const SizedBox(height: 60),

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ogiltig mejl';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),

                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Lösenord",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ogiltigt lösenord";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text("Logga in"),
                ),

                const SizedBox(height: 45),

                ElevatedButton(
                  onPressed: () async {
                    try {
                      final result = await signIn();

                      if (result == null) return;

                      bool success = await loginWithGoogle(result['idToken']!);

                      if (success) {
                        if (!mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeScreen(),
                          ),
                        );
                      } else {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Inloggning misslyckad",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint(e.toString());

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Något gick fel",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Logga in med Google"),
                ),

                const SizedBox(height: 35),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateAccount(),
                      ),
                    );
                  },
                  child: const Text('Skapa konto'),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ResetPassword(),
                      ),
                    );
                  },
                  child: const Text("Glömt lösenord?"),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _handleLogin() async {

    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/auth-service/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': nameController.text,
          'password': passwordController.text,
        }),
      );


      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);

        final storage = SessionStorage();
        await storage.saveUser(
          Session(
            token: data['token'],
            user: UserModel(
              id: data['userId'].toString(),
              username: data['name'],
              email: data['email'],
            ),
          ),
        );
        await storage.saveIsGoogleUser(false);


        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Fel email eller lösenord",
              textAlign: TextAlign.center,
              //style: const TextStyle(
              //color: Colors.white,
              //),
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
      Uri.parse('https://group-6-15.pvt.dsv.su.se/auth-service/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': idToken}),
    );

    debugPrint("Backend statuskod: ${response.statusCode}");
    debugPrint("Backend svar: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final storage = SessionStorage();
      await storage.saveUser(
        Session(
          token: data['token'],
          user: UserModel(
            id: data['userId'].toString(),
            username: data['name'],
            email: data['email'],
          ),
        ),
      );
      await storage.saveIsGoogleUser(true);
      return true;
    } else {
      print('Fel lösenord eller email: ${response.body}');
      return false;
    }

  }
}