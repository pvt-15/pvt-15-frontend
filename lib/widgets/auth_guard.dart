import 'package:flutter/material.dart';
import '../services/check_current_user.dart';
import '../screens/login/login.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  @override
  void initState() {
    super.initState();
    // Kör checken direkt när vakten skapas
    _checkToken();
  }

  Future<void> _checkToken() async {
    bool isValid = await CheckCurrentUser().checkValidToken();
    
    if (!isValid) {
      if (!mounted) return;
      // Om token är ogiltig, skicka till login och rensa historiken
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Vakten visar barnet (skärmen) direkt, men kastar ut användaren 
    // om _checkToken upptäcker att de inte ska vara där.
    return widget.child;
  }
}
