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
  final _formKey = GlobalKey<FormState>(); //lägg till denna för att valideringen ska fungera vid användarnamn formfield.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Skogsjakten 🌿", style: TextStyle(fontSize: 30)),

                const SizedBox(height: 30),

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Användarnamn",
                  ),
                  validator: (value){ // olika validations
                    if(value == null || value.isEmpty) return "Ogiltigt användarnamn";
                    if(value.contains(" ")) return "Ogiltigt användarnamn";
                    if(RegExp(r'[åäöÅÄÖ]').hasMatch(value)) return "Ogiltigt användarnamn";
                    if(!value.contains("@")) return "Ogiltigt användarnamn";
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: "skriv Lösenord",
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) { // kollar så att validation händer vid start.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(name: nameController.text),
                        ),
                      );
                    }
                  },
                  child: const Text("Starta"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}