import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  // Password has to be at least 10 characters, contain a uppercase and a number
  bool isValidPassword(String password) {
    final hasMinLength = password.length >= 10;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    return hasMinLength && hasUppercase && hasNumber;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF84C06C),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Skogsjakten 🌿", style: TextStyle(color: Color(0xFFB1067E), fontSize: 30)),

              const SizedBox(height: 30),

              // email input
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Email",
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  controller: passwordController,
                  obscureText: true, // Makes the input not totaly visable, only stars are shown
                  decoration: const InputDecoration(
                    labelText: "Lösenord",
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  final password = passwordController.text;

                  // Password controll
                  if (password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Vänligen skriv ditt lösenord"),
                      ),
                    );
                    return;

                  }
                  if (!isValidPassword(password)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Lösenordet måste vara minst 10 tecken, innehålla en stor bokstav och en siffra",
                        ),
                      ),
                    );
                    return;
                  }

                  // Go too meny
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          HomeScreen(name: nameController.text), // Nu blir namnet ens email
                    ),
                  );
                },
                child: const Text("Logga in"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}