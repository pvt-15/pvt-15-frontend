import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:Skogsjakten/services/session_storage.dart';
import 'package:Skogsjakten/screens/login/login.dart';
import 'package:Skogsjakten/screens/profile/settings.dart';
import 'package:Skogsjakten/screens/library/medals_library.dart';
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
        Uri.parse('https://group-6-15.pvt.dsv.su.se/auth-service/auth/me'),
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

  // Calculate progress percentage for level (same as home.dart)
  double _getProgressValue() {
    if (points == 0) return 0.0;
    return (points % 300) / 300;
  }

  NetworkImage getProfileImage() {
    if (profileImgUrl.isNotEmpty) {
      return NetworkImage(profileImgUrl);
    }

    return const NetworkImage('assets/rav.png');
  }

  void _navigateAndRefresh(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    // Refresh data after returning
    await loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBEDBB2),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Text(username),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 50,
              color: Color(0xFF000000),
            ),
            onPressed: () => _navigateAndRefresh(const SettingsScreen()),
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
              const SizedBox(height: 40),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 120),
                  width: 350,
                  height: 170,
                  child: const Card(
                    color: Color(0xFFF8ED76),
                    child: SizedBox.shrink(),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 120),
                  width: 350,
                  height: 170,
                  child: Card(
                    color: const Color(0xFFF8ED76),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 22,
                        horizontal: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$points poäng',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 8,
                            width: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDE75BF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: _getProgressValue(),
                                backgroundColor: Colors.transparent,
                                color: const Color(0xFFC0008B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nivå: $level',
                            style:
                            Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
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
                Text("Medaljer",
                    style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => _navigateAndRefresh(const MedalsLibrary()),
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
                "Inga medaljer ännu.\nSamla fler av en kategori så kanske du får en medalj!\nKategorierna är blomma, träd, växt, djur, fågel och insekt!",
                textAlign: TextAlign.center,
              ),
            )
                : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: badges.length > 3 ? 3 : badges.length,
              separatorBuilder: (context, index) =>
              const SizedBox(width: 20),
              itemBuilder: (context, index) {
                final badge = badges[index];
                final badgeImageUrl = badge['imageUrl'] ?? '';
                return GestureDetector(
                  onTap: () => _navigateAndRefresh(const MedalsLibrary()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        CircleAvatar(
                      radius: 42.5,
                      backgroundColor: Colors.transparent,
                      backgroundImage: badgeImageUrl.isNotEmpty
                          ? NetworkImage(badgeImageUrl)
                          : null,
                      child: badgeImageUrl.isEmpty
                          ? const Icon(Icons.emoji_events, size: 45)
                          : null,
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