import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Skogsjakten/repositories/auth_repository.dart';
import 'package:Skogsjakten/services/token_storage.dart';
import 'package:Skogsjakten/services/user_local_storage.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final authRepository = AuthRepository(
    tokenStorage: TokenStorage(),
    userLocalStorage: UserLocalStorage(),
  );

  int points = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPoints();
  }

  Future<void> loadPoints() async {
    final token = await authRepository.getToken();

    final response = await http.get(
      Uri.parse('https://group-6-15.pvt.dsv.su.se/endpointedHär???'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        points = data['points'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Min profil'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
          'Poäng: $points',
          style: const TextStyle(
            fontSize: 28,
            color: Color(0xFF4C290C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}


