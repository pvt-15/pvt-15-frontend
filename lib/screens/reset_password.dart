import 'package:flutter/material.dart';
import 'login_screen.dart';

class ResetPassword extends StatefulWidget{
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFBEDBB2),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [

            Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 80.0,
                ),
                child: Text("Återställ lösenord (temp)", style: TextStyle(fontSize: 30))
            ),

            const SizedBox(height: 70),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Användarnamn",
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
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: "Nytt lösenord",
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(),
                  ),
                );
              },
              child: const Text("Bekräfta nytt lösenord"),
            ),
          ],
        ),
      ),
    );
  }
}