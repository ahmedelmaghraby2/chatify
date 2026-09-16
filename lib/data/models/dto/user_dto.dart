class UserDto {
  final String id;
  final String username;
  final String displayName;
  final String? avatarPath;
  final String? bio;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserDto({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarPath,
    this.bio,
    this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserDto.fromMap(Map<String, dynamic> map) {
    return UserDto(
      id: map['id'] as String? ?? '',
      username: map['username'] as String? ?? '',
      displayName: map['display_name'] as String? ?? '',
      avatarPath: map['avatar_path'] as String?,
      bio: map['bio'] as String?,
      lastSeenAt: map['last_seen_at'] != null
          ? DateTime.parse(map['last_seen_at'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'avatar_path': avatarPath,
      'bio': bio,
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
