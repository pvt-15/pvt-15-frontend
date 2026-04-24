import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController ();
  final emailController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<bool> registerUser(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('https://group-6-15.pvt.dsv.su.se/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Konto skapat!: ${response.body}');
      return true;
    } else if (response.statusCode == 409) {
      print('Användaren finns redan');
      return false;
    } else {
      print('Fel: ${response.body}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFBEDBB2),
      body: Align(
        alignment: Alignment.topCenter,
        child: Form(
          key: _formKey,
          child: Column(

            children: [

              Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 80.0,
                  ),
                  child: Text("Skapa ett konto", style: TextStyle(fontSize: 30, color : Color(0xFF4C290C))
                  )
              ),

              const SizedBox(height: 70),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 15.0,
                ),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Mejladress",
                  ),
                  validator: (value){ // olika validations
                    if(value == null || value.isEmpty) return "Ogiltig mejl";
                    if(value.contains(" ")) return "Ogiltig mejl";
                    if(RegExp(r'[åäöÅÄÖ]').hasMatch(value)) return "Ogiltig mejl";
                    if(!value.contains("@")) return "Ogiltig mejl";
                    return null;
                  },
                ),
              ),

              // Name
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 15.0,
                ),
                child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Användarnamn",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vänligen skriv in ditt namn";
                      }
                      return null;
                    }
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 15.0,
                ),
                child: TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Lösenord",
                    ),

                    validator: (value){
                      if(value == null || value.isEmpty) return "Ogiltigt lösenord";
                      if(value.length <= 10) return "Lösenordet måste vara minst 10 tecken";
                      if(!value.contains(RegExp(r'[A-Z]'))) return "Lösenordet måste innehålla en stor bokstav";
                      if(!value.contains(RegExp(r'[0-9]'))) return "Lösenordet måste innehålla en siffra";
                      return null;
                    }
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 15.0,
                ),
                child: TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: "Bekräfta lösenord",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Bekräfta lösenord";
                      }

                      if (value != passwordController.text) {
                        return "Lösenorden matchar inte";
                      }

                      return null;
                    }
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {

                    bool success = await registerUser(
                      nameController.text,
                      emailController.text,
                      passwordController.text,
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Konto skapat!", textAlign: TextAlign.center)),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(name: nameController.text),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Användaren finns redan eller fel uppstod", textAlign: TextAlign.center),
                        ),
                      );
                    }
                  }
                },
                child: const Text("Skapa konto"),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text("Tillbaka till login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}