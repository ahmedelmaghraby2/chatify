import 'package:chatify/domain/entities/user.dart';

import '../dto/user_dto.dart';

extension UserDtoMapper on UserDto {
  User toEntity() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return User(
      id: id,
      username: username,
      displayName: displayName,
      avatarUrl: avatarPath,
      bio: bio,
      lastSeenAt: lastSeenAt,
      createdAt: createdAt,
      isOnline: lastSeenAt != null && lastSeenAt!.isAfter(sevenDaysAgo),
    );
  }
}
