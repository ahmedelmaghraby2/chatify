import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/remote/supabase_auth_datasource.dart';
import '../../data/models/dto/user_dto.dart';
import '../../data/models/mappers/user_mapper.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../l10n/app_localizations.dart';
import '../router/app_router.dart';
import '../shared/app_avatar.dart';
import '../shared/status_views.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<User> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    try {
      final authDatasource = sl.get<SupabaseAuthDatasource>();
      final rows = await authDatasource.searchUsers(query.trim());
      if (!mounted) return;
      setState(() {
        _results = rows
            .map((row) => UserDto.fromMap(row).toEntity())
            .toList();
      });
    } catch (_) {
      if (mounted) setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openChat(User user) async {
    final loc = AppLocalizations.of(context)!;
    try {
      final convRepo = sl.get<ConversationRepository>();
      final id = await convRepo.createDirectConversation(user.id);
      if (mounted) context.push(AppRoutes.chatWith(id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.couldNotStartChat('$e'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: loc.search,
            border: InputBorder.none,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          style: AppTypography.bodyLarge,
          onChanged: _onChanged,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _controller.clear();
              setState(() => _results = []);
            },
          ),
        ],
      ),
      body: _loading
          ? const AppLoadingView()
          : _results.isEmpty
              ? AppEmptyView(
                  icon: Icons.search,
                  title: loc.search,
                  subtitle: loc.findUsers,
                )
              : ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = _results[index];
                    return ListTile(
                      leading: AppAvatar(
                        avatarUrl: user.avatarUrl,
                        displayName: user.displayName,
                        radius: 20,
                      ),
                      title: Text(user.displayName),
                      subtitle: Text('@${user.username}'),
                      onTap: () => _openChat(user),
                    );
                  },
                ),
    );
  }
}