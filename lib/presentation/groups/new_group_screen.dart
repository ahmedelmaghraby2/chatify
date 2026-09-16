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

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final _titleController = TextEditingController();
  final List<String> _selectedUserIds = [];
  final List<User> _selectedUsers = [];
  bool _creating = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final loc = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.groupNameHint)),
      );
      return;
    }
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.selectMemberRequired)),
      );
      return;
    }

    setState(() => _creating = true);
    try {
      final repo = sl.get<ConversationRepository>();
      final conversationId = await repo.createGroupConversation(title: title);
      if (_selectedUserIds.isNotEmpty) {
        await repo.addMembers(conversationId, _selectedUserIds);
      }
      if (mounted) {
        context.go(AppRoutes.chatWith(conversationId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.failedToCreateGroup('$e'))),
        );
        setState(() => _creating = false);
      }
    }
  }

  Future<void> _openMemberPicker() async {
    final loc = AppLocalizations.of(context)!;
    final searchCtrl = TextEditingController();
    Timer? debounce;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final authDatasource = sl.get<SupabaseAuthDatasource>();
        late StateSetter sheetSetState;
        var searching = false;
        var searched = false;
        List<User> results = [];

        Future<void> search(String query) async {
          if (query.trim().length < 2) {
            sheetSetState(() {
              results = [];
              searched = false;
              searching = false;
            });
            return;
          }
          sheetSetState(() => searching = true);
          try {
            final rows = await authDatasource.searchUsers(query.trim());
            sheetSetState(() {
              results =
                  rows.map((r) => UserDto.fromMap(r).toEntity()).toList();
              searched = true;
            });
          } catch (_) {
            sheetSetState(() {
              results = [];
              searched = true;
            });
          } finally {
            sheetSetState(() => searching = false);
          }
        }

        return StatefulBuilder(
          builder: (context, setSheetState) {
            sheetSetState = setSheetState;
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                left: AppSpacing.base,
                right: AppSpacing.base,
                top: AppSpacing.base,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(loc.addMembers, style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: loc.findUsers,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (q) {
                      debounce?.cancel();
                      debounce = Timer(
                        const Duration(milliseconds: 400),
                        () => search(q),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 300,
                    child: searching
                        ? const Center(child: CircularProgressIndicator())
                        : results.isEmpty
                            ? Center(
                                child: Text(
                                  searched ? loc.noResults : loc.findUsers,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.builder(
                                itemCount: results.length,
                                itemBuilder: (context, index) {
                                  final user = results[index];
                                  final isSelected =
                                      _selectedUserIds.contains(user.id);
                                  return CheckboxListTile(
                                    value: isSelected,
                                    title: Text(user.displayName),
                                    subtitle: Text('@${user.username}'),
                                    onChanged: (checked) {
                                      setSheetState(() {
                                        if (checked == true) {
                                          _selectedUserIds.add(user.id);
                                          _selectedUsers.add(user);
                                        } else {
                                          _selectedUserIds.remove(user.id);
                                          _selectedUsers.removeWhere(
                                            (u) => u.id == user.id,
                                          );
                                        }
                                      });
                                      setState(() {});
                                    },
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(loc.done),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    searchCtrl.dispose();
    debounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.newGroup),
        actions: [
          TextButton(
            onPressed: _creating ? null : _createGroup,
            child: _creating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(loc.createGroup),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: AppRadius.mediumAll,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(
                    Icons.group,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: loc.groupName,
                      border: InputBorder.none,
                    ),
                    style: AppTypography.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            loc.membersCountPlural(_selectedUserIds.length),
            style: AppTypography.titleSmall.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (_selectedUsers.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final user in _selectedUsers)
                  Chip(
                    avatar: CircleAvatar(
                      radius: 12,
                      child: Text(_initial(user.displayName)),
                    ),
                    label: Text(user.displayName),
                    onDeleted: () {
                      setState(() {
                        _selectedUserIds.remove(user.id);
                        _selectedUsers.removeWhere((u) => u.id == user.id);
                      });
                    },
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(loc.addMembers),
              subtitle: Text(loc.findUsers),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openMemberPicker,
            ),
          ),
        ],
      ),
    );
  }

  String _initial(String name) {
    final t = name.trim();
    return t.isEmpty ? '?' : t[0].toUpperCase();
  }
}