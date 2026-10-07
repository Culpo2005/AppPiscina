class AuthResponse {
  final String userId;
  final String nome;
  final String username;
  final String email;
  final String role;
  final DateTime createdAt;
  final String token;
  final String status;

  AuthResponse({
    required this.userId,
    required this.nome,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.token,
    required this.status,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['user_id'] ?? '',
      nome: json['nome'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      token: json['token'] ?? '',
      status: json['status'] ?? '',
    );
  }

  bool get isAuthorized => status == 'authorized';
}