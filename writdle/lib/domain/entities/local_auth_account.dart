class LocalAuthAccount {
  const LocalAuthAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.bio = '',
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String password;
  final String bio;
  final DateTime? createdAt;

  LocalAuthAccount copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? bio,
    DateTime? createdAt,
  }) {
    return LocalAuthAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'bio': bio,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory LocalAuthAccount.fromJson(Map<String, dynamic> json) {
    return LocalAuthAccount(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }
}
