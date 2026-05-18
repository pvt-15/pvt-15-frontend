//Denna fil bestämmer filka fält en user ska inehålla +
// konverterar fram och tilbaka från json.

class UserModel {
  final String id;
  final String email;
  final String username;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.profileImageUrl,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      profileImageUrl: json['profileImageUrl'],
    );
  }
}
