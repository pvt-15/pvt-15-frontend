
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/session_storage.dart';
import '../../widgets/custom_navigation_bar.dart';

class Medal {
  final String name;
  final String description;
  final String imageUrl;
  final bool unlocked;
  final String tier;

  Medal({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.unlocked,
    required this.tier,
  });

  factory Medal.fromJson(Map<String, dynamic> json) {
    return Medal(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      unlocked: json['unlocked'] ?? false,
      tier: json['tier'] ?? 'BRONZE',
    );
  }
}

class MedalsLibrary extends StatefulWidget {
  const MedalsLibrary({super.key});

  @override
  State<MedalsLibrary> createState() => _MedalsLibraryState();
}

class _MedalsLibraryState extends State<MedalsLibrary> {
  final SessionStorage _sessionStorage = SessionStorage();

  List<Medal> _medals = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMedals();
  }

  Future<void> _fetchMedals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _sessionStorage.getToken();

      if (token == null) {
        setState(() {
          _errorMessage = 'Du är inte inloggad';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/badges/me/all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        setState(() {
          _errorMessage = 'Kunde inte hämta medaljer';
          _isLoading = false;
        });
        return;
      }

      final List<dynamic> data = jsonDecode(response.body);

      setState(() {
        _medals = data.map((e) => Medal.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Nätverksfel: $e';
        _isLoading = false;
      });
    }
  }

  int _tierValue(String tier) {
    switch (tier) {
      case 'BRONZE':
        return 0;
      case 'SILVER':
        return 1;
      case 'GOLD':
        return 2;
      case 'PLATINUM':
        return 3;
      default:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlockedMedals =
    _medals.where((medal) => medal.unlocked).toList();

    final lockedMedals =
    _medals.where((medal) => !medal.unlocked).toList()
      ..sort((a, b) => _tierValue(a.tier).compareTo(_tierValue(b.tier)));

    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBEDBB2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Medaljer'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(unlockedMedals, lockedMedals),
      ),
      bottomNavigationBar: const CustomNavigationBar(
        selectedIndex: 2,
      ),
    );
  }

  Widget _buildBody(
      List<Medal> unlockedMedals,
      List<Medal> lockedMedals,
      ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMedals,
              child: const Text('Försök igen'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        Text(
          'Mina medaljer',
          textAlign: TextAlign.center,
          //style: Theme.of(context).textTheme.headlineSmall,
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 24),

        if (unlockedMedals.isEmpty)
          const Center(
            child: Text('Du har inga medaljer än'),
          ),

        ...unlockedMedals.map((medal) => _buildMedalItem(medal)),

        const SizedBox(height: 40),

        Text(
          'Möjliga medaljer',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
          //style: Theme.of(context).textTheme.headlineSmall,
        ),

        const SizedBox(height: 24),

        ...lockedMedals.map((medal) => _buildMedalItem(medal)),
      ],
    );
  }

  Widget _buildMedalItem(Medal medal) {
    final opacity = medal.unlocked ? 1.0 : 0.45;

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Opacity(
        opacity: opacity,
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 95,
                  height: 95,
                  child: ClipOval(
                    child: Image.network(
                      medal.imageUrl,
                      width: 95,
                      height: 95,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.white,
                          child: const Icon(
                            Icons.emoji_events,
                            size: 50,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return Container(
                          color: Colors.white,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                if (!medal.unlocked)
                  const Icon(
                    Icons.lock,
                    size: 46,
                    color: Colors.black87,
                  ),
              ],
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medal.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medal.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}