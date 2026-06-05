import 'package:flutter/material.dart';
import '../../../Authorization/user_model.dart';
import 'reset_password.dart';
import '../home.dart';
import 'create_account.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Skogsjakten/services/session_storage.dart';
import 'package:Skogsjakten/services/session.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String serverClientId = '171324929378-o6f6ehfj8vtte1fasnhdd2jnjf376uto.apps.googleusercontent.com';

  int _failedAttempts = 0;
  int _lockoutTier = 0;
  bool _isLockedOut = false;
  int _secondsRemaining = 0;
  Timer? _cooldownTimer;

  int _getCooldownTime(int tier) {
    switch (tier) {
      case 1:
        return 30;
      case 2:
        return 60;
      case 3:
        return 300;
      case 4:
        return 600;
      case 5:
        return 1800;
      default:
        return 3600;
    }
  }

  String _getFormattedRemainingTime() {
    if (_secondsRemaining >= 3600) {
      int hours = (_secondsRemaining / 3600).ceil();
      return "$hours h";
    } else if (_secondsRemaining >= 60) {
      int minutes = (_secondsRemaining / 60).ceil();
      return "$minutes min";
    } else {
      return "$_secondsRemaining s";
    }
  }

  void _startTimeout() {
    _cooldownTimer?.cancel();

    _lockoutTier++;
    int cooldown = _getCooldownTime(_lockoutTier);

    setState(() {
      _isLockedOut = true;
      _secondsRemaining = cooldown;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _isLockedOut = false;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

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
                  onPressed: _isLockedOut ? null : _handleLogin,
                  child: _isLockedOut
                      ? Text("Låst (${_getFormattedRemainingTime()})")
                      : const Text("Logga in"),
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
    if (_isLockedOut) return;

    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('https://group-6-15.pvt.dsv.su.se/auth-service/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': nameController.text,
            'password': passwordController.text,
          }),
        ).timeout(const Duration(seconds: 3));

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

          try {
            await (storage as dynamic).saveIsGoogleUser(false);
          } catch (_) {
            try {
              await (storage as dynamic).saveisgoogleUser(false);
            } catch (_) {}
          }

          setState(() {
            _failedAttempts = 0;
            _lockoutTier = 0;
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(),
            ),
          );
          return;
        }
      } catch (e) {
        debugPrint("Nätverksfel eller timeout fångat: $e");
      }

      if (mounted) {
        if (_isLockedOut) return;

        setState(() => _failedAttempts++);

        int nextLockoutTrigger = 5 + (_lockoutTier * 3);

        if (_failedAttempts >= nextLockoutTrigger) {
          _startTimeout();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "För många försök. Kontot är tillfälligt låst i ${_getFormattedRemainingTime()}.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else {
          int currentAttemptsLeft = nextLockoutTrigger - _failedAttempts;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Fel email eller lösenord. $currentAttemptsLeft försök kvar.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }
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
        throw Exception("Ingen token mottagen från Google");
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

      try {
        await (storage as dynamic).saveIsGoogleUser(true);
      } catch (_) {
        try {
          await (storage as dynamic).saveisgoogleUser(true);
        } catch (_) {}
      }

      return true;
    } else {
      print('Fel lösenord eller email: ${response.body}');
      return false;
    }
  }
}