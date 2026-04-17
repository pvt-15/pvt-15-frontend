import 'package:flutter/material.dart';
import 'package:pvt/screens/reset_password.dart';
import 'home_screen.dart';
import 'create_account.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: Stack(
        children: [

          Positioned(
            top: 190,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const Text("Skogsjakten 🌿", style: TextStyle(fontSize: 30)),
              ],
            ),
          ),

          Positioned(
            top: 380,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 5.0,
                  ),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Vad heter du?",
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 15.0,
                  ),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "skriv Lösenord",
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            HomeScreen(name: nameController.text),
                      ),
                    );
                  },
                  child: const Text("Starta"),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Padding(
                  padding: const EdgeInsets.only(
                      top: 20
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
                      top: 20
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
}