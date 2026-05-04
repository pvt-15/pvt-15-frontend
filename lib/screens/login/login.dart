import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Skogsjakten/repositories/auth_repository.dart';
import 'package:Skogsjakten/services/token_storage.dart';
import 'package:Skogsjakten/services/user_local_storage.dart';
import 'package:Skogsjakten/Authorization/user_model.dart';
import '../skogsjakten_exception.dart';
import '../home.dart';
import 'reset_password.dart';
import 'create_account.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final String serverClientId = '171324929378-o6f6ehfj8vtte1fasnhdd2jnjf376uto.apps.googleusercontent.com';

  final authRepository = AuthRepository(
    tokenStorage: TokenStorage(),
    userLocalStorage: UserLocalStorage(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFBEDBB2),
      body: Stack(
        children: [
          Positioned(
            top: 190,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text("Skogsjakten", style: Theme.of(context).textTheme.headlineLarge),
                Image.asset('assets/maskot_skogstroll.png', width: 90, height: 90),
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
                children: [
                  _buildTextField(nameController, "Email"),
                  _buildTextField(passwordController, "Lösenord", obscure: true),
                  const SizedBox(height: 20),
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
            child: Center(
              child: ElevatedButton(
                onPressed: _handleGoogleLogin,
                child: const Text("Logga in med Google"),
              ),
            ),
          ),
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Column(
              children: [
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAccount())),
                  child: const Text("Skapa konto"),
                ),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPassword())),
                  child: const Text("Glömt lösenord?"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(labelText: label),
        validator: (value) => (value == null || value.isEmpty) ? "Fältet får inte vara tomt" : null,
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
        await authRepository.saveLoginData(
          token: data['token'],
          user: UserModel(
            userId: data['userId'].toString(),
            username: data['name'],
            email: data['email'],
          ),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(name: nameController.text)));
      } else if (mounted) {
        _showError("Fel email eller lösenord");
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: serverClientId);
      final account = await googleSignIn.signIn();
      if (account == null) return;

      final auth = await account.authentication;
      final response = await http.post(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': auth.idToken}),
      );

      if (response.statusCode == 200 && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(name: account.displayName ?? "Användare")));
      } else if (mounted) {
        _showError("Google-inloggning misslyckad");
      }
    } catch (e) {
      _showError("Ett fel uppstod: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, textAlign: TextAlign.center)));
  }
}
