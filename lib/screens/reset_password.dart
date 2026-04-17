import 'package:flutter/material.dart';
import 'login_screen.dart';

class ResetPassword extends StatefulWidget{
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
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
                  labelText: "Nytt lösenord",
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
                  labelText: "Bekräfta lösenord",
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