import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:Skogsjakten/services/session_storage.dart';
import 'package:Skogsjakten/screens/login/login.dart';
import '../../widgets/custom_navigation_bar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final sessionStorage = SessionStorage();

  String username = '';
  String level = '';
  String profileImgUrl = '';
  List<dynamic> badges = [];

  int points = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadBadges() async {
    final session = await sessionStorage.getUserAndToken();
    if (session == null) return;

    final response = await http.get(
      Uri.parse('https://group-6-15.pvt.dsv.su.se/badges/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${session.token}',
      },
    );

    print("BADGES STATUS: ${response.statusCode}");
    print("BADGES BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        badges = data;
        print('Badges: $badges');
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadAll() async {
    print("loadAll START");
    await loadProfile();
    await loadBadges();

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadProfile() async {
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
        Uri.parse('https://group-6-15.pvt.dsv.su.se/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          username = data['name'] ?? '';
          points = data['totalPoints'] ?? 0;
          level = data['level'] ?? '';
          profileImgUrl = data['profileImageUrl'] ?? '';
        });
      } else if (response.statusCode == 401) {
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
      debugPrint('Error loading profile: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
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

  AssetImage getProfileImage() {
    if (profileImgUrl.isNotEmpty) {
      return AssetImage(profileImgUrl);
    }
    return const AssetImage('assets/rav.png');
  }

  NetworkImage getBadgeImage(String? tier) {
    return const NetworkImage(
      "https://cdn.pixabay.com/photo/2015/04/17/19/02/ko-727828_1280.jpg",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Text("Profil: $username"),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 50,
              color: Color(0xFF000000),
            ),
            onPressed: () {
              print('clicked');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 25),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 120),
                        width: 350,
                        height: 170,
                        child: Card(
                          color: const Color(0xFFF8ED76),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.eco,
                                color: Color(0xFF84C06C),
                                size: 35,
                              ),
                              Text("Level: $level"),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: 250,
                                child: LinearProgressIndicator(
                                  backgroundColor: const Color(0xFFDE75BF),
                                  color: const Color(0xFFC0008B),
                                  value: (points % 300) / 300,
                                  minHeight: 10,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text("Poäng: $points"),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFC0008B),
                            width: 6,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: getProfileImage(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("Medaljer", style: TextStyle(fontSize: 25)),
                IconButton(
                  onPressed: () {
                    print("Gå till medaljsida");
                  },
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF000000),
                    size: 35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: badges.isEmpty
                ? const Align(
              alignment: Alignment.topCenter,
              child: Text(
                "Inga medaljer ännu.\nSamla fler av en art så kanske du får en medalj!",
                textAlign: TextAlign.center,
              ),
            )
                : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: badges.length,
              separatorBuilder: (context, index) =>
              const SizedBox(width: 20),
              itemBuilder: (context, index) {
                final badge = badges[index];
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42.5,
                        backgroundImage: const NetworkImage(
                          "https://cdn.pixabay.com/photo/2015/04/17/19/02/ko-727828_1280.jpg",
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 80,
                        child: Text(
                          badge['name'],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
         ],
        ),
       ),
      ),

      bottomNavigationBar: const CustomNavigationBar(
        selectedIndex: 0,
      ),
    );
  }
}

class _ProfileCardContentPlaceholder extends StatelessWidget {
  const _ProfileCardContentPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}