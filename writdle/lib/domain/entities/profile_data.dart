class ProfileData {
  const ProfileData({
    required this.name,
    required this.email,
    this.bio = '',
    this.joinedAt,
  });

  final String name;
  final String email;
  final String bio;
  final DateTime? joinedAt;

  ProfileData copyWith({
    String? name,
    String? email,
    String? bio,
    DateTime? joinedAt,
  }) {
    return ProfileData(
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
