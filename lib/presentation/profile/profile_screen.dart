import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../l10n/app_localizations.dart';
import '../router/app_router.dart';
import '../shared/app_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final isMe = userId == sl.get<AuthRepository>().currentUser?.id;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(isMe ? loc.myProfile : loc.profile),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: AppAvatar(
              avatarUrl: null,
              displayName: _initial(userId),
              radius: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!isMe)
            Center(
              child: Text(
                userId,
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(loc.displayName),
                  subtitle: Text(loc.name),
                  trailing: isMe ? const Icon(Icons.chevron_right) : null,
                  onTap: isMe ? () => _editName(context) : null,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(loc.bio),
                  subtitle: Text(loc.tapToAddBio),
                  trailing: isMe ? const Icon(Icons.chevron_right) : null,
                  onTap: isMe ? () => _editBio(context) : null,
                ),
                if (isMe) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.photo_camera_outlined),
                    title: Text(loc.changePhoto),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ],
            ),
          ),
          if (!isMe) ...[
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.chat_outlined),
                    title: Text(loc.sendButtonLabel),
                    onTap: () {
                      context.go(AppRoutes.home);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.block,
                      color: AppColors.errorColor,
                    ),
                    title: Text(
                      loc.blockUser,
                      style: TextStyle(color: AppColors.errorColor),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _initial(String id) {
    if (id.length <= 2) return id;
    return id.substring(0, 2).toUpperCase();
  }

  void _editName(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: AppSpacing.base,
          right: AppSpacing.base,
          top: AppSpacing.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.editDisplayName, style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.md),
            TextField(autofocus: true, decoration: InputDecoration(hintText: loc.displayName)),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: Text(loc.save),
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }

  void _editBio(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: AppSpacing.base,
          right: AppSpacing.base,
          top: AppSpacing.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.editBio, style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.md),
            TextField(
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(hintText: loc.bioHint),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: Text(loc.save),
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}
