//Denna fil bestämmer filka fält en user ska inehålla +
// konverterar fram och tilbaka från json.

class UserModel {
  final String id;
  final String email;
  final String username;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
    );
  }
}

