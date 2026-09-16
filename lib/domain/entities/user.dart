import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final bool isOnline;

  const User({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.lastSeenAt,
    required this.createdAt,
    this.isOnline = false,
  });

  User copyWith({
    String? id,
    String? username,
    String? displayName,
    String? Function()? avatarUrl,
    String? Function()? bio,
    DateTime? Function()? lastSeenAt,
    DateTime? createdAt,
    bool? isOnline,
  }) => User(
    id: id ?? this.id,
    username: username ?? this.username,
    displayName: displayName ?? this.displayName,
    avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
    bio: bio != null ? bio() : this.bio,
    lastSeenAt: lastSeenAt != null ? lastSeenAt() : this.lastSeenAt,
    createdAt: createdAt ?? this.createdAt,
    isOnline: isOnline ?? this.isOnline,
  );

  @override
  List<Object?> get props => [id, username, displayName, avatarUrl, bio, lastSeenAt, createdAt, isOnline];
}
