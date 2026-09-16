import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_bloc.dart';
import '../router/app_router.dart';
import 'settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl.get<AuthRepository>().currentUser;
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(user?.displayName ?? loc.profile),
                subtitle: Text(user?.username ?? ''),
                onTap: () {
                  if (user != null) {
                    context.go(AppRoutes.profileWith(user.id));
                  }
                },
                trailing: const Icon(Icons.chevron_right),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.sm,
                ),
                child: Text(loc.appearance, style: AppTypography.titleSmall),
              ),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(loc.theme),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(loc.systemTheme),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(loc.lightTheme),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(loc.darkTheme),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      context.read<SettingsCubit>().setThemeMode(mode);
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(loc.language),
                trailing: DropdownButton<String>(
                  value: settings.localeCode,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  ],
                  onChanged: (code) {
                    if (code != null) {
                      context.read<SettingsCubit>().setLocale(code);
                    }
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.sm,
                ),
                child: Text(loc.account, style: AppTypography.titleSmall),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(loc.signOut),
                onTap: () => _signOut(context, loc),
              ),
            ],
          );
        },
      ),
    );
  }

  void _signOut(BuildContext context, AppLocalizations loc) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.signOut),
        content: Text(loc.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(SignOutRequested());
            },
            child: Text(loc.signOut),
          ),
        ],
      ),
    );
  }
}