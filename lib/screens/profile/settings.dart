import 'package:flutter/material.dart';
import 'package:Skogsjakten/screens/login/change_password.dart';
import 'package:Skogsjakten/screens/login/login.dart';
import 'package:Skogsjakten/services/session_storage.dart';
import 'package:http/http.dart' as http;
import '../../widgets/custom_navigation_bar.dart';
import 'package:Skogsjakten/screens/login/profile_pic.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SessionStorage _sessionStorage = SessionStorage();
  bool _isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    _loadGoogleUserStatus();
  }

  Future<void> _loadGoogleUserStatus() async {
    final isGoogle = await _sessionStorage.getIsGoogleUser();
    if (mounted) {
      setState(() {
        _isGoogleUser = isGoogle;
      });
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final session = await _sessionStorage.getUserAndToken();

      if (session == null) {
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
                (route) => false,
          );
        }
        return;
      }

      final response = await http.delete(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/auth-service/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.token}',
        },
      );

      if (response.statusCode == 204) {
        await _sessionStorage.clear();

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
                (route) => false,
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Kunde inte radera konto ${response.statusCode}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Något gick fel $e',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final session = await _sessionStorage.getUserAndToken();

      if (session != null) {
        await http.post(
          Uri.parse('https://group-6-15.pvt.dsv.su.se/auth-service/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${session.token}',
          },
        );
      }

      await _sessionStorage.clear();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      await _sessionStorage.clear();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
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
        title: const Text('Inställningar'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _settingsButton(
              context,
              text: 'Byt profilbild',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePic(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _settingsButton(
              context,
              text: 'Ändra lösenord',
              onPressed: () {
                if (_isGoogleUser) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      content: const Text(
                        'Kan inte byta lösenord på Google-konto',
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePassword(),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            _settingsButton(
              context,
              text: 'Radera konto',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Radera konto'),
                    content: const Text(
                      'Är du säker på att du vill radera konto? Detta går inte att ångra.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Avbryt'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await _deleteAccount(context);
                        },
                        child: const Text('Radera'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _settingsButton(
              context,
              text: 'Logga ut',
              onPressed: () async {
                await _logout(context);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(
        selectedIndex: -1,
      ),
    );
  }

  Widget _settingsButton(
      BuildContext context, {
        required String text,
        required VoidCallback onPressed,
      }) {
    return SizedBox(
      height: 70,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF8ED76),
          foregroundColor: const Color(0xFF4C290C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}