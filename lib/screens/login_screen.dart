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
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); //lägg till denna för att valideringen ska fungera vid användarnamn formfield.

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
      body: Stack(
        children: [

          Positioned(
            top: 190,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const Text("Skogsjakten 🌿", style: TextStyle(color: Color(0xFFB1067E), fontSize: 30)),
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
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 30.0,
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Lösenord",
                    ),
                  ),
                ),

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