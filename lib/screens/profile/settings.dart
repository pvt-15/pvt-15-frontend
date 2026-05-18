import 'package:flutter/material.dart';
import 'package:Skogsjakten/screens/login/reset_password.dart';
import 'package:Skogsjakten/screens/login/login.dart';
import 'package:Skogsjakten/services/session_storage.dart';
import 'package:http/http.dart' as http;
import '../../widgets/custom_navigation_bar.dart';
import 'package:Skogsjakten/screens/login/profile_pic.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAccount(
      BuildContext context,
      SessionStorage sessionStorage,
      ) async {
        try {
          final session = await sessionStorage.getUserAndToken();

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
            Uri.parse('https://group-6-15.pvt.dsv.su.se/users/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${session.token}',
            },
          );

          if (response.statusCode == 204) {
            await sessionStorage.clear();

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
                      'Kunde inte radera konto. Statuskod: ${response.statusCode}',
                    ),
                  ),
              );
            }
          }
    } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Något gick fel: $e'),
                ),
            );
          }
        }
  }

  @override
  Widget build(BuildContext context) {
    final sessionStorage = SessionStorage();

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
                Navigator.push(
                context,
                MaterialPageRoute(
                builder: (_) => const ResetPassword(),
              ),
            );
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
                        await _deleteAccount(context, sessionStorage);
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
            await sessionStorage.clear();

            if (context.mounted) {
            Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
            builder: (_) => const LoginScreen(),
            ),
            (route) => false,
            );
          }
        },
       ),
     ],
    ),
   ),
      bottomNavigationBar: const CustomNavigationBar(
        selectedIndex: 2,
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
