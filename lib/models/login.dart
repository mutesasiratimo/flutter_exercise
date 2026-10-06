class AuthUser {
  final String id;
  final String name;
  final String email;

  const AuthUser({required this.id, required this.name, required this.email});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final AuthUser? user;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return LoginResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int? ?? 0,
      user: user == null ? null : AuthUser.fromJson(user),
    );
  }
}
