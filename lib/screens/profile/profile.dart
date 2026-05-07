import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:Skogsjakten/services/session_storage.dart';
import 'package:Skogsjakten/screens/login/login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final sessionStorage = SessionStorage();

  int points = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPoints();
  }

  Future<void> loadPoints() async {
    try {
      final session = await sessionStorage.getUserAndToken();

      if (session == null) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
          );
        }
        return;
      }

      final response = await http.get(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/points'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          points = data['points'] ?? 0;
          isLoading = false;
        });
      }

      else if (response.statusCode == 401) {
        await sessionStorage.clear();

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
          );
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading points: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }


  Future<void> _logout() async {
    await sessionStorage.clear();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
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
            onPressed: _logout,
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
