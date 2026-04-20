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
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Vad heter du?",
                  labelStyle: TextStyle(
                    color: Color(0xFF4C290C),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF8ED76),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),

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
              child: TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: "Lösenord",
                  labelStyle: TextStyle(
                    color: Color(0xFF4C290C),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF8ED76),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: "Bekräfta lösenord",
                  labelStyle: TextStyle(
                    color: Color(0xFF4C290C),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF8ED76),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB1067E),
                foregroundColor: Color(0xFF4C290C),
              ),
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