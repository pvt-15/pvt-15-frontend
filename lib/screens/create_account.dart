import 'package:flutter/material.dart';
import 'login_screen.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController ();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF84C06C),
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
                child: Text("Skapa ett konto", style: TextStyle(fontSize: 30))
            ),

            const SizedBox(height: 70),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Vad heter du?",
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


            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
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
                decoration: const InputDecoration(
                  labelText: "Bekräfta lösenord",
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

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(),
                    ),
                  );
                }
              },
              child: const Text("Skapa konto"),
            ),
          ],
          ),
        ),
      ),
    );
  }
}