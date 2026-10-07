enum UserRole { collaboratore, cliente }

class User {
  final String id;
  final String nome;
  final String username;
  final String email;
  final UserRole ruolo;
  final DateTime createdAt;

  User({
    required this.id,
    required this.nome,
    required this.username,
    required this.email,
    required this.ruolo,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    UserRole ruolo;
    if (json['ruolo'] == 'collaboratore') {
      ruolo = UserRole.collaboratore;
    } else {
      ruolo = UserRole.cliente;
    }

    return User(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      ruolo: ruolo,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'username': username,
      'email': email,
      'ruolo': ruolo == UserRole.collaboratore ? 'collaboratore' : 'cliente',
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
