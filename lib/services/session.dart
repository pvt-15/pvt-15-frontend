// visar vad en session inkluderar (gör authentication enklare)
import '../Authorization/user_model.dart';

class Session {
  final String token;
  final UserModel user;

  Session({
    required this.token,
    required this.user,
  });
}