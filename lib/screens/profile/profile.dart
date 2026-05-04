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
    try {
      final token = await authRepository.getToken();

      final response = await http.get(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/points'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          points = data['points'] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading points: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Min profil',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF4C290C)),
            onPressed: () async {
              await authRepository.logout();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Color(0xFF4C290C))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars, size: 80, color: Color(0xFFFFEE7A)),
                  const SizedBox(height: 10),
                  Text('Dina poäng', style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    '$points',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 60),
                  ),
                ],
              ),
      ),
    );
  }
}
