class UserModel {
  final String userId;
  final String email;
  final String username;

  UserModel({
    required this.userId,
    required this.email,
    required this.username,
});

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'username': username,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      email: json['email'],
      username: json['username'],
    );
  }
}

